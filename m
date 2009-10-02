From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/3] cr: add selinux support (v4)
Date: Fri, 2 Oct 2009 17:05:56 -0500
Message-ID: <20091002220556.GB7446@us.ibm.com>
References: <20091002034916.GA16871@us.ibm.com> <20091002035250.GC16920@us.ibm.com> <4AC66D47.5050305@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AC66D47.5050305@librato.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@librato.com>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, Stephen Smalley <sds@epoch.ncsc.mil>, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@librato.com):
> 
> Serge E. Hallyn wrote:
> > diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> > index 55bd2b5..008a116 100644
> > --- a/checkpoint/restart.c
> > +++ b/checkpoint/restart.c
> > @@ -471,6 +471,7 @@ static int restore_read_header(struct ckpt_ctx *ctx)
> >  		/* to be implemented later, per-lsm */
> >  		if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
> >  				strcmp(ctx->lsm_name, "smack") != 0 &&
> > +				strcmp(ctx->lsm_name, "selinux") != 0 &&
> >  				strcmp(ctx->lsm_name, "default") != 0) {
> 
> If we expect this to grow, it may make sense to look it up in an
> array.

We don't  :)  The only other LSM in the kernel right now is TOMOYO.

> >  			pr_warning("c/r: RESTART_KEEP_LSM unsupported for %s\n",
> >  					ctx->lsm_name);
> > diff --git a/kernel/cred.c b/kernel/cred.c
> > index 06bc676..5eb09b8 100644
> > --- a/kernel/cred.c
> > +++ b/kernel/cred.c
> > @@ -732,6 +732,8 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
> >  	if (!h)
> >  		return -ENOMEM;
> >  
> > +	ckpt_debug("cred uid %d fsuid %d gid %d secref %d\n", cred->uid,
> > +		cred->fsuid, cred->gid, sec_ref);
> 
> Please place this (and a few others also in other patches) debug-only
> changes in a separate patch - it will make my life tremendously easier
> when merging v18-dev to a nice and clean v19.

Ok, I'll resend those just to containers@ to spare the lsm folks.

> [...]
> 
> > +static inline char *selinux_file_checkpoint(void *security)
> > +{
> > +	struct file_security_struct *fsec = security;
> > +	char *s1 = NULL, *s2 = NULL, *sfull;
> > +	__u32 len1, len2, lenfull;
> > +	int ret;
> > +
> > +	if (fsec->sid == 0 || fsec->fown_sid == 0)
> > +		return ERR_PTR(-EINVAL);
> > +
> > +	ret = security_sid_to_context(fsec->sid, &s1, &len1);
> > +	if (ret)
> > +		return ERR_PTR(ret);
> > +	len1--;
> > +	ret = security_sid_to_context(fsec->fown_sid, &s2, &len2);
> > +	if (ret) {
> > +		kfree(s1);
> > +		return ERR_PTR(ret);
> > +	}
> > +	len2--;
> > +	lenfull = len1+len2+3;
> 
> Would checkpatch.pl complain about no spaces here ?

Hmm, it doesn't, actually... you'd think it should!  I'll change
that in the split-up version I'll send in a bit.

thanks,
-serge
