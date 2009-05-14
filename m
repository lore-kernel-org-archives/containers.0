From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/5] cr: checkpoint and restore task credentials
Date: Thu, 14 May 2009 12:18:50 +0400
Message-ID: <20090514081850.GA21115@x200.localdomain>
References: <20090511160424.GA12234@us.ibm.com>
	<20090511160539.GD12286@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090511160539.GD12286-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, May 11, 2009 at 11:05:39AM -0500, Serge E. Hallyn wrote:
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> +#define CKPT_MAXGROUPS 15
> +#define MAX_GROUPINFO_SIZE (sizeof(*h)+CKPT_MAXGROUPS*sizeof(gid_t))
> +/* move this fn into kernel/sys.c next to group functions? */
> +static int checkpoint_write_groupinfo(struct ckpt_ctx *ctx,
> +					struct group_info *g)
> +{
> +	int ret, i, size;
> +	struct ckpt_hdr_groupinfo *h;
> +
> +	if (g->ngroups > CKPT_MAXGROUPS) {
> +		ckpt_debug("Too many groups: %d  (max is %d)\n",
> +			g->ngroups, CKPT_MAXGROUPS);
> +		return -E2BIG;
> +	}

Ooh, a hack :-)

> +	size = sizeof(*h) + g->ngroups * sizeof(__u32);
> +	h = ckpt_hdr_get_type(ctx, size, CKPT_HDR_GROUPINFO);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->ngroups = g->ngroups;
> +	for (i = 0; i < g->ngroups; i++)
> +		h->groups[i] = GROUP_AT(g, i);
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}

> +/*
> + * write the user struct
> + * TODO keyring will need to be dumped
> + */
> +#define UNSAVED_NS_MAX 5

Another hack :-)

This is an invitation to discuss what to do with references to future,
especially given that object image can be variable-size _and_
streamability on dump.

In case of user->user_ns->creator, we can avoid the issue and dump creator
first.
