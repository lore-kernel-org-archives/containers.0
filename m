From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH] namespaces: Avoid task_lock when setting tsk->nsproxy
Date: Fri, 26 Feb 2016 11:31:24 -0600
Message-ID: <87wpprgyz7.fsf@x220.int.ebiederm.org>
References: <1456481448-3925-1-git-send-email-dbueso@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1456481448-3925-1-git-send-email-dbueso-l3A5Bk7waGM@public.gmane.org> (Davidlohr
	Bueso's message of "Fri, 26 Feb 2016 02:10:48 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Davidlohr Bueso <dbueso-l3A5Bk7waGM@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, dave-h16yJtLeMjHk1uMJSBkQmQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Including a few more relevant people in the Cc list.

Davidlohr Bueso <dbueso-l3A5Bk7waGM@public.gmane.org> writes:

> From: Davidlohr Bueso <dave-h16yJtLeMjHk1uMJSBkQmQ@public.gmane.org>
>
> The access rules around nsproxy are quite clear about who reads and
> writes to a task's nsproxy. In fact, up until 728dba3a39c (namespaces:
> Use task_lock and not rcu to protect nsproxy), these rw paths were
> differentiated with rcu, making the sync part too expensive for the most
> popular job, which is setns() related. As such, readers are quite rare,
> yet require some sort of serialization with writers, otherwise only the
> current task can update the nsproxy pointer, and therefore no concurrency.

Unless you are doing something completely wrong the number of instances
of setns and the readers that form the file descriptors that are passed
to setns should be about equal.

> Instead of recycling the task_lock and unnecessarily serializing with
> other choirs such as allocation and mempolicy, use pointer tagging to
> track any current readers before we update the nsproxy, if present, fall
> back to this path, otherwise just [Rmw] and be done. This extra work
> comes at a slightly higher cost when there are readers, but the writer
> common fastpath should at least optimize in saving us from dealing with
> the alloc_lock (albeit probably uncontended). And this seems to be very
> much a real-world concern to be fast, ie docker workloads, etc.
>
> I could very well be missing something and this patch is quite lightly
> tested on qemu, mainly through the mentioned commit, referring to the
> make_fake_routers.sh script, in which I'm seeing some runtime reduction
> in creating 100, up to ~10%, although there is quite a bit of variability
> so cannot say for sure if it does make a real impact:
> http://people.canonical.com/~inaddy/lp1328088/make_fake_routers.sh
>
> Applies on current Linus' tree.

I would really appreciate it, if you are going to come up with a new
locking primitive that you implement that locking primitive separately.
A fresh locking primitive comingled with other code is a good way to get
something wrong, and generally to get code that is not well maintained
because there is not a separation of concerns.

Furthermore there is a world of difference between a 1+jiffy delay
waiting for rcu_synchronize and the short hold times of task_lock.

Looking at your locking it appears to be a complete hack.  Always taking
task_lock on read (but now you have an extra atomic op where you call
xchg on the pointer).  Just calling compare_xchg on write if there
are no concurrent readers.

For raw performance you would do better to have a separate lock, or
potentially a specialized locking primitive that just used the low
pointer bits.

I don't know what motivates this work are you actually seeing
performance problems with setns?

I am very uncomofortable with a novel, and very awkward new locking
primitive that does not clearly show improvements in even it's target
workloads.

Hmm.  After thinking about this a little more your set_reader_nsproxy is
completely unsafe.  Most readers of nsproxy are from the same task.
Changing the low bits of the pointer of from another task will cause
those readers to segfault, and if not segfault they are reading from the
wrong memory locations.

So this patch is completely unsafe.

Nacked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

If there is something worth optimizing here you need to go back to the
drawing board and come up with something that is safe.

