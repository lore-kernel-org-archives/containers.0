From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 3 Nov 2011 17:43:07 +0100
Message-ID: <20111103164302.GE8198@somewhere.redhat.com>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111103162238.27609.11515.stgit-Rjmu19FXx3rR8JxBgnUBv+rzNCUFrscg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Nov 03, 2011 at 05:22:38PM +0100, Max Kellermann wrote:
> Can limit the number of fork()/clone() calls in a cgroup.  It is
> useful as a safeguard against fork bombs.
> =

> Signed-off-by: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>

Please have a look at the task counter subsystem: https://lwn.net/Articles/=
461462/

It's in the -mm tree. I'm glad to hear about another user who wants
this feature in cgroups. We need to hear about you and whether this
meets your requirements in order to get it merged upstream.

Thanks.

	Fr=E9d=E9ric.

> ---
>  Documentation/cgroups/fork.txt |   30 ++++++
>  include/linux/cgroup_fork.h    |   26 +++++
>  include/linux/cgroup_subsys.h  |    6 +
>  init/Kconfig                   |    6 +
>  kernel/Makefile                |    1 =

>  kernel/cgroup_fork.c           |  197 ++++++++++++++++++++++++++++++++++=
++++++
>  kernel/fork.c                  |    5 +
>  7 files changed, 271 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/cgroups/fork.txt
>  create mode 100644 include/linux/cgroup_fork.h
>  create mode 100644 kernel/cgroup_fork.c
> =

> diff --git a/Documentation/cgroups/fork.txt b/Documentation/cgroups/fork.=
txt
> new file mode 100644
> index 0000000..dfbf291
> --- /dev/null
> +++ b/Documentation/cgroups/fork.txt
> @@ -0,0 +1,30 @@
> +The "fork" Controller
> +---------------------
> +
> +The "fork" controller limits the number of times a new child process
> +or thread can be created.  It maintains a per-group counter which gets
> +decremented on each fork() / clone().  When the counter reaches zero,
> +no process in the cgroup is allowed to create new child
> +processes/threads, even if existing ones quit.
> +
> +This has been proven useful in a shared hosting environment.  A new
> +temporary cgroup is created for each CGI process, and the maximum fork
> +count is configured to a sensible value.  Since CGIs are expected to
> +run for only a short time with predictable resource usage, this may be
> +an appropriate tool to limit the damage that a freaked CGI can do.
> +
> +Initially, the counter is set to -1, which is a magic value for
> +"disabled" - no limits are imposed on the processes in the group.  To
> +set a new value, type (in the working directory of that control
> +group):
> +
> + echo 16 > fork.remaining
> +
> +This examples allows 16 forks in the control group.  0 means no
> +further forks are allowed.  The limit may be lowered or increased or
> +even disabled at any time by a process with write permissions to the
> +attribute.
> +
> +To check if a fork is allowed, the controller walks the cgroup
> +hierarchy up, and verifies all ancestors.  The counter of all
> +ancestors is decreased.
> diff --git a/include/linux/cgroup_fork.h b/include/linux/cgroup_fork.h
> new file mode 100644
> index 0000000..4ac66b3
> --- /dev/null
> +++ b/include/linux/cgroup_fork.h
> @@ -0,0 +1,26 @@
> +#ifndef _LINUX_CGROUP_FORK_H
> +#define _LINUX_CGROUP_FORK_H
> +
> +#ifdef CONFIG_CGROUP_FORK
> +
> +/**
> + * Checks if another fork is allowed.  Call this before creating a new
> + * child process.
> + *
> + * @return 0 on success, a negative errno value if forking should be
> + * denied
> + */
> +int
> +cgroup_fork_pre_fork(void);
> +
> +#else /* !CONFIG_CGROUP_FORK */
> +
> +static inline int
> +cgroup_fork_pre_fork(void)
> +{
> +	return 0;
> +}
> +
> +#endif /* !CONFIG_CGROUP_FORK */
> +
> +#endif /* !_LINUX_CGROUP_FORK_H */
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index ac663c1..e2dbd65 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -64,3 +64,9 @@ SUBSYS(perf)
>  #endif
>  =

>  /* */
> +
> +#ifdef CONFIG_CGROUP_FORK
> +SUBSYS(fork)
> +#endif
> +
> +/* */
> diff --git a/init/Kconfig b/init/Kconfig
> index 31ba0fd..7a2fe2e 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -603,6 +603,12 @@ config CGROUP_FREEZER
>  	  Provides a way to freeze and unfreeze all tasks in a
>  	  cgroup.
>  =

