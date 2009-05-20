From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/6] cr: checkpoint and restore task credentials
Date: Wed, 20 May 2009 12:54:56 -0400
Message-ID: <4A1435E0.3010306@cs.columbia.edu>
References: <20090519014446.GA28277@us.ibm.com>
	<20090519014538.GD28312@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090519014538.GD28312-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> This patch adds the checkpointing and restart of credentials
> (uids, gids, and capabilities) to Oren's c/r patchset (on top
> of v14).  It goes to great pains to re-use (and define when
> needed) common helpers, in order to make sure that as security
> code is modified, the cr code will be updated.  Some of the
> helpers should still be moved (i.e. _creds() functions should
> be in kernel/cred.c).
> 
> When building the credentials for the restarted process, I
> 1. create a new struct cred as a copy of the running task's
> cred (using prepare_cred())
> 2. always authorize any changes to the new struct cred
> based on the permissions of current_cred() (not the current
> transient state of the new cred).
> 
> While this may mean that certain transient_cred1->transient_cred2
> states are allowed which otherwise wouldn't be allowed, the
> fact remains that current_cred() is allowed to transition to
> transient_cred2.
> 
> The reconstructed creds are applied to the task at the very
> end of the sys_restart call.  This ensures that any objects which
> need to be re-created (file, socket, etc) are re-created using
> the creds of the task calling sys_restart - preventing an unpriv
> user from creating a privileged object, and ensuring that a
> root task can restart a process which had started out privileged,
> created some privileged objects, then dropped its privilege.
> 
> With these patches, the root user can restart checkpoint images
> (created by either hallyn or root) of user hallyn's tasks,
> resulting in a program owned by hallyn.

In this case, it is necessary to ensure that all resources created
during the restart are properly owned. You do take care of open
files (next patch); can you also add a patch for IPC ?

> 
> Plenty of bugs to be found, no doubt.
> 
> Changelog:
> 	May 18: fix more refcounting: if (userns 5, uid 0) had
> 		no active tasks or child user_namespaces, then
> 		it shouldn't exist at restart or it, its namespace,
> 		and its whole chain of creators will be leaked.
> 	May 14: fix some refcounting:
> 		1. a new user_ns needs a ref to remain pinned
> 		   by its root user
> 		2. current_user_ns needs an extra ref bc objhash
> 		   drops two on restart
> 		3. cred needs a ref for the real credentials bc
> 		   commit_creds eats one ref.
> 	May 13: folded in fix to userns refcounting.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---

[...]

> @@ -290,6 +396,18 @@ static struct ckpt_obj *obj_find_by_ptr(struct ckpt_ctx *ctx, void *ptr)
>  	return NULL;
>  }
>  
> +/*
> + * look up an obj and return objref if in hash, else
> + * return 0.  Used during checkpoint.
> + */
> +int obj_lookup_dontadd(struct ckpt_ctx *ctx, void *ptr)

Do you mind calling it simply obj_lookup() ?

> +{
> +	struct ckpt_obj *obj = obj_find_by_ptr(ctx, ptr);
> +	if (obj)
> +		return obj->objref;
> +	return 0;
> +}
> +
>  static struct ckpt_obj *obj_find_by_objref(struct ckpt_ctx *ctx, int objref)
>  {
>  	struct hlist_head *h;
> @@ -389,7 +507,6 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
>  		*first = 0;
>  	}
>  
> -	ckpt_debug("%s objref %d first %d\n", ops->obj_name, objref, *first);

Please leave the debug messages inside... In fact, a debug message
above in obj_lookup() may prove useful as well.

>  	return objref;
>  }
>  
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index d8d346b..74b411a 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -17,6 +17,7 @@
>  #include <linux/poll.h>
>  #include <linux/nsproxy.h>
>  #include <linux/utsname.h>
> +#include <linux/user_namespace.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  #include <linux/syscalls.h>
> @@ -27,16 +28,210 @@
>   * Checkpoint
>   */
>  
> +#define CKPT_MAXGROUPS 15
> +#define MAX_GROUPINFO_SIZE (sizeof(*h)+CKPT_MAXGROUPS*sizeof(gid_t))

Is this really necessary ?  If you are worried about DoS by alloc'ing
a lot of memory on checkpoint, you can write it out in chunks (e.g.
like the pids array), or set a sysctl tunable.  Likewise for restart.

> +/* move this fn into kernel/sys.c next to group functions? */
> +static int checkpoint_write_groupinfo(struct ckpt_ctx *ctx,
> +					struct group_info *g)

[...]

