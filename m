From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] cr: add generic LSM c/r support (v6)
Date: Mon, 19 Oct 2009 14:02:27 -0500
Message-ID: <20091019190227.GA7201@us.ibm.com>
References: <20091019144315.GA30535@us.ibm.com>
	<20091019144341.GA30566@us.ibm.com> <4ADCAC5B.9080205@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ADCAC5B.9080205-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> > 	oct 19: At checkpoint, we insert the void* security into the
> > 		objhash.  The first time that we do so, we next write out
> > 		the string representation of the context to the checkpoint
> > 		image, along with the value of the objref for the void*
> > 		security, and insert that into the objhash.  Then at
> > 		restart, when we read a LSM context, we read the objref
> > 		which the void* security had at checkpoint, and we then
> > 		insert the string context with that objref as well.
> 
> I hoped to see similar comment inlined in the code.

If we're happy with this approach, then I will add good comments above
security_checkpoint_obj and security_restore_obj, and above the objhash
entries.

> [...]
> 
> > @@ -159,8 +175,12 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
> >  	if (h->f_credref < 0)
> >  		return h->f_credref;
> >  
> > -	ckpt_debug("file %s credref %d", file->f_dentry->d_name.name,
> > -		h->f_credref);
> > +	ret = checkpoint_file_security(ctx, file, &h->f_secref);
> > +	if (ret < 0)
> > +		return ret;
> 
> How about a ckpt_write_err() here, or in checkpoint_file_security(),
> or in security_checkpoint_obj(), or all of the above.

Yeah, definately, at each of the checkpoint failures I add.

> > +
> > +	ckpt_debug("file %s credref %d secref %d\n",
> > +		file->f_dentry->d_name.name, h->f_credref, h->f_secref);
> 
> [...]
> 
> > @@ -433,6 +464,22 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
> >  		.checkpoint = checkpoint_tty,
> >  		.restore = restore_tty,
> >  	},
> > +	/* LSM void *security on objhash - at checkpoint */
> > +	{
> > +		.obj_name = "SECURITY PTR",
> > +		.obj_type = CKPT_OBJ_SECURITY_PTR,
> > +		.ref_drop = obj_no_drop,
> > +		.ref_grab = obj_no_grab,
> > +	},
> 
> I really wish there was a comment explaining why it's ok to not
> drop/grab the reference (because the security is always referenced
> by an object that is itself grabbed, e.g. file, ipc etc ?).

Yes.

> > +	/* LSM security strings - at restart */
> > +	{
> > +		.obj_name = "SECURITY STRING",
> > +		.obj_type = CKPT_OBJ_SECURITY,
> > +		.ref_grab = lsm_string_grab,
> > +		.ref_drop = lsm_string_drop,
> > +		.checkpoint = checkpoint_lsm_string,
> > +		.restore = restore_lsm_string_wrap,
> > +	},
> >  };
> 
> [...]
> 
> > @@ -376,6 +383,16 @@ struct ckpt_hdr_groupinfo {
> >  	__u32 groups[0];
> >  } __attribute__((aligned(8)));
> >  
> > +struct ckpt_hdr_lsm {
> > +	struct ckpt_hdr h;
> > +	__s32 ptrref;
> > +	__u8 sectype;
> > +	__u8 padding;
> 
> I don't think padding is necessary here...

Ok, I'll take it out.

> > +	/*
> > +	 * This is followed by a string of size len+1,
> > +	 * null-terminated
> > +	 */
> > +} __attribute__((aligned(8)));
> 
> [...]
> 
> > +/**
> > + * security_checkpoint_obj - if first checkpoint of this void* security,
> > + * then 1. ask the LSM for a string representing the context, 2. checkpoint
> > + * that string
> > + * @ctx: the checkpoint context
> > + * @security: the void* security being checkpointed
> > + * @sectype: indicates the type of object, because LSMs can (and do) store
> > + * @secref: We return the objref here
> > + * different types of data for different types of objects.
> > + *
> > + * Returns the objref of the checkpointed ckpt_lsm_string representing the
> > + * context, or -error on error.
> > + *
> > + * This is only used at checkpoint of course.
> > + */
> > +int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
> > +				int sectype, int *secref)
> 
> This function returns 0 for success or a negative error. It should
> return the @secref instead of passing it by reference (see your
> description of the return value above !)
> 
> [...]

Yes the comment is out of date but the API is imo an improvement.
Note that SECURITY_CTX_NONE, -1, is a meaningful secref, and at
the sametime -EPERM, -1, is conceivably a valid error code (though
at the moment no lsm will return it).

So I think overloading the secref with error codes is wrong here.

> > +	/* Ask the LSM to apply a void*security to the object
> > +	 * based on the checkpointed context string */
> > +	switch (sectype) {
> > +	case CKPT_SECURITY_IPC:
> > +		ret = security_ipc_restore(v, l->string);
> 
> Nit: I know it's not strictly necessary, but adding an explicit
> type conversion here and in the other three seems cleaner

Hmm, it'll make some lines wrap making it harder to read, so it
was a tossup.  But ok I'll change it.

> > +		break;
> > +	case CKPT_SECURITY_MSG_MSG:
> > +		ret = security_msg_msg_restore(v, l->string);
> > +		break;
> > +	case CKPT_SECURITY_FILE:
> > +		ret = security_file_restore(v, l->string);
> > +		break;
> > +	case CKPT_SECURITY_CRED:
> > +		ret = security_cred_restore(ctx->file, v, l->string);
> > +		break;
> > +	default:
> > +		ret = -EINVAL;
> > +	}
> > +	if (ret)
> > +		ckpt_debug("sectype %d objref %d lsm's hook returned %d\n",
> > +			   sectype, secref, ret);
> > +	if (ret == -EOPNOTSUPP)
> > +		ret = 0;
> 
> If you silently ignore EOPNOTSUPP, how can a user tell if a restarted
> succeeded fully or by silently skipping the security part ?

Actually I agree, EOPNOTSUPP (or ENOSYS) with RESTART_KEEP_LSM should
just return failure.

> Should the user approve this behavior (e.g. RESTART_SECURITY_LAX...) ?
> 
> Also, I suggest the s/EOPNOTSUPP/ENOSYS/ all over the patch.

thanks,
-serge
