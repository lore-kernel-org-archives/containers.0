From: Raghu D K <dk.raghu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Testing Linux-CR -- Some Documentation
Date: Fri, 13 May 2011 10:39:15 +0530
Message-ID: <BANLkTimjvdKGr_ZKpoozV5JzdbJeSE7PEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello All,

Further to some checking out the sources ( linux-cr, user-cr and
test-cr ), I was able to make some progress after reading the
"linux/Documentation/checkpoint".
I just wanted to summarize the steps I did for reaching what I see. I
have a Ubuntu 10.10 64-bit machine ( however I have installed only a
32-bit ) Ubuntu version.

Checking out Source Code:

1. $ mkdir test-linux-cr
2. $ git clone git://www.linux-cr.org/pub/git/linux-cr
3. $ git clone git://www.linux-cr.org/pub/git/user-cr
4. $ git clone git://www.linux-cr.org/pub/git/tests-cr

I am behind a firewall so I had to configure my proxy setting since
GIT server port "9418" was not open, this is well documented in the
community. However for completeness.

Setting Proxy:

$ apt-get install socat

Create a file "gitproxy.sh" and give it execute permission.

#!/bin/bash
_proxy=<your proxy ip>
_proxyport=<your port>

exec socat STDIO PROXY:$_proxy:$1:$2,proxyport=$_proxyport

Edit ".bashrc" or ".profile" file and add

$ export GIT_PROXY_COMMAND=$(HOME)/gitproxy.sh

Compiling and Building Linux Kernel:

1. Since I have a Ubuntu 10.10 running, I used the kernel
configuration file "config-2.6.35-28-generic" from "/boot" folder

$ cp /boot/config-2.6.35-28-generic ~test-linux-cr/linux-cr/.config

Ensure the following tokens are enabled in the ".config" file.
CONFIG_CHECKPOINT_SUPPORT=y
CONFIG_SYSVIPC_CHECKPOINT=y
CONFIG_CHECKPOINT=y
CONFIG_NETNS_CHECKPOINT=y
CONFIG_CHECKPOINT_DEBUG=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_FREEZER=y
CONFIG_NAMESPACES=y
CONFIG_CGROUP_NS=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_FREEZER=y

$ sudo fakeroot make-kpkg --intrd --append-to-version=-cr kernel_image
kernel_headers

On a successful build we'll have two ".deb" packages for "kernel" and
"headers" and they can be installed with

$ sudo dpkg -i linux-image-2.6.37-cr.Custom_i386.deb
$ sudo dpkg -i linux-headers-2.6.37-cr.Custom_i386.deb

On the Ubuntu 10.10 the GRUB2 is automatically updated when the
package is successfully installed. Reboot and you are in
"Checkpoint/Reset" capable kernel :-)

Building "user-cr" and "tests-cr":
$ cd ~/test-linux-cr/user-cr
$ cd scripts
$ bash ./extract-headers.sh --kernel-src=< path to Linux kernel>
$ cd ..
$ make all

$ cd ~/test-linux-cr/tests-cr
$ bash ./rewrite-cr-header.sh --- This will create a "cr.h" header
file with appropriate macro defines for "__NR_checkpoint" and
"__NR_restart"
$ make all
$ cd simple
$ ./ckpt
$ cat /tmp/cr-test.out
Invoking checkpoint syscall... PASSED.
ret = 1

$ restart < /tmp/out
Invoking checkpoint syscall... PASSED.
ret = 0

However I was not able to run the test scripts ( runall.sh ) as it
gave some errors. Also analyzing the "out" file using "ckptinfo"
results in EOF error.
Any additional help on this is appreciated.

Warm Regards,
Raghu
