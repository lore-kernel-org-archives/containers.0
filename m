From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: define CHECKPOINT_SUBTREE flag and sysctl
Date: Sat, 25 Apr 2009 01:39:08 -0700
Message-ID: <20090425083908.GA2767@us.ibm.com>
References: <20090424210608.GA16973@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090424210608.GA16973-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Apr 24, 2009 at 04:06:08PM -0500, Serge E. Hallyn wrote:
> Hey Alexey and Oren,
> 
> here is my proposal for a patch on top of Oren's tree to do the leak
> checking by default (basically the same way it was done in Alexey's
> patchset).  It also by default explicitly requires CAP_SYS_ADMIN for
> both checkpoint and restart.
> 
> I think the mm->exe_file save/restore is a separate feature addition,
> but it was required to cleanly pass the file use count checks...
> 
> Any chance this is acceptable to both of you?
> 
> thanks,
> -serge
> 
> From 8cbfbbdde1e9eab01766fcfb193846ae12ec07d6 Mon Sep 17 00:00:00 2001
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 23 Apr 2009 11:37:23 -0700
> Subject: [PATCH 1/1] cr: define CHECKPOINT_SUBTREE flag and sysctl
> 
> Define a CHECKPOINT_SUBTREE flag for sys_checkpoint() which
> says it's ok if the the checkpointed set of tasks are not
> a fully isolated container without leaks.
> 
> Define a sysctl 'ckpt_subtree_allowed' which determines
> whether subtree checkpoints are ok.  If that sysctl,
> ckpt_subtree_allowed, is 0, then the CHECKPOINT_SUBTREE flag
> may not be used.  Also, if that sysctl is 0, then both
> sys_checkpoint() and sys_restart() always require
> CAP_SYS_ADMIN.
> 
> Finally, add a 'users' count to objhash items, and, for a
> !CHECKPOINT_SUBTREE checkpoint, return an error code if
> the actual objects' counts are higher, indicating leaks
> (references to the objects from a task not being checkpointed).
> Of course, by this time most of the checkpoint image has been
> written out to disk, so this is purely advisory.  But then,
> it's probably naive to argue that anything more than an
> advisory 'this went wrong' error code is useful.
> 
> The comparison of the objhash user counts to object
> refcounts as a basis for checking for leaks comes from
> Alexey's OpenVZ-based c/r patchset.
> 
> TODO: I still need to figure out what to do about
> CONFIG_*_NS dependencies in the cr_check_leaks() fn.

I like what you and Nathtan have settled on so far. I have a significant
note re: exe_file below but otherwise just some minor comments. 

<snip> (signoff, diffstat)

> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 7382cc3..e42d3eb 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -25,6 +25,7 @@
>  #include <linux/checkpoint_hdr.h>
> 
>  #include "checkpoint_arch.h"
> +#include "objhash.h"
> 
>  /* unique checkpoint identifier (FIXME: should be per-container ?) */
>  static atomic_t cr_ctx_count = ATOMIC_INIT(0);
> @@ -487,6 +488,9 @@ static int cr_get_container(struct cr_ctx *ctx, pid_t pid)
>  	ctx->root_nsproxy = nsproxy;
>  	ctx->root_init = is_container_init(task);
> 
> +	if (!(ctx->flags & CHECKPOINT_SUBTREE) && !ctx->root_init)
> +		return -EBUSY;
> +
>  	return 0;
> 
>   out:
> @@ -523,6 +527,96 @@ static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
>  	return 0;
>  }
> 
> +static int check_obj_isolated(struct cr_ctx *ctx, struct cr_objref *ref)
> +{
> +	struct uts_namespace *utsns;
> +	struct ipc_namespace *ipcns;
> +	struct file *file;
> +	struct mm_struct *mm;
> +	unsigned long cnt, cnt2;
> +	int ret = 1;
> +
> +	/* note - one might think it worthwhile to put the ns
> +	 * ones under #ifdefs for the CONFIG_X_NS, but instead
> +	 * it CONFIG_CHECKPOINT should depend on all of those
> +	 */
> +	/* note2: the objhash has taken a reference, so we account
> +	 * for that */
> +
> +	cnt = ref->users + 1;

Perhaps this switch is another candidate for an fops-style function pointer.

> +	switch (ref->type) {
> +	case CR_OBJ_UTSNS:
> +		utsns = ref->ptr;
> +		cnt2 = (unsigned long) atomic_read(&utsns->kref.refcount);
> +		if (cnt != cnt2) {
> +			cr_debug("uts namespace leak\n");
> +			printk(KERN_NOTICE "%s: uts: %lu users count %lu\n",
> +				__func__, cnt, cnt2);
> +			ret = 0;
> +		}
> +		break;
> +	case CR_OBJ_IPCNS:
> +		ipcns = ref->ptr;
> +		cnt2 = (unsigned long) atomic_read(&ipcns->kref.refcount);
> +		if (cnt != cnt2) {
> +			cr_debug("ipc namespace leak\n");
> +			printk(KERN_NOTICE "%s: ipc: %lu users count %lu\n",
> +				__func__, cnt, cnt2);
> +			ret = 0;
> +		}
> +		break;
> +	case CR_OBJ_FILE:
> +		file = ref->ptr;
> +		if (file == ctx->file)
> +			cnt++;
> +		cnt2 = (unsigned long) atomic_long_read(&file->f_count);
> +		if (cnt != cnt2) {
> +			cr_debug("file usage leak\n");
> +			printk(KERN_NOTICE "%s: file: %lu users count %lu\n",
> +				__func__, cnt, cnt2);
> +			printk(KERN_NOTICE "%s: filename is %s (%s)\n",
> +				__func__, file->f_dentry->d_iname,
> +				file->f_dentry->d_name.name);
> +			ret = 0;
> +		}
> +		break;
> +	case CR_OBJ_MM:
> +		mm = ref->ptr;
> +		cnt2 = (unsigned long) atomic_read(&mm->mm_users);
> +		if (cnt != cnt2) {
> +			cr_debug("mm usage leak\n");
> +			printk(KERN_NOTICE "%s: mm: %lu users count %lu\n",
> +				__func__, cnt, cnt2);
> +			ret = 0;
> +		}
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	return ret;
> +}
> +
> +static int cr_check_leaks(struct cr_ctx *ctx)

What are "leaks" ? ;)

