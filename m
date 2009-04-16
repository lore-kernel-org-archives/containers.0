From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 15/36] c/r of restart-blocks
Date: Wed, 15 Apr 2009 23:02:21 -0700
Message-ID: <20090416060220.GB14934@us.ibm.com>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
	<1239107264-21775-16-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239107264-21775-16-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:

| +/* dump the task_struct of a given task */
| +int cr_write_restart_block(struct cr_ctx *ctx, struct task_struct *t)
| +{
| +	struct cr_hdr h;
| +	struct cr_hdr_restart_block *hh;
| +	struct restart_block *restart_block;
| +	long (*fn)(struct restart_block *);
| +	s64 base, expire = 0;
| +	int ret;
| +
| +	h.type = CR_HDR_RESTART_BLOCK;
| +	h.len = sizeof(*hh);
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +	memset(hh, 0, sizeof(*hh));
| +
| +	base = ktime_to_ns(ctx->ktime_beg);
| +	restart_block = &task_thread_info(t)->restart_block;
| +	fn = restart_block->fn;

Can we define another operation in 'struct restart_block' and replace
the following 'fn == xyz' checks with:

	if (!restart_block->checkpoint)
		BUG(1);

	expires = restart_block->checkpoint(restart_block, &hh);

It would touch other files and require ifdef CONFIG_CHECKPOINT in them
though.

| +
| +	/* FIX: enumerate clockid_t so we're immune to changes */
| +
| +	if (fn == do_no_restart_syscall) {
| +
| +		hh->fn = CR_RESTART_BLOCK_NONE;
| +		cr_debug("restart_block: non\n");
| +
| +	} else if (fn == hrtimer_nanosleep_restart) {
| +
| +		hh->fn = CR_RESTART_BLOCK_HRTIMER_NANOSLEEP;
| +		hh->arg_0 = restart_block->nanosleep.index;
| +		hh->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
| +		expire = restart_block->nanosleep.expires;
| +		cr_debug("restart_block: hrtimer expire %lld now %lld\n",
| +			 expire, base);
| +
| +	} else if (fn == posix_cpu_nsleep_restart) {
| +		struct timespec ts;
| +
| +		hh->fn = CR_RESTART_BLOCK_POSIX_CPU_NANOSLEEP;
| +		hh->arg_0 = restart_block->arg0;
| +		hh->arg_1 = restart_block->arg1;
| +		ts.tv_sec = restart_block->arg2;
| +		ts.tv_nsec = restart_block->arg3;
| +		expire = timespec_to_ns(&ts);
| +		cr_debug("restart_block: posix_cpu expire %lld now %lld\n",
| +			 expire, base);
| +
| +#ifdef CONFIG_COMPAT
| +	} else if (fn == compat_nanosleep_restart) {
| +
| +		hh->fn = CR_RESTART_BLOCK_NANOSLEEP;
| +		hh->arg_0 = restart_block->nanosleep.index;
| +		hh->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
| +		hh->arg_2 = (unsigned long)
| +			restart_block->nanosleep.compat_rmtp;
| +		expire = restart_block->nanosleep.expires;
| +		cr_debug("restart_block: compat expire %lld now %lld\n",
| +			 expire, base);
| +
| +	} else if (fn == compat_clock_nanosleep_restart) {
| +
| +		hh->fn = CR_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP;
| +		hh->arg_0 = restart_block->nanosleep.index;
| +		hh->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
| +		hh->arg_2 = (unsigned long)
| +			restart_block->nanosleep.compat_rmtp;
| +		expire = restart_block->nanosleep.expires;
| +		cr_debug("restart_block: compat_clock expire %lld now %lld\n",
| +			 expire, base);
| +
| +#endif
| +	} else if (fn == futex_wait_restart) {
| +
| +		hh->fn = CR_RESTART_BLOCK_FUTEX;
| +		hh->arg_0 = (unsigned long) restart_block->futex.uaddr;
| +		hh->arg_1 = restart_block->futex.val;
| +		hh->arg_2 = restart_block->futex.flags;
| +		hh->arg_3 = restart_block->futex.bitset;
| +		expire = restart_block->futex.time;
| +		cr_debug("restart_block: futex expire %lld now %lld\n",
| +			 expire, base);
| +
| +	} else if (fn == do_restart_poll) {
| +		struct timespec ts;
| +
| +		hh->fn = CR_RESTART_BLOCK_POLL;
| +		hh->arg_0 = (unsigned long) restart_block->poll.ufds;
| +		hh->arg_1 = restart_block->poll.nfds;
| +		hh->arg_2 = restart_block->poll.has_timeout;
| +		ts.tv_sec = restart_block->poll.tv_sec;
| +		ts.tv_nsec = restart_block->poll.tv_nsec;
| +		expire = timespec_to_ns(&ts);
| +		cr_debug("restart_block: poll expire %lld now %lld\n",
| +			 expire, base);
| +
| +	} else {
| +
| +		BUG();
| +
| +	}
| +
| +	/* common to all restart blocks: */
| +	if (base < expire)
| +		hh->arg_4 = (expire - base);
| +
| +	cr_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
| +		 hh->arg_0, hh->arg_1, hh->arg_2, hh->arg_3, hh->arg_4);
| +
| +	ret = cr_write_obj(ctx, &h, hh);
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +
| +	return ret;
| +}
| +
|  /* dump the entire state of a given task */
|  int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
|  {
| diff --git a/checkpoint/restart.c b/checkpoint/restart.c
| index 234cc92..daaaeec 100644
| --- a/checkpoint/restart.c
| +++ b/checkpoint/restart.c
| @@ -264,18 +264,16 @@ int do_restart(struct cr_ctx *ctx, pid_t pid)
| 
|  	ret = cr_ctx_restart(ctx, pid);
|  	if (ret < 0)
| -		goto out;
| +		return ret;
|  	ret = cr_read_head(ctx);
|  	if (ret < 0)
| -		goto out;
| +		return ret;
|  	ret = cr_read_task(ctx);
|  	if (ret < 0)
| -		goto out;
| +		return ret;
|  	ret = cr_read_tail(ctx);
|  	if (ret < 0)
| -		goto out;
| +		return ret;

Nit, would this patch be simpler if we left the 'goto out' lines above
and added the 'return cr_retval_restart(ctx);' here (i.e just before the
'out:' label) ?

| 
| -	/* on success, adjust the return value if needed [TODO] */
| - out:
| -	return ret;
| +	return cr_retval_restart(ctx);
|  }
| diff --git a/checkpoint/rstr_task.c b/checkpoint/rstr_task.c
| index 93c86ab..52206d8 100644
| --- a/checkpoint/rstr_task.c
| +++ b/checkpoint/rstr_task.c
| @@ -9,6 +9,9 @@
|   */
| 
|  #include <linux/sched.h>
| +#include <linux/posix-timers.h>
| +#include <linux/futex.h>
| +#include <linux/poll.h>
|  #include <linux/checkpoint.h>
|  #include <linux/checkpoint_hdr.h>
| 
| @@ -52,6 +55,115 @@ static int cr_read_task_struct(struct cr_ctx *ctx)
|  	return ret;
|  }
| 
| +int cr_read_restart_block(struct cr_ctx *ctx)
| +{
| +	struct cr_hdr_restart_block *hh;
| +	struct restart_block restart_block;
| +	struct timespec ts;
| +	clockid_t clockid;
| +	s64 expire;
| +	int ret;
| +
| +	hh = cr_hbuf_get(ctx, sizeof(*hh));
| +	if (!hh)
| +		return -ENOMEM;
| +
| +	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_RESTART_BLOCK);
| +	if (ret < 0)
| +		goto out;
| +
| +	expire = ktime_to_ns(ctx->ktime_beg) + hh->arg_4;
| +	restart_block.fn = NULL;
| +
| +	cr_debug("restart_block: expire %lld begin %lld\n",
| +		 expire, ktime_to_ns(ctx->ktime_beg));
| +	cr_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
| +		 hh->arg_0, hh->arg_1, hh->arg_2, hh->arg_3, hh->arg_4);
| +
| +	switch (hh->fn) {
| +	case CR_RESTART_BLOCK_NONE:
| +		restart_block.fn = do_no_restart_syscall;
| +		break;
| +	case CR_RESTART_BLOCK_HRTIMER_NANOSLEEP:
| +		clockid = hh->arg_0;
| +		if (clockid < 0 || invalid_clockid(clockid))
| +			break;
| +		restart_block.fn = hrtimer_nanosleep_restart;
| +		restart_block.nanosleep.index = clockid;
| +		restart_block.nanosleep.rmtp =
| +			(struct timespec __user *) (unsigned long) hh->arg_1;
| +		restart_block.nanosleep.expires = expire;
| +		break;
| +	case CR_RESTART_BLOCK_POSIX_CPU_NANOSLEEP:
| +		clockid = hh->arg_0;
| +		if (clockid < 0 || invalid_clockid(clockid))
| +			break;
| +		restart_block.fn = posix_cpu_nsleep_restart;
| +		restart_block.arg0 = clockid;
| +		restart_block.arg1 = hh->arg_1;
| +		ts = ns_to_timespec(expire);
| +		restart_block.arg2 = ts.tv_sec;
| +		restart_block.arg3 = ts.tv_nsec;
| +		break;
| +#ifdef CONFIG_COMPAT
| +	case CR_RESTART_BLOCK_COMPAT_NANOSLEEP:
| +		clockid = hh->arg_0;
| +		if (clockid < 0 || invalid_clockid(clockid))
| +			break;
| +		restart_block.fn = compat_nanosleep_restart;
| +		restart_block.nanosleep.index = clockid;
| +		restart_block.nanosleep.rmtp =
| +			(struct timespec __user *) (unsigned long) hh->arg_1;
| +		restart_block.nanosleep.compat_rmtp =
| +			(struct compat_timespec __user *)
| +				(unsigned long) hh->arg_2;
| +		resatrt_block.nanosleep.expires = expire;
| +		break;
| +	case CR_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
| +		clockid = hh->arg_0;
| +		if (clockid < 0 || invalid_clockid(clockid))
| +			break;
| +		restart_block.fn = compat_clock_nanosleep_restart;
| +		restart_block.nanosleep.index = clockid;
| +		restart_block.nanosleep.rmtp =
| +			(struct timespec __user *) (unsigned long) hh->arg_1;
| +		restart_block.nanosleep.compat_rmtp =
| +			(struct compat_timespec __user *)
| +				(unsigned long) hh->arg_2;
| +		resatrt_block.nanosleep.expires = expire;
| +		break;
| +#endif
| +	case CR_RESTART_BLOCK_FUTEX:
| +		restart_block.fn = futex_wait_restart;
| +		restart_block.futex.uaddr = (u32 *) (unsigned long) hh->arg_0;
| +		restart_block.futex.val = hh->arg_1;
| +		restart_block.futex.flags = hh->arg_2;
| +		restart_block.futex.bitset = hh->arg_3;
| +		restart_block.futex.time = expire;
| +		break;
| +	case CR_RESTART_BLOCK_POLL:
| +		restart_block.fn = do_restart_poll;
| +		restart_block.poll.ufds =
| +			(struct pollfd __user *) (unsigned long) hh->arg_0;
| +		restart_block.poll.nfds = hh->arg_1;
| +		restart_block.poll.has_timeout = hh->arg_2;
| +		ts = ns_to_timespec(expire);
| +		restart_block.poll.tv_sec = ts.tv_sec;
| +		restart_block.poll.tv_nsec = ts.tv_nsec;
| +		break;
| +	default:
| +		break;
| +	}
| +
| +	if (restart_block.fn)
| +		task_thread_info(current)->restart_block = restart_block;
| +	else
| +		ret = -EINVAL;
| + out:
| +	cr_hbuf_put(ctx, sizeof(*hh));
| +	return ret;
| +}
| +
|  /* read the entire state of the current task */
|  int cr_read_task(struct cr_ctx *ctx)
|  {
| @@ -76,6 +188,5 @@ int cr_read_task(struct cr_ctx *ctx)
|  	ret = cr_read_cpu(ctx);
|  	cr_debug("cpu: ret %d\n", ret);
|   out:
| -
|  	return ret;
|  }
| diff --git a/checkpoint/sys.c b/checkpoint/sys.c
| index 8652c5c..863cb63 100644
| --- a/checkpoint/sys.c
| +++ b/checkpoint/sys.c
| @@ -186,6 +186,7 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
|  		return ERR_PTR(-ENOMEM);
| 
|  	ctx->flags = flags;
| +	ctx->ktime_beg = ktime_get();
| 
|  	INIT_LIST_HEAD(&ctx->pgarr_list);
|  	INIT_LIST_HEAD(&ctx->pgarr_pool);
| @@ -203,6 +204,7 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
|  	if (cr_objhash_alloc(ctx) < 0)
|  		goto err;
| 
| +
|  	return ctx;
| 
|   err:
| diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
| index 3a514fc..a94ce98 100644
| --- a/include/linux/checkpoint.h
| +++ b/include/linux/checkpoint.h
| @@ -18,6 +18,8 @@
|  struct cr_ctx {
|  	int crid;		/* unique checkpoint id */
| 
| +	ktime_t ktime_beg;	/* checkpoint start time */

Nit: spell out 'begin' fully ? :-) 

