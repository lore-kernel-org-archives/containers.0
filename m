From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/4] cr: add generic LSM c/r support (v5)
Date: Thu, 15 Oct 2009 10:57:30 -0400
Message-ID: <4AD7385A.8010902@librato.com>
References: <20091009205552.GA5778@us.ibm.com>
	<20091009205626.GA5823@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091009205626.GA5823-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Documentation/checkpoint/readme.txt begins:
> """
> Application checkpoint/restart is the ability to save the state
> of a running application so that it can later resume its execution
> from the time at which it was checkpointed.
> """
> 
> This patch adds generic support for c/r of LSM credentials.  Support
> for Smack and SELinux (and TOMOYO if appropriate) will be added later.
> Capabilities is already supported through generic creds code.
> 
> This patch supports ipc_perm, msg_msg, cred (task) and file ->security
> fields.  Inodes, superblocks, netif, and xfrm currently are restored
> not through sys_restart() but through container creation, and so the
> security fields should be done then as well.  Network should be added
> when network c/r is added.
> 
> Briefly, all security fields must be exported by the LSM as a simple
> null-terminated string.  They are checkpointed through the
> security_checkpoint_obj() helper, because we must pass it an extra
> sectype field.  Splitting SECURITY_OBJ_SEC into one type per object
> type would not work because, in Smack, one void* security is used for
> all object types.  But we must pass the sectype field because in
> SELinux a different type of structure is stashed in each object type.
> 
> The RESTART_KEEP_LSM flag indicates that the LSM should
> attempt to reuse checkpointed security labels.  It is always
> invalid when the LSM at restart differs from that at checkpoint.
> It is currently only usable for capabilities.
> 
> (For capabilities, restart without RESTART_KEEP_LSM is technically
> not implemented.  There actually might be a use case for that,
> but the safety of it is dubious so for now we always re-create
> checkpointed capability sets whether RESTART_KEEP_LSM is
> specified or not)

[...]

Can you please pull this part, which adds a global "container" section
to the checkpoint image, into a separate patch ?

(It will be helpful for folding the patches into ckpt-v19 eventually).

And IIRC, this needs to be accompanied by a user-cr patch, right ?

> diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
> index 571c469..9c6422c 100644
> --- a/Documentation/checkpoint/readme.txt
> +++ b/Documentation/checkpoint/readme.txt
> @@ -161,9 +161,10 @@ in-userspace conversion tools.
>  
>  The general format of the checkpoint image is as follows:
>  1. Image header
> -2. Task hierarchy
> -3. Tasks' state
> -4. Image trailer
> +2. Container configuration
> +3. Task hierarchy
> +4. Tasks' state
> +5. Image trailer
>  
>  The image always begins with a general header that holds a magic
>  number, an architecture identifier (little endian format), a format
> @@ -172,6 +173,11 @@ version number (@rev), followed by information about the kernel
>  checkpoint and the flags given to sys_checkpoint(). This header is
>  followed by an arch-specific header.
>  
> +The container configuration section contains details about the
> +security (LSM) configuration.  Network configuration and
> +container-wide mounts may also go here, so that the userspace
> +restart coordinator can re-create a suitable environment.
> +
>  The task hierarchy comes next so that userspace tools can read it
>  early (even from a stream) and re-create the restarting tasks. This is
>  basically an array of all checkpointed tasks, and their relationships
> @@ -333,6 +339,31 @@ So that's why we don't want CAP_SYS_ADMIN required up-front. That way
>  we will be forced to more carefully review each of those features.
>  However, this can be controlled with a sysctl-variable.

[...]

> +/*
> + * We restore a security label only if
> + * 1. sys_restart specified RESTART_KEEP_LSM
> + * 2. the checkpointed security context was not SECURITY_CTX_NONE
> + */
> +static inline int ckpt_restore_lsm_label(struct ckpt_ctx *ctx, int sec_ref)

Maybe add 'may' somewhere inside tol make it more descriptive ?
(e.g. ckpt_may_restore_lsm_label)

> +{
> +	if ((ctx->uflags & RESTART_KEEP_LSM) && (sec_ref != SECURITY_CTX_NONE))
> +		return 1;
> +	return 0;
> +}
> +

[...]

>  
> +/* stored on hashtable */
> +struct ckpt_stored_lsm {
> +	struct kref kref;
> +	int sectype;
> +	char *string;
> +};

Nit: maybe ckpt_lsm_str(ing) ?

[...]

> +#ifdef CONFIG_CHECKPOINT
> +
> +/**
> + * security_checkpoint_obj - if first checkpoint of this void* security,
> + * then 1. ask the LSM for a string representing the context, 2. checkpoint
> + * that string
> + * @ctx: the checkpoint context
> + * @security: the void* security being checkpointed
> + * @sectype: indicates the type of object, because LSMs can (and do) store
> + * different types of data for different types of objects.
> + *
> + * Returns the objref of the checkpointed ckpt_stored_lsm representing the
> + * context, or -error on error.
> + *
> + * This is only used at checkpoint of course.
> + */
> +int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
> +				unsigned sectype)
> +{
> +	int secref, len, new, ret, fulllen;
> +	char *str;
> +	struct ckpt_hdr_lsm *h;
> +
> +	if (!security)
> +		return -EOPNOTSUPP;
> +
> +	secref = ckpt_obj_lookup_add(ctx, security, CKPT_OBJ_CHECKPOINT_SEC,
> +					&new);
> +	if (!new)
> +		return secref;
> +
> +	ret = ckpt_write_objref(ctx, CKPT_OBJ_SEC, secref);
> +	if (ret < 0)
> +		return ret;
> +
> +	switch (sectype) {
> +	case CKPT_SECURITY_MSG_MSG:
> +		str = security_msg_msg_checkpoint(security);
> +		break;
> +	case CKPT_SECURITY_IPC:
> +		str = security_ipc_checkpoint(security);
> +		break;
> +	case CKPT_SECURITY_FILE:
> +		str = security_file_checkpoint(security);
> +		break;
> +	case CKPT_SECURITY_CRED:
> +		str = security_cred_checkpoint(security);
> +		break;
> +	default:
> +		str = ERR_PTR(-EINVAL);
> +		break;
> +	}

Let me suggest a different scheme (also last night's IRC); I think it's
less hackish and uses better the existing {checkpoint,restore}_obj().

* Define one obj type CKPT_OBJ_SEC_{IPC, MSG_MSG, FILE, CRED}, with
matching c/r functions security_{c,r}_{ipc,msg_msg,file,cred}_obj()

* Define one obj type for the string representation CKPT_OBJ_SEC_STR
with matchin c/r functions security_{c,r}_string_obj()

* The helper will now:

	security_checkpoint_obj()
	{
		switch (type) {
		case CKPT_OBJ_SEC_IPC:
			ret = checkpoint_obj(ctx, sec, CKPT_OBJ_SEC_IPC);
			break;
		case CKPT_OBJ_SEC_CRED:
			ret = checkpoint_obj(ctx, sec, CKPT_OBJ_SEC_CRED);
		...
	}

	security_checkpoint_ipc_obj()
	{
		...
		ckpt_lsm_str = str_from_sec_ipc();   /* like you do now */
		objref = checkpoint_obj(ctx, ckpt_lsm_str, CKPT_OBJ_SEC_STR);
		...
		h->objref = objref;
		ckpt_write_obj();
	}

Perhaps a variation on this where the string is checkpoint_obj()'ed
first would also work.

I haven't looked at all the details, but I hope something along these
lines would help untangle the current mess.

Oren.
