From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/3] cr: add generic LSM c/r support (v4)
Date: Fri, 2 Oct 2009 17:13:49 -0500
Message-ID: <20091002221349.GC7446@us.ibm.com>
References: <20091002034916.GA16871@us.ibm.com> <4AC6694F.3050509@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AC6694F.3050509@librato.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@librato.com>
Cc: Linux Containers <containers@lists.osdl.org>, Casey Schaufler <casey@schaufler-ca.com>, linux-security-module@vger.kernel.org, Stephen Smalley <sds@epoch.ncsc.mil>, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@librato.com):
> 
> 
> Serge E. Hallyn wrote:
> > (wasn't versioning the patchsets before, so randomly pick 4 as
> > the version for this patchset...)
> > 
> > Documentation/checkpoint/readme.txt begins:
> > """
> > Application checkpoint/restart is the ability to save the state
> > of a running application so that it can later resume its execution
> > from the time at which it was checkpointed.
> > """
> > 
> 
> [...]
> 
> >  Kernel interfaces
> >  =================
> > diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> > index 1eeb557..6722035 100644
> > --- a/checkpoint/checkpoint.c
> > +++ b/checkpoint/checkpoint.c
> > @@ -25,6 +25,7 @@
> >  #include <linux/magic.h>
> >  #include <linux/hrtimer.h>
> >  #include <linux/deferqueue.h>
> > +#include <linux/security.h>
> >  #include <linux/checkpoint.h>
> >  #include <linux/checkpoint_hdr.h>
> >  
> > @@ -351,6 +352,16 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
> >  	if (ret < 0)
> >  		return ret;
> >  
> > +	memset(ctx->lsm_name, 0, SECURITY_NAME_MAX + 1);
> > +	strlcpy(ctx->lsm_name, security_get_lsm_name(), SECURITY_NAME_MAX + 1);
> > +	ret = ckpt_write_buffer(ctx, ctx->lsm_name, SECURITY_NAME_MAX + 1);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	ret = security_checkpoint_header(ctx);
> > +	if (ret < 0)
> > +		return ret;
> > +
> 
> This is actually a case for a 'container-global' section that would
> appear after the header and before the rest of the image. (Would be
> useful also for network namespaces).

But LSM's are specifically not containerized, so this is a host
property, not a container one.