> +
>  /* dump the task_struct of a given task */
>  static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
>  {
>  	struct ckpt_hdr_task *h;
>  	int ret;
> +	int realcred_ref, ecred_ref;
> +
> +	realcred_ref = checkpoint_obj(ctx, t->real_cred, CKPT_OBJ_CRED);
> +	if (realcred_ref < 0)
> +		return realcred_ref;
> +
> +	ecred_ref = checkpoint_obj(ctx, t->cred, CKPT_OBJ_CRED);
> +	if (ecred_ref < 0)
> +		return ecred_ref;

Is this safe even if the checkpointed task's state changes ?
(e.g. unfrozen - yes, I know there is a patch in the works to
prevent this; but if we ever want to checkpoint STOPPED tasks...
for instance).

Would incrementing the refcount on t->{cred,real_cred} help ?

[...]

> +}
> +
> +/* move this code into kernel/cred.c and do proper perms checking of course */
> +struct cred *restore_read_cred(struct ckpt_ctx *ctx)
> +{
> +	struct cred *cred;
> +	struct ckpt_hdr_cred *h;
> +	struct user_struct *user;
> +	struct group_info *groupinfo;
> +	int ret = -EINVAL;
> +	uid_t olduid;
> +	gid_t oldgid;
> +	int i;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CRED);
> +	if (IS_ERR(h))
> +		return ERR_PTR(PTR_ERR(h));
> +	if (h->version != 1)
			 ^^^
This probably deserves some constant defined somewhere ... (heh,
I must have missed it in the checkpoint code above).

[...]

>  /* read the task_struct into the current task */
> -static int restore_task_struct(struct ckpt_ctx *ctx)
> +static int restore_task_struct(struct ckpt_ctx *ctx, struct cred **realcredp,
> +				struct cred **ecredp)

				^^^^^^^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^
				
This probably belongs to restore_task_shared() ?

>  {
>  	struct ckpt_hdr_task *h;
>  	struct task_struct *t = current;
> @@ -365,8 +778,21 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
>  
>  	memset(t->comm, 0, TASK_COMM_LEN);
>  	ret = _ckpt_read_string(ctx, t->comm, h->task_comm_len);
> +	if (ret < 0)
> +		goto out;
>  
>  	/* FIXME: restore remaining relevant task_struct fields */
> +
> +	ret = 0;
> +	*realcredp = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
> +	if (IS_ERR(*realcredp)) {
> +		ret = PTR_ERR(*realcredp);
> +		goto out;
> +	}
> +	*ecredp = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
> +	if (IS_ERR(*ecredp))
> +		ret = PTR_ERR(*ecredp);
> +
>   out:
>  	ckpt_hdr_put(ctx, h);
>  	return ret;
> @@ -648,12 +1074,35 @@ static int restore_task_shared(struct ckpt_ctx *ctx)
>  	return ret;
>  }
>  
> +static int restore_creds(struct ckpt_ctx *ctx, struct cred *rcred,
> +			struct cred *ecred)
> +{
> +	int ret;
> +	const struct cred *old;
> +
> +	/* commit_creds will take one ref for the eff creds, but
> +	 * expects us to hold a ref for the obj creds, so take a
> +	 * ref here */
> +	get_cred(rcred);
> +	ret = commit_creds(rcred);
> +	if (ret)
> +		return ret;
> +
> +	if (ecred == rcred)
> +		return 0;
> +
> +	old =  override_creds(ecred); /* override_creds otoh takes new ref */
> +	put_cred(old);
> +	return 0;
> +}
> +
>  /* read the entire state of the current task */
>  int restore_task(struct ckpt_ctx *ctx)
>  {
>  	int ret;
> +	struct cred *realcred, *ecred;
>  
> -	ret = restore_task_struct(ctx);
> +	ret = restore_task_struct(ctx, &realcred, &ecred);

Actually, this is one of several cases where we need to restore some
resources but only apply it to a process at the end of its restart.

Another example would be restoring pending signals and the blocked
signal mask in the future.

I suggest that we keep a pointer on the task_struct to a structure
that will hold all that do-later work. The structure can encapsulate
the pending work either explicitly - e.g. a struct with fields like
realcred, ecred, signal mask, etc... - or implicitly, by reusing the
deferqueue framework, per task.

Actually, that pointer can be kept on the ckpt_ctx structure, to be
used by the current-restarting-task only.

>  	ckpt_debug("ret %d\n", ret);
>  	if (ret < 0)
>  		goto out;
> @@ -671,6 +1120,10 @@ int restore_task(struct ckpt_ctx *ctx)
>  		goto out;
>  	ret = restore_cpu(ctx);
>  	ckpt_debug("cpu: ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
> +	ret = restore_creds(ctx, realcred, ecred);

... and this would then be called from a restore_task_finalize()
function explicitly or implicitly by deferqueue_run().

> +	ckpt_debug("creds: ret %d\n", ret);
>   out:
>  	return ret;
>  }

[...]

Oren.
