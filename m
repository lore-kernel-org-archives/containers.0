From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Restore task fs_root and pwd (v2)
Date: Wed, 20 Jan 2010 15:28:13 -0500
Message-ID: <4B57675D.8080609@cs.columbia.edu>
References: <20091228183948.GA19788@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091228183948.GA19788-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Very necessary !
See comments inline.

Serge E. Hallyn wrote:
> Checkpoint and restore task->fs.  Tasks sharing task->fs will
> share them again after restart.
> 
> Changelog:
> 	Dec 28: Addressed comments by Oren (and Dave)
> 		1. define and use {get,put}_fs_struct helpers
> 		2. fix locking comment
> 		3. define ckpt_read_fname() and use in checkpoint/files.c
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/files.c             |  197 +++++++++++++++++++++++++++++++++++++++-
>  checkpoint/objhash.c           |    9 ++
>  checkpoint/process.c           |   13 +++
>  fs/fs_struct.c                 |   21 ++++
>  fs/open.c                      |   53 ++++++-----
>  include/linux/checkpoint.h     |   10 ++-
>  include/linux/checkpoint_hdr.h |   10 ++
>  include/linux/fs.h             |    4 +
>  include/linux/fs_struct.h      |    2 +
>  9 files changed, 293 insertions(+), 26 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index b622588..d6cf945 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -24,6 +24,9 @@
>  #include <linux/checkpoint_hdr.h>
>  #include <linux/eventpoll.h>
>  #include <linux/eventfd.h>
> +#include <linux/fs.h>
> +#include <linux/fs_struct.h>
> +#include <linux/namei.h>
>  #include <net/sock.h>
>  
>  
> @@ -449,10 +452,81 @@ int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
>  	return ret;
>  }
>  
> +int checkpoint_get_task_fs(struct ckpt_ctx *ctx, struct task_struct *t)

Renaming these to {checkpoint/restore}_obj_filesystem() will be
consistent with existing naming convention there.

> +{
> +	struct fs_struct *fs;
> +	int fs_objref;
> +
> +	task_lock(current);
> +	fs = t->fs;
> +	get_fs_struct(fs);
> +	task_unlock(current);
> +
> +	fs_objref = checkpoint_obj(ctx, fs, CKPT_OBJ_TASK_FS);
> +	put_fs_struct(fs);
> +
> +	return fs_objref;
> +}
> +
> +/*
> + * called with fs refcount bumped so it won't disappear
> + */
> +int checkpoint_obj_task_fs(struct ckpt_ctx *ctx, struct fs_struct *fs)
> +{
> +	struct ckpt_hdr_task_fs *h;
> +	int ret;
> +	struct fs_struct *fscopy;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_FS);
> +	if (!h)
> +		return -ENOMEM;
> +	ret = ckpt_write_obj(ctx, &h->h);
> +	ckpt_hdr_put(ctx, h);
> +	if (ret)
> +		return ret;
> +
> +	fscopy = copy_fs_struct(fs);
> +	if (!fs)
> +		return -ENOMEM;
> +

Reverse the order below: cwd first then root - this will allow
the cwd to be outside of the current chroot, in the case that
the task escaped the chroot.

> +	ret = checkpoint_fname(ctx, &fscopy->root, &ctx->fs_mnt);
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "%(T)writing name of fs root");
> +		goto out;
> +	}
> +	ret = checkpoint_fname(ctx, &fscopy->pwd, &ctx->fs_mnt);
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "%(T)writing name of pwd");
> +		goto out;
> +	}
> +	ret = 0;

[...]

> +/* this is the fn called by objhash when it runs into a
> + * CKPT_OBJ_TASK_FS entry.  Creates an fs_struct and
> + * places it in the hash. */
> +static struct fs_struct *restore_obj_task_fs(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_task_fs *h;
> +	struct fs_struct *fs;
> +	int ret = 0;
> +	char *root, *cwd;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_FS);
> +	if (IS_ERR(h))
> +		return ERR_PTR(PTR_ERR(h));
> +	ckpt_hdr_put(ctx, h);
> +
> +	fs = copy_fs_struct(current->fs);
> +	if (!fs)
> +		return ERR_PTR(-ENOMEM);
> +

Please reverse the order below: restore cwd before chroot.

> +	ret = ckpt_read_fname(ctx, &root);
> +	if (ret < 0)
> +		goto out;
> +	ret = restore_chroot(ctx, fs, root);
> +	kfree(root);
> +	if (ret)
> +		goto out;
> +
> +	ret = ckpt_read_fname(ctx, &cwd);
> +	if (ret < 0)
> +		goto out;
> +	ret = restore_cwd(ctx, fs, cwd);
> +	kfree(cwd);
> +
> +out:
> +	if (ret) {
> +		free_fs_struct(fs);
> +		return ERR_PTR(ret);
> +	}
> +	return fs;
> +}
> +
> +void *restore_task_fs(struct ckpt_ctx *ctx)
> +{
> +	return (void *) restore_obj_task_fs(ctx);
> +}
> +
> +/*
> + * Called by task restore code to set the restarted task's
> + * current->fs to an entry on the hash
> + */
> +int restore_set_task_fs(struct ckpt_ctx *ctx, int fs_objref)

