From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH linux-cr] nested pid namespaces (v2)
Date: Mon, 22 Mar 2010 19:17:29 -0400
Message-ID: <4BA7FA89.208@cs.columbia.edu>
References: <20100319213955.GA17912@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100319213955.GA17912@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Support checkpoint and restart of tasks in nested pid namespaces.  At
> Oren's request here is an alternative to my previous implementation.  In
> this one, we keep the original single pids_array to minimize memory
> allocations.  The pids array entries are augmented with a pidns depth

Thanks for adapting the patch.

FWIW, not only minimize memory allocations, but also permit a more
regular structure of the image data (array of fixed size elements
followed by an array of vpids), which simplifies the code that needs
to read/write/access this data.

> (relative to the container init's pidns, and an "rpid" which is the pid
> in the checkpointer's pidns (or 0 if no valid pid exists).  The rpid
> will be used by userspace to gather more information (like
> /proc/$$/mountinfo) after the kernel sys_checkpoint.  If any tasks are
> in nested pid namespace, another single array holds all of the vpids.
> At restart those are used by userspace to determine how to call
> eclone().  Kernel ignores them.
> 
> All cr_tests including the new pid_ns testcase pass.
> 
> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> ---

[...]

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

Currently we do this while() loop twice - once here and once when
we collect the vpids. While I doubt if this has any performance
impact, is there an advantage to doing it also here ?  (a violation
will be observed there too).

[...]

>  
>  	if (nsproxy != task_nsproxy(current)) {
> +		/*
> +		 * This is *kinda* shady to do without any locking.  However
> +		 * it is safe because each task is restarted separately in
> +		 * serial.  If that ever changes, we'll need a spinlock?
> +		 */

Maybe add the lock/rcu already, so it is never forgotten later ?

> +		if (!nsproxy->pid_ns)
> +			nsproxy->pid_ns = get_pid_ns(current->nsproxy->pid_ns);
>  		get_nsproxy(nsproxy);
>  		switch_task_namespaces(current, nsproxy);
>  	}

[...]

> +/*
> + * read all the vpids - we don't actually care about them,
> + * userspace did
> + */

How about ckpt_read_consume() for this ?

> +static int restore_slurp_vpids(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_vpids *h;
> +	int size, ret;
> +	void *junk;
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
> +	size = sizeof(struct ckpt_vpid) * ctx->nr_vpids;
> +	if (size < 0)		/* overflow ? */
> +		return -EINVAL;
> +
> +	junk = kmalloc(size, GFP_KERNEL);
> +	if (!junk)
> +		return -ENOMEM;
> +
> +	ret = _ckpt_read_buffer(ctx, junk, size);
> +	kfree(junk);
> +
> +	return ret;
> +}
> +

[...]

> @@ -1237,6 +1271,11 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
>  	if (ret < 0)
>  		return ret;
>  
> +	ret = restore_slurp_vpids(ctx);

instead:
	ret = ckpt_read_consume(ctx, ..., ...);

[...]

>  struct ckpt_pids {
> +	/* These pids are in the root_nsproxy's pid ns */
>  	__s32 vpid;
>  	__s32 vppid;
>  	__s32 vtgid;
>  	__s32 vpgid;
>  	__s32 vsid;
> +	__s32 rpid;  /* real pid - in checkpointer's pidns */

This comes from an unrelated patch/purpose, right - maybe mention
in the patch description ?

> +	__s32 depth; /* pid depth */
> +} __attribute__((aligned(8)));
> +
> +/* number of vpids */
> +struct ckpt_hdr_vpids {
> +	struct ckpt_hdr h;
> +	__s32 nr_vpids;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_vpid {
> +	__s32 pid;
> +	__s32 pad;

@pad is redundant as last element.

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

This doesn't look healthy.

If it is (or will be) possible for another process to look at the
restarting process, not having a pid-ns may confuse other code in
the kernel ?

>  	}
>   out:
>  	if (ret < 0)

Oren.
