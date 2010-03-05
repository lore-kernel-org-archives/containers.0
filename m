From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: locking imbalance in restart error path
Date: Fri, 05 Mar 2010 14:29:04 -0600
Message-ID: <1267820944.8485.19.camel@localhost.localdomain>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

With ckpt-v19-dev I see the following complaint from lockdep when an
error is detected.  This is from what I believe to be a legitimately
failed restart attempt.  I guess releasing ctx->errno_sem in a task
context different from the one in which it was acquired is causing this?

(I have a couple patches from the list applied and some debugging code
of my own, but they shouldn't affect this code.)


[9145:9130:c/r:do_restore_tty:3073] sanity checks passed, link 0
[err -16][pos 3297][E @ do_restore_tty:3083][pid -1 tsk NULL]Open ptmx
=====================================
[ BUG: bad unlock balance detected! ]
-------------------------------------
simple-wait/9145 is trying to release lock (&ctx->errno_sem) at:
[<c000000000401bd0>] .ckpt_set_error+0x64/0x9c
but there are no more locks to release!

other info that might help us debug this:
no locks held by simple-wait/9145.

stack backtrace:
Call Trace:
[c000000002b12b70] [c000000000015350] .show_stack+0xc0/0x200 (unreliable)
[c000000002b12c40] [c0000000007dc6a8] .dump_stack+0x28/0x3c
[c000000002b12cc0] [c0000000000f897c] .print_unlock_inbalance_bug+0x110/0x13c
[c000000002b12de0] [c0000000000f8d84] .lock_release+0x12c/0x228
[c000000002b12e90] [c0000000000e2598] .up_write+0x3c/0x90
[c000000002b12f20] [c000000000401bd0] .ckpt_set_error+0x64/0x9c
[c000000002b12fb0] [c000000000401ca4] .do_ckpt_msg+0x9c/0xbc
[c000000002b13050] [c0000000004951d8] .restore_tty+0x1a4/0x530
[c000000002b13100] [c000000000403e84] .restore_obj+0x11c/0x1fc
[c000000002b131b0] [c000000000406fd8] .ckpt_read_obj_dispatch+0x2dc/0x330
[c000000002b13250] [c000000000407078] .ckpt_read_obj+0x4c/0x18c
[c000000002b13310] [c0000000004072b4] .ckpt_read_buf_type+0x54/0xa8
[c000000002b133b0] [c00000000040c568] .restore_file+0x44/0x174
[c000000002b13450] [c000000000403e84] .restore_obj+0x11c/0x1fc
[c000000002b13500] [c000000000406fd8] .ckpt_read_obj_dispatch+0x2dc/0x330
[c000000002b135a0] [c000000000407078] .ckpt_read_obj+0x4c/0x18c
[c000000002b13660] [c000000000407364] .ckpt_read_obj_type+0x5c/0x104
[c000000002b13700] [c00000000040c1ac] .restore_file_table+0x164/0x4dc
[c000000002b137f0] [c000000000403e84] .restore_obj+0x11c/0x1fc
[c000000002b138a0] [c000000000406fd8] .ckpt_read_obj_dispatch+0x2dc/0x330
[c000000002b13940] [c000000000407078] .ckpt_read_obj+0x4c/0x18c
[c000000002b13a00] [c000000000407364] .ckpt_read_obj_type+0x5c/0x104
[c000000002b13aa0] [c00000000040b12c] .restore_task+0x81c/0xd44
[c000000002b13b50] [c000000000408d6c] .do_restart+0x1580/0x1a4c
[c000000002b13cd0] [c000000000401110] .do_sys_restart+0xc4/0x108
[c000000002b13d80] [c0000000000155e0] .sys_restart+0x64/0x94
[c000000002b13e30] [c000000000008850] .ppc_restart+0x8/0x54
[9143:1:c/r:wait_all_tasks_finish:1137] final sync kflags 0xa (ret 0)