(Please rename this one, too)

> +{
> +	struct fs_struct *newfs, *oldfs;
> +
> +	newfs = ckpt_obj_fetch(ctx, fs_objref, CKPT_OBJ_TASK_FS);
> +	if (IS_ERR(newfs))
> +		return PTR_ERR(newfs);
> +
> +	task_lock(current);
> +	get_fs_struct(newfs);
> +	oldfs = current->fs;
> +	current->fs = newfs;
> +	task_unlock(current);
> +	put_fs_struct(oldfs);
> +
> +	return 0;
> +}
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 782661d..20fd3e9 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -417,6 +417,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.checkpoint = checkpoint_userns,
>  		.restore = restore_userns,
>  	},
> +	/* struct fs_struct */
> +	{
> +		.obj_name = "TASK_FS",
> +		.obj_type = CKPT_OBJ_TASK_FS,
> +		.ref_drop = obj_task_fs_drop,
> +		.ref_grab = obj_task_fs_grab,
> +		.checkpoint = checkpoint_task_fs,
> +		.restore = restore_task_fs,

I think we also need a .collect method to prevent leaks ?

> +	},
>  	/* struct cred */
>  	{
>  		.obj_name = "CRED",
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index 9c0463d..603bbf4 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -234,6 +234,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  	int mm_objref;
>  	int sighand_objref;
>  	int signal_objref;
> +	int fs_objref;
>  	int first, ret;
>  
>  	/*
> @@ -253,6 +254,12 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  	if (ret < 0)
>  		return ret;
>  
> +	fs_objref = checkpoint_get_task_fs(ctx, t);
> +	if (fs_objref < 0) {
> +		ckpt_err(ctx, fs_objref, "%(T)process fs\n");
> +		return fs_objref;
> +	}
> +
>  	files_objref = checkpoint_obj_file_table(ctx, t);

The fs should be saved and restored after the file-table, or otherwise
I'd expect files that were open before a task changed called chroot()
to be unreachable.

>  	ckpt_debug("files: objref %d\n", files_objref);
>  	if (files_objref < 0) {
> @@ -294,6 +301,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  	h->mm_objref = mm_objref;
>  	h->sighand_objref = sighand_objref;
>  	h->signal_objref = signal_objref;
> +	h->fs_objref = fs_objref;
>  	ret = ckpt_write_obj(ctx, &h->h);
>  	ckpt_hdr_put(ctx, h);
>  	if (ret < 0)
> @@ -628,6 +636,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
>  		return PTR_ERR(h);
>  	}
>  
> +	ret = restore_set_task_fs(ctx, h->fs_objref);
> +	ckpt_debug("restore_task_fs returned %d\n", ret);
> +	if (ret < 0)
> +		return ret;
> +
>  	ret = restore_obj_file_table(ctx, h->files_objref);
>  	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
>  	if (ret < 0)

Here too.

> diff --git a/fs/fs_struct.c b/fs/fs_struct.c
> index eee0590..2a4c6f5 100644
> --- a/fs/fs_struct.c
> +++ b/fs/fs_struct.c
> @@ -6,6 +6,27 @@
>  #include <linux/fs_struct.h>
>  
>  /*
> + * call with owning task locked
> + */
> +void get_fs_struct(struct fs_struct *fs)
> +{
> +	write_lock(&fs->lock);
> +	fs->users++;
> +	write_unlock(&fs->lock);
> +}
> +
> +void put_fs_struct(struct fs_struct *fs)
> +{
> +	int kill;
> +
> +	write_lock(&fs->lock);
> +	kill = !--fs->users;
> +	write_unlock(&fs->lock);
> +	if (kill)
> +		free_fs_struct(fs);
> +}

I didn't look everywhere, however - could there be other users of
these two elsewhere in the kernel ?

> +
> +/*
>   * Replace the fs->{rootmnt,root} with {mnt,dentry}. Put the old values.
>   * It can block.
>   */

[...]

> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 5ae34fc..0efa62a 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1819,9 +1819,13 @@ extern struct vfsmount *collect_mounts(struct path *);
>  extern void drop_collected_mounts(struct vfsmount *);
>  
>  extern int vfs_statfs(struct dentry *, struct kstatfs *);
> +struct fs_struct;
> +extern int do_chdir(struct fs_struct *fs, struct path *path);
> +extern int do_chroot(struct fs_struct *fs, struct path *path);
>  
>  extern int current_umask(void);
>  
> +

:(

>  /* /sys/fs */
>  extern struct kobject *fs_kobj;
>  
> diff --git a/include/linux/fs_struct.h b/include/linux/fs_struct.h
> index 78a05bf..a73cbcb 100644
> --- a/include/linux/fs_struct.h
> +++ b/include/linux/fs_struct.h
> @@ -20,5 +20,7 @@ extern struct fs_struct *copy_fs_struct(struct fs_struct *);
>  extern void free_fs_struct(struct fs_struct *);
>  extern void daemonize_fs_struct(void);
>  extern int unshare_fs_struct(void);
> +extern void get_fs_struct(struct fs_struct *);
> +extern void put_fs_struct(struct fs_struct *);
>  
>  #endif /* _LINUX_FS_STRUCT_H */

Thanks,

Oren.
