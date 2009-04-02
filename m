From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add UTS support (v6)
Date: Thu, 2 Apr 2009 12:44:51 -0500
Message-ID: <20090402174451.GC9984@us.ibm.com>
References: <1238533107-11796-1-git-send-email-danms@us.ibm.com>
	<1238533107-11796-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238533107-11796-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> This patch adds a "phase" of checkpoint that saves out information about any
> namespaces the task(s) may have.  Do this by tracking the namespace objects
> of the tasks and making sure that tasks with the same namespace that follow
> get properly referenced in the checkpoint stream.
> 
> I tested this with single and multiple task restore, on top of Oren's
> v13 tree.
> 
> Changes:
>   - Remove the kernel restore path
>   - Punt on nested namespaces
>   - Use __NEW_UTS_LEN in nodename and domainname buffers
>   - Add a note to Documentation/checkpoint/internals.txt to indicate where
>     in the save/restore process the UTS information is kept
>   - Store (and track) the objref of the namespace itself instead of the
>     nsproxy (based on comments from Dave on IRC)
>   - Remove explicit check for non-root nsproxy
>   - Store the nodename and domainname lengths and use cr_write_string()
>     to store the actual name strings
>   - Catch failure of cr_obj_add_ptr() in cr_write_namespaces()
>   - Remove "types" bitfield and use the "is this new" flag to determine
>     whether or not we should write out a new ns descriptor
>   - Replace kernel restore path
>   - Move the namespace information to be directly after the task
>     information record
>   - Update Documentation to reflect new location of namespace info
>   - Support checkpoint and restart of nested UTS namespaces
> 
> Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  Documentation/checkpoint/internals.txt |    1 +
>  checkpoint/Makefile                    |    1 +
>  checkpoint/checkpoint.c                |   66 ++++++++++++++++++++-
>  checkpoint/objhash.c                   |    7 ++
>  checkpoint/restart.c                   |  101 ++++++++++++++++++++++++++++++++
>  include/linux/checkpoint.h             |    1 +
>  include/linux/checkpoint_hdr.h         |   11 ++++
>  7 files changed, 185 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/checkpoint/internals.txt b/Documentation/checkpoint/internals.txt
> index c741b6c..bdd202c 100644
> --- a/Documentation/checkpoint/internals.txt
> +++ b/Documentation/checkpoint/internals.txt
> @@ -17,6 +17,7 @@ The order of operations, both save and restore, is as follows:
>    -> thread state: elements of thread_struct and thread_info
>    -> CPU state: registers etc, including FPU
>    -> memory state: memory address space layout and contents
> +  -> namespace information
>    -> filesystem state: [TBD] filesystem namespace state, chroot, cwd, etc
>    -> files state: open file descriptors and their state
>    -> signals state: [TBD] pending signals and signal handling state
> diff --git a/checkpoint/Makefile b/checkpoint/Makefile
> index 607d864..55c5c3d 100644
> --- a/checkpoint/Makefile
> +++ b/checkpoint/Makefile
> @@ -4,3 +4,4 @@
> 
>  obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o objhash.o \
>  		ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o
> +EXTRA_CFLAGS += -DDEBUG
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index c2f0e16..5f83e83 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -213,6 +213,65 @@ static int cr_write_tail(struct cr_ctx *ctx)
>  	return ret;
>  }
> 
> +static int cr_write_utsns(struct cr_ctx *ctx, struct new_utsname *name)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_utsns *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int ret;
> +
> +	h.type = CR_HDR_UTSNS;
> +	h.len = sizeof(*hh);
> +
> +	hh->nodename_len = strlen(name->nodename) + 1;
> +	hh->domainname_len = strlen(name->domainname) + 1;
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = cr_write_string(ctx, name->nodename, hh->nodename_len);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = cr_write_string(ctx, name->domainname, hh->domainname_len);
> + out:
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}
> +
> +static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_namespaces *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct nsproxy *nsp = t->nsproxy;
> +	int ret;
> +	int uts;
> +
> +	h.type = CR_HDR_NS;
> +	h.len = sizeof(*hh);
> +
> +	uts = cr_obj_add_ptr(ctx, nsp->uts_ns, &hh->uts_ref, CR_OBJ_UTSNS, 0);
> +	if (uts < 0)
> +		goto out;
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	if (ret)
> +		goto out;
> +
> +	if (uts) {
> +		ret = cr_write_utsns(ctx, &nsp->uts_ns->name);
> +		if (ret < 0)
> +			goto out;
> +	}
> +
> +	/* FIXME: Write other namespaces here */
> + out:
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}
> +
>  /* dump the task_struct of a given task */
>  static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
>  {
> @@ -267,6 +326,10 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
>  		goto out;
>  	ret = cr_write_cpu(ctx, t);
>  	cr_debug("cpu: ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_write_namespaces(ctx, t);
> +	cr_debug("ns: ret %d\n", ret);
>   out:
>  	return ret;
>  }
> @@ -302,9 +365,6 @@ static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
>  	if (t != current && !frozen(t))
>  		return -EBUSY;
> 
> -	if (task_nsproxy(t)->uts_ns != ctx->root_nsproxy->uts_ns)
> -		return -EPERM;
> -
>  	if (task_nsproxy(t)->ipc_ns != ctx->root_nsproxy->ipc_ns)
>  		return -EPERM;
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 25916c1..c6ae7c1 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -12,6 +12,7 @@
>  #include <linux/file.h>
>  #include <linux/hash.h>
>  #include <linux/checkpoint.h>
> +#include <linux/utsname.h>
> 
>  struct cr_objref {
>  	int objref;
> @@ -38,6 +39,9 @@ static void cr_obj_ref_drop(struct cr_objref *obj)
>  	case CR_OBJ_INODE:
>  		iput((struct inode *) obj->ptr);
>  		break;
> +	case CR_OBJ_UTSNS:
> +		put_uts_ns((struct uts_namespace *) obj->ptr);
> +		break;
>  	default:
>  		BUG();
>  	}
> @@ -55,6 +59,9 @@ static int cr_obj_ref_grab(struct cr_objref *obj)
>  		if (!igrab((struct inode *) obj->ptr))
>  			ret = -EBADF;
>  		break;
> +	case CR_OBJ_UTSNS:
> +		get_uts_ns((struct uts_namespace *) obj->ptr);
> +		break;
>  	default:
>  		BUG();
>  	}
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index d9e01ce..f42d549 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -15,6 +15,8 @@
>  #include <linux/magic.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> +#include <linux/utsname.h>
> +#include <linux/syscalls.h>
> 
>  #include "checkpoint_arch.h"
> 
> @@ -237,6 +239,101 @@ static int cr_read_tail(struct cr_ctx *ctx)
>  	return ret;
>  }
> 
> +static int cr_read_utsns(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr_utsns hh;
> +	struct uts_namespace *ns;
> +	int ret;
> +	char *nn = NULL;
> +	char *dn = NULL;
> +
> +	ret = cr_read_obj_type(ctx, &hh, sizeof(hh), CR_HDR_UTSNS);
> +	if (ret < 0)
> +		return ret;
> +
> +	nn = kmalloc(hh.nodename_len, GFP_KERNEL);
> +	if (!nn) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	dn = kmalloc(hh.domainname_len, GFP_KERNEL);
> +	if (!dn) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	ret = cr_read_string(ctx, nn, hh.nodename_len);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = cr_read_string(ctx, dn, hh.domainname_len);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = sys_unshare(CLONE_NEWUTS);

One thing to note is that this will drive the ns cgroup
bananas.  It might still be worthwhile collecting the
flags for all the to-be-unshared namespaces, and then
doing all of the unsharing at once.

Futhermore, you do sys_unshare here, then further down you
do another copy_namespaces(CLONE_NEWUTS)?

Finally, it seems to me every task will unshare(CLONE_NEWUTS),
no?  Where is the check done (and stored) for whether this
task has a different utsns from its parent?

I could be misunderstanding your code...

But it seems to me a simpler algorith would be:

Save identifiers for all of the namespaces at the top of the
checkpoint image;  have restart create a set of dummy tasks,
enough to contain all of the new namespaces;  have each unshare
their  namespaces;  then, as each real new task is restarted,
manually create a new nsproxy and link it to all of the
required new namespaces.

OR you can stick to trying to use clone(), but I don't think
this patch is doing that right.

> +	if (ret)
> +		goto out;
> +
> +	ns = t->nsproxy->uts_ns;
> +	memcpy(ns->name.nodename, nn, hh.nodename_len);
> +	memcpy(ns->name.domainname, dn, hh.domainname_len);
> +
> + out:
> +	kfree(nn);
> +	kfree(dn);
> +
> +	return ret;
> +}
> +
> +static int cr_restore_utsns(struct cr_ctx *ctx, int ref)
> +{
> +	struct uts_namespace *uts;
> +	int ret;
> +
> +	uts = cr_obj_get_by_ref(ctx, ref, CR_OBJ_UTSNS);
> +	if (uts == NULL) {
> +		ret = cr_read_utsns(ctx, current);
> +		if (ret < 0)
> +			return ret;
> +
> +		return cr_obj_add_ref(ctx, current->nsproxy->uts_ns,
> +				      ref, CR_OBJ_UTSNS, 0);
> +	} else if (IS_ERR(uts)) {
> +		cr_debug("Failed to get UTS ns from objhash");
> +		return PTR_ERR(uts);
> +	}
> +
> +	ret = copy_namespaces(CLONE_NEWUTS, current);
> +	if (ret < 0)
> +		return ret;
> +
> +	put_uts_ns(current->nsproxy->uts_ns);
> +	get_uts_ns(uts);
> +	current->nsproxy->uts_ns = uts;
> +
> +	return 0;
> +}
> +
> +static int cr_read_namespaces(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_namespaces hh;
> +	int ret;
> +
> +	ret = cr_read_obj_type(ctx, &hh, sizeof(hh), CR_HDR_NS);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = cr_restore_utsns(ctx, hh.uts_ref);
> +	cr_debug("uts ns: %d\n", ret);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* FIXME: Add more namespaces here */
> +
> +	return 0;
> +}
> +
>  /* read the task_struct into the current task */
>  static int cr_read_task_struct(struct cr_ctx *ctx)
>  {
> @@ -298,6 +395,10 @@ static int cr_read_task(struct cr_ctx *ctx)
>  		goto out;
>  	ret = cr_read_cpu(ctx);
>  	cr_debug("cpu: ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_read_namespaces(ctx);
> +	cr_debug("ns: ret %d\n", ret);
> 
>   out:
>  	return ret;
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 2e99c74..cb62716 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -75,6 +75,7 @@ extern void cr_ctx_put(struct cr_ctx *ctx);
>  enum {
>  	CR_OBJ_FILE = 1,
>  	CR_OBJ_INODE,
> +	CR_OBJ_UTSNS,
>  	CR_OBJ_MAX
>  };
> 
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 3addb48..6f29a72 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -48,6 +48,8 @@ enum {
>  	CR_HDR_TASK,
>  	CR_HDR_THREAD,
>  	CR_HDR_CPU,
> +	CR_HDR_NS,
> +	CR_HDR_UTSNS,
> 
>  	CR_HDR_MM = 201,
>  	CR_HDR_VMA,
> @@ -177,4 +179,13 @@ struct cr_hdr_fd_pipe {
>  	__s32 nr_bufs;
>  } __attribute__((aligned(8)));
> 
> +struct cr_hdr_namespaces {
> +	__u32 uts_ref;
> +};
> +
> +struct cr_hdr_utsns {
> +	__u32 nodename_len;
> +	__u32 domainname_len;
> +};
> +
>  #endif /* _CHECKPOINT_CKPT_HDR_H_ */
> -- 
> 1.5.6.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
