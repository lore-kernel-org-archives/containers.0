From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 6/8] cr: checkpoint and restore task credentials
Date: Wed, 27 May 2009 22:36:10 +0400
Message-ID: <20090527183610.GA31930@x200.localdomain>
References: <20090526173242.GA13757@us.ibm.com> <20090526173354.GF13991@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090526173354.GF13991@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, May 26, 2009 at 12:33:54PM -0500, Serge E. Hallyn wrote:
> +struct ckpt_hdr_cred {
> +	struct ckpt_hdr h;
> +	__u32 version; /* especially since capability sets might grow */

Oh, no. Image version should be incremented.

> +	__u32 uid, suid, euid, fsuid;
> +	__u32 gid, sgid, egid, fsgid;
> +	__u64 cap_i, cap_p, cap_e;
> +	__u64 cap_x;  /* bounding set ('X') */
> +	__s32 user_ref;
> +	__s32 groupinfo_ref;
> +	__u32 padding;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_groupinfo {
> +	struct ckpt_hdr h;
> +	__u32 ngroups;
> +	/*
> +	 * This is followed by ngroups __u32s
> +	 */
> +	__u32 groups[0];
> +} __attribute__((aligned(8)));

> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1871,6 +1871,12 @@ static inline struct user_struct *get_uid(struct user_struct *u)
>  extern void free_uid(struct user_struct *);
>  extern void release_uids(struct user_namespace *ns);
>  
> +#ifdef CONFIG_CHECKPOINT
> +struct ckpt_ctx;
> +int checkpoint_write_user(struct ckpt_ctx *, struct user_struct *);
> +struct user_struct *restore_read_user(struct ckpt_ctx *);
> +#endif

I'll rip credential stuff from sched.h, better not add more.

> --- a/kernel/groups.c
> +++ b/kernel/groups.c
> @@ -287,3 +288,58 @@ int in_egroup_p(gid_t grp)
>  }
>  
>  EXPORT_SYMBOL(in_egroup_p);
> +
> +#ifdef CONFIG_CHECKPOINT
> +int checkpoint_write_groupinfo(struct ckpt_ctx *ctx, struct group_info *g)
> +{
> +	int ret, i, size;
> +	struct ckpt_hdr_groupinfo *h;
> +
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
> +
> +/*
> + * TODO - switch to reading in blocks, and only return an
> + * error for truly obscene # groups (like 10000)
> + */
> +#define CKPT_MAXGROUPS 100
> +#define MAX_GROUPINFO_SIZE (sizeof(*h)+CKPT_MAXGROUPS*sizeof(gid_t))
> +struct group_info *restore_read_groupinfo(struct ckpt_ctx *ctx)
> +{
> +	struct group_info *g;
> +	struct ckpt_hdr_groupinfo *h;
> +	int i;
> +
> +	h = ckpt_read_buf_type(ctx, MAX_GROUPINFO_SIZE, CKPT_HDR_GROUPINFO);
> +	if (IS_ERR(h))
> +		return ERR_PTR(PTR_ERR(h));
> +	if (h->ngroups > CKPT_MAXGROUPS) {
> +		g = ERR_PTR(-EINVAL);
> +		goto out;
> +	}
> +	g = groups_alloc(h->ngroups);
> +	if (!g) {
> +		g = ERR_PTR(-ENOMEM);
> +		goto out;
> +	}
> +	for (i = 0; i < h->ngroups; i++)
> +		GROUP_AT(g, i) = h->groups[i];
> +
> +out:
> +	ckpt_hdr_put(ctx, h);
> +	return g;
> +}

No checks, that groups in image are a) sorted, b) ->ngroups is compatible
with object image.
