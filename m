From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: freezer_fork BUG with ckpt-v16-dev
Date: Tue, 09 Jun 2009 16:17:36 -0500
Message-ID: <m37hzl2jkf.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
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

--=-=-=

Last commit is a5e53f3 "Define clone_with_pids syscall".

With a fork/exec-intensive workload I'm hitting the BUG_ON in
freezer_fork.  Testcase attached.

kernel BUG at kernel/cgroup_freezer.c:319!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/class/net/br0/ifindex
Modules linked in:

Pid: 3203, comm: bash Not tainted (2.6.30-rc7 #91) 
EIP: 0060:[<c026295a>] EFLAGS: 00010046 CPU: 0
EIP is at freezer_fork+0x30/0x4f
EAX: 00000002 EBX: df0a5540 ECX: c0262952 EDX: df0a5564
ESI: df0a5554 EDI: decad1c0 EBP: dea92ec0 ESP: dea92eb4
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process bash (pid: 3203, ti=dea92000 task=df1e8000 task.ti=dea92000)
Stack:
 00000005 decad1c0 dfad5f18 dea92ed0 c025f1bd decad1c0 decad418 dea92f04
 c022b3ab c024bfbe dea92fb4 bfe332b4 01200011 decad3d8 decad1c0 00000000
 00000000 00000000 dea92fb4 00000000 dea92f78 c022ba57 00000000 b7ff0708
Call Trace:
 [<c025f1bd>] ? cgroup_fork_callbacks+0x29/0x33
 [<c022b3ab>] ? copy_process+0xd2c/0x11f1
 [<c024bfbe>] ? get_lock_stats+0x11/0x38
 [<c022ba57>] ? do_fork_with_pids+0x1e7/0x3ad
 [<c02035c3>] ? ftrace_call+0x5/0x8
 [<c0245b50>] ? current_kernel_time+0x8/0x2c
 [<c026cbf9>] ? audit_syscall_entry+0x19e/0x1c0
 [<c022bc35>] ? do_fork+0x18/0x1a
 [<c02016c4>] ? sys_clone+0x29/0x30
 [<c0202ba5>] ? syscall_call+0x7/0xb
Code: 53 e8 6f 0c fa ff 8b 82 dc 0c 00 00 89 d7 8b 58 30 8b 03 83 78 18 00 74 2c 8d 73 14 89 f0 e8 ec f4 3a 00 8b 43 10 83 f8 02 75 04 <0f> 0b eb fe 48 75 0c ba 01 00 00 00 89 f8 e8 8f 1e fe ff 89 f0 
EIP: [<c026295a>] freezer_fork+0x30/0x4f SS:ESP 0068:dea92eb4
---[ end trace 9392d6dcb720d092 ]---



--=-=-=
Content-Type: application/x-sh
Content-Disposition: attachment; filename=bash-cgf-forky.sh
Content-Description: testcase

#!/bin/bash

set -eu

set_freezer_state () {
    # $1 path to cgroup dir
    # $2 state
    local cgroup=$1
    local goal_state=$2
    local state=""
    local attempts=0

    read state < "$cgroup/freezer.state"
    while [ "$state" != "$goal_state" ] ; do
	let attempts=attempts+1
	echo $goal_state > "$cgroup/freezer.state"
	read state < "$cgroup/freezer.state"
    done

    echo Freezer state set to $goal_state after $attempts attempts.
}

tmpdir="/tmp/bash-$$"
rm -rf $tmpdir
mkdir $tmpdir

cgroup_mnt="$tmpdir/cgroup"
cgroup="$cgroup_mnt/bash-test-$$"

mkdir -p "$cgroup_mnt"
mount -t cgroup none $cgroup_mnt

trap '\
set +eu ; set -x ; \
echo THAWED > "$cgroup/freezer.state" ; \
sleep 1 ; \
kill $! &>/dev/null ; \
echo Working around signal delivery failure ; \
echo THAWED > "$cgroup/freezer.state" ; \
kill -9 $! &>/dev/null ; \
wait $! ; \
rmdir "$cgroup" ; \
umount "$cgroup_mnt" ; \
echo results in $tmpdir ' EXIT

bash -c 'while : ; do /bin/true & done' &

pid=$!

echo "Creating cgroup $cgroup."
mkdir "$cgroup"

    # need to assign cpus and mems to our new cgroup
for knob in cpuset.cpus cpuset.mems ; do
    test -f "$cgroup_mnt/$knob" && \
	cat "$cgroup_mnt/$knob" > "$cgroup/$knob"
done

echo $pid > "$cgroup/tasks"

sleep 1

for i in $(seq 1 1000) ; do
    set_freezer_state $cgroup FROZEN
    usleep 10
    set_freezer_state $cgroup THAWED
    usleep 10
done

--=-=-=
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--=-=-=--
