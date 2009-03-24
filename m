From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Tue, 24 Mar 2009 11:07:54 -0400
Message-ID: <49C8F74A.5000309@cs.columbia.edu>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237402291-28812-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Dan,

You might want to look at ckpt-v14-rc1 which has some cleanups, see below.

Dan Smith wrote:
> This patch adds a "phase" of checkpoint that saves out information about any
> namespaces the task(s) may have.  Do this by tracking the namespace objects
> of the tasks and making sure that tasks with the same namespace that follow
> get properly referenced in the checkpoint stream.  Note that for now, we
> refuse to checkpoint if all tasks in the set don't share the same set of
> *all* namespaces.
> 
> Restart is handled in userspace by reading the UTS record(s), calling
> unshare() and setting the hostname accordingly.  See my changes to
> mktree.c for details.

[...]

> +static int cr_write_ns_uts(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_utsns *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct new_utsname *n = &t->nsproxy->uts_ns->name;
> +	int ret;

Need to test whether cr_hbuf_get() succeeds (while now it's trivial, in
the future it may fail if we change the allocation method).

> +
> +	h.type = CR_HDR_UTSNS;
> +	h.len = sizeof(*hh);
> +	h.parent = 0;

The 'h.parent' fields is gone.

> +
> +	hh->nodename_len = sizeof(n->nodename);
> +	hh->domainname_len = sizeof(n->domainname);
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = cr_write_string(ctx, n->nodename, hh->nodename_len);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = cr_write_string(ctx, n->domainname, hh->domainname_len);
> + out:
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}
> +
> +static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_namespaces *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct nsproxy *nsp = t->nsproxy;
> +	int ret;
> +
> +	h.type = CR_HDR_NS;
> +	h.len = sizeof(*hh);
> +	h.parent = 0;

Here too.

> +
> +	hh->types = 0;
> +
> +	if (cr_obj_add_ptr(ctx, nsp->uts_ns, &hh->uts_ref, CR_OBJ_UTSNS, 0))
> +		hh->types |= CR_NS_UTS;

cr_obj_add_ptr() mail fail, with -ENOMEM for instance.

If we plan to support multiple uts_ns, then it makes sense to save the
'objref' value. If you omit the 'objref' because you assume a single
namespace for all for now, then you may also drop the loop on all tasks
(below), for now.

> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	if (ret)
> +		goto out;
> +
> +	if (hh->types & CR_NS_UTS) {
> +		ret = cr_write_ns_uts(ctx, t);
> +		if (ret < 0)
> +			goto out;
> +
> +		/* FIXME: Write other namespaces here */
> +	}
> + out:
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}
> +
> +static int cr_write_all_namespaces(struct cr_ctx *ctx)
> +{
> +	int n, ret = 0;
> +
> +	for (n = 0; n < ctx->tasks_nr; n++) {
> +		pr_debug("dumping ns for task #%d\n", n);

I changed this back to cr_debug() in response to a comment about pr_fmt.

> +		ret = cr_write_namespaces(ctx, ctx->tasks_arr[n]);
> +		if (ret < 0)
> +			break;
> +	}

I'm still unhappy with this loop. It isn't necessary now, since we assume
and enforce a single, common namespace among all tasks. It is unlikely to
be useful as is in the future because the format is likely to change anyway.
Even in the (userspace) restart part the code to read it is in the global
section as opposed to per task section. Is there any reason to keep it ?

If you are to dump the namespace information of each task, why not add it
to an already existing table of tasks - the pids_arr (cr_hdr_pids) ?

> +
> +	return ret;
> +}
> +

[...]

Oren.