> Signed-off-by: Davidlohr Bueso <dbueso-l3A5Bk7waGM@public.gmane.org>
> ---
>  fs/namespace.c           |  6 +++---
>  fs/proc/proc_net.c       |  6 +++---
>  fs/proc_namespace.c      |  6 +++---
>  include/linux/nsproxy.h  | 51 ++++++++++++++++++++++++++++++++++++++----------
>  ipc/namespace.c          |  6 +++---
>  kernel/nsproxy.c         | 22 ++++++++++++++++-----
>  kernel/utsname.c         |  6 +++---
>  net/core/net_namespace.c | 13 ++++++------
>  8 files changed, 80 insertions(+), 36 deletions(-)
>
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 4fb1691..31663a4 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -3297,13 +3297,13 @@ static struct ns_common *mntns_get(struct task_struct *task)
>  	struct ns_common *ns = NULL;
>  	struct nsproxy *nsproxy;
>  
> -	task_lock(task);
> -	nsproxy = task->nsproxy;
> +	set_reader_nsproxy(task);
> +	nsproxy = task_nsproxy(task);
>  	if (nsproxy) {
>  		ns = &nsproxy->mnt_ns->ns;
>  		get_mnt_ns(to_mnt_ns(ns));
>  	}
> -	task_unlock(task);
> +	clear_reader_nsproxy(task);
>  
>  	return ns;
>  }
> diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
> index 350984a..a908510 100644
> --- a/fs/proc/proc_net.c
> +++ b/fs/proc/proc_net.c
> @@ -113,11 +113,11 @@ static struct net *get_proc_task_net(struct inode *dir)
>  	rcu_read_lock();
>  	task = pid_task(proc_pid(dir), PIDTYPE_PID);
>  	if (task != NULL) {
> -		task_lock(task);
> -		ns = task->nsproxy;
> +	        set_reader_nsproxy(task);
> +		ns = task_nsproxy(task);
>  		if (ns != NULL)
>  			net = get_net(ns->net_ns);
> -		task_unlock(task);
> +	        clear_reader_nsproxy(task);
>  	}
>  	rcu_read_unlock();
>  
> diff --git a/fs/proc_namespace.c b/fs/proc_namespace.c
> index 2256e7e..2ece8e9 100644
> --- a/fs/proc_namespace.c
> +++ b/fs/proc_namespace.c
> @@ -244,8 +244,8 @@ static int mounts_open_common(struct inode *inode, struct file *file,
>  	if (!task)
>  		goto err;
>  
> -	task_lock(task);
> -	nsp = task->nsproxy;
> +	set_reader_nsproxy(task);
> +	nsp = task_nsproxy(task);
>  	if (!nsp || !nsp->mnt_ns) {
>  		task_unlock(task);
>  		put_task_struct(task);
> @@ -260,7 +260,7 @@ static int mounts_open_common(struct inode *inode, struct file *file,
>  		goto err_put_ns;
>  	}
>  	get_fs_root(task->fs, &root);
> -	task_unlock(task);
> +	clear_reader_nsproxy(task);
>  	put_task_struct(task);
>  
>  	ret = seq_open_private(file, &mounts_op, sizeof(struct proc_mounts));
> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> index 35fa08f..3102ae4 100644
> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -39,29 +39,60 @@ extern struct nsproxy init_nsproxy;
>  /*
>   * the namespaces access rules are:
>   *
> - *  1. only current task is allowed to change tsk->nsproxy pointer or
> - *     any pointer on the nsproxy itself.  Current must hold the task_lock
> - *     when changing tsk->nsproxy.
> + *  1. only current task is allowed to change current->nsproxy pointer or
> + *     any pointer on the nsproxy itself.
>   *
> - *  2. when accessing (i.e. reading) current task's namespaces - no
> - *     precautions should be taken - just dereference the pointers
> + *  2. the access to other task namespaces (reader) are very rare and short
> + *     lived, enough to refcount whatever resource we are dealing with. This
> + *     remote reader access is performed like this:
>   *
> - *  3. the access to other task namespaces is performed like this
> - *     task_lock(task);
> - *     nsproxy = task->nsproxy;
> + *     set_reader_nsproxy(task);
> + *     nsproxy = task_nsproxy(task);
>   *     if (nsproxy != NULL) {
>   *             / *
>   *               * work with the namespaces here
> - *               * e.g. get the reference on one of them
> + *               * i.e. get the reference on one of them
>   *               * /
>   *     } / *
>   *         * NULL task->nsproxy means that this task is
>   *         * almost dead (zombie)
>   *         * /
> - *     task_unlock(task);
> + *     clear_reader_nsproxy(task);
>   *
> + *  3. above guarantees 1 & 2 enable writer pointer fastpath optimizations
> + *     and proxy on the task's alloc_lock as a slowpath. Otherwise the common
> + *     case will be that nobody is peeking into our ns and, synchronized via
> + *     [Rmw], we can skip any locks altogether when setting a new namespace,
> + *     i.e. switch_task_namespaces().
>   */
>  
> +#define NSPROXY_READER	1UL
> +
> +static inline void set_reader_nsproxy(struct task_struct *tsk)
> +{
> +	/*
> +	 * In case there is contention on the alloc_lock, toggle
> +	 * readers before we try to acquire it. Any incoming writer
> +	 * must sync-up at this point.
> +	 */
> +	(void)xchg(&tsk->nsproxy, (struct nsproxy *)
> +		   ((unsigned long)tsk->nsproxy | NSPROXY_READER));
> +	task_lock(tsk);
> +}
> +
> +static inline void clear_reader_nsproxy(struct task_struct *tsk)
> +{
> +	task_unlock(tsk);
> +	(void)xchg(&tsk->nsproxy, (struct nsproxy *)
> +		   ((unsigned long)tsk->nsproxy & ~NSPROXY_READER));
> +}
> +
> +static inline struct nsproxy *task_nsproxy(struct task_struct *tsk)
> +{
> +	return (struct nsproxy *)
> +		((unsigned long)READ_ONCE(tsk->nsproxy) & ~NSPROXY_READER);
> +}
> +
>  int copy_namespaces(unsigned long flags, struct task_struct *tsk);
>  void exit_task_namespaces(struct task_struct *tsk);
>  void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index 068caf1..08bb5a8 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -138,11 +138,11 @@ static struct ns_common *ipcns_get(struct task_struct *task)
>  	struct ipc_namespace *ns = NULL;
>  	struct nsproxy *nsproxy;
>  
> -	task_lock(task);
> -	nsproxy = task->nsproxy;
> +	set_reader_nsproxy(task);
> +	nsproxy = task_nsproxy(task);
>  	if (nsproxy)
>  		ns = get_ipc_ns(nsproxy->ipc_ns);
> -	task_unlock(task);
> +	clear_reader_nsproxy(task);
>  
>  	return ns ? &ns->ns : NULL;
>  }
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 49746c8..c2071d1 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -11,6 +11,7 @@
>   *  Jun 2006 - namespaces support
>   *             OpenVZ, SWsoft Inc.
>   *             Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> + *  Feb 2016 - setns() performance work, Davidlohr Bueso.
>   */
>  
>  #include <linux/slab.h>
> @@ -200,17 +201,28 @@ out:
>  
>  void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
>  {
> -	struct nsproxy *ns;
> +	struct nsproxy *old, *cur = task_nsproxy(p);
>  
>  	might_sleep();
>  
> +	/*
> +	 * On success, cmpxchg barrier pairs with xchg()
> +	 * barrier in reader paths.
> +	 */
> +	old = cmpxchg(&p->nsproxy, cur, new);
> +	if (old == cur)
> +		goto put_old;
> +
> +	/*
> +	 * Slowpath, default to task_lock() alternative.
> +	 */
>  	task_lock(p);
> -	ns = p->nsproxy;
> +	old = p->nsproxy;
>  	p->nsproxy = new;
>  	task_unlock(p);
> -
> -	if (ns && atomic_dec_and_test(&ns->count))
> -		free_nsproxy(ns);
> +put_old:
> +	if (old)
> +		put_nsproxy(old);
>  }
>  
>  void exit_task_namespaces(struct task_struct *p)
> diff --git a/kernel/utsname.c b/kernel/utsname.c
> index 831ea71..ea81cb8 100644
> --- a/kernel/utsname.c
> +++ b/kernel/utsname.c
> @@ -100,13 +100,13 @@ static struct ns_common *utsns_get(struct task_struct *task)
>  	struct uts_namespace *ns = NULL;
>  	struct nsproxy *nsproxy;
>  
> -	task_lock(task);
> -	nsproxy = task->nsproxy;
> +	set_reader_nsproxy(task);
> +	nsproxy = task_nsproxy(task);
>  	if (nsproxy) {
>  		ns = nsproxy->uts_ns;
>  		get_uts_ns(ns);
>  	}
> -	task_unlock(task);
> +	clear_reader_nsproxy(task);
>  
>  	return ns ? &ns->ns : NULL;
>  }
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 2c2eb1b..2633d65c 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -502,11 +502,12 @@ struct net *get_net_ns_by_pid(pid_t pid)
>  	tsk = find_task_by_vpid(pid);
>  	if (tsk) {
>  		struct nsproxy *nsproxy;
> -		task_lock(tsk);
> -		nsproxy = tsk->nsproxy;
> +
> +	        set_reader_nsproxy(tsk);
> +		nsproxy = task_nsproxy(tsk);
>  		if (nsproxy)
>  			net = get_net(nsproxy->net_ns);
> -		task_unlock(tsk);
> +	        clear_reader_nsproxy(tsk);
>  	}
>  	rcu_read_unlock();
>  	return net;
> @@ -964,11 +965,11 @@ static struct ns_common *netns_get(struct task_struct *task)
>  	struct net *net = NULL;
>  	struct nsproxy *nsproxy;
>  
> -	task_lock(task);
> -	nsproxy = task->nsproxy;
> +	set_reader_nsproxy(task);
> +	nsproxy = task_nsproxy(task);
>  	if (nsproxy)
>  		net = get_net(nsproxy->net_ns);
> -	task_unlock(task);
> +	clear_reader_nsproxy(task);
>  
>  	return net ? &net->ns : NULL;
>  }
