From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 5/6] [RFC] Checkpoint/restart unlinked files
Date: Fri, 22 Oct 2010 16:43:44 -0700
Message-ID: <20101022234344.GA23663__6586.73470975391$1287790715$gmane$org@us.ibm.com>
References: <6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc@us.ibm.com>
	<7da8a050193a91b69ecb3899ce2eda541ecd2473.1285278339.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7da8a050193a91b69ecb3899ce2eda541ecd2473.1285278339.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, Amir Goldstein <amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Aneesh Kumar <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley [matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
<snip>

| To understand why relinking is extremely useful for checkpoint/restart
| consider this simple pseudocode program and a specific example checkpoint
| of it:

I can see how relinking the file simplifies C/R :-) But patch 2 indicates
not all filesystems can support relink. Hope they aren't too many of those.

| 
| 	a_fd = open("a"); /* example: size of the file at "a" is 1GB */
| 	link("a", "b");
| 	unlink("a");
| 	creat("a");
| 	             <---- example: checkpoint happens here
| 	write(a_fd, "bar");
| 
| The file "a" is unlinked and a different file has been placed at that
| path. a_fd still refers to the inode shared with "b".
| 
| Without relinking we would need to walk the entire filesystem to find out
| that "b" is a path to the same inode 

You may want to mention here that to checkpoint/restart a file, we save/
restore the pathname. So finding a path for the unliked file 'a' would
require walking the entire filesystem to find any alias.

| (another variation on this case: "b"
| would also have been unlinked). We'd need to do this for every
| unlinked file that remains open in every task to checkpoint. Even then
| there is no guarantee such a "b" exists for every unlinked file -- the
| inodes could be "orphans" -- and we'd need to preserve their contents
| some other way.
| 
| I considered a couple alternatives to preserving unlinked file contents:

s/couple/couple of/

| copying and file handles. Each has significant drawbacks.
| 
| First I attempted to copy the file contents into the image and then
| recreate and unlink the file during restart. Using a simple version of
| that method the write above would not reach "b". One fix would be to search
| the filesystem for a file with the same inode number (inode of "b") and
| either open it or hardlink it to "a". Another would be to record the inode
| number. This either shifts the search from checkpoint time to restart time
| or has all the drawbacks of the second method I considered: file handles.
| 
| Instead of copying contents or recording inodes I also considered using
| file handles. We'd need to ensure that the filehandles persist in storage,
| can be snapshotted/backed up, and can be migrated. Can handlefs or any
| generic file handle system do this? My _guess_ is "no" but folks are
| welcome to tell me I'm wrong.
| 
| In contrast, linking the file from a_fd back into its filesystem can avoid
| these complexities. Relinking avoids the search for matching inodes and
| copying large quantities of data from storage only to write it back (in
| fact the data would be read-and-written twice -- once for checkpoint and
| once for restart). Like file handles it does require changes to the
| filesystem code. Unlike file handles, enabling relinking does not require
| every filesystem to support a new kind of filesystem "object" -- only
| an operation that is quite similar to one that already exists: link.
| 
| Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| Cc: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
| Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
| Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
| Cc: linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
| Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
| Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
| Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
| Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
| Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
| Cc: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
| Cc: Amir Goldstein <amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>
| Cc: Aneesh Kumar <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
| ---
|  fs/checkpoint.c                  |   51 ++++++++++++++-----
|  fs/namei.c                       |  102 ++++++++++++++++++++++++++++++++++++++
|  fs/pipe.c                        |    2 +-
|  include/linux/checkpoint.h       |    3 +-
|  include/linux/checkpoint_hdr.h   |    3 +
|  include/linux/checkpoint_types.h |    3 +
|  6 files changed, 149 insertions(+), 15 deletions(-)
| 
| diff --git a/fs/checkpoint.c b/fs/checkpoint.c
| index 87d7c6e..9c7caec 100644
| --- a/fs/checkpoint.c
| +++ b/fs/checkpoint.c
| @@ -16,6 +16,7 @@
|  #include <linux/sched.h>
|  #include <linux/file.h>
|  #include <linux/namei.h>
| +#include <linux/mount.h>
|  #include <linux/fs_struct.h>
|  #include <linux/fs.h>
|  #include <linux/fdtable.h>
| @@ -26,6 +27,7 @@
|  #include <linux/checkpoint.h>
|  #include <linux/eventpoll.h>
|  #include <linux/eventfd.h>
| +#include <linux/sys-wrapper.h>
|  #include <net/sock.h>
| 
|  /**************************************************************************
| @@ -174,6 +176,9 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
|  	h->f_pos = file->f_pos;
|  	h->f_version = file->f_version;
| 
| +	if (d_unlinked(file->f_dentry))
| +		/* Perform post-checkpoint and post-restart unlink() */
| +		h->f_restart_flags |= RESTART_FILE_F_UNLINK;
|  	h->f_credref = checkpoint_obj(ctx, f_cred, CKPT_OBJ_CRED);
|  	if (h->f_credref < 0)
|  		return h->f_credref;
| @@ -197,16 +202,6 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
|  	struct ckpt_hdr_file_generic *h;
|  	int ret;
| 
| -	/*
| -	 * FIXME: when we'll add support for unlinked files/dirs, we'll
| -	 * need to distinguish between unlinked filed and unlinked dirs.
| -	 */
| -	if (d_unlinked(file->f_dentry)) {
| -		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
| -			 file);
| -		return -EBADF;
| -	}
| -
|  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
|  	if (!h)
|  		return -ENOMEM;
| @@ -220,6 +215,9 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
|  	if (ret < 0)
|  		goto out;
|  	ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);

