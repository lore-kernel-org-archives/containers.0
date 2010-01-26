From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Restore task fs_root and pwd (v3)
Date: Mon, 25 Jan 2010 23:29:41 -0600
Message-ID: <20100126052940.GA27763@us.ibm.com>
References: <1264453132-22387-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1264453132-22387-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Checkpoint and restore task->fs.  Tasks sharing task->fs will
> share them again after restart.
> 
> Original patch by Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Changelog:
>   Jan 25: [orenl] Addressed comments by .. myself:
>     - add leak detection
>     - change order of save/restore of chroot and cwd
>     - save/restore fs only after file-table and mm
>     - rename functions to adapt existing conventions
>   Dec 28: [serge] Addressed comments by Oren (and Dave)
>     - define and use {get,put}_fs_struct helpers
>     - fix locking comment
>     - define ckpt_read_fname() and use in checkpoint/files.c
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks, Oren.  Looks good to me.

-serge

> ---
>  checkpoint/files.c             |  204 +++++++++++++++++++++++++++++++++++++++-
>  checkpoint/objhash.c           |   34 +++++++
>  checkpoint/process.c           |   17 ++++
>  fs/fs_struct.c                 |   21 ++++
>  fs/open.c                      |   53 ++++++-----
>  include/linux/checkpoint.h     |    8 ++-
>  include/linux/checkpoint_hdr.h |   12 +++
>  include/linux/fs.h             |    4 +
>  include/linux/fs_struct.h      |    2 +
>  9 files changed, 329 insertions(+), 26 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index ff486cd..797ce40 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -15,6 +15,9 @@
>  #include <linux/module.h>
>  #include <linux/sched.h>
>  #include <linux/file.h>
> +#include <linux/namei.h>
> +#include <linux/fs_struct.h>
> +#include <linux/fs.h>
>  #include <linux/fdtable.h>
>  #include <linux/fsnotify.h>
>  #include <linux/pipe_fs_i.h>
> @@ -387,6 +390,62 @@ int checkpoint_obj_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
>  	return objref;
>  }
> 
> +int checkpoint_obj_fs(struct ckpt_ctx *ctx, struct task_struct *t)
> +{
> +	struct fs_struct *fs;
> +	int fs_objref;
> +
> +	task_lock(current);
> +	fs = t->fs;
> +	get_fs_struct(fs);
> +	task_unlock(current);
> +
> +	fs_objref = checkpoint_obj(ctx, fs, CKPT_OBJ_FS);
> +	put_fs_struct(fs);
> +
> +	return fs_objref;
> +}
> +
> +/* called with fs refcount bumped so it won't disappear */
> +static int do_checkpoint_fs(struct ckpt_ctx *ctx, struct fs_struct *fs)
> +{
> +	struct ckpt_hdr_fs *h;
> +	struct fs_struct *fscopy;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FS);
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
> +	ret = checkpoint_fname(ctx, &fscopy->pwd, &ctx->root_fs_path);
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "%(T)writing path of cwd");
> +		goto out;
> +	}
> +	ret = checkpoint_fname(ctx, &fscopy->root, &ctx->root_fs_path);
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "%(T)writing path of fs root");
> +		goto out;
> +	}
> +	ret = 0;
> +out:
> +	free_fs_struct(fscopy);
> +	return ret;
> +}
> +
> +int checkpoint_fs(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	return do_checkpoint_fs(ctx, (struct fs_struct *) ptr);
> +}
> +
>  /***********************************************************************
>   * Collect
>   */
> @@ -473,10 +532,41 @@ int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
>  	return ret;
>  }
> 
> +int ckpt_collect_fs(struct ckpt_ctx *ctx, struct task_struct *t)
> +{
> +	struct fs_struct *fs;
> +	int ret;
> +
> +	task_lock(t);
> +	fs = t->fs;
> +	get_fs_struct(fs);
> +	task_unlock(t);
> +
> +	ret = ckpt_obj_collect(ctx, fs, CKPT_OBJ_FS);
> +
> +	put_fs_struct(fs);
> +	return ret;
> +}
> +
>  /**************************************************************************
>   * Restart
>   */
> 
> +static int ckpt_read_fname(struct ckpt_ctx *ctx, char **fname)
> +{
> +	int len;
> +
> +	len = ckpt_read_payload(ctx, (void **) fname,
> +				PATH_MAX, CKPT_HDR_FILE_NAME);
> +	if (len < 0)
> +		return len;
> +
> +	(*fname)[len - 1] = '\0';	/* always play if safe */
> +	ckpt_debug("read filename '%s'\n", *fname);
> +
> +	return len;
> +}
> +
>  /**
>   * restore_open_fname - read a file name and open a file
>   * @ctx: checkpoint context
> @@ -492,11 +582,9 @@ struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
>  	if (flags & (O_CREAT | O_EXCL | O_NOCTTY | O_TRUNC))
>  		return ERR_PTR(-EINVAL);
> 
> -	len = ckpt_read_payload(ctx, (void **) &fname,
> -				PATH_MAX, CKPT_HDR_FILE_NAME);
> +	len = ckpt_read_fname(ctx, &fname);
>  	if (len < 0)
>  		return ERR_PTR(len);
> -	fname[len - 1] = '\0';	/* always play if safe */
>  	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
> 
>  	file = filp_open(fname, flags, 0);
> @@ -836,3 +924,113 @@ int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref)
> 
>  	return 0;
>  }
> +
> +/*
> + * Called by task restore code to set the restarted task's
> + * current->fs to an entry on the hash
> + */
> +int restore_obj_fs(struct ckpt_ctx *ctx, int fs_objref)
> +{
> +	struct fs_struct *newfs, *oldfs;
> +
> +	newfs = ckpt_obj_fetch(ctx, fs_objref, CKPT_OBJ_FS);
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
> +
> +static int restore_chroot(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
> +{
> +	struct nameidata nd;
> +	int ret;
> +
> +	ckpt_debug("attempting chroot to %s\n", name);
> +	ret = path_lookup(name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &nd);
> +	if (ret) {
> +		ckpt_err(ctx, ret, "%(T)Opening chroot dir %s", name);
> +		return ret;
> +	}
> +	ret = do_chroot(fs, &nd.path);
> +	path_put(&nd.path);
> +	if (ret) {
> +		ckpt_err(ctx, ret, "%(T)Setting chroot %s", name);
> +		return ret;
> +	}
> +	return 0;
> +}
> +
> +static int restore_cwd(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
> +{
> +	struct nameidata nd;
> +	int ret;
> +
> +	ckpt_debug("attempting chdir to %s\n", name);
> +	ret = path_lookup(name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &nd);
> +	if (ret) {
> +		ckpt_err(ctx, ret, "%(T)Opening cwd %s", name);
> +		return ret;
> +	}
> +	ret = do_chdir(fs, &nd.path);
> +	path_put(&nd.path);
> +	if (ret) {
> +		ckpt_err(ctx, ret, "%(T)Setting cwd %s", name);
> +		return ret;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * Called by objhash when it runs into a CKPT_OBJ_FS entry. Creates
> + * an fs_struct with desired chroot/cwd and places it in the hash.
> + */
> +static struct fs_struct *do_restore_fs(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_fs *h;
> +	struct fs_struct *fs;
> +	char *path;
> +	int ret = 0;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FS);
> +	if (IS_ERR(h))
> +		return ERR_PTR(PTR_ERR(h));
> +	ckpt_hdr_put(ctx, h);
> +
> +	fs = copy_fs_struct(current->fs);
> +	if (!fs)
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = ckpt_read_fname(ctx, &path);
> +	if (ret < 0)
> +		goto out;
> +	ret = restore_cwd(ctx, fs, path);
> +	kfree(path);
> +	if (ret)
> +		goto out;
> +
> +	ret = ckpt_read_fname(ctx, &path);
> +	if (ret < 0)
> +		goto out;
> +	ret = restore_chroot(ctx, fs, path);
> +	kfree(path);
> +
> +out:
> +	if (ret) {
> +		free_fs_struct(fs);
> +		return ERR_PTR(ret);
> +	}
> +	return fs;
> +}
> +
> +void *restore_fs(struct ckpt_ctx *ctx)
> +{
> +	return (void *) do_restore_fs(ctx);
> +}
> +
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 782661d..190983b 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -15,6 +15,7 @@
>  #include <linux/hash.h>
>  #include <linux/file.h>
>  #include <linux/fdtable.h>
> +#include <linux/fs_struct.h>
>  #include <linux/sched.h>
>  #include <linux/kref.h>
>  #include <linux/ipc_namespace.h>
> @@ -127,6 +128,29 @@ static int obj_mm_users(void *ptr)
>  	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
>  }
> 
> +static int obj_fs_grab(void *ptr)
> +{
> +	get_fs_struct((struct fs_struct *) ptr);
> +	return 0;
> +}
> +
> +static void obj_fs_drop(void *ptr, int lastref)
> +{
> +	put_fs_struct((struct fs_struct *) ptr);
> +}
> +
> +static int obj_fs_users(void *ptr)
> +{
> +	/*
> +	 * It's safe to not use fs->lock because the fs referenced.
> +	 * It's also sufficient for leak detection: with no leak the
> +	 * count can't change; with a leak it will be too big already
> +	 * (even if it's about to grow), and if it's about to shrink
> +	 * then it's as if we sampled the count a bit earlier.
> +	 */
> +	return ((struct fs_struct *) ptr)->users;
> +}
> +
>  static int obj_sighand_grab(void *ptr)
>  {
>  	atomic_inc(&((struct sighand_struct *) ptr)->count);
> @@ -361,6 +385,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.checkpoint = checkpoint_mm,
>  		.restore = restore_mm,
>  	},
> +	/* struct fs_struct */
> +	{
> +		.obj_name = "FS",
> +		.obj_type = CKPT_OBJ_FS,
> +		.ref_drop = obj_fs_drop,
> +		.ref_grab = obj_fs_grab,
> +		.ref_users = obj_fs_users,
> +		.checkpoint = checkpoint_fs,
> +		.restore = restore_fs,
> +	},
>  	/* sighand object */
>  	{
>  		.obj_name = "SIGHAND",
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index 6655cc7..94cd0c1 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -232,6 +232,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  	struct ckpt_hdr_task_objs *h;
>  	int files_objref;
>  	int mm_objref;
> +	int fs_objref;
>  	int sighand_objref;
>  	int signal_objref;
>  	int first, ret;
> @@ -272,6 +273,13 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  		return mm_objref;
>  	}
> 
> +	/* note: this must come *after* file-table and mm */
> +	fs_objref = checkpoint_obj_fs(ctx, t);
> +	if (fs_objref < 0) {
> +		ckpt_err(ctx, fs_objref, "%(T)process fs\n");
> +		return fs_objref;
> +	}
> +
>  	sighand_objref = checkpoint_obj_sighand(ctx, t);
>  	ckpt_debug("sighand: objref %d\n", sighand_objref);
>  	if (sighand_objref < 0) {
> @@ -299,6 +307,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  		return -ENOMEM;
>  	h->files_objref = files_objref;
>  	h->mm_objref = mm_objref;
> +	h->fs_objref = fs_objref;
>  	h->sighand_objref = sighand_objref;
>  	h->signal_objref = signal_objref;
>  	ret = ckpt_write_obj(ctx, &h->h);
> @@ -477,6 +486,9 @@ int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
>  	ret = ckpt_collect_mm(ctx, t);
>  	if (ret < 0)
>  		return ret;
> +	ret = ckpt_collect_fs(ctx, t);
> +	if (ret < 0)
> +		return ret;
>  	ret = ckpt_collect_sighand(ctx, t);
> 
>  	return ret;
> @@ -645,6 +657,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
>  	if (ret < 0)
>  		goto out;
> 
> +	ret = restore_obj_fs(ctx, h->fs_objref);
> +	ckpt_debug("fs: ret %d (%p)\n", ret, current->fs);
> +	if (ret < 0)
> +		return ret;
> +
>  	ret = restore_obj_sighand(ctx, h->sighand_objref);
>  	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
>  	if (ret < 0)
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
> +
> +/*
>   * Replace the fs->{rootmnt,root} with {mnt,dentry}. Put the old values.
>   * It can block.
>   */
> diff --git a/fs/open.c b/fs/open.c
> index 4f01e06..75c395d 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -524,6 +524,18 @@ SYSCALL_DEFINE2(access, const char __user *, filename, int, mode)
>  	return sys_faccessat(AT_FDCWD, filename, mode);
>  }
> 
> +int do_chdir(struct fs_struct *fs, struct path *path)
> +{
> +	int error;
> +
> +	error = inode_permission(path->dentry->d_inode, MAY_EXEC | MAY_ACCESS);
> +	if (error)
> +		return error;
> +
> +	set_fs_pwd(fs, path);
> +	return 0;
> +}
> +
>  SYSCALL_DEFINE1(chdir, const char __user *, filename)
>  {
>  	struct path path;
> @@ -531,17 +543,10 @@ SYSCALL_DEFINE1(chdir, const char __user *, filename)
> 
>  	error = user_path_dir(filename, &path);
>  	if (error)
> -		goto out;
> -
> -	error = inode_permission(path.dentry->d_inode, MAY_EXEC | MAY_ACCESS);
> -	if (error)
> -		goto dput_and_out;
> -
> -	set_fs_pwd(current->fs, &path);
> +		return error;
> 
> -dput_and_out:
> +	error = do_chdir(current->fs, &path);
>  	path_put(&path);
> -out:
>  	return error;
>  }
> 
> @@ -571,6 +576,21 @@ out:
>  	return error;
>  }
> 
> +int do_chroot(struct fs_struct *fs, struct path *path)
> +{
> +	int error;
> +
> +	error = inode_permission(path->dentry->d_inode, MAY_EXEC | MAY_ACCESS);
> +	if (error)
> +		return error;
> +
> +	if (!capable(CAP_SYS_CHROOT))
> +		return -EPERM;
> +
> +	set_fs_root(fs, path);
> +	return 0;
> +}
> +
>  SYSCALL_DEFINE1(chroot, const char __user *, filename)
>  {
>  	struct path path;
> @@ -578,21 +598,10 @@ SYSCALL_DEFINE1(chroot, const char __user *, filename)
> 
>  	error = user_path_dir(filename, &path);
>  	if (error)
> -		goto out;
> -
> -	error = inode_permission(path.dentry->d_inode, MAY_EXEC | MAY_ACCESS);
> -	if (error)
> -		goto dput_and_out;
> -
> -	error = -EPERM;
> -	if (!capable(CAP_SYS_CHROOT))
> -		goto dput_and_out;
> +		return error;
> 
> -	set_fs_root(current->fs, &path);
> -	error = 0;
> -dput_and_out:
> +	error = do_chroot(current->fs, &path);
>  	path_put(&path);
> -out:
>  	return error;
>  }
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 90c8436..b2cbd30 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -10,7 +10,7 @@
>   *  distribution for more details.
>   */
> 
> -#define CHECKPOINT_VERSION  4
> +#define CHECKPOINT_VERSION  5
> 
>  /* checkpoint user flags */
>  #define CHECKPOINT_SUBTREE	0x1
> @@ -245,6 +245,12 @@ extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
>  extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
>  			       struct ckpt_hdr_file *h);
> 
> +extern int ckpt_collect_fs(struct ckpt_ctx *ctx, struct task_struct *t);
> +extern int checkpoint_obj_fs(struct ckpt_ctx *ctx, struct task_struct *t);
> +extern int restore_obj_fs(struct ckpt_ctx *ctx, int fs_objref);
> +extern int checkpoint_fs(struct ckpt_ctx *ctx, void *ptr);
> +extern void *restore_fs(struct ckpt_ctx *ctx);
> +
>  /* credentials */
>  extern int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr);
>  extern int checkpoint_user(struct ckpt_ctx *ctx, void *ptr);
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index a1b67c8..53ae8bf 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -144,6 +144,9 @@ enum {
>  	CKPT_HDR_MM_CONTEXT,
>  #define CKPT_HDR_MM_CONTEXT CKPT_HDR_MM_CONTEXT
> 
> +	CKPT_HDR_FS,	/* must be after file-table, mm */
> +#define CKPT_HDR_FS CKPT_HDR_FS
> +
>  	CKPT_HDR_IPC = 501,
>  #define CKPT_HDR_IPC CKPT_HDR_IPC
>  	CKPT_HDR_IPC_SHM,
> @@ -218,6 +221,8 @@ enum obj_type {
>  #define CKPT_OBJ_FILE CKPT_OBJ_FILE
>  	CKPT_OBJ_MM,
>  #define CKPT_OBJ_MM CKPT_OBJ_MM
> +	CKPT_OBJ_FS,
> +#define CKPT_OBJ_FS CKPT_OBJ_FS
>  	CKPT_OBJ_SIGHAND,
>  #define CKPT_OBJ_SIGHAND CKPT_OBJ_SIGHAND
>  	CKPT_OBJ_SIGNAL,
> @@ -452,6 +457,7 @@ struct ckpt_hdr_task_objs {
> 
>  	__s32 files_objref;
>  	__s32 mm_objref;
> +	__s32 fs_objref;
>  	__s32 sighand_objref;
>  	__s32 signal_objref;
>  } __attribute__((aligned(8)));
> @@ -489,6 +495,12 @@ enum restart_block_type {
>  };
> 
>  /* file system */
> +struct ckpt_hdr_fs {
> +	struct ckpt_hdr h;
> +	/* char *fs_root */
> +	/* char *fs_pwd */
> +} __attribute__((aligned(8)));
> +
>  struct ckpt_hdr_file_table {
>  	struct ckpt_hdr h;
>  	__s32 fdt_nfds;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 089549b..c18b864 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1826,6 +1826,10 @@ extern void drop_collected_mounts(struct vfsmount *);
> 
>  extern int vfs_statfs(struct dentry *, struct kstatfs *);
> 
> +struct fs_struct;
> +extern int do_chdir(struct fs_struct *fs, struct path *path);
> +extern int do_chroot(struct fs_struct *fs, struct path *path);
> +
>  extern int current_umask(void);
> 
>  /* /sys/fs */
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
> -- 
> 1.6.3.3
