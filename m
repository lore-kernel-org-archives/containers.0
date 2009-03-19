From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Thu, 19 Mar 2009 18:28:02 -0400
Message-ID: <49C2C6F2.7060403@cs.columbia.edu>
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
> 
> I tested this with single and multiple task restore, on top of Oren's
> v13 tree.
> 
> Changes:
>   - Remove the kernel restore path
>   - Punt on nested namespaces
>   - Use __NEW_UTS_LEN in nodename and domainname buffers
>   - Add a note to Documentation/checkpoint/internals.txt to indicate where
>     in the save/restore process the UTS information is kept
>   - Store (and track) the objref of the namespace itself instead of the
>     nsproxy (based on comments from Dave on IRC)
>   - Remove explicit check for non-root nsproxy
>   - Store the nodename and domainname lengths and use cr_write_string()
>     to store the actual name strings
> 

[...]

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
> +
> +	hh->types = 0;
> +
> +	if (cr_obj_add_ptr(ctx, nsp->uts_ns, &hh->uts_ref, CR_OBJ_UTSNS, 0))
> +		hh->types |= CR_NS_UTS;

cr_obj_add_ptr() may fail with an error (e.g. -ENOMEM).

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

[...]

Oren.
