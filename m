From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: pin down modules registered to obj-ops
Date: Thu, 29 Apr 2010 23:34:32 -0500
Message-ID: <20100430043432.GA15098@hallyn.com>
References: <1272580878-7268-1-git-send-email-orenl@cs.columbia.edu>
	<20100429231121.GA3862@us.ibm.com>
	<4BDA5DDA.3010701@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BDA5DDA.3010701-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

How can it crash kernels?  At the moment every ckpt_ops that is
registered is done so from files which are not parts of modules.

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> I don't feel comfortable with posting a version that we know
> can crash a kernel, and even less so if we say that's it's broken...
> So I prefer it inside.
> 
> Oren
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> To ensure that a module does not unload in the middle of a checkpoint
> >> or a restart operation, pin (module_get) all the modules during either
> >> operation.  For that, add a new memeber ->owner in ckpt_obj_ops.
> >>
> >> Also add a counter that keeps track of how many module_gets we have
> >> going on, to properly handle new modules that register when an
> >> operation is underway.
> >>
> >> This is a proof of concept, applies on top of the patch that introduces
> >> objhash on rc7 (patch 33).
> >>
> >> Todo:
> >>
> >> - I put the initialization part in init_*_ctx(), but it could be moved
> >> to ckpt_ctx_alloc() which is common to both checkpoint and restart.
> >>
> >> - If this is ok, then additional patches should adjust those modules
> >> that indeed register...
> >>
> >> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> > 
> > Yes this looks good to me
> > 
> > Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Were you going to stick this into v21 too, or queue that up as
> > first patch after the patchbomb?
> > 
> > thanks,
> > -serge
> > 
> >> ---
> >> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> >> index 2f5af3c..4ed8a8c 100644
> >> --- a/include/linux/checkpoint.h
> >> +++ b/include/linux/checkpoint.h
> >> @@ -40,11 +40,13 @@ extern long do_sys_restart(pid_t pid, int fd,
> >>  #define CKPT_CTX_RESTART_BIT		1
> >>  #define CKPT_CTX_SUCCESS_BIT		2
> >>  #define CKPT_CTX_ERROR_BIT		3
> >> +#define CKPT_CTX_PINNED_BIT		4
> >>
> >>  #define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
> >>  #define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
> >>  #define CKPT_CTX_SUCCESS	(1 << CKPT_CTX_SUCCESS_BIT)
> >>  #define CKPT_CTX_ERROR		(1 << CKPT_CTX_ERROR_BIT)
> >> +#define CKPT_CTX_PINNED		(1 << CKPT_CTX_PINNED_BIT)
> >>
> >>  /* ckpt_ctx: uflags */
> >>  #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
> >> @@ -107,6 +109,9 @@ static inline int ckpt_get_error(struct ckpt_ctx *ctx)
> >>  extern void restore_notify_error(struct ckpt_ctx *ctx);
> >>
> >>  /* obj_hash */
> >> +extern int ckpt_obj_module_get(void);
> >> +extern void ckpt_obj_module_put(void);
> >> +
> >>  extern void ckpt_obj_hash_free(struct ckpt_ctx *ctx);
> >>  extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
> >>
> >> @@ -284,6 +289,7 @@ extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
> >>
> >>  struct ckpt_obj_ops;
> >>  extern int register_checkpoint_obj(const struct ckpt_obj_ops *ops);
> >> +extern void unregister_checkpoint_obj(const struct ckpt_obj_ops *ops);
> >>
> >>  #else /* CONFIG_CHEKCPOINT */
> >>
> >> @@ -293,6 +299,10 @@ static inline int register_checkpoint_obj(const struct ckpt_obj_ops *ops)
> >>  	return 0;
> >>  }
> >>
> >> +static inline void unregister_checkpoint_obj(const struct ckpt_obj_ops *ops)
> >> +{
> >> +}
> >> +
> >>  #endif /* CONFIG_CHECKPOINT */
> >>  #endif /* __KERNEL__ */
> >>
> >> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> >> index 912e06a..8035556 100644
> >> --- a/include/linux/checkpoint_types.h
> >> +++ b/include/linux/checkpoint_types.h
> >> @@ -79,6 +79,7 @@ struct ckpt_obj_ops {
> >>  	int (*ref_grab)(void *ptr);
> >>  	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
> >>  	void *(*restore)(struct ckpt_ctx *ctx);
> >> +	struct module *owner;
> >>  };
> >>
> >>
> >> diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
> >> index f451f8f..1a08bfb 100644
> >> --- a/kernel/checkpoint/checkpoint.c
> >> +++ b/kernel/checkpoint/checkpoint.c
> >> @@ -473,6 +473,7 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
> >>  {
> >>  	struct task_struct *task;
> >>  	struct nsproxy *nsproxy;
> >> +	int ret;
> >>
> >>  	/*
> >>  	 * No need for explicit cleanup here, because if an error
> >> @@ -514,6 +515,12 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
> >>  		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
> >>  	}
> >>
> >> +	/* pin down modules - cleanup by ckpt_ctx_free() */
> >> +	ret = ckpt_obj_module_get();
> >> +	if (ret < 0)
> >> +		return ret;
> >> +	ckpt_ctx_set_kflag(ctx, CKPT_CTX_PINNED);
> >> +
> >>  	return 0;
> >>  }
> >>
> >> diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
> >> index 1ee06d0..db795e3 100644
> >> --- a/kernel/checkpoint/objhash.c
> >> +++ b/kernel/checkpoint/objhash.c
> >> @@ -45,17 +45,80 @@ static const struct ckpt_obj_ops *ckpt_obj_ops[CKPT_OBJ_MAX] = {
> >>  	[CKPT_OBJ_IGNORE] = &ckpt_obj_ignored_ops,
> >>  };
> >>
> >> +static int ckpt_obj_pinned_count;
> >> +static DEFINE_SPINLOCK(ckpt_obj_pinned_lock);
> >> +
> >>  int register_checkpoint_obj(const struct ckpt_obj_ops *ops)
> >>  {
> >> +	int ret = -EINVAL;
> >> +	int i;
> >> +
> >>  	if (ops->obj_type < 0 || ops->obj_type >= CKPT_OBJ_MAX)
> >>  		return -EINVAL;
> >> -	if (ckpt_obj_ops[ops->obj_type] != NULL)
> >> -		return -EINVAL;
> >> -	ckpt_obj_ops[ops->obj_type] = ops;
> >> -	return 0;
> >> +	spin_lock(&ckpt_obj_pinned_lock);
> >> +	if (ckpt_obj_ops[ops->obj_type] == NULL) {
> >> +		if (ops->owner) {
> >> +			for (i = 0; i < ckpt_obj_pinned_count)
> >> +				__module_get(owner->module);
> >> +		}
> >> +		ckpt_obj_ops[ops->obj_type] = ops;
> >> +		ret = 0;
> >> +	}
> >> +	spin_unlock(&ckpt_obj_pinned_lock);
> >> +	return ret;
> >>  }
> >>  EXPORT_SYMBOL(register_checkpoint_obj);
> >>
> >> +void unregister_checkpoint_obj(const struct ckpt_obj_ops *ops)
> >> +{
> >> +	if (ops->obj_type < 0 || ops->obj_type >= CKPT_OBJ_MAX)
> >> +		return;
> >> +	spin_lock(&ckpt_obj_pinned_lock);
> >> +	if (ckpt_obj_ops[ops->obj_type] == ops)
> >> +		ckpt_obj_ops[ops->obj_type] = NULL;
> >> +	spin_unlock(&ckpt_obj_pinned_lock);
> >> +	return ret;
> >> +}
> >> +EXPORT_SYMBOL(unregister_checkpoint_obj);
> >> +
> >> +static void _ckpt_obj_module_put(int last)
> >> +{
> >> +	int i;
> >> +
> >> +	for (i = 0; i < last; i++) {
> >> +		if (!ckpt_obj_ops[i] || !ckpt_obj_ops[i]->owner)
> >> +			continue;
> >> +		module_put(ckpt_obj_ops[i]->owner);
> >> +	}
> >> +}
> >> +void ckpt_obj_module_put(void)
> >> +{
> >> +	spin_lock(&ckpt_obj_pinned_lock);
> >> +	_ckpt_obj_module_put(CKPT_OBJ_MAX);
> >> +	ckpt_obj_pinned_count--;
> >> +	spin_unlock(&ckpt_obj_pinned_lock);
> >> +}
> >> +
> >> +int ckpt_obj_module_get(void)
> >> +{
> >> +	int i, ret = 0;
> >> +
> >> +	spin_lock(&ckpt_obj_pinned_lock);
> >> +	for (i = 0; i < CKPT_OBJ_MAX; i++) {
> >> +		if (!ckpt_obj_ops[i] || !ckpt_obj_ops[i]->owner)
> >> +			continue;
> >> +		ret = try_module_get(ckpt_obj_ops[i]->owner);
> >> +		if (ret < 0)
> >> +			break;
> >> +	}
> >> +	if (ret < 0)
> >> +		_ckpt_obj_module_put(i);
> >> +	else
> >> +		ckpt_obj_pinned_count++;
> >> +	spin_unlock(&ckpt_obj_pinned_lock);
> >> +	return ret;
> >> +}
> >> +
> >>  #define CKPT_OBJ_HASH_NBITS  10
> >>  #define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
> >>
> >> diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
> >> index 437de4f..582e1f1 100644
> >> --- a/kernel/checkpoint/restart.c
> >> +++ b/kernel/checkpoint/restart.c
> >> @@ -1084,6 +1084,12 @@ static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
> >>
> >>  	ctx->active_pid = -1;	/* see restore_activate_next, get_active_pid */
> >>
> >> +	/* pin down modules - cleanup by ckpt_ctx_free() */
> >> +	ret = ckpt_obj_module_get();
> >> +	if (ret < 0)
> >> +		return ret;
> >> +	ckpt_ctx_set_kflag(ctx, CKPT_CTX_PINNED);
> >> +
> >>  	return 0;
> >>  }
> >>
> >> diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
> >> index 5e84915..e1a1f96 100644
> >> --- a/kernel/checkpoint/sys.c
> >> +++ b/kernel/checkpoint/sys.c
> >> @@ -217,6 +217,10 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
> >>
> >>  	kfree(ctx->pids_arr);
> >>
> >> +	/* un-pin modules */
> >> +	if (ctx->kflags & CKPT_CTX_PINNED)
> >> +		ckpt_obj_module_put();
> >> +
> >>  	kfree(ctx);
> >>  }
> > 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
