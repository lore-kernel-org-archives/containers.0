From: "Rishikesh K. Rajak" <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [Testing CGROUP inside CONTAINER]: BUG#2
Date: Thu, 04 Dec 2008 13:44:39 +0530
Message-ID: <1228378480.4234.36.camel@localhost.localdomain>
Reply-To: risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
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
Cc: risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, sudhirkumarmalik-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, dhavalgiani-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi All,

Recently i have started using tool (lxc-0.4.1.tar.gz) for container
creation released by Daniel. I am not sure if inside container cgroup
support is there or not. If it is not supported till now then here is
the point where we can start to look into it.

Steps executed:

    - Executed following command on host:
        mkdir /cpu
    mount -t cgroup -ocpu cgroup /cpu
        mount
        umount /cpu
        mount

After executing above commands you can see mount will not show extra
mounted file as: cgroup on /cpu type cgroup (rw,cpu)

But If the same thing you do inside container, you will be able to see
this line (cgroup on /cpu type cgroup (rw,cpu) ) still with mount
command.
    - create a container : lxc-create -f /etc/lxc-no-netns.conf -n xray
        rishi :~ # cat /etc/lxc-no-netns.conf
            # Container with non-virtualized network
             lxc.utsname = delta
    -  Execute container
        :~ # lxc-execute -n xray /bin/bash
        delta:~ #
    -  Execute the following command inside container
     delta:~ # mkdir /cpu
     delta:~ # mount -t cgroup -ocpu cgroup /cpu

    -   delta:~ # umount /cpu
        delta:~ # mount
            ...
            cgroup on /cpu type cgroup (rw,cpu)
            cgroup on /cpu type cgroup (rw,cpu)
            cgroup on /cpu type cgroup (rw,cpu)
        delta:~ # umount /cpu
            umount: cgroup: not found
            umount: /cpu: not mounted
            umount: cgroup: not found
            umount: /cpu: not mounted
            umount: cgroup: not found
            umount: /cpu: not mounted
            umount: cgroup: not found
            umount: /cpu: not mounted
        delta:~ #

As i can understand cgroup has been mounted and unmounted inside
container so it should delete the mount entry also. And also you will be
able to see from host too .

Additional info:

rishi:~ # cat /boot/config-2.6.27.7-4-pae | grep CGROUP
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_NS=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_SCHED=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_CGROUP_MEM_RES_CTLR=y
rishi:~ # cat /boot/config-2.6.27.7-4-pae | grep _NS
CONFIG_CGROUP_NS=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NSC_FIR=m
CONFIG_BLK_DEV_NS87415=m
CONFIG_SCSI_NSP32=m
CONFIG_PATA_NS87410=m
CONFIG_PATA_NS87415=m
CONFIG_NS83820=m
CONFIG_GAMEPORT_NS558=m
CONFIG_NSC_GPIO=m
CONFIG_TCG_NSC=m
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
rishi:~ # uname -a
Linux rishi 2.6.27.7-4-pae #1 SMP 2008-11-25 00:02:37 +0100 i686 i686
i386 GNU/Linux
rishi:~ #


- Rishi
