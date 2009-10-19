From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/4] cr: add generic LSM c/r support (v6)
Date: Mon, 19 Oct 2009 14:13:47 -0400
Message-ID: <4ADCAC5B.9080205@librato.com>
References: <20091019144315.GA30535@us.ibm.com>
	<20091019144341.GA30566@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091019144341.GA30566-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
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

> 	oct 19: At checkpoint, we insert the void* security into the
> 		objhash.  The first time that we do so, we next write out
> 		the string representation of the context to the checkpoint
> 		image, along with the value of the objref for the void*
> 		security, and insert that into the objhash.  Then at
> 		restart, when we read a LSM context, we read the objref
> 		which the void* security had at checkpoint, and we then
> 		insert the string context with that objref as well.

I hoped to see similar comment inlined in the code.

[...]

> @@ -159,8 +175,12 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
>  	if (h->f_credref < 0)
>  		return h->f_credref;
>  
> -	ckpt_debug("file %s credref %d", file->f_dentry->d_name.name,
> -		h->f_credref);
> +	ret = checkpoint_file_security(ctx, file, &h->f_secref);
> +	if (ret < 0)
> +		return ret;

How about a ckpt_write_err() here, or in checkpoint_file_security(),
or in security_checkpoint_obj(), or all of the above.

> +
> +	ckpt_debug("file %s credref %d secref %d\n",
> +		file->f_dentry->d_name.name, h->f_credref, h->f_secref);

[...]

> @@ -433,6 +464,22 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.checkpoint = checkpoint_tty,
>  		.restore = restore_tty,
>  	},
> +	/* LSM void *security on objhash - at checkpoint */
> +	{
> +		.obj_name = "SECURITY PTR",
> +		.obj_type = CKPT_OBJ_SECURITY_PTR,
> +		.ref_drop = obj_no_drop,
> +		.ref_grab = obj_no_grab,
> +	},

I really wish there was a comment explaining why it's ok to not
drop/grab the reference (because the security is always referenced
by an object that is itself grabbed, e.g. file, ipc etc ?).

> +	/* LSM security strings - at restart */
> +	{
> +		.obj_name = "SECURITY STRING",
> +		.obj_type = CKPT_OBJ_SECURITY,
> +		.ref_grab = lsm_string_grab,
> +		.ref_drop = lsm_string_drop,
> +		.checkpoint = checkpoint_lsm_string,
> +		.restore = restore_lsm_string_wrap,
> +	},
>  };

[...]

> @@ -376,6 +383,16 @@ struct ckpt_hdr_groupinfo {
>  	__u32 groups[0];
>  } __attribute__((aligned(8)));
>  
> +struct ckpt_hdr_lsm {
> +	struct ckpt_hdr h;
> +	__s32 ptrref;
> +	__u8 sectype;
> +	__u8 padding;

I don't think padding is necessary here...

> +	/*
> +	 * This is followed by a string of size len+1,
> +	 * null-terminated
> +	 */
> +} __attribute__((aligned(8)));

[...]

> +/**
> + * security_checkpoint_obj - if first checkpoint of this void* security,
> + * then 1. ask the LSM for a string representing the context, 2. checkpoint
> + * that string
> + * @ctx: the checkpoint context
> + * @security: the void* security being checkpointed
> + * @sectype: indicates the type of object, because LSMs can (and do) store
> + * @secref: We return the objref here
> + * different types of data for different types of objects.
> + *
> + * Returns the objref of the checkpointed ckpt_lsm_string representing the
> + * context, or -error on error.
> + *
> + * This is only used at checkpoint of course.
> + */
> +int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
> +				int sectype, int *secref)

This function returns 0 for success or a negative error. It should
return the @secref instead of passing it by reference (see your
description of the return value above !)

[...]

> +	/* Ask the LSM to apply a void*security to the object
> +	 * based on the checkpointed context string */
> +	switch (sectype) {
> +	case CKPT_SECURITY_IPC:
> +		ret = security_ipc_restore(v, l->string);

Nit: I know it's not strictly necessary, but adding an explicit
type conversion here and in the other three seems cleaner

> +		break;
> +	case CKPT_SECURITY_MSG_MSG:
> +		ret = security_msg_msg_restore(v, l->string);
> +		break;
> +	case CKPT_SECURITY_FILE:
> +		ret = security_file_restore(v, l->string);
> +		break;
> +	case CKPT_SECURITY_CRED:
> +		ret = security_cred_restore(ctx->file, v, l->string);
> +		break;
> +	default:
> +		ret = -EINVAL;
> +	}
> +	if (ret)
> +		ckpt_debug("sectype %d objref %d lsm's hook returned %d\n",
> +			   sectype, secref, ret);
> +	if (ret == -EOPNOTSUPP)
> +		ret = 0;

If you silently ignore EOPNOTSUPP, how can a user tell if a restarted
succeeded fully or by silently skipping the security part ?

Should the user approve this behavior (e.g. RESTART_SECURITY_LAX...) ?

Also, I suggest the s/EOPNOTSUPP/ENOSYS/ all over the patch.

> +
> +	return ret;
> +}
> +#endif

Oren.