| +
|  	pid_t root_pid;		/* container identifier */
|  	struct task_struct *root_task;	/* container root task */
|  	struct nsproxy *root_nsproxy;	/* container root nsproxy */
| @@ -87,10 +89,12 @@ extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
|  				       int flags, int mode);
| 
|  extern int cr_write_task(struct cr_ctx *ctx, struct task_struct *t);
| +extern int cr_write_restart_block(struct cr_ctx *ctx, struct task_struct *t);
|  extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
|  extern int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t);
| 
|  extern int cr_read_task(struct cr_ctx *ctx);
| +extern int cr_read_restart_block(struct cr_ctx *ctx);
|  extern int cr_read_mm(struct cr_ctx *ctx);
|  extern int cr_read_fd_table(struct cr_ctx *ctx);
| 
| diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
| index 30e649b..8821a30 100644
| --- a/include/linux/checkpoint_hdr.h
| +++ b/include/linux/checkpoint_hdr.h
| @@ -45,6 +45,7 @@ enum {
|  	CR_HDR_FNAME,
| 
|  	CR_HDR_TASK = 101,
| +	CR_HDR_RESTART_BLOCK,
|  	CR_HDR_THREAD,
|  	CR_HDR_CPU,
| 
| @@ -97,6 +98,25 @@ struct cr_hdr_task {
|  	__u32 task_comm_len;
|  } __attribute__((aligned(8)));
| 
| +struct cr_hdr_restart_block {
| +	__u64 fn;

Nit: This a function-type rather than the function itself ? A bit misleading
considering restart_block->fn refers to a function.

| +	__u64 arg_0;
| +	__u64 arg_1;
| +	__u64 arg_2;
| +	__u64 arg_3;
| +	__u64 arg_4;
| +} __attribute__((aligned(8)));
| +
| +enum restart_block_type {
| +	CR_RESTART_BLOCK_NONE = 1,
| +	CR_RESTART_BLOCK_HRTIMER_NANOSLEEP,
| +	CR_RESTART_BLOCK_POSIX_CPU_NANOSLEEP,
| +	CR_RESTART_BLOCK_COMPAT_NANOSLEEP,
| +	CR_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP,
| +	CR_RESTART_BLOCK_POLL,
| +	CR_RESTART_BLOCK_FUTEX
| +};
| +
|  struct cr_hdr_mm {
|  	__s32 objref;		/* identifier for shared objects */
|  	__u32 map_count;
| -- 
| 1.5.4.3
| 
| _______________________________________________
| Containers mailing list
| Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
| https://lists.linux-foundation.org/mailman/listinfo/containers
