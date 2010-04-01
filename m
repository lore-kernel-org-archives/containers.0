From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 0/6][v3][lxc] Link LXC with USERCR
Date: Wed, 31 Mar 2010 18:55:03 -0700
Message-ID: <20100401015503.GA25228@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Resending patches after fixing whitespace damage and the typo in
configure.ac. Add a section to patch-0 (below) to describe the
kernel build (commit-id, config tokens etc).

---
Following set of patches, when applied to LXC 0.6.5 and built with usercr,
enable lxc_checkpoint and lxc_restart of some simple containers.

TODO:
	- Determine if lxc_checkpoint needs a --container option (see
	  TODOs in src/lxc/checkpoint.c)
	- This patchset was tested using lxc-nonetns.conf. I ran into a problem
	  creating a bridge with lxc-veth.conf and lxc-macvlan.conf.  I have
	  not debugged the problem with VNC and lxc-macvlan.conf.
	- 'global_send_sigint' is still a global variable in USERCR. We need
	  to define a better interface to expose its functionality to callers
	  of app_restart().
	- Choose better names and API for USERCR :-)
	- Additional TODOs specific to checkpoint/restart are listed in their
	  specific patches.

Changelog[v3]:
	- Renamed --image option to --statefile
	- Added --with-libcr configuration option to specify the path to
	  usercr (see usage below).
	- lxc-checkpoint now implicitly freezes before and unfreezes after
	  checkpoint.
	- Implemented the --pause options to lxc-checkpoint and lxc-restart
	  and the --kill option to lxc-checkpoint.
	- Ported to ckpt-v20-dev (required adding CHECKPOINT_NONETNS flag to
	  app_checkpoint() to work around)

Changelog[v2]: 

	(Based on feedback from Oren Laadan, Serge Hallyn, Daniel Lezcano
	and Cedric Le Goater)

	- Rather than drop --directory option to lxc_checkpoint/lxc_restart
	  add a new option (--image).
	- Integrate lxc_checkpoint to work with USERCR
	- USERCR renamed usercr.h to "app-checkpoint.h"
	- USERCR does not create/install libcheckpoint.a and usercr.h for now.
	  So link directly with app-checkpoint.h, restart.o and checkpoint.o
	- USERCR renames the interfaces to app_checkpoint() and app_restart()
	  'struct app_checkpoint_args' 'struct app_restart_args'.
	  
USAGE:

1. Build C/R-enabled Linux kernel

	$ cd /root

	$ git-clone  git://www.linux-cr.org/pub/git/linux-cr.git linux-cr

	$ cd linux-cr

	$ git-checkout ckpt-v20-dev

		I tested with commit 3522c57a9ec6f08a129a78322318abcb4467db28 
		as HEAD.

	# Ensure following tokens are set in .config

	CONFIG_CHECKPOINT_SUPPORT=y
	CONFIG_SYSVIPC_CHECKPOINT=y
	CONFIG_CHECKPOINT=y
	CONFIG_CHECKPOINT_NETNS=y
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

	# Build, install, reboot on new kernel

	# After every reboot, ensure '-o newinstance' mount option to /dev/pts
	  works (see Documentation/filesystems/devpts.txt for details). In
	  short, run following commands on each reboot:

		$ rm /dev/ptmx

		$ ln -s pts/ptmx /dev/ptmx

		$ chmod 666 /dev/pts/ptmx


1. Build USERCR

	$ cd /root

	$ git-clone git://git.ncl.cs.columbia.edu/pub/git/user-cr.git user-cr

	$ cd user-cr

	$ git-checkout ckpt-v20-dev

	  	Tested with commit e275f77e4a82d228c1df14dbeb691342e32cdac2
		as HEAD.
	
	# Apply following two patches:

	https://lists.linux-foundation.org/pipermail/containers/2010-March/024037.html
	https://lists.linux-foundation.org/pipermail/containers/2010-March/024038.html

	$ KERNELSRC=/root/linux-cr make 

		Build USERCR by pointing to corresponding kernel-source.
		This should create restart.o and checkpoint.o needed by LXC.

		I did not need to, but you may need to compile checkpoint.o
		and restart.o with -fPIC compiler option.

	$ make install

2. Build/install LXC

	$ cd /root

	$ git-clone git://lxc.git.sourceforge.net/gitroot/lxc/lxc lxc.git

	$ cd lxc.git

	# Apply attached patches to LXC (I tested with these patches applied
	to commit 9ea8066aa67b808f71f46e346bd7a215e2a355f3)

	$ autogen.sh

	$ ./configure --with-libcr=/root/user-cr

		This will fail if /root/user-cr does not container checkpoint.o,
		restart.o and app-checkpoint.h files 
	$ make

	$ make install

3. Checkpoint/restart a simple LXC container

	$ lxc-execute --name foo --rcfile lxc-no-netns.conf -- /bin/sleep 1000

	$ lxc-checkpoint --name foo --statefile /root/lxc-foo.ckpt

	$ lxc-stop --name foo

	$ lxc-restart --name foo --statefile /root/lxc-foo.ckpt

4. Checkpoint/restart other LXC containers such as:

	- a file-io session (see run-fileio1 in cr-tests[1])

	- process-tree (see run-ptree1 in cr-tests[1])

	- A vi session inside a VNC Server using "twm". i.e

		$ cat /root/.vnc/xstartup
		#!/bin/sh

		xsetroot -solid grey
		vncconfig -iconic &
		xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
		twm &

		$ lxc-execute --name foo --rcfile lxc-no-netns.conf -- \
			/usr/bin/vncserver :1

		$ vncviewer :1

			# Open a vi session

		$ lxc-checkpoint --name foo  --statefile /root/vnc.ckpt

		$ lxc-stop --name foo

		$ lxc-restart --pause --name foo --statefile /root/vnc.ckpt

			# Leaves the server frozen due to --pause

		$ lxc-unfreeze --name foo

		$ vncviewer :1

			# Should bring up the old VNC session with vi window

[1]: cr-tests:	git://git.sr71.net/~hallyn/cr_tests.git

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
