From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: c/r updates
Date: Thu, 14 May 2009 11:26:45 -0500
Message-ID: <m37i0jveey.fsf@pobox.com>
References: <4A0C3E84.1040702@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A0C3E84.1040702-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Thu\, 14 May 2009 11\:53\:40 -0400")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:

> Hi,
>
> The current development kernel git:
>   git://git.ncl.cs.columbia.edu/pub/git/linux-cr    [ckpt-v15-dev]
>
> The current development user tools git:
>   git://git.ncl.cs.columbia.edu/pub/git/user-cr     [ckpt-v15-dev]
>
> (branch naming will remain consistent from now ...)
>
> Dave: I pushed a series of patches/fixes to current c/r tree, some of
> which are are relevant to the patch series you're preparing.
>
> Nathan: patches "tee...", "splice..." and "c/r: redo..." change the
> way pipes are saved/restored, and avoids the lockdep issue.

Yes, I just re-tested and it seems to avoid it.

However, when trying to checkpoint an unfrozen container (user error)
with ckpt -c I see the following trace.  Looks like ckpt_write_err is
called with tasklist_lock held.

BUG: sleeping function called from invalid context at mm/slub.c:1595
in_atomic(): 1, irqs_disabled(): 0, pid: 3603, name: ckpt
1 lock held by ckpt/3603:
 #0:  (tasklist_lock){.+.+.+}, at: [<c0397e9a>] tree_count_tasks+0x2a/0x22e
Pid: 3603, comm: ckpt Not tainted 2.6.30-rc3 #15
Call Trace:
 [<c024ca49>] ? __debug_show_held_locks+0x1e/0x20
 [<c02237a1>] __might_sleep+0x100/0x107
 [<c02aaea0>] __kmalloc+0xd1/0x1b4
 [<c0397179>] ckpt_hdr_get+0x14/0x16
 [<c0397d57>] ckpt_write_obj_type+0x25/0x73
 [<c0397de9>] ckpt_write_err+0x22/0xa9
 [<c024bb97>] ? get_lock_stats+0x16/0x38
 [<c024bbc6>] ? put_lock_stats+0xd/0x21
 [<c024bcd7>] ? lock_release_holdtime+0xfd/0x105
 [<c023bb12>] ? __task_pid_nr_ns+0x84/0xc0
 [<c0397f31>] tree_count_tasks+0xc1/0x22e
 [<c03981ee>] do_checkpoint+0x150/0x532
 [<c0397b0f>] ? ckpt_obj_hash_alloc+0x94/0x122
 [<c0397388>] ? ckpt_ctx_alloc+0xd8/0xfd
 [<c03974b3>] sys_checkpoint+0x6c/0x82
 [<c0202b65>] syscall_call+0x7/0xb
BUG: scheduling while atomic: ckpt/3603/0x10000002
2 locks held by ckpt/3603:
 #0:  (tasklist_lock){.+.+.+}, at: [<c0397e9a>] tree_count_tasks+0x2a/0x22e
 #1:  (&sb->s_type->i_mutex_key#8){+.+.+.}, at: [<c0288fb6>] generic_file_aio_write+0x59/0xc2
Modules linked in:
Pid: 3603, comm: ckpt Not tainted 2.6.30-rc3 #15
Call Trace:
 [<c02242e6>] __schedule_bug+0x63/0x6a
 [<c05f8865>] __schedule+0x8f/0xa34
 [<c03107d9>] ? journal_stop+0x24d/0x258
 [<c03107d9>] ? journal_stop+0x24d/0x258
 [<c0203583>] ? ftrace_call+0x5/0x8
 [<c0203583>] ? ftrace_call+0x5/0x8
 [<c028f2a2>] ? put_page+0xe/0xf1
 [<c02f96fd>] ? ext3_writeback_write_end+0xd5/0x102
 [<c0203583>] ? ftrace_call+0x5/0x8
 [<c05f9221>] schedule+0x17/0x30
 [<c0224b67>] __cond_resched+0x26/0x3f
 [<c05f9337>] _cond_resched+0x29/0x34
 [<c0288094>] generic_file_buffered_write+0x141/0x253
 [<c028874c>] __generic_file_aio_write_nolock+0x3d7/0x40f
 [<c05f9fa6>] ? mutex_lock_nested+0x279/0x2b9
 [<c0288fcb>] generic_file_aio_write+0x6e/0xc2
 [<c02f70b5>] ext3_file_write+0x1f/0x92
 [<c02aef31>] do_sync_write+0xb0/0xee
 [<c023e460>] ? autoremove_wake_function+0x0/0x38
 [<c0367279>] ? selinux_file_permission+0xa1/0xa5
 [<c036328e>] ? security_file_permission+0x14/0x16
 [<c02aee81>] ? do_sync_write+0x0/0xee
 [<c02af947>] vfs_write+0x8f/0x133
 [<c03975bb>] ckpt_kwrite+0x50/0x95
 [<c0397d79>] ckpt_write_obj_type+0x47/0x73
 [<c0397de9>] ckpt_write_err+0x22/0xa9
 [<c024bb97>] ? get_lock_stats+0x16/0x38
 [<c024bbc6>] ? put_lock_stats+0xd/0x21
 [<c024bcd7>] ? lock_release_holdtime+0xfd/0x105
 [<c023bb12>] ? __task_pid_nr_ns+0x84/0xc0
 [<c0397f31>] tree_count_tasks+0xc1/0x22e
 [<c03981ee>] do_checkpoint+0x150/0x532
 [<c0397b0f>] ? ckpt_obj_hash_alloc+0x94/0x122
 [<c0397388>] ? ckpt_ctx_alloc+0xd8/0xfd
 [<c03974b3>] sys_checkpoint+0x6c/0x82
 [<c0202b65>] syscall_call+0x7/0xb
