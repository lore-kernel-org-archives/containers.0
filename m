From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] linux-cr: nested pid namespaces (v3)
Date: Tue, 30 Mar 2010 00:51:47 -0400
Message-ID: <4BB18363.8090109@cs.columbia.edu>
References: <20100323051839.GA16123@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100323051839.GA16123-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
List-Id: containers.vger.kernel.org


Applied for ckpt-v21, thanks.
Will also send a cleanup patch on top of this.

Serge E. Hallyn wrote:
> Support checkpoint and restart of tasks in nested pid namespaces.
> We keep the original single pids_array to minimize memory
> allocations.  The pids array entries are augmented with a pidns
> depth (relative to the container init's pidns, and an "rpid" which
> is the pid in the checkpointer's pidns (or 0 if no valid pid exists).
> The rpid will be used by userspace to gather more information (like
> /proc/$$/mountinfo) after the kernel sys_checkpoint.  If any tasks
> are in nested pid namespace, another single array will hold all of
> the vpids.  At restart those are used by userspace to determine how
> to call eclone().  Kernel ignores them.
> 
> This patch also adds 'rpid' to struct ckpt_hdr_pids, which is not
> needed for nested pid_ns support, but will be needed for the
> userspace checkpointer to gather additional information (i.e.
> /proc/pid/mountinfo) after sys_checkpoint() completes.
> 
> Changelog:
>   Mar 22:
> 	Use Louis Rilling's smarter ckpt_vpids algorithm
> 	verbatim, to handle pid_ns depths > CKPT_HDR_PIDS_CHUNK,
> 	as well as fix an apparent bug in my original code.
> 
> 	As Louis suggested, use task_active_pid_ns() rather than
> 	task->nsproxy->pid_ns.  In fact it's a must, bc the
> 	checkpointed task may be dead and have NULL
> 	task->nsproxy->pid_ns.
> 
> 	Oren: Add spinlock for nsproxy->pidns; use
> 	ckpt_read_consume() to consume vpids; and use __s32 instead
> 	of ckpt_vpid struct
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/checkpoint.c          |  123 ++++++++++++++++++++++++++++++++++----
>  checkpoint/process.c             |   22 ++++++-
>  checkpoint/restart.c             |   43 ++++++++++++-
>  checkpoint/sys.c                 |    2 +
>  include/linux/checkpoint.h       |    2 +-
>  include/linux/checkpoint_hdr.h   |   14 ++++
>  include/linux/checkpoint_types.h |    3 +
>  kernel/nsproxy.c                 |    9 ++-
>  8 files changed, 195 insertions(+), 23 deletions(-)
> 
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index f27af41..fd61a80 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -27,6 +27,7 @@
>  #include <linux/deferqueue.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> +#include <linux/pid_namespace.h>
>  
>  /* unique checkpoint identifier (FIXME: should be per-container ?) */
>  static atomic_t ctx_count = ATOMIC_INIT(0);
> @@ -242,6 +243,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
>  	struct task_struct *root = ctx->root_task;
>  	struct nsproxy *nsproxy;
>  	int ret = 0;
> +	struct pid_namespace *pidns;
>  
>  	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
>  
> @@ -293,10 +295,15 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
>  		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
>  		ret = -EPERM;
>  	}
> -	/* no support for >1 private pidns */
> -	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
> -		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
> -		ret = -EPERM;
> +	/* pidns must be descendent of root_nsproxy */
> +	pidns = nsproxy->pid_ns;
> +	while (pidns != ctx->root_nsproxy->pid_ns) {
> +		if (pidns == &init_pid_ns) {
> +			ret = -EPERM;
> +			_ckpt_err(ctx, ret, "%(T)stranger pid_ns\n");
> +			break;
> +		}
> +		pidns = pidns->parent;
>  	}
>  	rcu_read_unlock();
>  
> @@ -305,15 +312,19 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
>  
>  #define CKPT_HDR_PIDS_CHUNK	256
>  
> +/*
> + * Write the pids in ctx->root_nsproxy->pidns.  This info is
> + * needed at restart to unambiguously dereference tasks.
> + */
>  static int checkpoint_pids(struct ckpt_ctx *ctx)
>  {
>  	struct ckpt_pids *h;
> -	struct pid_namespace *ns;
> +	struct pid_namespace *root_pidns;
>  	struct task_struct *task;
>  	struct task_struct **tasks_arr;
>  	int nr_tasks, n, pos = 0, ret = 0;
>  
> -	ns = ctx->root_nsproxy->pid_ns;
> +	root_pidns = ctx->root_nsproxy->pid_ns;
>  	tasks_arr = ctx->tasks_arr;
>  	nr_tasks = ctx->nr_tasks;
>  	BUG_ON(nr_tasks <= 0);
> @@ -331,15 +342,21 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
>  	do {
>  		rcu_read_lock();
>  		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
> +			struct pid_namespace *task_pidns;
>  			task = tasks_arr[pos];
>  
> -			h[n].vpid = task_pid_nr_ns(task, ns);
> -			h[n].vtgid = task_tgid_nr_ns(task, ns);
> -			h[n].vpgid = task_pgrp_nr_ns(task, ns);
> -			h[n].vsid = task_session_nr_ns(task, ns);
> -			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
> +			h[n].vpid = task_pid_nr_ns(task, root_pidns);
> +			h[n].vtgid = task_tgid_nr_ns(task, root_pidns);
> +			h[n].vpgid = task_pgrp_nr_ns(task, root_pidns);
> +			h[n].vsid = task_session_nr_ns(task, root_pidns);
> +			h[n].vppid = task_tgid_nr_ns(task->real_parent,
> +					root_pidns);
> +			task_pidns = task_active_pid_ns(task);
> +			h[n].rpid = task_pid_vnr(task);
> +			h[n].depth = task_pidns->level - root_pidns->level;
>  			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
>  				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
> +			ctx->nr_vpids += h[n].depth;
>  			pos++;
>  		}
>  		rcu_read_unlock();
> @@ -356,6 +373,71 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
>  	return ret;
>  }
>  
> +static int checkpoint_vpids(struct ckpt_ctx *ctx)
> +{
> +	__s32 *h;  /* vpid array */
> +	struct pid_namespace *root_pidns, *task_pidns = NULL, *active_pidns;
> +	struct task_struct *task;
> +	int ret, nr_tasks = ctx->nr_tasks;
> +	int tidx = 0, /* index into task array */
> +		hidx = 0, /* pids written into current __s32 chunk */
> +		vidx = 0; /* vpid index for current task */
> +
> +	root_pidns = ctx->root_nsproxy->pid_ns;
> +	nr_tasks = ctx->nr_tasks;
> +
> +	ret = ckpt_write_obj_type(ctx, NULL,
> +				  sizeof(*h) * ctx->nr_vpids,
> +				  CKPT_HDR_BUFFER);
> +	if (ret < 0)
> +		return ret;
> +
> +	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	do {
> +		rcu_read_lock();
> +		while (tidx < nr_tasks && hidx < CKPT_HDR_PIDS_CHUNK) {
> +			int nsdelta;
> +
> +			task = ctx->tasks_arr[tidx];
> +			active_pidns = task_active_pid_ns(task);
> +			nsdelta = active_pidns->level - root_pidns->level;
> +			if (hidx + nsdelta - vidx > CKPT_HDR_PIDS_CHUNK)
> +				/*
> +				 * We will release rcu before recording the
> +				 * remaining vpids, but neither task nor its
> +				 * pid can disappear.
> +				 */
> +				nsdelta = CKPT_HDR_PIDS_CHUNK - hidx + vidx;
> +
> +			if (vidx == 0)
> +				task_pidns = active_pidns;
> +			for (; vidx < nsdelta; vidx++) {
> +				h[hidx] = task_pid_nr_ns(task, task_pidns);
> +				hidx++;
> +				task_pidns = task_pidns->parent;
> +			}
> +
> +			if (task_pidns == root_pidns) {
> +				tidx++;
> +				vidx = 0;
> +			}
> +		}
> +		rcu_read_unlock();
> +
> +		ret = ckpt_kwrite(ctx, h, hidx * sizeof(*h));
> +		if (ret < 0)
> +			break;
> +
> +		hidx = 0;
> +	} while (tidx < nr_tasks);
> +
> +	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
> +	return ret;
> +}
> +
>  static int collect_objects(struct ckpt_ctx *ctx)
>  {
>  	int n, ret = 0;
> @@ -466,6 +548,7 @@ static int build_tree(struct ckpt_ctx *ctx)
>  static int checkpoint_tree(struct ckpt_ctx *ctx)
>  {
>  	struct ckpt_hdr_tree *h;
> +	struct ckpt_hdr_vpids *hvpids;
>  	int ret;
>  
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TREE);
> @@ -480,7 +563,23 @@ static int checkpoint_tree(struct ckpt_ctx *ctx)
>  		return ret;
>  
>  	ret = checkpoint_pids(ctx);
> -	return ret;
> +	if (ret < 0)
> +		return ret;
> +
> +	hvpids = ckpt_hdr_get_type(ctx, sizeof(*hvpids), CKPT_HDR_VPIDS);
> +	if (!hvpids)
> +		return -ENOMEM;
> +
> +	hvpids->nr_vpids = ctx->nr_vpids;
> +
> +	ret = ckpt_write_obj(ctx, &hvpids->h);
> +	ckpt_hdr_put(ctx, hvpids);
> +	if (ret < 0)
> +		return ret;
> +	if (ctx->nr_vpids == 0)
> +		return 0;
> +
> +	return checkpoint_vpids(ctx);
>  }
>  
>  static struct task_struct *get_freezer_task(struct task_struct *root_task)
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index f917112..602ba9f 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -22,7 +22,7 @@
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  #include <linux/syscalls.h>
> -
> +#include <linux/pid_namespace.h>
>  
>  pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
>  {
> @@ -51,7 +51,7 @@ struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
>  		 * Find the owner process of this pgid (it must exist
>  		 * if pgrp exists). It must be a thread group leader.
>  		 */
> -		pgrp = find_vpid(pgid);
> +		pgrp = find_pid_ns(pgid, ctx->root_nsproxy->pid_ns);
>  		p = pid_task(pgrp, PIDTYPE_PID);
>  		if (!p || !thread_group_leader(p))
>  			return NULL;
> @@ -561,6 +561,13 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
>  	return ret;
>  }
>  
> +/*
> + * restart is currently serialized, but if/when that changes we want
> + * to make sure that setting nsproxy->pidns in restore_task_ns() is only
> + * done once.  That's what checkpoint_nslock is for
> + */
> +DEFINE_SPINLOCK(checkpoint_nslock);
> +
>  static int restore_task_ns(struct ckpt_ctx *ctx)
>  {
>  	struct ckpt_hdr_task_ns *h;
> @@ -578,6 +585,10 @@ static int restore_task_ns(struct ckpt_ctx *ctx)
>  	}
>  
>  	if (nsproxy != task_nsproxy(current)) {
> +		spin_lock(&checkpoint_nslock);
> +		if (!nsproxy->pid_ns)
> +			nsproxy->pid_ns = get_pid_ns(current->nsproxy->pid_ns);
> +		spin_unlock(&checkpoint_nslock);
>  		get_nsproxy(nsproxy);
>  		switch_task_namespaces(current, nsproxy);
>  	}
> @@ -829,8 +840,8 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
>  
>  	pgid = ctx->pids_arr[ctx->active_pid].vpgid;
>  
> -	if (pgid == task_pgrp_vnr(task))  /* nothing to do */
> -		return 0;
> +	if (pgid == task_pgrp_nr_ns(task, ctx->root_nsproxy->pid_ns))
> +		return 0;  /* nothing to do */
>  
>  	if (task->signal->leader)  /* (2) */
>  		return -EINVAL;
> @@ -850,6 +861,9 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
>  	if (ctx->uflags & RESTART_TASKSELF)
>  		ret = 0;
>  
> +	if (ret < 0)
> +		ckpt_err(ctx, ret, "setting pgid\n");
> +
>  	return ret;
>  }
>  
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 6a9644d..c25ce88 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -23,6 +23,7 @@
>  #include <asm/syscall.h>
>  #include <linux/elf.h>
>  #include <linux/deferqueue.h>
> +#include <linux/pid_namespace.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  
> @@ -760,6 +761,33 @@ static int restore_read_tree(struct ckpt_ctx *ctx)
>  	return ret;
>  }
>  
> +/*
> + * read all the vpids - we don't actually care about them,
> + * userspace did
> + */
> +static int restore_slurp_vpids(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_vpids *h;
> +	int size, ret;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_VPIDS);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +	ctx->nr_vpids = h->nr_vpids;
> +	ckpt_hdr_put(ctx, h);
> +
> +	if (!ctx->nr_vpids)
> +		return 0;
> +
> +	size = sizeof(__s32) * ctx->nr_vpids;
> +	if (size < 0)		/* overflow ? */
> +		return -EINVAL;
> +
> +	ret = ckpt_read_consume(ctx, size + sizeof(struct ckpt_hdr),
> +				CKPT_HDR_BUFFER);
> +	return ret;
> +}
> +
>  static inline int all_tasks_activated(struct ckpt_ctx *ctx)
>  {
>  	return (ctx->active_pid == ctx->nr_pids);
> @@ -848,7 +876,8 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
>  		pid = get_active_pid(ctx);
>  
>  		rcu_read_lock();
> -		task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
> +		task = find_task_by_pid_ns(pid,
> +					task_active_pid_ns(ctx->root_task));
>  		/* target task must have same restart context */
>  		if (task && task->checkpoint_ctx == ctx)
>  			wake_up_process(task);
> @@ -870,7 +899,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
>  
>  static int wait_task_active(struct ckpt_ctx *ctx)
>  {
> -	pid_t pid = task_pid_vnr(current);
> +	pid_t pid = task_pid_nr_ns(current, task_active_pid_ns(ctx->root_task));
>  	int ret;
>  
>  	ckpt_debug("pid %d waiting\n", pid);
> @@ -886,7 +915,8 @@ static int wait_task_active(struct ckpt_ctx *ctx)
>  
>  static int wait_task_sync(struct ckpt_ctx *ctx)
>  {
> -	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
> +	ckpt_debug("pid %d syncing\n",
> +		task_pid_nr_ns(current, task_active_pid_ns(ctx->root_task)));
>  	wait_event_interruptible(ctx->waitq, ckpt_test_complete(ctx));
>  	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
>  	if (ckpt_test_error(ctx))
> @@ -1160,7 +1190,7 @@ static struct task_struct *choose_root_task(struct ckpt_ctx *ctx, pid_t pid)
>  
>  	read_lock(&tasklist_lock);
>  	list_for_each_entry(task, &current->children, sibling) {
> -		if (task_pid_vnr(task) == pid) {
> +		if (task_pid_nr_ns(task, ctx->coord_pidns) == pid) {
>  			get_task_struct(task);
>  			ctx->root_task = task;
>  			ctx->root_pid = pid;
> @@ -1237,6 +1267,11 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
>  	if (ret < 0)
>  		return ret;
>  
> +	ret = restore_slurp_vpids(ctx);
> +	ckpt_debug("read vpids %d\n", ret);
> +	if (ret < 0)
> +		return ret;
> +
>  	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
>  		return -EINVAL;
>  
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 9e9df9b..45d3e7a 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -22,6 +22,7 @@
>  #include <linux/capability.h>
>  #include <linux/checkpoint.h>
>  #include <linux/deferqueue.h>
> +#include <linux/pid_namespace.h>
>  
>  /*
>   * ckpt_unpriv_allowed - sysctl controlled.
> @@ -276,6 +277,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
>  	ctx->uflags = uflags;
>  	ctx->kflags = kflags;
>  	ctx->ktime_begin = ktime_get();
> +	ctx->coord_pidns = get_pid_ns(current->nsproxy->pid_ns);
>  
>  	atomic_set(&ctx->refcount, 0);
>  	INIT_LIST_HEAD(&ctx->pgarr_list);
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 792b523..e860bf5 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -10,7 +10,7 @@
>   *  distribution for more details.
>   */
>  
> -#define CHECKPOINT_VERSION  5
> +#define CHECKPOINT_VERSION  6
>  
>  /* checkpoint user flags */
>  #define CHECKPOINT_SUBTREE	0x1
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 41412d1..20c90b3 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -117,6 +117,8 @@ enum {
>  #define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
>  	CKPT_HDR_TASK_CREDS,
>  #define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
> +	CKPT_HDR_VPIDS,
> +#define CKPT_HDR_VPIDS CKPT_HDR_VPIDS
>  
>  	/* 201-299: reserved for arch-dependent */
>  
> @@ -327,11 +329,23 @@ struct ckpt_hdr_tree {
>  } __attribute__((aligned(8)));
>  
>  struct ckpt_pids {
> +	/* These pids are in the root_nsproxy's pid ns */
>  	__s32 vpid;
>  	__s32 vppid;
>  	__s32 vtgid;
>  	__s32 vpgid;
>  	__s32 vsid;
> +	/* rpid is the real pid, in checkpointer's pidns.  This is
> +	 * so checkpointer in userspace can get more info about the
> +	 * task (i.e. /proc/pid/mountinfo) */
> +	__s32 rpid;
> +	__s32 depth; /* pid namespace depth relative to container init */
> +} __attribute__((aligned(8)));
> +
> +/* number of vpids */
> +struct ckpt_hdr_vpids {
> +	struct ckpt_hdr h;
> +	__s32 nr_vpids;
>  } __attribute__((aligned(8)));
>  
>  /* pids */
> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index ecd3e91..2fb79cf 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -72,6 +72,9 @@ struct ckpt_ctx {
>  	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
>  	int nr_tasks;                   /* size of tasks array */
>  
> +	int nr_vpids;
> +	struct pid_namespace *coord_pidns;	/* coordinator pid_ns */
> +
>  	/* [multi-process restart] */
>  	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
>  	int nr_pids;			/* size of pids array */
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 0da0d83..6d86240 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -364,8 +364,13 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  		get_net(net_ns);
>  		nsproxy->net_ns = net_ns;
>  
> -		get_pid_ns(current->nsproxy->pid_ns);
> -		nsproxy->pid_ns = current->nsproxy->pid_ns;
> +		/*
> +		 * The pid_ns will get assigned the first time that we
> +		 * assign the nsproxy to a task.  The task had unshared
> +		 * its pid_ns in userspace before calling restart, and
> +		 * we want to keep using that pid_ns.
> +		 */
> +		nsproxy->pid_ns = NULL;
>  	}
>   out:
>  	if (ret < 0)
