From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] cr: pty: don't use required_id, change ptmx_open()
Date: Tue, 08 Sep 2009 14:14:03 -0400
Message-ID: <4AA69EEB.9040706@librato.com>
References: <20090902233111.GA27125@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090902233111.GA27125-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


I assume this will be the preferred approach. See comments
below.

Serge E. Hallyn wrote:
> Ok so here is the patch to do unix98 pty restore by making
> invasive changes to ptmx_open() instead of using
> task_struct->required_id to pass an index.  Patch generated
> against the cr tree with the original pty patches, as I
> assume that will be easier to read.
> 
> Break ptmx_open() into a ptmx_create() which is used both
> by ptmx_open itself, and fs/devpts/inode.c:open_create_pty().
> The latter function is used only during sys_restart() when
> a unix98 pty must be restored.
> 
> Either with or without this patch, the pty test at
> 	git://git.sr71.net/~hallyn/cr_tests.git
> under the pty/ directory.  The question then is which is
> a more likely approach to be acceptable upstream.  The
> task->required_id approach is imo 'hacky', but it actually
> does a much better job of re-using existing helpers, and
> therefore is more maintainable.  So part of me DOES prefer
> the original required_id approach.
> 
> This is purely RFC, so comments very much appreciated.
> 
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> --
>  checkpoint/sys.c           |    8 ---
>  drivers/char/pty.c         |   16 +++---
>  drivers/char/tty_io.c      |  112 +++++++++++++++++++++++++++++++++++----------
>  fs/devpts/inode.c          |   55 ++++++++++++++++++++--
>  include/linux/checkpoint.h |    2 
>  include/linux/devpts_fs.h  |    2 
>  include/linux/sched.h      |    1 
>  7 files changed, 151 insertions(+), 45 deletions(-)
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 3db18f7..b1fdbd7 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -339,14 +339,6 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
>  	return ret;
>  }
>  
> -static int __init checkpoint_init(void)
> -{
> -	init_task.required_id = CKPT_REQUIRED_NONE;
> -	return 0;
> -}
> -__initcall(checkpoint_init);
> -
> -
>  /* 'ckpt_debug_level' controls the verbosity level of c/r code */
>  #ifdef CONFIG_CHECKPOINT_DEBUG
>  
> diff --git a/drivers/char/pty.c b/drivers/char/pty.c
> index afdab5e..79e86e4 100644
> --- a/drivers/char/pty.c
> +++ b/drivers/char/pty.c
> @@ -28,6 +28,8 @@
>  #include <linux/uaccess.h>
>  #include <linux/bitops.h>
>  #include <linux/devpts_fs.h>
> +#include <linux/file.h>
> +#include <linux/mount.h>
>  
>  #include <asm/system.h>
>  
> @@ -629,20 +631,13 @@ static const struct tty_operations pty_unix98_ops = {
>   *		allocated_ptys_lock handles the list of free pty numbers
>   */
>  
> -static int __ptmx_open(struct inode *inode, struct file *filp)
> +int ptmx_create(struct inode *inode, struct file *filp, int index)
>  {
>  	struct tty_struct *tty;
>  	int retval;
> -	int index = -1;
>  
>  	nonseekable_open(inode, filp);
>  
> -#ifdef CONFIG_CHECKPOINT
> -	/* when restarting, request specific index */
> -	if (current->flags & PF_RESTARTING)
> -		index = (int) current->required_id;
> -#endif
> -	/* find a device that is not in use. */
>  	index = devpts_new_index(inode, index);
>  	if (index < 0)
>  		return index;
> @@ -675,6 +670,11 @@ out:
>  	return retval;
>  }
>  
> +static int __ptmx_open(struct inode *inode, struct file *filp)
> +{
> +	return ptmx_create(inode, filp, UNSPECIFIED_PTY_INDEX);
> +}
> +
>  static int ptmx_open(struct inode *inode, struct file *filp)
>  {
>  	int ret;
> diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
> index b8f8d79..d27ec36 100644
> --- a/drivers/char/tty_io.c
> +++ b/drivers/char/tty_io.c
> @@ -79,6 +79,7 @@
>  #include <linux/devpts_fs.h>
>  #include <linux/file.h>
>  #include <linux/fdtable.h>
> +#include <linux/namei.h>
>  #include <linux/console.h>
>  #include <linux/timer.h>
>  #include <linux/ctype.h>
> @@ -2982,13 +2983,97 @@ static int restore_tty_ldisc(struct ckpt_ctx *ctx,
>  	return 0;
>  }
>  
> -#define CKPT_PTMX_PATH  "/dev/ptmx"
> +#define PTMXNAME "ptmx"
> +struct tty_struct *pty_open_by_master_in_ns(struct ckpt_ctx *ctx,
> +		struct ckpt_hdr_tty *h, struct file *fdir)

I assume you split this to two functions so that in the future you
could feed a different "base" directory (for a different devpts mount).
To simplify this patch, perhaps we can defer it until we do that ?

Nit: s/pty_open_by_master_in_ns/pty_open_by_index/ ?

Instead of passing ckpt_hdr_tty, maybe instead make it return the
file pointer, and pass the desired index instead:
	struct file *pty_open_by_index(char *path, int index)

By letting the caller decide on the path, and what to do with the
resulting file pointer, I hope the c/r code will be more separate
and therefore easier to follow ?

> +{
> +	struct tty_struct *tty;
> +	struct file *file;
> +	int ret;
> +	struct qstr ptmxname;
> +	struct dentry *ptmxdentry;
> +	struct nameidata nd;
> +
> +	ret = file_permission(fdir, MAY_EXEC);
> +	if (ret)
> +		return ERR_PTR(ret);
> +	nd.path = fdir->f_path;
> +	path_get(&nd.path);
> +	ptmxname.name = PTMXNAME;
> +	ptmxname.len = strlen(ptmxname.name);
> +	mutex_lock(&fdir->f_dentry->d_inode->i_mutex);
> +	ptmxdentry = d_hash_and_lookup(fdir->f_dentry, &ptmxname);
> +	mutex_unlock(&fdir->f_dentry->d_inode->i_mutex);
> +	if (!ptmxdentry) {
> +		path_put(&nd.path);
> +		return ERR_PTR(-ENOENT);
> +	}

Need to verify that the resulting dentry points to a ptmx device.
(With current code, user can arrange for something else in /dev/pts)

> +
> +	/* should get mode from the file handle... */

Should be ok, since restore_file_common() should restore the mode...

> +	file = alloc_file(nd.path.mnt, ptmxdentry, FMODE_READ|FMODE_WRITE, &tty_fops);
> +	path_put(&nd.path);
> +	if (!file) {
> +		dput(ptmxdentry);
> +		return ERR_PTR(-EINVAL);
> +	}
> +
> +	ret = security_dentry_open(file, current_cred());
> +	if (ret) {
> +		fput(file);
> +		return ERR_PTR(ret);
> +	}
> +	/* check write access perms to file */

I bet the above can be done by reusing lookup and __dentry_open()
functions from fs/open.c and fs/namei.c ...

> +
> +	lock_kernel();  /* tty_open does it... */
> +	ret = open_create_pty(fdir, h->index, file);
> +	unlock_kernel();
> +	if (ret) {
> +		fput(file);
> +		return ERR_PTR(ret);
> +	}
> +	ckpt_debug("master file %p (obj %d)\n", file, h->file_objref);
> +
> +	/*
> +	 * Add file to objhash to ensure proper cleanup later
> +	 * (it isn't referenced elsewhere). Use h->file_objref
> +	 * which was explicitly during checkpoint for this.
> +	 */
> +	ret = ckpt_obj_insert(ctx, file, h->file_objref, CKPT_OBJ_FILE);
> +	if (ret < 0) {
> +		fput(file);
> +		return ERR_PTR(ret);
> +	}

Can do this in caller. So

> +
> +	tty = file->private_data;
> +	fput(file);   /* objhash took a ref */
> +
> +	return tty;
> +}
> +
> +struct tty_struct *pty_open_by_master(struct ckpt_ctx *ctx,
> +		struct ckpt_hdr_tty *h)
> +{
> +	struct file *fdir;
> +	struct tty_struct *tty;
> +	/*
> +	 * we need to pick a way to specify which devpts
> +	 * mountpoint to use.  For now, we'll just use
> +	 * whatever /dev/ptmx points to
> +	 */
> +	fdir = filp_open("/dev/pts", O_RDONLY, 0);
> +	if (IS_ERR(fdir))
> +		return ERR_PTR(PTR_ERR(fdir));

Does this mean that to restore a subtree on a system without
devpts-ns it won't work ?  (no /dev/pts/ptmx)

[...]

Oren.
