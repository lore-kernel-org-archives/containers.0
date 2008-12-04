From: "Rishikesh K. Rajak" <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [Testing CGROUP inside CONTAINER]: BUG#1
Date: Thu, 04 Dec 2008 13:44:38 +0530
Message-ID: <1228378478.4234.35.camel@localhost.localdomain>
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
Cc: risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, sudhirkumarmalik-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, dhavalgiani-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi All,

Recently i have started using tool (lxc-0.4.1.tar.gz) for container
creation released by Daniel. I am not sure if inside container, cgroup
support is there or not. If it is not supported till now then here is
the point where we can start to look into it.

Steps executed:

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

    -   delta:~ # cat /cpu/tasks

    - You can see many zero's has attached with task file inside
container. 

As i can understand cgroup has been mounted inside container so it
should attach the task which is running inside container. Please correct
me if i am wrong here.

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