Hmm, what file name will be checkpointed here, if the file is unlinked ?

| +	if (ret < 0)
| +		goto out;
| +	ret = checkpoint_file_links(ctx, file);
|   out:
|  	ckpt_hdr_put(ctx, h);
|  	return ret;
| @@ -570,9 +568,11 @@ static int ckpt_read_fname(struct ckpt_ctx *ctx, char **fname)
|  /**
|   * restore_open_fname - read a file name and open a file
|   * @ctx: checkpoint context
| + * @restore_unlinked: unlink the opened file
|   * @flags: file flags
|   */
| -struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
| +struct file *restore_open_fname(struct ckpt_ctx *ctx,
| +				int restore_unlinked, int flags)

nit: s/restore_unlinked/unlinked/ ?

|  {
|  	struct file *file;
|  	char *fname;
| @@ -586,8 +586,33 @@ struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
|  	if (len < 0)
|  		return ERR_PTR(len);
|  	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
| -
| +	if (restore_unlinked) {
| +		kfree(fname);
| +		fname = NULL;
| +		len = ckpt_read_payload(ctx, (void **)&fname, PATH_MAX,
| +					CKPT_HDR_BUFFER);

Hmm, is there a reason we need a special way to read the file name for
unlinked files ? After re-linking the file during checkpoint, can we
not treat it like any other open file (except for the flag) ?

| +		if (len < 0)
| +			return ERR_PTR(len);
| +		fname[len] = '\0';
| +	}
|  	file = filp_open(fname, flags, 0);
| +	if (IS_ERR(file)) {
| +		ckpt_err(ctx, PTR_ERR(file), "Could not open file \"%s\"\n", fname);
| +
| +		goto out;
| +	}
| +	if (!restore_unlinked)
| +		goto out;
| +	if (S_ISDIR(file->f_mapping->host->i_mode))
| +		len = kernel_sys_rmdir(fname);
| +	else
| +		len = kernel_sys_unlink(fname);
| +	if (len < 0) {
| +		ckpt_err(ctx, len, "Could not unlink \"%s\"\n", fname);
| +		fput(file);
| +		file = ERR_PTR(len);
| +	}

nit: how about moving this unlink block to a smaller function ?

| +out:
|  	kfree(fname);
| 
|  	return file;
| @@ -692,7 +717,7 @@ static struct file *generic_file_restore(struct ckpt_ctx *ctx,
|  	    ptr->h.len != sizeof(*ptr) || ptr->f_type != CKPT_FILE_GENERIC)
|  		return ERR_PTR(-EINVAL);
| 
| -	file = restore_open_fname(ctx, ptr->f_flags);
| +	file = restore_open_fname(ctx, !!(ptr->f_restart_flags & RESTART_FILE_F_UNLINK), ptr->f_flags);

nit: long line

|  	if (IS_ERR(file))
|  		return file;
| 
| diff --git a/fs/namei.c b/fs/namei.c
| index 8c9663d..69c4f4e 100644
| --- a/fs/namei.c
| +++ b/fs/namei.c
| @@ -32,6 +32,9 @@
|  #include <linux/fcntl.h>
|  #include <linux/device_cgroup.h>
|  #include <linux/fs_struct.h>
| +#ifdef CONFIG_CHECKPOINT
| +#include <linux/checkpoint.h>
| +#endif
|  #include <asm/uaccess.h>
| 
|  #include "internal.h"
| @@ -2543,6 +2546,105 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, const char __user *, newname
|  	return sys_linkat(AT_FDCWD, oldname, AT_FDCWD, newname, 0);
|  }
| 
| +#ifdef CONFIG_CHECKPOINT
| +
| +/* Path relative to the mounted filesystem's root -- not a "global" root or even a namespace root. The unique_name_count is unique for the entire checkpoint. */
| +#define CKPT_RELINKAT_FMT "lost+found/checkpoint/unlink-at-restart-%08llx-%u"
| +
| +static int checkpoint_fill_relink_fname(struct ckpt_ctx *ctx,

nit. since it is a static function, we could probably drop the 'checkpoint_'
prefix in the name ?

| +					struct file *for_file,
| +					char relink_dir_pathname[PATH_MAX],
| +					int *lenp)
| +{
| +	struct path relink_dir_path;

nit. since the function name has "relink", maybe variable names can skip
(code is easier to read with smaller variable names).

| +	char *tmp;
| +	int len;
| +
| +	/* Find path to mount */
| +	relink_dir_path.mnt = for_file->f_path.mnt;
| +	relink_dir_path.dentry = relink_dir_path.mnt->mnt_root;
| +	tmp = d_path(&relink_dir_path, relink_dir_pathname, PATH_MAX);
| +	if (IS_ERR(tmp))
| +		return PTR_ERR(tmp);
| +
| +	/* Append path to relinked file. */
| +	len = strlen(tmp);
| +	if (len <= 0)
| +		return -ENOENT;
| +	memmove(relink_dir_pathname, tmp, len);
| +	tmp = relink_dir_pathname + len - 1;
| +	/* Ensure we've got a single dir separator */
| +	if (*tmp == '/')
| +		tmp++;
| +	else {
| +		tmp++;

we could simplify the 'if-else' by making the tmp++ unconditional (or by
removing the -1 above).

| +		*tmp = '/';
| +		tmp++;
| +		len++;
| +	}
| +	len += snprintf(tmp, PATH_MAX - len, CKPT_RELINKAT_FMT,
| +			ctx->ktime_begin.tv64,
| +			 ++ctx->unique_name_count);

Since the format is dependent on additional parameters (tv64, unique_name_count)
any changes to the format will require updates in multiple places in the future
right ? That would make the CKPT_RELINKAT_FMT macro less useful.

Instead how about a function like this that could be used during both checkpoint
and restart: 

	static inline int generate_relinked_path(ctx, buf, len)
	{
		return sprintf(...);
	}

| +	relink_dir_pathname[len] = '\0';
| +	*lenp = len;
| +	return 0;
| +}
| +
| +static int checkpoint_file_relink(struct ckpt_ctx *ctx,
| +				  struct file *file,
| +				  char new_path[PATH_MAX])
| +{
| +	int ret, len;
| +
| +	/* 
| +	 * Relinking arbitrary files without searching a path
| +	 * (which non-existent if the file is unlinked) requires

s/which/which is/
s/file is/file was/

| +	 * special privileges.
| +	 */
| +	if (!capable(CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH)) {
| +		ckpt_err(ctx, -EPERM, "%(T)Relinking unlinked files requires CAP_DAC_{OVERRIDE,READ_SEARCH}\n");

nit: long line

| +		return -EPERM;
| +	}
nit: a blank line here might help
| +	ret = checkpoint_fill_relink_fname(ctx, file, new_path, &len);
| +	if (ret)
| +		return ret;
| +	ret = do_kern_linkat(&file->f_path, file->f_dentry,
| +			     AT_FDCWD, new_path, 0);
| +	if (ret)
| +		ckpt_err(ctx, ret, "%(T)%(P)%(V)Failed to relink unlinked file.\n", file, file->f_op);

nit: long line

| +	return ret;
| +}
| +
| +int checkpoint_file_links(struct ckpt_ctx *ctx, struct file *file)
| +{
| +	char *new_link_path;
| +	int ret, len;
| +
| +	if (!d_unlinked(file->f_dentry))
| +		return 0;
| +
| +	/*
| +	 * Unlinked files need at least one hardlink for the post-sys_checkpoint
| +	 * filesystem backup/snapshot.
| +	 */
| +	new_link_path = kmalloc(PATH_MAX, GFP_KERNEL);
| +	if (!new_link_path)
| +		return -ENOMEM;
| +	ret = checkpoint_file_relink(ctx, file, new_link_path);
| +	if (ret < 0)
| +		goto out_free;
| +	len = strlen(new_link_path);
| +	ret = ckpt_write_obj_type(ctx, NULL, len + 1, CKPT_HDR_BUFFER);
| +	if (ret < 0)
| +		goto out_free;
| +	ret = ckpt_kwrite(ctx, new_link_path, len + 1);
| +out_free:
| +	kfree(new_link_path);
| +
| +	return ret;
| +}

nit: some blank lines separating the different sections of the function will
help readability

Sukadev
