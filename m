From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [C/R] sleepers don't wake up on restart
Date: Wed, 29 Apr 2009 17:45:32 -0400
Message-ID: <49F8CA7C.9060307@cs.columbia.edu>
References: <20090402002005.GA22375@us.ibm.com>
	<49D539B5.7060305@cs.columbia.edu>
	<20090402224342.GA7613@us.ibm.com>
	<49DB4B6C.3050500@cs.columbia.edu>
	<20090426005641.GA4376@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090426005641.GA4376-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | 
> | I just posted v14-rc3 which includes the c/r of restart-blocks.
> | That should improve the situation.
> | 
> | However, depending on which syscalls one uses, process may still
> | seem "stuck" after restart because the current code still does
> | not save signals nor task timers; If a signal was pending (SIGALRM
> | for example) after freezing but before checkpoint, it will be lost.
> | If a timer was set at checkpoint, it will not be restored.
> | 
> | So depending on your program, you may still experience issues
> | until I add patches to handle that.
> 
> Ok, Just an fyi, the original program seemed to work fine, but when
> I try to restart a small process tree, I get stuck on restart again.
> 
> I am running on v14-rc3 branch. Has this got anything to do with
> pending SIGCHLD ? Seems to be easier to repro with larger process
> trees (2 children per process, 4 or more levels deep).

Could be. You can verify by adding a couple of lines of code to
the checkpoint to complain if there are signals pending on a task
that is being checkpointed.

BTW, current code disregards Zombie processes.

Support for both (signals and zombies) is in the queue.

Oren.

> 
> Test programs (attached) (they need some cleanup though)
> 
> 	ptree2.c
> 	p2.loop
> 
> --------- Processes after restart:
> 
> $ ps -ef|grep ptree
> 
> root     10461 10459  0 22:07 pts/0    00:00:00 ./ptree2 -n 1 -d 2
> root     10465 10461  0 22:07 pts/0    00:00:00 ./ptree2 -n 1 -d 2
> root     10466 10465  0 22:07 pts/0    00:00:00 [ptree2] <defunct>
> root     10479  8220  0 22:09 pts/1    00:00:00 grep ptree
> 
> ---------- Process stacks
> 
> tree2        S f6270a90     0 10461  10459
>  f5e59380 00000082 08048a86 f6270a90 f6270bfc c2b32260 00000000 0000d9d3
>  f5f423b0 00000000 ffffffff 00000000 00000000 00000001 00000000 f6270a88
>  00000000 f6270a90 00000000 c02243aa 00000004 00000003 0000000c 00000006
> Call Trace:
>  [<c02243aa>] do_wait+0x1dd/0x2f6
>  [<c021cd14>] default_wake_function+0x0/0x8
>  [<c0224542>] sys_wait4+0x7f/0x92
>  [<c0224568>] sys_waitpid+0x13/0x17
>  [<c0202ce5>] sysenter_do_call+0x12/0x25
>  [<c0510000>] rtl8139_init_one+0x5ae/0x887
> ptree2        S f5f423b0     0 10465  10461
>  f6002180 00000082 c2b265c8 f5f423b0 f5f4251c c2b29260 f67b1f44 e06d0177
>  00000282 c023363c c2b265c8 00000000 00000282 0000c350 00000001 0000c350
>  00000001 f67b1f44 0000c350 c051be99 00000000 00000001 0000c350 bf9d0e04
> Call Trace:
>  [<c023363c>] hrtimer_start_range_ns+0x105/0x111
>  [<c051be99>] do_nanosleep+0x54/0x8c
>  [<c02336d7>] hrtimer_nanosleep+0x8f/0xee
>  [<c02332b8>] hrtimer_wakeup+0x0/0x18
>  [<c051be7f>] do_nanosleep+0x3a/0x8c
>  [<c0233777>] sys_nanosleep+0x41/0x51
>  [<c0202ce5>] sysenter_do_call+0x12/0x25
> ptree2        ? f6bee040     0 10466  10465
>  f638cb80 00000046 00200200 f6bee040 f6bee1ac c2b17260 f6bee038 0000dd77
>  00000000 c022f576 ffffffff 00000303 00000000 00000001 00000000 00000012
>  f5a61e84 f6bee040 f6bee038 c0224c29 f6270a90 00000001 f6bee038 f5a61f88
> Call Trace:
>  [<c022f576>] wakeme_after_rcu+0x0/0x8
>  [<c0224c29>] do_exit+0x638/0x63c
>  [<c0224c87>] do_group_exit+0x5a/0x83
>  [<c0224cbd>] sys_exit_group+0xd/0x10
>  [<c0202ce5>] sysenter_do_call+0x12/0x25
> 
