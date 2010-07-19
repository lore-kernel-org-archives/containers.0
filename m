From: John Paul Walters <jpnwalters-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: multi-threaded app fails to restart
Date: Mon, 19 Jul 2010 15:36:25 -0400
Message-ID: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja@mail.gmail.com>
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

I have a very simple multi-threaded application that I'm testing with,
but I'm unable to get a restart to complete.  I've tried both versions
21 and version 22-dev.  I'm using a debian 32 bit install inside of a
VMWare fusion virtual machine.  The problem seems to be limited to
threads as I'm able to checkpoint and restart the multitask test
application.  The steps that I'm executing are:

./pthread_test  &
[1] 3982

 ps -efL | grep pthread_test
jwalters  3982  3357  3982  0    2 19:21 pts/0    00:00:00 ./pthread_test
jwalters  3982  3357  3983  0    2 19:21 pts/0    00:00:00 ./pthread_test

for i in 3982 3983; do echo $i > /containers/1/tasks ; done

echo FROZEN /containers/1/freezer.state

cat /containers/1/freezer.state
FROZEN

 ./checkpoint 3982 > checkpoint_out
(there aren't any unusual looking messages in the dmesg output at this point)

After thawing and killing off the running instance, I attempt to restart:
./restart -d < checkpoint_out
...

<4030>c/r read input 16384
<4030>c/r read input 16384
<4030>c/r read input 12789
<4030>c/r read input 0
<4029>restart succeeded
<4029>SIGCHLD: already collected
<4029>task terminated with signal 11
<4029>c/r succeeded

The tail end of the syslog also contains:
[ 3210.327177] [4029:4029:c/r:do_restart:1451] sys_restart returns 0
[ 3210.327190] [4033:4033:c/r:wait_task_sync:919] task sync done (errno 0)
[ 3210.327192] [4033:4033:c/r:clear_task_ctx:852] task 4033 clear checkpoint_ctx
[ 3210.327194] [4033:4033:c/r:do_restart:1451] sys_restart returns -516
[ 3210.327227] pthread_test[4033]: segfault at b781f424 ip b781f424 sp
b75cc1c0 error 4
[ 3210.330254] [4031:4031:c/r:wait_task_sync:919] task sync done (errno 0)
[ 3210.330257] [4031:4031:c/r:clear_task_ctx:852] task 4031 clear checkpoint_ctx
[ 3210.330259] [4031:4031:c/r:restore_debug_free:144] 4 tasks
registered, nr_tasks was 0 nr_total 0
[ 3210.330261] [4031:4031:c/r:restore_debug_free:147] active pid was
2, ctx->errno 0
[ 3210.330263] [4031:4031:c/r:restore_debug_free:149] kflags 22 uflags
0 oflags 1
[ 3210.330265] [4031:4031:c/r:restore_debug_free:151] task[0] to run 4031
[ 3210.330267] [4031:4031:c/r:restore_debug_free:151] task[1] to run 4033
[ 3210.330269] [4031:4031:c/r:restore_debug_free:176] pid 4029 type
Coord state Success
[ 3210.330272] [4031:4031:c/r:restore_debug_free:176] pid 4031 type
Root state Success
[ 3210.330274] [4031:4031:c/r:restore_debug_free:176] pid 4033 type
Task state Success
[ 3210.330276] [4031:4031:c/r:restore_debug_free:176] pid 4032 type
Ghost state Success
[ 3210.330285] [4031:4031:c/r:pgarr_release_pages:102] total pages 0
[ 3210.330288] [4031:4031:c/r:do_restart:1451] sys_restart returns -512

Any thoughts?

best regards,
JP
