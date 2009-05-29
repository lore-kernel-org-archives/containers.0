From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][RFC] freezer: Add CHECKPOINTING state to safeguard
	container checkpoint
Date: Fri, 29 May 2009 15:25:35 -0700
Message-ID: <20090529222535.GD9285@us.ibm.com>
References: <20090505002620.2173735E178@count0.localdomain>
	<4A201C91.8060706@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A201C91.8060706-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 29, 2009 at 01:34:09PM -0400, Oren Laadan wrote:
> Hi,
> 
> While trying Matt's patch I hit a problem reported lockdep (report
> further below).
> 
> There is a possible deadlock in the cgroup_freezer. The problem is
> a locking order, and actually exists in the code already, and only
> exposed by this patch.
> 
> From the lock-ordering comment in cgroup_freezer.c:
> 
>  * freezer_fork() (preserving fork() performance ...)
>  * task->alloc_lock (to get task's cgroup)
>  * freezer->lock
>  *  sighand->siglock (if the cgroup is freezing)
> 
> ...
> 
>  * freezer_write() (unfreeze):
>  * cgroup_mutex
>  *  freezer->lock
>  *   read_lock css_set_lock (cgroup iterator start)
>  *    task->alloc_lock (to prevent races with freeze_task())
>  *     sighand->siglock
> 
> 'task->alloc_lock' and 'freezer->lock' are taken in different order.

I suspect the new ordering is in the CHECKPOINTING patch and the comment
above is stale. I'll check to confirm it and send a patch to mainline if
the comment is stale.

> Oren.
> 
> -------------
> kernel:
> kernel: =======================================================
> kernel: [ INFO: possible circular locking dependency detected ]
> kernel: 2.6.30-rc7-orenl #366
> kernel: -------------------------------------------------------
> kernel: ckpt/2787 is trying to acquire lock:
> kernel:  (&freezer->lock){......}, at: [<c0157b35>]
> freezer_checkpointing+0x35/0x80
> kernel:
> kernel: but task is already holding lock:
> kernel:  (&p->alloc_lock){+.+...}, at: [<c0157b21>]
> freezer_checkpointing+0x21/0x80
> kernel:
> kernel: which lock already depends on the new lock.
> kernel:
> kernel:
> kernel: the existing dependency chain (in reverse order) is:
> kernel:
> kernel: -> #2 (&p->alloc_lock){+.+...}:
> kernel:        [<c0148f32>] validate_chain+0xa82/0xfc0
> kernel:        [<c0149708>] __lock_acquire+0x298/0x9a0
> kernel:        [<c0149e6e>] lock_acquire+0x5e/0x80
> kernel:        [<c0336633>] _spin_lock+0x33/0x40
> kernel:        [<c0155285>] cgroup_iter_start+0xa5/0xe0
> kernel:        [<c015781a>] update_freezer_state+0x1a/0x70
> kernel:        [<c01578e7>] freezer_write+0x77/0x160
> kernel:        [<c0156576>] cgroup_file_write+0x156/0x210
> kernel:        [<c0186c56>] vfs_write+0x96/0x130
> kernel:        [<c01871bd>] sys_write+0x3d/0x70
> kernel:        [<c0102c38>] sysenter_do_call+0x12/0x36
> kernel:        [<ffffffff>] 0xffffffff
> kernel:
> kernel: -> #1 (css_set_lock){++++..}:
> kernel:        [<c0148f32>] validate_chain+0xa82/0xfc0
> kernel:        [<c0149708>] __lock_acquire+0x298/0x9a0
> kernel:        [<c0149e6e>] lock_acquire+0x5e/0x80
> kernel:        [<c03366c3>] _write_lock+0x33/0x40
> kernel:        [<c015522b>] cgroup_iter_start+0x4b/0xe0
> kernel:        [<c015781a>] update_freezer_state+0x1a/0x70
> kernel:        [<c01578e7>] freezer_write+0x77/0x160
> kernel:        [<c0156576>] cgroup_file_write+0x156/0x210
> kernel:        [<c0186c56>] vfs_write+0x96/0x130
> kernel:        [<c01871bd>] sys_write+0x3d/0x70
> kernel:        [<c0102c38>] sysenter_do_call+0x12/0x36
> kernel:        [<ffffffff>] 0xffffffff
> kernel:
> kernel: -> #0 (&freezer->lock){......}:
> kernel:        [<c0148a21>] validate_chain+0x571/0xfc0
> kernel:        [<c0149708>] __lock_acquire+0x298/0x9a0
> kernel:        [<c0149e6e>] lock_acquire+0x5e/0x80
> kernel:        [<c0336939>] _spin_lock_irq+0x39/0x50
> kernel:        [<c0157b35>] freezer_checkpointing+0x35/0x80
> kernel:        [<c0157bbd>] cgroup_freezer_begin_checkpoint+0xd/0x30
> kernel:        [<c02185c6>] do_checkpoint+0xf6/0x6a0
> kernel:        [<c02172a6>] sys_checkpoint+0x46/0x90
> kernel:        [<c0102c38>] sysenter_do_call+0x12/0x36
> kernel:        [<ffffffff>] 0xffffffff
> kernel:
> 
> Matt Helsley wrote:
> > The CHECKPOINTING state prevents userspace from unfreezing tasks until
> > sys_checkpoint() is finished. When doing container checkpoint userspace
> > will do:
> > 
> > echo FROZEN > /cgroups/my_container/freezer.state
> > ...
> > rc = sys_checkpoint( <pid of container root> );
> > 
> > To ensure a consistent checkpoint image userspace should not be allowed
> > to thaw the cgroup (echo THAWED > /cgroups/my_container/freezer.state)
> > during checkpoint.
> > 
> 
> [...]
> 
> 
