From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 6/8] cr: checkpoint and restore task credentials
Date: Thu, 28 May 2009 09:01:10 -0500
Message-ID: <20090528140110.GA772@hallyn.com>
References: <20090526173242.GA13757@us.ibm.com> <20090526173354.GF13991@us.ibm.com> <20090527183610.GA31930@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090527183610.GA31930@x200.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan@gmail.com):
> On Tue, May 26, 2009 at 12:33:54PM -0500, Serge E. Hallyn wrote:
> > +struct ckpt_hdr_cred {
> > +	struct ckpt_hdr h;
> > +	__u32 version; /* especially since capability sets might grow */
> 
> Oh, no. Image version should be incremented.

Why?  The format hasn't changed since my last set I don't think...

Oh, I added the padding.  Thanks.  I have to bump it again for the
next set (hopefully out today or tomorrow) as it adds securebits.
(And hopefully a first stab at LSM, though it's not looking
likely)

> > +	__u32 uid, suid, euid, fsuid;
> > +	__u32 gid, sgid, egid, fsgid;
> > +	__u64 cap_i, cap_p, cap_e;
> > +	__u64 cap_x;  /* bounding set ('X') */
> > +	__s32 user_ref;
> > +	__s32 groupinfo_ref;
> > +	__u32 padding;
> > +} __attribute__((aligned(8)));
> > +
> > +struct ckpt_hdr_groupinfo {
> > +	struct ckpt_hdr h;
> > +	__u32 ngroups;
> > +	/*
> > +	 * This is followed by ngroups __u32s
> > +	 */
> > +	__u32 groups[0];
> > +} __attribute__((aligned(8)));
> 
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1871,6 +1871,12 @@ static inline struct user_struct *get_uid(struct user_struct *u)
> >  extern void free_uid(struct user_struct *);
> >  extern void release_uids(struct user_namespace *ns);
> >  
> > +#ifdef CONFIG_CHECKPOINT
> > +struct ckpt_ctx;
> > +int checkpoint_write_user(struct ckpt_ctx *, struct user_struct *);
> > +struct user_struct *restore_read_user(struct ckpt_ctx *);
> > +#endif
> 
> I'll rip credential stuff from sched.h, better not add more.

Yeah I'll move this in cred.h.

...

> > +#define CKPT_MAXGROUPS 100
> > +#define MAX_GROUPINFO_SIZE (sizeof(*h)+CKPT_MAXGROUPS*sizeof(gid_t))
> > +struct group_info *restore_read_groupinfo(struct ckpt_ctx *ctx)
> > +{
> > +	struct group_info *g;
> > +	struct ckpt_hdr_groupinfo *h;
> > +	int i;
> > +
> > +	h = ckpt_read_buf_type(ctx, MAX_GROUPINFO_SIZE, CKPT_HDR_GROUPINFO);
> > +	if (IS_ERR(h))
> > +		return ERR_PTR(PTR_ERR(h));
> > +	if (h->ngroups > CKPT_MAXGROUPS) {
> > +		g = ERR_PTR(-EINVAL);
> > +		goto out;
> > +	}
> > +	g = groups_alloc(h->ngroups);
> > +	if (!g) {
> > +		g = ERR_PTR(-ENOMEM);
> > +		goto out;
> > +	}
> > +	for (i = 0; i < h->ngroups; i++)
> > +		GROUP_AT(g, i) = h->groups[i];
> > +
> > +out:
> > +	ckpt_hdr_put(ctx, h);
> > +	return g;
> > +}
> 
> No checks, that groups in image are a) sorted, b) ->ngroups is compatible
> with object image.

Thanks, will fix.

So I'd like to suggest that we take the pieces that we can both use
(the code in groups.c, cred.c, security/security.c, and capabilities)
and get it identical between both versions.  But we would need to
find a way to ignore API differences for reading and writing the
checkpoint file.

BTW I have some credentials (users, user namespaces, and securebits)
testcases under cr_tests/userns/ in git://git.sr71.net/~hallyn/cr_tests.git.
Maybe you can reuse some of that for your own testing.

thanks,
-serge
