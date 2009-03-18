From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v3)
Date: Wed, 18 Mar 2009 05:22:43 -0400
Message-ID: <49C0BD63.7000309@cs.columbia.edu>
References: <1237306139-23075-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237306139-23075-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> namespaces the task(s) may have.  Do this by tracking the nsproxy of the
> first task and making sure that the tasks that follow get hooked back to
> share the same one on restart.
> 
> Restart is handled in userspace by reading the UTS record(s), calling
> unshare() and setting the hostname accordingly.  See my changes to
> mktree.c for details.
> 
> I tested this with single and multiple task restore, on top of Oren's
> v13 tree.

Thanks, Dan.

[..]

> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 64155de..12eb1d5 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -193,6 +193,82 @@ static int cr_write_tail(struct cr_ctx *ctx)
>  	return ret;
>  }
>  
> +static int cr_write_ns_uts(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_utsns *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct new_utsname *n = &t->nsproxy->uts_ns->name;
> +	int ret;
> +
> +	h.type = CR_HDR_UTSNS;
> +	h.len = sizeof(*hh);
> +	h.parent = 0;
> +
> +	memcpy(hh->nodename, n->nodename, sizeof(n->nodename));
> +	memcpy(hh->domainname, n->domainname, sizeof(n->domainname));
> +

The length of ->nodename etc may change in the future. It's probably
safer to also add the length of the field as well (see for instance
how task->comm is saved).

> +	ret = cr_write_obj(ctx, &h, hh);
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}

[...]

> @@ -156,4 +158,17 @@ struct cr_hdr_fd_data {
>  	__u64 f_version;
>  } __attribute__((aligned(8)));
>  
> +#define CR_NSP_UTS 1
> +
> +struct cr_hdr_nsproxy {
> +	__u32 objref;
> +	__u32 types;
> +};
> +
> +struct cr_hdr_utsns {
> +	/* Both of these fields are defined as 65-chars long */
> +	char nodename[__NEW_UTS_LEN+1];
> +	char domainname[__NEW_UTS_LEN+1];
> +};

add ?
	__u16 nodename_len;
	__u16 domainname_len;

> +
>  #endif /* _CHECKPOINT_CKPT_HDR_H_ */

Oren.