> +config CGROUP_FORK
> +	bool "fork controller for cgroups"
> +	help
> +	  Limits the number of fork() calls in a cgroup.  An application
> +	  for this is to make a cgroup safe against fork bombs.
> +
>  config CGROUP_DEVICE
>  	bool "Device controller for cgroups"
>  	help
> diff --git a/kernel/Makefile b/kernel/Makefile
> index e898c5b..2aab192 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -60,6 +60,7 @@ obj-$(CONFIG_BACKTRACE_SELF_TEST) +=3D backtracetest.o
>  obj-$(CONFIG_COMPAT) +=3D compat.o
>  obj-$(CONFIG_CGROUPS) +=3D cgroup.o
>  obj-$(CONFIG_CGROUP_FREEZER) +=3D cgroup_freezer.o
> +obj-$(CONFIG_CGROUP_FORK) +=3D cgroup_fork.o
>  obj-$(CONFIG_CPUSETS) +=3D cpuset.o
>  obj-$(CONFIG_UTS_NS) +=3D utsname.o
>  obj-$(CONFIG_USER_NS) +=3D user_namespace.o
> diff --git a/kernel/cgroup_fork.c b/kernel/cgroup_fork.c
> new file mode 100644
> index 0000000..e9aa650
> --- /dev/null
> +++ b/kernel/cgroup_fork.c
> @@ -0,0 +1,197 @@
> +/*
> + * A cgroup implementation which limits the number of fork() calls.
> + * See Documentation/cgroups/fork.txt for more information.
> + *
> + * Copyright 2011 Content Management AG
> + * Author: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
> + *
> + * This file is subject to the terms and conditions of the GNU General
> + * Public License.  See the file COPYING in the main directory of the
> + * Linux distribution for more details.
> + */
> +
> +#include <linux/cgroup.h>
> +#include <linux/cgroup_fork.h>
> +#include <linux/slab.h>
> +
> +struct cgroup_fork {
> +	struct cgroup_subsys_state css;
> +
> +	/** protect the "remaining" attribute */
> +	spinlock_t lock;
> +
> +	/**
> +	 * The remaining number of forks allowed.  -1 is the magic
> +	 * value for "unlimited".
> +	 */
> +	int remaining;
> +};
> +
> +/**
> + * Get the #cgroup_fork instance of the specified #cgroup.
> + */
> +static inline struct cgroup_fork *
> +cgroup_fork_group(struct cgroup *cgroup)
> +{
> +	return container_of(cgroup_subsys_state(cgroup, fork_subsys_id),
> +			    struct cgroup_fork, css);
> +}
> +
> +/**
> + * Get the #cgroup_fork instance of the specified task.
> + */
> +static inline struct cgroup_fork *
> +cgroup_fork_task(struct task_struct *task)
> +{
> +	return container_of(task_subsys_state(task, fork_subsys_id),
> +			    struct cgroup_fork, css);
> +}
> +
> +/**
> + * Get the #cgroup_fork instance of the current task.
> + */
> +static inline struct cgroup_fork *
> +cgroup_fork_current(void)
> +{
> +	return cgroup_fork_task(current);
> +}
> +
> +static __pure int
> +cgroup_fork_lock_get_remaining(struct cgroup_fork *t)
> +{
> +	unsigned remaining;
> +
> +	spin_lock(&t->lock);
> +	remaining =3D t->remaining;
> +	spin_unlock(&t->lock);
> +
> +	return remaining;
> +}
> +
> +static struct cgroup_subsys_state *
> +cgroup_fork_create(struct cgroup_subsys *ss, struct cgroup *cgroup)
> +{
> +	struct cgroup_fork *t =3D kzalloc(sizeof(*t), GFP_KERNEL);
> +	if (!t)
> +		return ERR_PTR(-ENOMEM);
> +
> +	spin_lock_init(&t->lock);
> +
> +	t->remaining =3D -1;
> +
> +	return &t->css;
> +}
> +
> +static void
> +cgroup_fork_destroy(struct cgroup_subsys *ss, struct cgroup *cgroup)
> +{
> +	struct cgroup_fork *t =3D cgroup_fork_group(cgroup);
> +
> +	kfree(t);
> +}
> +
> +static void
> +cgroup_fork_fork(struct cgroup_subsys *ss, struct task_struct *task)
> +{
> +	struct cgroup_fork *t;
> +
> +	rcu_read_lock();
> +
> +	/* decrement the counters in the cgroup and all of its
> +	   ancestors (except for the root cgroup) */
> +
> +	t =3D cgroup_fork_current();
> +	while (t->css.cgroup->parent !=3D NULL) {
> +		spin_lock(&t->lock);
> +		if (t->remaining > 0)
> +			--t->remaining;
> +		spin_unlock(&t->lock);
> +
> +		t =3D cgroup_fork_group(t->css.cgroup->parent);
> +	}
> +
> +	rcu_read_unlock();
> +}
> +
> +static s64
> +cgroup_fork_remaining_read(struct cgroup *cgroup, struct cftype *cft)
> +{
> +	struct cgroup_fork *t =3D cgroup_fork_group(cgroup);
> +
> +	return cgroup_fork_lock_get_remaining(t);
> +}
> +
> +static int
> +cgroup_fork_remaining_write(struct cgroup *cgroup, struct cftype *cft,
> +			    s64 value)
> +{
> +	struct cgroup_fork *t =3D cgroup_fork_group(cgroup);
> +
> +	if (value < -1 || value > (1L << 30))
> +		return -EINVAL;
> +
> +	spin_lock(&t->lock);
> +	t->remaining =3D (int)value;
> +	spin_unlock(&t->lock);
> +
> +	return 0;
> +}
> +
> +static const struct cftype cgroup_fork_files[] =3D  {
> +	{
> +		.name =3D "remaining",
> +		.read_s64 =3D cgroup_fork_remaining_read,
> +		.write_s64 =3D cgroup_fork_remaining_write,
> +	},
> +};
> +
> +static int
> +cgroup_fork_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
> +{
> +	if (cgroup->parent =3D=3D NULL)
> +		/* cannot limit the root cgroup */
> +		return 0;
> +
> +	return cgroup_add_files(cgroup, ss, cgroup_fork_files,
> +				ARRAY_SIZE(cgroup_fork_files));
> +}
> +
> +struct cgroup_subsys fork_subsys =3D {
> +	.name =3D "fork",
> +	.create =3D cgroup_fork_create,
> +	.destroy =3D cgroup_fork_destroy,
> +	.fork =3D cgroup_fork_fork,
> +	.populate =3D cgroup_fork_populate,
> +	.subsys_id =3D fork_subsys_id,
> +};
> +
> +int
> +cgroup_fork_pre_fork(void)
> +{
> +	struct cgroup_fork *t;
> +	int err =3D 0;
> +
> +	if (unlikely(current =3D=3D &init_task))
> +		/* ignore the kernel's fork request while booting; the
> +		   cgroup subsystem doesn't get initialized by
> +		   INIT_TASK(), so we need this check */
> +		return err;
> +
> +	BUG_ON(current->cgroups =3D=3D NULL);
> +
> +	rcu_read_lock();
> +
> +	t =3D cgroup_fork_current();
> +	while (t->css.cgroup->parent !=3D NULL && err =3D=3D 0) {
> +		if (unlikely(cgroup_fork_lock_get_remaining(t) =3D=3D 0)) {
> +			err =3D -EPERM;
> +			break;
> +		}
> +
> +		t =3D cgroup_fork_group(t->css.cgroup->parent);
> +	}
> +
> +	rcu_read_unlock();
> +
> +	return err;
> +}
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 70d7619..c8cba7d 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -32,6 +32,7 @@
>  #include <linux/capability.h>
>  #include <linux/cpu.h>
>  #include <linux/cgroup.h>
> +#include <linux/cgroup_fork.h>
>  #include <linux/security.h>
>  #include <linux/hugetlb.h>
>  #include <linux/swap.h>
> @@ -1084,6 +1085,10 @@ static struct task_struct *copy_process(unsigned l=
ong clone_flags,
>  				current->signal->flags & SIGNAL_UNKILLABLE)
>  		return ERR_PTR(-EINVAL);
>  =

> +	retval =3D cgroup_fork_pre_fork();
> +	if (retval)
> +		goto fork_out;
> +
>  	retval =3D security_task_create(clone_flags);
>  	if (retval)
>  		goto fork_out;
> =

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