> >  	return checkpoint_write_header_arch(ctx);
> >  }
> >  
> > diff --git a/checkpoint/files.c b/checkpoint/files.c
> > index 27e29a0..570facb 100644
> > --- a/checkpoint/files.c
> > +++ b/checkpoint/files.c
> > @@ -145,6 +145,19 @@ static int scan_fds(struct files_struct *files, int **fdtable)
> >  	return n;
> >  }
> >  
> > +#ifdef CONFIG_SECURITY
> > +int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
> > +{
> > +	return security_checkpoint_obj(ctx, file->f_security,
> > +					CKPT_SECURITY_FILE);
> > +}
> > +#else
> > +int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
> > +{
> > +	return -EOPNOTSUPP;
> > +}
> > +#endif
> > +
> >  int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
> >  			   struct ckpt_hdr_file *h)
> >  {
> > @@ -159,6 +172,16 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
> >  	if (h->f_credref < 0)
> >  		return h->f_credref;
> >  
> > +	h->f_secref = checkpoint_file_security(ctx, file);
> > +	if (h->f_secref == -EOPNOTSUPP)
> > +		h->f_secref = -1;
> 
> #define CKPT_SECURITY_NONE  -1     ??

Yeah, that'd be cleaner.

> > +	else if (h->f_secref < 0)
> > +		return h->f_secref;
> 
> [...]
> 
> > +
> > +static int do_checkpoint_security(struct ckpt_ctx *ctx,
> > +				const struct ckpt_stored_lsm *l)
> > +{
> > +	int ret, len;
> > +	struct ckpt_hdr_lsm *h;
> > +
> > +	len = strlen(l->string);
> > +	if (len > PAGE_SIZE - sizeof(*h))
> > +		return -E2BIG;
> 
> A call to ckpt_write_err() here may be useful.

ok

> > +	h = ckpt_hdr_get_type(ctx, sizeof(*h)+len+1, CKPT_HDR_SEC);
> > +	if (!h)
> > +		return -ENOMEM;
> > +	h->len = len;
> > +	h->sectype = l->sectype;
> > +	strncpy(h->string, l->string, len);
> > +	h->string[len] = '\0';
> > +	ret = ckpt_write_obj(ctx, &h->h);
> > +	ckpt_hdr_put(ctx, h);
> > +	return ret;
> > +}
> > +
> > +static int checkpoint_security(struct ckpt_ctx *ctx, void *ptr)
> > +{
> > +	return do_checkpoint_security(ctx, (struct ckpt_stored_lsm *) ptr);
> > +}
> > +
> > +static struct ckpt_stored_lsm *do_restore_security(struct ckpt_ctx *ctx)
> > +{
> > +	struct ckpt_hdr_lsm *h;
> > +	struct ckpt_stored_lsm *l;
> > +
> > +	h = ckpt_read_buf_type(ctx, PAGE_SIZE, CKPT_HDR_SEC);
> > +	if (IS_ERR(h))
> > +		return (struct ckpt_stored_lsm *)h;
> > +	if (h->len > h->h.len - sizeof(struct ckpt_hdr) ||
> > +				h->len > PAGE_SIZE) {
> 
> The second test (for h->len > PAGE_SIZE) is unnecessary - already
> done in ckpt_read_buf_type()

Huh.  I had no idea :)

> > +		ckpt_hdr_put(ctx, h);
> > +		return ERR_PTR(-EINVAL);
> > +	}
> > +	l = kzalloc(sizeof(*l), GFP_KERNEL);
> > +	if (!l) {
> > +		ckpt_hdr_put(ctx, h);
> > +		return ERR_PTR(-ENOMEM);
> 
> Nit: this part is common... set ret = -ENOMEM and use goto ?

ok

> [...]
> 
> > @@ -608,14 +613,21 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
> >  	 * referenced. See comment in checkpoint_task_objs.
> >  	 */
> >  	ret = restore_task_creds(ctx);
> > -	if (!ret)
> > -		ret = restore_task_ns(ctx);
> > -	if (ret < 0)
> > +	if (ret) {
> 
> Nit: (ret < 0) helps (me) read it.

Really?  Whenever I review something like that it forces me to
go through and make sure no >0 codes will be returned for failure...
But ok.

> > +		ckpt_debug("restore_task_creds returned %d", ret);
> > +		return ret;
> > +	}
> > +	ret = restore_task_ns(ctx);
> > +	if (ret) {
> > +		ckpt_debug("restore_task_ns returned %d", ret);
> >  		return ret;
> > +	}
> >  
> >  	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
> > -	if (IS_ERR(h))
> > +	if (IS_ERR(h)) {
> > +		ckpt_debug("Error fetching task obj");
> >  		return PTR_ERR(h);
> > +	}
> >  
> >  	ret = restore_obj_file_table(ctx, h->files_objref);
> >  	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
> > diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> > index b12c8bd..bba2b45 100644
> > --- a/checkpoint/restart.c
> > +++ b/checkpoint/restart.c
> > @@ -457,6 +457,31 @@ static int restore_read_header(struct ckpt_ctx *ctx)
> >  	if (ret < 0)
> >  		goto out;
> >  
> > +	ret = _ckpt_read_buffer(ctx, ctx->lsm_name, SECURITY_NAME_MAX + 1);
> > +	if (ret < 0)
> > +		goto out;
> > +	if (ctx->uflags & RESTART_KEEP_LSM) {
> > +		char *cur = security_get_lsm_name();
> > +		if (strncmp(cur, ctx->lsm_name, SECURITY_NAME_MAX + 1) != 0) {
> > +			pr_warning("c/r: checkpointed LSM %s, current is %s.\n",
> > +				ctx->lsm_name, cur);
> > +			ret = -EINVAL;
> 
> EPERM ?

Hmm...   I think of this not as "you're not allowed" but rather "it doesn't
make sense."

> [...]
> 
> > @@ -277,6 +283,16 @@ struct ckpt_hdr_groupinfo {
> >  	__u32 groups[0];
> >  } __attribute__((aligned(8)));
> >  
> > +struct ckpt_hdr_lsm {
> > +	struct ckpt_hdr h;
> > +	__u8 sectype;
> > +	__u16 len;
> 
> Alignment ...
> 
> > +	/*
> > +	 * This is followed by a string of size len+1,
> > +	 * null-terminated
> > +	 */
> > +	__u8 string[0];
> > +} __attribute__((aligned(8)));
> >  /*
> >   * todo - keyrings and LSM
> >   * These may be better done with userspace help though
> > @@ -392,6 +408,8 @@ struct ckpt_hdr_file {
> >  	__s32 f_credref;
> >  	__u64 f_pos;
> >  	__u64 f_version;
> > +	__s32 f_secref;
> > +	__u32 f_padding;
> 
> No need for padding here.
> 
> >  } __attribute__((aligned(8)));
> >  
> >  struct ckpt_hdr_file_generic {
> > @@ -634,6 +652,8 @@ struct ckpt_hdr_ipc_perms {
> >  	__u32 mode;
> >  	__u32 _padding;
> >  	__u64 seq;
> > +	__s32 sec_ref;
> > +	__u32 padding;
> 
> Ditto.
> 
> [...]
> 
> > @@ -224,6 +234,16 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
> >  	msg->next = NULL;
> >  	pseg = &msg->next;
> >  
> > +	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->sec_ref != -1)) {
> > +		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->sec_ref,
> > +					CKPT_OBJ_SEC);
> > +		if (IS_ERR(l))
> > +			return (struct msg_msg *)l;
> 
> That's a leak. Need to 'goto out' instead.

ok

> > +		ret = security_msg_msg_restore(msg, l->string);
> > +		if (ret)
> > +			return ERR_PTR(ret);
> 
> Here too.
> 
> [...]
> 
> > @@ -806,6 +815,15 @@ static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
> >  	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
> >  	if (oldgid != h->fsgid && ret < 0)
> >  		goto err_putcred;
> > +	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->sec_ref != -1)) {
> > +		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->sec_ref,
> > +					CKPT_OBJ_SEC);
> > +		if (IS_ERR(l))
> > +			return (struct cred *)l;
> 
> And here too ?
> 
> > +/**
> > + * security_checkpoint_obj - if first checkpoint of this void* security,
> > + * then 1. ask the LSM for a string representing the context, 2. checkpoint
> > + * that string
> > + * @ctx: the checkpoint context
> > + * @security: the void* security being checkpointed
> > + * @sectype: indicates the type of object, because LSMs can (and do) store
> > + * different types of data for different types of objects.
> > + *
> > + * Returns the objref of the checkpointed ckpt_stored_lsm representing the
> > + * context, or -error on error.
> > + *
> > + * This is only used at checkpoint of course.
> > + */
> > +int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
> > +				unsigned sectype)
> > +{
> > +	int strref;
> > +	struct ckpt_stored_lsm *l;
> > +	char *str;
> > +	int len;
> > +
> > +	/*
> > +	 * to simplify the LSM code, short-cut a null security
> > +	 * here.
> > +	 */
> > +	if (!security)
> > +		return -EOPNOTSUPP;
> > +
> > +	switch (sectype) {
> > +	case CKPT_SECURITY_MSG_MSG:
> > +		str = security_msg_msg_checkpoint(security);
> > +		break;
> > +	case CKPT_SECURITY_IPC:
> > +		str = security_ipc_checkpoint(security);
> > +		break;
> > +	case CKPT_SECURITY_FILE:
> > +		str = security_file_checkpoint(security);
> > +		break;
> > +	case CKPT_SECURITY_CRED:
> > +		str = security_cred_checkpoint(security);
> > +		break;
> > +	default:
> > +		str = ERR_PTR(-EINVAL);
> > +		break;
> > +	}
> > +	/* str will be alloc'ed for us by the LSM.  We will free it when
> > +	 * we clear out our hashtable */
> > +	if (IS_ERR(str))
> > +		return PTR_ERR(str);
> > +
> > +	len = strlen(str);
> > +	l = kzalloc(sizeof(*l) + len + 1, GFP_KERNEL);
> 
> Probably a dumb question: why do you allocate with the size of
> the string when it merely points to the string ?

No just dumb code - I used to strcpy it in but don't anymore.

> > +	if (!l) {
> > +		kfree(str);
> > +		return -ENOMEM;
> > +	}
> > +	kref_init(&l->kref);
> > +	l->sectype = sectype;
> > +	l->string = str;
> > +
> > +	strref = checkpoint_obj(ctx, l, CKPT_OBJ_SEC);
> > +	/* do we need to free l if strref was err? */
> > +	return strref;
> > +}
> > +
> > +#endif
> 
> Oren.

Thanks!  Will send a new version.

-serge
