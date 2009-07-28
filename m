From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: run-pthread1.sh stuck on restart
Date: Mon, 27 Jul 2009 19:24:53 -0700
Message-ID: <20090728022453.GA19644@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/9DWx/yDrRhgMJTb"
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


run-pthread1.sh runs a simple pthread application that creates 3 sub
threads each of which sleep until a 'test-done' file is created.
On restart the application seems to hang in sys_futex().


	pthread1      S f7243be0     0  2847   2845 0x00000000
	 f6657780 00000082 00000001 f7243be0 f7243d74 c3192180 d3d0be1c b80a2000
	 c104196a c2f7b560 ffffffea b80a2bd8 d3d0be1c 00000000 c15ffbac c1041a4b
	 c15ffbac d3d0be00 d3d0be00 00000000 c1041b4d 00000000 d3d0be00 00000000
	Call Trace:
	 [<c104196a>] ? get_futex_key+0xfe/0x108
	 [<c1041a4b>] ? futex_wait_setup+0x63/0xd1
	 [<c1041b4d>] ? futex_wait_queue_me+0x94/0xa5
	 [<c1041c54>] ? futex_wait+0xf6/0x1e9
	 [<c1154043>] ? number+0x15b/0x232
	 [<c1042e2e>] ? do_futex+0x93/0xa01
	 [<c115551c>] ? vsnprintf+0x279/0x2be
	 [<c115532c>] ? vsnprintf+0x89/0x2be
	 [<c10300e2>] ? __dequeue_signal+0xd/0xd0
	 [<c102fd37>] ? recalc_sigpending+0xb/0x2b
	 [<c1031450>] ? dequeue_signal+0x9d/0x117
	 [<c1032206>] ? get_signal_to_deliver+0xc8/0x32b
	 [<c100203c>] ? do_notify_resume+0x6f/0x669
	 [<c134f76d>] ? schedule+0x69c/0x6f8
	 [<c102808e>] ? printk+0x14/0x18
	 [<c1037d43>] ? finish_wait+0x27/0x48
	 [<c114bfde>] ? do_restart+0xce9/0xdca
	 [<c104389d>] ? sys_futex+0x101/0x116

The other three threads are waiting in do_nanosleep(). 

Attached is the complete log from mktree. I am still debugging the
problem.

--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Description: mktree.log
Content-Disposition: attachment; filename="mktree.log"

Created container with pid 2807
root      2805  0.0  0.0   1660   424 ttyp0    S+   19:53   0:00 ../ns_exec -cpuimP pid.pthread1 -- ./pthread1 -n 4
root      2807  0.0  0.0  34520   520 ttyp0    Sl+  19:53   0:00 ./pthread1 -n 4
root      2819  0.0  0.0   3904   648 ttyp0    R+   19:53   0:00 grep ./pthread1
<1>number of tasks: 5
<1>pid 2: thread tgid 1
<1>pid 2: creator set to 1
<1>pid 3: thread tgid 1
<1>pid 3: creator set to 1
<1>pid 4: thread tgid 1
<1>pid 4: creator set to 1
<1>pid 5: thread tgid 1
<1>pid 5: creator set to 1
<1>[0] pid 1 ppid 0 sid 1 creator 0     
<1>[1] pid 2 ppid 0 sid 1 creator 1 prev 3 T   
<1>[2] pid 3 ppid 0 sid 1 creator 1 next 2 prev 4 T   
<1>[3] pid 4 ppid 0 sid 1 creator 1 next 3 prev 5 T   
<1>[4] pid 5 ppid 0 sid 1 creator 1 next 4 T   
<1>subtree (existing pidns)
<1>forking child vpid 1 flags 0x1
<1>forked child vpid 3 (asked 1)
<3>root task pid 3
<3>pid 1: pid 3 sid 0 parent 1
<3>pid 1: fork child 5 without session
<3>forking child vpid 5 flags 0x4
<3>forked child vpid 4 (asked 5)
<3>pid 1: fork child 4 without session
<4>pid 5: pid 4 sid 3 parent 1
<3>forking child vpid 4 flags 0x4
<2>c/r swap old 5 new 4
<5>pid 4: pid 5 sid 3 parent 1
<5>about to call sys_restart()
<2>c/r swap old 4 new 5
<3>forked child vpid 5 (asked 4)
<4>about to call sys_restart()
<3>pid 1: fork child 3 without session
<3>forking child vpid 3 flags 0x4
<3>forked child vpid 6 (asked 3)
<3>pid 1: fork child 2 without session
<6>pid 3: pid 6 sid 3 parent 1
<3>forking child vpid 2 flags 0x4
<2>c/r swap old 3 new 6
<6>about to call sys_restart()
<7>pid 2: pid 7 sid 3 parent 1
<7>about to call sys_restart()
<2>c/r swap old 2 new 7
<3>forked child vpid 7 (asked 2)
<2>c/r swap old 1 new 3
<2>c/r read input 16384
<2>c/r read input 16384
<2>c/r read input 16384
<2>c/r read input 16384
<2>c/r read input 16384
<3>about to call sys_restart()
<2>c/r read input 16384
<2>c/r read input 668
<2>c/r read input 0
<1>restart succeeded
root      2847  0.0  0.0  34520   136 ?        Ssl  19:53   0:00 ./pthread1 -n 4
root      2857  0.0  0.0   3904   652 ttyp0    R+   19:53   0:00 grep ./pthread1

--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--/9DWx/yDrRhgMJTb--