How about cr_find_ref_leaks ? I suggest "find" because "check" confuses with
"checkpoint". "ref" because we're not looking for memory leaks.

> +{
> +	struct cr_objref *ref;
> +	struct hlist_node *node;
> +
> +	if (ctx->flags & CHECKPOINT_SUBTREE)
> +		return 0;
> +
> +	/* Make sure the uts and ipc namespaces aren't
> +	 * shared with any tasks not being checkpointed */
> +	hlist_for_each_entry(ref, node, &ctx->objhash->all_nodes, next) {
> +		if (!check_obj_isolated(ctx, ref))
> +			return -EBUSY;
> +	}
> +
> +	/* TODO: check netns, etc */
> +
> +	return 0;
> +}
> +
>  int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
>  {
>  	int ret;
> @@ -550,6 +644,10 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
>  	if (ret < 0)
>  		goto out;
> 
> +	ret = cr_check_leaks(ctx);
> +	if (ret < 0)
> +		goto out;
> +
>  	ctx->crid = atomic_inc_return(&cr_ctx_count);
> 
>  	/* on success, return (unique) checkpoint identifier */
> diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
> index 8be6abe..04ce1a0 100644
> --- a/checkpoint/ckpt_file.c
> +++ b/checkpoint/ckpt_file.c
> @@ -146,7 +146,8 @@ int cr_write_file(struct cr_ctx *ctx, struct file *file)
>   * otherwise calls cr_write_file to dump the file pointer too.
>   */
>  static int
> -cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
> +cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd,
> +		struct task_struct *t)
>  {
>  	struct cr_hdr h;
>  	struct cr_hdr_fd_ent *hh;
> @@ -236,7 +237,7 @@ int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t)
> 
>  	cr_debug("nfds %d\n", nfds);
>  	for (n = 0; n < nfds; n++) {
> -		ret = cr_write_fd_ent(ctx, files, fdtable[n]);
> +		ret = cr_write_fd_ent(ctx, files, fdtable[n], t);
>  		if (ret < 0)
>  			break;
>  	}
> diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
> index 54b2674..834a78e 100644
> --- a/checkpoint/ckpt_mem.c
> +++ b/checkpoint/ckpt_mem.c
> @@ -616,10 +616,12 @@ static enum cr_vma_type cr_shared_vma_type(struct vm_area_struct *vma, int old)
>   * cr_write_vma - classify the vma and dump its contents
>   * @ctx: checkpoint context
>   * @vma: vma object
> + * @task: owning task
>   *
>   * (see vma subtypes in checkpoint_hdr.h)
>   */
> -static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
> +static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma,
> +			struct task_struct *task)
>  {
>  	struct cr_hdr h;
>  	struct cr_hdr_vma *hh;
> @@ -742,11 +744,19 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
>  	struct cr_hdr_mm *hh;
>  	struct mm_struct *mm;
>  	struct vm_area_struct *vma;
> -	int objref, new;
> +	int objref, new, exe_new;
> +	int exefile_objref;
>  	int ret;
> 
>  	mm = get_task_mm(t);
> 

Might add a check for exe_file == NULL here too (see below).

> +	exe_new = cr_obj_add_ptr(ctx, mm->exe_file, &exefile_objref,
> +				CR_OBJ_FILE, 0);
> +	if (exe_new < 0) {
> +		ret = exe_new;
> +		goto mmput;
> +	}
> +
>  	new = cr_obj_add_ptr(ctx, mm, &objref, CR_OBJ_MM, 0);
>  	if (new < 0) {
>  		ret = new;
> @@ -764,6 +774,7 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
>  	down_read(&mm->mmap_sem);
> 
>  	hh->objref = objref;
> +	hh->exefile_objref = exefile_objref;
> 
>  	hh->start_code = mm->start_code;
>  	hh->end_code = mm->end_code;
> @@ -786,10 +797,17 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
>  	if (ret < 0)
>  		goto out;
> 
> +	if (exe_new) {
> +		/* write out the exe_file */
> +		ret = cr_write_file(ctx, mm->exe_file);
> +		if (ret < 0)
> +			goto out;
> +	}
> +
>  	if (new) {
>  		/* write the vma's */
>  		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -			ret = cr_write_vma(ctx, vma);
> +			ret = cr_write_vma(ctx, vma, t);
>  			if (ret < 0)
>  				goto out;
>  		}

<snip>
 
> diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
> index 9de770d..84a7255 100644
> --- a/checkpoint/rstr_mem.c
> +++ b/checkpoint/rstr_mem.c
> @@ -19,6 +19,7 @@
>  #include <linux/mm.h>
>  #include <linux/err.h>
>  #include <linux/syscalls.h>
> +#include <linux/proc_fs.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> 
> @@ -519,6 +520,7 @@ int cr_read_mm(struct cr_ctx *ctx)
>  	struct mm_struct *mm;
>  	unsigned int nr;
>  	int ret;
> +	struct file *exe_file;
> 
>  	hh = cr_hbuf_get(ctx, sizeof(*hh));
>  	if (!hh)
> @@ -580,6 +582,24 @@ int cr_read_mm(struct cr_ctx *ctx)
>  	mm->arg_end = hh->arg_end;
>  	mm->env_start = hh->env_start;
>  	mm->env_end = hh->env_end;
> +	exe_file = cr_obj_get_by_ref(ctx, hh->exefile_objref, CR_OBJ_FILE);
> +	if (exe_file < 0) {
> +		ret = -ENOENT;
> +		up_write(&mm->mmap_sem);
> +		goto out;
> +	}
> +	if (!exe_file) {
> +		/* really it can't be the case that it NOT be NULL... */

This comment isn't correct. Yes, *most* of the time exe_file should be
non-NULL. 

Some tools avoid pinning the filesystem with a reference to its executable file
by copying the executable into private, anonymous, executable pages,
and then unmaping the originals. This drops the last VMA reference to the
file which causes the exe_file reference to be dropped as well.

It may provide an interesting testcase for checkpoint/restart since it
would mean the executable couldn't be mapped from a checkpointed file --
we'd have to rely solely on VMA reconstruction for these.

> +		int fd = cr_read_file(ctx, hh->exefile_objref);
> +		if (fd < 0) {
> +			ret = fd;
> +			up_write(&mm->mmap_sem);
> +			goto out;
> +		}
> +		exe_file = fget(fd);
> +		sys_close(fd);
> +	}
> +	set_mm_exe_file(mm, exe_file);
>  	up_write(&mm->mmap_sem);
> 
>  	/* FIX: need also mm->flags */

<snip>

> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 82d2a40..175d727 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -33,7 +33,7 @@ struct cr_ctx {
>  	unsigned long flags;
>  	unsigned long oflags;	/* restart: old flags */
> 
> -	struct file *file;
> +	struct file *file;	/* file to write image to */
>  	int total;		/* total read/written */
> 
>  	void *hbuf;		/* temporary buffer for headers */
> @@ -63,8 +63,12 @@ struct cr_ctx {
>  };
> 
>  /* cr_ctx: flags */
> -#define CR_CTX_CKPT	0x1
> -#define CR_CTX_RSTR	0x2
> +#define CR_CTX_CKPT		0x1
> +#define CR_CTX_RSTR		0x2
> +#define CHECKPOINT_SUBTREE	0x4

The whitespace change somewhat obscures the introduction of the flag here.

Cheers,
	-Matt Helsley
