From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Lockdep splat in cpuset code acquiring alloc_lock
Date: Wed, 14 Apr 2010 13:23:47 -0700
Message-ID: <20100414202347.GA26791__1392.15136082402$1271276845$gmane$org@linux.vnet.ibm.com>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hello!

I hit the following lockdep splat on one of many runs.  Thoughts?

							Thanx, Paul

------------------------------------------------------------------------

=================================
[ INFO: inconsistent lock state ]
2.6.34-rc3-autokern1 #1
---------------------------------
inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
swapper/0 [HC0[0]:SC1[1]:HE0:SE0] takes:
 (&(&p->alloc_lock)->rlock){+.?...}, at: [<c0000000000affd4>] .cpuset_cpus_allowed_locked+0x2c/0xbc
{SOFTIRQ-ON-W} state was registered at:
  [<c000000000097ca8>] .lock_acquire+0x5c/0x88
  [<c000000000570270>] ._raw_spin_lock+0x48/0x70
  [<c000000000126cec>] .set_task_comm+0x34/0x9c
  [<c0000000000802f0>] .kthreadd+0x30/0x160
  [<c000000000026c90>] .kernel_thread+0x54/0x70
irq event stamp: 782497
hardirqs last  enabled at (782496): [<c000000000570ebc>] ._raw_spin_unlock_irq+0x38/0x80
hardirqs last disabled at (782497): [<c000000000050fb4>] .task_rq_lock+0x74/0x130
softirqs last  enabled at (782478): [<c000000000026acc>] .call_do_softirq+0x14/0x24
softirqs last disabled at (782493): [<c000000000026acc>] .call_do_softirq+0x14/0x24

other info that might help us debug this:
2 locks held by swapper/0:
 #0:  (&timer){+.-.-.}, at: [<c0000000000712a0>] .run_timer_softirq+0x138/0x298
 #1:  (rcu_read_lock){.+.+..}, at: [<c000000000054180>] .select_fallback_rq+0xe8/0x1c4

stack backtrace:
Call Trace:
[c00000000ffff740] [c000000000010168] .show_stack+0x70/0x184 (unreliable)
[c00000000ffff7f0] [c0000000000933b8] .print_usage_bug+0x1d4/0x208
[c00000000ffff8b0] [c000000000093778] .mark_lock+0x38c/0x6f4
[c00000000ffff960] [c00000000009696c] .__lock_acquire+0x6ac/0x96c
[c00000000ffffa60] [c000000000097ca8] .lock_acquire+0x5c/0x88
[c00000000ffffb00] [c000000000570270] ._raw_spin_lock+0x48/0x70
[c00000000ffffb90] [c0000000000affd4] .cpuset_cpus_allowed_locked+0x2c/0xbc
[c00000000ffffc20] [c0000000000541bc] .select_fallback_rq+0x124/0x1c4
[c00000000ffffcd0] [c00000000005ee44] .try_to_wake_up+0x1ac/0x3b4
[c00000000ffffd80] [c000000000071910] .process_timeout+0x10/0x24
[c00000000ffffdf0] [c000000000071348] .run_timer_softirq+0x1e0/0x298
[c00000000ffffed0] [c00000000006a440] .__do_softirq+0x158/0x254
[c00000000fffff90] [c000000000026acc] .call_do_softirq+0x14/0x24
[c00000000095b8f0] [c00000000000cd34] .do_softirq+0xb0/0x138
[c00000000095b990] [c00000000006a680] .irq_exit+0x88/0x100
[c00000000095ba20] [c0000000000243a8] .timer_interrupt+0x150/0x19c
[c00000000095bad0] [c000000000003704] decrementer_common+0x104/0x180
--- Exception: 901 at .raw_local_irq_restore+0x6c/0x80
    LR = .cpu_idle+0x138/0x20c
[c00000000095bdc0] [0000000000253400] 0x253400 (unreliable)
[c00000000095be40] [c0000000000129e8] .cpu_idle+0x138/0x20c
[c00000000095bed0] [c00000000057a844] .start_secondary+0x3c4/0x404
[c00000000095bf90] [c000000000008264] .start_secondary_prolog+0x10/0x14
