From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v8 1/3] cgroups: read-write lock CLONE_THREAD forking per
	threadgroup
Date: Thu, 3 Mar 2011 09:54:21 -0800
Message-ID: <AANLkTimXg8WKgof74rYsnCfFNuq+QMOX1VU45uO3OBpU__30111.2471650869$1299175022$gmane$org@mail.gmail.com>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110208013741.GD31569@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110208013741.GD31569-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Feb 7, 2011 at 5:37 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgr=
oup
>
> From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
>
> This patch adds an rwsem that lives in a threadgroup's signal_struct that=
's
> taken for reading in the fork path, under CONFIG_CGROUPS. If another part=
 of
> the kernel later wants to use such a locking mechanism, the CONFIG_CGROUPS
> ifdefs should be changed to a higher-up flag that CGROUPS and the other s=
ystem
> would both depend on.
>
> This is a pre-patch for cgroup-procs-write.patch.
>
> Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

AFAICS, the only change from the previous version of this patch is the
addition of including linux/rwsem.h in sched.h, so I think it's fair
to assume my previous Reviewed-by: tag still holds.

(Incidentally, does anyone have any handy tools for tracking diffs
between things you've previously tagged as Acked or Reviewed-by, and
newer versions?

Paul

> ---
> =A0include/linux/init_task.h | =A0 =A09 +++++++++
> =A0include/linux/sched.h =A0 =A0 | =A0 37 +++++++++++++++++++++++++++++++=
++++++
> =A0kernel/fork.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 10 ++++++++++
> =A03 files changed, 56 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> index 6b281fa..b560381 100644
> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -15,6 +15,14 @@
> =A0extern struct files_struct init_files;
> =A0extern struct fs_struct init_fs;
>
> +#ifdef CONFIG_CGROUPS
> +#define INIT_THREADGROUP_FORK_LOCK(sig) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 .threadgroup_fork_lock =3D =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __RWSEM_INITIALIZER(sig.threadgroup_fork_lo=
ck),
> +#else
> +#define INIT_THREADGROUP_FORK_LOCK(sig)
> +#endif
> +
> =A0#define INIT_SIGNALS(sig) { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0.nr_threads =A0 =A0 =3D 1, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0.wait_chldexit =A0=3D __WAIT_QUEUE_HEAD_INITIALIZER(sig.wa=
it_chldexit),\
> @@ -31,6 +39,7 @@ extern struct fs_struct init_fs;
> =A0 =A0 =A0 =A0}, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0.cred_guard_mutex =3D =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __MUTEX_INITIALIZER(sig.cred_guard_mutex)=
, =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 INIT_THREADGROUP_FORK_LOCK(sig) =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0}
>
> =A0extern struct nsproxy init_nsproxy;
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 8580dc6..2fdbeb1 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -509,6 +509,8 @@ struct thread_group_cputimer {
> =A0 =A0 =A0 =A0spinlock_t lock;
> =A0};
>
> +#include <linux/rwsem.h>
> +
> =A0/*
> =A0* NOTE! "signal_struct" does not have it's own
> =A0* locking, because a shared signal_struct always
> @@ -623,6 +625,16 @@ struct signal_struct {
> =A0 =A0 =A0 =A0unsigned audit_tty;
> =A0 =A0 =A0 =A0struct tty_audit_buf *tty_audit_buf;
> =A0#endif
> +#ifdef CONFIG_CGROUPS
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* The threadgroup_fork_lock prevents threads from forkin=
g with
> + =A0 =A0 =A0 =A0* CLONE_THREAD while held for writing. Use this for fork=
-sensitive
> + =A0 =A0 =A0 =A0* threadgroup-wide operations. It's taken for reading in=
 fork.c in
> + =A0 =A0 =A0 =A0* copy_process().
> + =A0 =A0 =A0 =A0* Currently only needed write-side by cgroups.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct rw_semaphore threadgroup_fork_lock;
> +#endif
>
> =A0 =A0 =A0 =A0int oom_adj; =A0 =A0 =A0 =A0 =A0 =A0/* OOM kill score adju=
stment (bit shift) */
> =A0 =A0 =A0 =A0int oom_score_adj; =A0 =A0 =A0/* OOM kill score adjustment=
 */
> @@ -2270,6 +2282,31 @@ static inline void unlock_task_sighand(struct task=
_struct *tsk,
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&tsk->sighand->siglock, *flags);
> =A0}
>
> +/* See the declaration of threadgroup_fork_lock in signal_struct. */
> +#ifdef CONFIG_CGROUPS
> +static inline void threadgroup_fork_read_lock(struct task_struct *tsk)
> +{
> + =A0 =A0 =A0 down_read(&tsk->signal->threadgroup_fork_lock);
> +}
> +static inline void threadgroup_fork_read_unlock(struct task_struct *tsk)
> +{
> + =A0 =A0 =A0 up_read(&tsk->signal->threadgroup_fork_lock);
> +}
> +static inline void threadgroup_fork_write_lock(struct task_struct *tsk)
> +{
> + =A0 =A0 =A0 down_write(&tsk->signal->threadgroup_fork_lock);
> +}
> +static inline void threadgroup_fork_write_unlock(struct task_struct *tsk)
> +{
> + =A0 =A0 =A0 up_write(&tsk->signal->threadgroup_fork_lock);
> +}
> +#else
> +static inline void threadgroup_fork_read_lock(struct task_struct *tsk) {}
> +static inline void threadgroup_fork_read_unlock(struct task_struct *tsk)=
 {}
> +static inline void threadgroup_fork_write_lock(struct task_struct *tsk) =
{}
> +static inline void threadgroup_fork_write_unlock(struct task_struct *tsk=
) {}
> +#endif
> +
> =A0#ifndef __HAVE_THREAD_FUNCTIONS
>
> =A0#define task_thread_info(task) ((struct thread_info *)(task)->stack)
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 0979527..aefe61f 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -905,6 +905,10 @@ static int copy_signal(unsigned long clone_flags, st=
ruct task_struct *tsk)
>
> =A0 =A0 =A0 =A0tty_audit_fork(sig);
>
> +#ifdef CONFIG_CGROUPS
> + =A0 =A0 =A0 init_rwsem(&sig->threadgroup_fork_lock);
> +#endif
> +
> =A0 =A0 =A0 =A0sig->oom_adj =3D current->signal->oom_adj;
> =A0 =A0 =A0 =A0sig->oom_score_adj =3D current->signal->oom_score_adj;
> =A0 =A0 =A0 =A0sig->oom_score_adj_min =3D current->signal->oom_score_adj_=
min;
> @@ -1087,6 +1091,8 @@ static struct task_struct *copy_process(unsigned lo=
ng clone_flags,
> =A0 =A0 =A0 =A0monotonic_to_bootbased(&p->real_start_time);
> =A0 =A0 =A0 =A0p->io_context =3D NULL;
> =A0 =A0 =A0 =A0p->audit_context =3D NULL;
> + =A0 =A0 =A0 if (clone_flags & CLONE_THREAD)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 threadgroup_fork_read_lock(current);
> =A0 =A0 =A0 =A0cgroup_fork(p);
> =A0#ifdef CONFIG_NUMA
> =A0 =A0 =A0 =A0p->mempolicy =3D mpol_dup(p->mempolicy);
> @@ -1294,6 +1300,8 @@ static struct task_struct *copy_process(unsigned lo=
ng clone_flags,
> =A0 =A0 =A0 =A0write_unlock_irq(&tasklist_lock);
> =A0 =A0 =A0 =A0proc_fork_connector(p);
> =A0 =A0 =A0 =A0cgroup_post_fork(p);
> + =A0 =A0 =A0 if (clone_flags & CLONE_THREAD)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 threadgroup_fork_read_unlock(current);
> =A0 =A0 =A0 =A0perf_event_fork(p);
> =A0 =A0 =A0 =A0return p;
>
> @@ -1332,6 +1340,8 @@ bad_fork_cleanup_policy:
> =A0 =A0 =A0 =A0mpol_put(p->mempolicy);
> =A0bad_fork_cleanup_cgroup:
> =A0#endif
> + =A0 =A0 =A0 if (clone_flags & CLONE_THREAD)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 threadgroup_fork_read_unlock(current);
> =A0 =A0 =A0 =A0cgroup_exit(p, cgroup_callbacks_done);
> =A0 =A0 =A0 =A0delayacct_tsk_free(p);
> =A0 =A0 =A0 =A0module_put(task_thread_info(p)->exec_domain->module);
>
