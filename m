From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/12] Move checkpoint/files.c into fs/
Date: Fri, 26 Feb 2010 00:45:07 -0800
Message-ID: <d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Subsequent patches break up fs/checkpoint.c into the file table checkpoint,
the fs_struct checkpoint, etc.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/Makefile |    1 -
 checkpoint/files.c  | 1041 ---------------------------------------------------
 fs/Makefile         |    1 +
 fs/checkpoint.c     | 1041 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 1042 insertions(+), 1042 deletions(-)
 delete mode 100644 checkpoint/files.c
 create mode 100644 fs/checkpoint.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index f8a55df..02e66b6 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -9,6 +9,5 @@ obj-$(CONFIG_CHECKPOINT) += \
 	restart.o \
 	process.o \
 	namespace.o \
-	files.o \
 	memory.o \
 	signal.o
diff --git a/checkpoint/files.c b/checkpoint/files.c
deleted file mode 100644
index 2859cf9..0000000
--- a/checkpoint/files.c
+++ /dev/null
@@ -1,1041 +0,0 @@
-/*
- *  Checkpoint file descriptors
- *
- *  Copyright (C) 2008-2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DFILE
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/sched.h>
-#include <linux/file.h>
-#include <linux/namei.h>
-#include <linux/fs_struct.h>
-#include <linux/fs.h>
-#include <linux/fdtable.h>
-#include <linux/fsnotify.h>
-#include <linux/pipe_fs_i.h>
-#include <linux/syscalls.h>
-#include <linux/deferqueue.h>
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-#include <linux/eventpoll.h>
-#include <linux/eventfd.h>
-#include <net/sock.h>
-
-
-/**************************************************************************
- * Checkpoint
- */
-
-/**
- * ckpt_fill_fname - return pathname of a given file
- * @path: path name
- * @root: relative root
- * @buf: buffer for pathname
- * @len: buffer length (in) and pathname length (out)
- */
-char *ckpt_fill_fname(struct path *path, struct path *root, char *buf, int *len)
-{
-	struct path tmp = *root;
-	char *fname;
-
-	BUG_ON(!buf);
-	spin_lock(&dcache_lock);
-	fname = __d_path(path, &tmp, buf, *len);
-	spin_unlock(&dcache_lock);
-	if (IS_ERR(fname))
-		return fname;
-	*len = (buf + (*len) - fname);
-	/*
-	 * FIX: if __d_path() changed these, it must have stepped out of
-	 * init's namespace. Since currently we require a unified namespace
-	 * within the container: simply fail.
-	 */
-	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
-		fname = ERR_PTR(-EBADF);
-
-	return fname;
-}
-
-/**
- * checkpoint_fname - write a file name
- * @ctx: checkpoint context
- * @path: path name
- * @root: relative root
- */
-int checkpoint_fname(struct ckpt_ctx *ctx, struct path *path, struct path *root)
-{
-	char *buf, *fname;
-	int ret, flen;
-
-	/*
-	 * FIXME: we can optimize and save memory (and storage) if we
-	 * share strings (through objhash) and reference them instead
-	 */
-
-	flen = PATH_MAX;
-	buf = kmalloc(flen, GFP_KERNEL);
-	if (!buf)
-		return -ENOMEM;
-
-	fname = ckpt_fill_fname(path, root, buf, &flen);
-	if (!IS_ERR(fname)) {
-		ret = ckpt_write_obj_type(ctx, fname, flen,
-					  CKPT_HDR_FILE_NAME);
-	} else {
-		ret = PTR_ERR(fname);
-		ckpt_err(ctx, ret, "%(T)%(S)Obtain filename\n",
-			 path->dentry->d_name.name);
-	}
-
-	kfree(buf);
-	return ret;
-}
-
-#define CKPT_DEFAULT_FDTABLE  256		/* an initial guess */
-
-/**
- * scan_fds - scan file table and construct array of open fds
- * @files: files_struct pointer
- * @fdtable: (output) array of open fds
- *
- * Returns the number of open fds found, and also the file table
- * array via *fdtable. The caller should free the array.
- *
- * The caller must validate the file descriptors collected in the
- * array before using them, e.g. by using fcheck_files(), in case
- * the task's fdtable changes in the meantime.
- */
-static int scan_fds(struct files_struct *files, int **fdtable)
-{
-	struct fdtable *fdt;
-	int *fds = NULL;
-	int i = 0, n = 0;
-	int tot = CKPT_DEFAULT_FDTABLE;
-
-	/*
-	 * We assume that all tasks possibly sharing the file table are
-	 * frozen (or we are a single process and we checkpoint ourselves).
-	 * Therefore, we can safely proceed after krealloc() from where we
-	 * left off. Otherwise the file table may be modified by another
-	 * task after we scan it. The behavior is this case is undefined,
-	 * and either checkpoint or restart will likely fail.
-	 */
- retry:
-	fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
-	if (!fds)
-		return -ENOMEM;
-
-	rcu_read_lock();
-	fdt = files_fdtable(files);
-	for (/**/; i < fdt->max_fds; i++) {
-		if (!fcheck_files(files, i))
-			continue;
-		if (n == tot) {
-			rcu_read_unlock();
-			tot *= 2;	/* won't overflow: kmalloc will fail */
-			goto retry;
-		}
-		fds[n++] = i;
-	}
-	rcu_read_unlock();
-
-	*fdtable = fds;
-	return n;
-}
-
-#ifdef CONFIG_SECURITY
-int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
-{
-	return security_checkpoint_obj(ctx, file->f_security,
-				       CKPT_SECURITY_FILE);
-}
-#else
-int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
-{
-	return SECURITY_CTX_NONE;
-}
-#endif
-
-int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
-			   struct ckpt_hdr_file *h)
-{
-	struct cred *f_cred = (struct cred *) file->f_cred;
-
-	h->f_flags = file->f_flags;
-	h->f_mode = file->f_mode;
-	h->f_pos = file->f_pos;
-	h->f_version = file->f_version;
-
-	h->f_credref = checkpoint_obj(ctx, f_cred, CKPT_OBJ_CRED);
-	if (h->f_credref < 0)
-		return h->f_credref;
-
-	h->f_secref = checkpoint_file_security(ctx, file);
-	if (h->f_secref < 0) {
-		ckpt_err(ctx, h->f_secref, "%(T)file->f_security");
-		return h->f_secref;
-	}
-
-	ckpt_debug("file %s credref %d secref %d\n",
-		file->f_dentry->d_name.name, h->f_credref, h->f_secref);
-
-	/* FIX: need also file->f_owner, etc */
-
-	return 0;
-}
-
-int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
-{
-	struct ckpt_hdr_file_generic *h;
-	int ret;
-
-	/*
-	 * FIXME: when we'll add support for unlinked files/dirs, we'll
-	 * need to distinguish between unlinked filed and unlinked dirs.
-	 */
-	if (d_unlinked(file->f_dentry)) {
-		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
-			 file);
-		return -EBADF;
-	}
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
-	if (!h)
-		return -ENOMEM;
-
-	h->common.f_type = CKPT_FILE_GENERIC;
-
-	ret = checkpoint_file_common(ctx, file, &h->common);
-	if (ret < 0)
-		goto out;
-	ret = ckpt_write_obj(ctx, &h->common.h);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-EXPORT_SYMBOL(generic_file_checkpoint);
-
-/* checkpoint callback for file pointer */
-int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
-{
-	struct file *file = (struct file *) ptr;
-	int ret;
-
-	if (!file->f_op || !file->f_op->checkpoint) {
-		ckpt_err(ctx, -EBADF, "%(T)%(P)%(V)f_op lacks checkpoint\n",
-			       file, file->f_op);
-		return -EBADF;
-	}
-
-	if (is_dnotify_attached(file)) {
-		ckpt_err(ctx, -EBADF, "%(T)%(P)dnotify unsupported\n", file);
-		return -EBADF;
-	}
-
-	ret = file->f_op->checkpoint(ctx, file);
-	if (ret < 0)
-		ckpt_err(ctx, ret, "%(T)%(P)file checkpoint failed\n", file);
-	return ret;
-}
-
-/**
- * ckpt_write_file_desc - dump the state of a given file descriptor
- * @ctx: checkpoint context
- * @files: files_struct pointer
- * @fd: file descriptor
- *
- * Saves the state of the file descriptor; looks up the actual file
- * pointer in the hash table, and if found saves the matching objref,
- * otherwise calls ckpt_write_file to dump the file pointer too.
- */
-static int checkpoint_file_desc(struct ckpt_ctx *ctx,
-				struct files_struct *files, int fd)
-{
-	struct ckpt_hdr_file_desc *h;
-	struct file *file = NULL;
-	struct fdtable *fdt;
-	int objref, ret;
-	int coe = 0;	/* avoid gcc warning */
-	pid_t pid;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
-	if (!h)
-		return -ENOMEM;
-
-	rcu_read_lock();
-	fdt = files_fdtable(files);
-	file = fcheck_files(files, fd);
-	if (file) {
-		coe = FD_ISSET(fd, fdt->close_on_exec);
-		get_file(file);
-	}
-	rcu_read_unlock();
-
-	ret = find_locks_with_owner(file, files);
-	/*
-	 * find_locks_with_owner() returns an error when there
-	 * are no locks found, so we *want* it to return an error
-	 * code.  Its success means we have to fail the checkpoint.
-	 */
-	if (!ret) {
-		ret = -EBADF;
-		ckpt_err(ctx, ret, "%(T)fd %d has file lock or lease\n", fd);
-		goto out;
-	}
-
-	/* sanity check (although this shouldn't happen) */
-	ret = -EBADF;
-	if (!file) {
-		ckpt_err(ctx, ret, "%(T)fd %d gone?\n", fd);
-		goto out;
-	}
-
-	/*
-	 * TODO: Implement c/r of fowner and f_sigio.  Should be
-	 * trivial, but for now we just refuse its checkpoint
-	 */
-	pid = f_getown(file);
-	if (pid) {
-		ret = -EBUSY;
-		ckpt_err(ctx, ret, "%(T)fd %d has an owner (%d)\n", fd);
-		goto out;
-	}
-
-	/*
-	 * if seen first time, this will add 'file' to the objhash, keep
-	 * a reference to it, dump its state while at it.
-	 */
-	objref = checkpoint_obj(ctx, file, CKPT_OBJ_FILE);
-	ckpt_debug("fd %d objref %d file %p coe %d)\n", fd, objref, file, coe);
-	if (objref < 0) {
-		ret = objref;
-		goto out;
-	}
-
-	h->fd_objref = objref;
-	h->fd_descriptor = fd;
-	h->fd_close_on_exec = coe;
-
-	ret = ckpt_write_obj(ctx, &h->h);
-out:
-	ckpt_hdr_put(ctx, h);
-	if (file)
-		fput(file);
-	return ret;
-}
-
-static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
-				    struct files_struct *files)
-{
-	struct ckpt_hdr_file_table *h;
-	int *fdtable = NULL;
-	int nfds, n, ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_TABLE);
-	if (!h)
-		return -ENOMEM;
-
-	nfds = scan_fds(files, &fdtable);
-	if (nfds < 0) {
-		ret = nfds;
-		goto out;
-	}
-
-	h->fdt_nfds = nfds;
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	if (ret < 0)
-		goto out;
-
-	ckpt_debug("nfds %d\n", nfds);
-	for (n = 0; n < nfds; n++) {
-		ret = checkpoint_file_desc(ctx, files, fdtable[n]);
-		if (ret < 0)
-			goto out;
-	}
-
-	ret = deferqueue_run(ctx->files_deferq);
-	ckpt_debug("files_deferq ran %d entries\n", ret);
-	if (ret > 0)
-		ret = 0;
- out:
-	kfree(fdtable);
-	return ret;
-}
-
-/* checkpoint callback for file table */
-int checkpoint_file_table(struct ckpt_ctx *ctx, void *ptr)
-{
-	return do_checkpoint_file_table(ctx, (struct files_struct *) ptr);
-}
-
-/* checkpoint wrapper for file table */
-int checkpoint_obj_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct files_struct *files;
-	int objref;
-
-	files = get_files_struct(t);
-	if (!files)
-		return -EBUSY;
-	objref = checkpoint_obj(ctx, files, CKPT_OBJ_FILE_TABLE);
-	put_files_struct(files);
-
-	return objref;
-}
-
-int checkpoint_obj_fs(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct fs_struct *fs;
-	int fs_objref;
-
-	task_lock(current);
-	fs = t->fs;
-	get_fs_struct(fs);
-	task_unlock(current);
-
-	fs_objref = checkpoint_obj(ctx, fs, CKPT_OBJ_FS);
-	put_fs_struct(fs);
-
-	return fs_objref;
-}
-
-/* called with fs refcount bumped so it won't disappear */
-static int do_checkpoint_fs(struct ckpt_ctx *ctx, struct fs_struct *fs)
-{
-	struct ckpt_hdr_fs *h;
-	struct fs_struct *fscopy;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FS);
-	if (!h)
-		return -ENOMEM;
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	if (ret)
-		return ret;
-
-	fscopy = copy_fs_struct(fs);
-	if (!fs)
-		return -ENOMEM;
-
-	ret = checkpoint_fname(ctx, &fscopy->pwd, &ctx->root_fs_path);
-	if (ret < 0) {
-		ckpt_err(ctx, ret, "%(T)writing path of cwd");
-		goto out;
-	}
-	ret = checkpoint_fname(ctx, &fscopy->root, &ctx->root_fs_path);
-	if (ret < 0) {
-		ckpt_err(ctx, ret, "%(T)writing path of fs root");
-		goto out;
-	}
-	ret = 0;
- out:
-	free_fs_struct(fscopy);
-	return ret;
-}
-
-int checkpoint_fs(struct ckpt_ctx *ctx, void *ptr)
-{
-	return do_checkpoint_fs(ctx, (struct fs_struct *) ptr);
-}
-
-/***********************************************************************
- * Collect
- */
-
-int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file)
-{
-	int ret;
-
-	ret = ckpt_obj_collect(ctx, file, CKPT_OBJ_FILE);
-	if (ret <= 0)
-		return ret;
-	/* if first time for this file (ret > 0), invoke ->collect() */
-	if (file->f_op->collect)
-		ret = file->f_op->collect(ctx, file);
-	if (ret < 0)
-		ckpt_err(ctx, ret, "%(T)%(P)File collect\n", file);
-	return ret;
-}
-
-static int collect_file_desc(struct ckpt_ctx *ctx,
-			     struct files_struct *files, int fd)
-{
-	struct fdtable *fdt;
-	struct file *file;
-	int ret;
-
-	rcu_read_lock();
-	fdt = files_fdtable(files);
-	file = fcheck_files(files, fd);
-	if (file)
-		get_file(file);
-	rcu_read_unlock();
-
-	if (!file) {
-		ckpt_err(ctx, -EBUSY, "%(T)%(P)File removed\n", file);
-		return -EBUSY;
-	}
-
-	ret = ckpt_collect_file(ctx, file);
-	fput(file);
-
-	return ret;
-}
-
-static int collect_file_table(struct ckpt_ctx *ctx, struct files_struct *files)
-{
-	int *fdtable;
-	int nfds, n;
-	int ret;
-
-	/* if already exists (ret == 0), nothing to do */
-	ret = ckpt_obj_collect(ctx, files, CKPT_OBJ_FILE_TABLE);
-	if (ret <= 0)
-		return ret;
-
-	/* if first time for this file table (ret > 0), proceed inside */
-	nfds = scan_fds(files, &fdtable);
-	if (nfds < 0)
-		return nfds;
-
-	for (n = 0; n < nfds; n++) {
-		ret = collect_file_desc(ctx, files, fdtable[n]);
-		if (ret < 0)
-			break;
-	}
-
-	kfree(fdtable);
-	return ret;
-}
-
-int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct files_struct *files;
-	int ret;
-
-	files = get_files_struct(t);
-	if (!files) {
-		ckpt_err(ctx, -EBUSY, "%(T)files_struct missing\n");
-		return -EBUSY;
-	}
-	ret = collect_file_table(ctx, files);
-	put_files_struct(files);
-
-	return ret;
-}
-
-int ckpt_collect_fs(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct fs_struct *fs;
-	int ret;
-
-	task_lock(t);
-	fs = t->fs;
-	get_fs_struct(fs);
-	task_unlock(t);
-
-	ret = ckpt_obj_collect(ctx, fs, CKPT_OBJ_FS);
-
-	put_fs_struct(fs);
-	return ret;
-}
-
-/**************************************************************************
- * Restart
- */
-
-static int ckpt_read_fname(struct ckpt_ctx *ctx, char **fname)
-{
-	int len;
-
-	len = ckpt_read_payload(ctx, (void **) fname,
-				PATH_MAX, CKPT_HDR_FILE_NAME);
-	if (len < 0)
-		return len;
-
-	(*fname)[len - 1] = '\0';	/* always play if safe */
-	ckpt_debug("read filename '%s'\n", *fname);
-
-	return len;
-}
-
-/**
- * restore_open_fname - read a file name and open a file
- * @ctx: checkpoint context
- * @flags: file flags
- */
-struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
-{
-	struct file *file;
-	char *fname;
-	int len;
-
-	/* prevent bad input from doing bad things */
-	if (flags & (O_CREAT | O_EXCL | O_NOCTTY | O_TRUNC))
-		return ERR_PTR(-EINVAL);
-
-	len = ckpt_read_fname(ctx, &fname);
-	if (len < 0)
-		return ERR_PTR(len);
-	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
-
-	file = filp_open(fname, flags, 0);
-	kfree(fname);
-
-	return file;
-}
-
-static int close_all_fds(struct files_struct *files)
-{
-	int *fdtable;
-	int nfds;
-
-	nfds = scan_fds(files, &fdtable);
-	if (nfds < 0)
-		return nfds;
-	while (nfds--)
-		sys_close(fdtable[nfds]);
-	kfree(fdtable);
-	return 0;
-}
-
-/**
- * attach_file - attach a lonely file ptr to a file descriptor
- * @file: lonely file pointer
- */
-static int attach_file(struct file *file)
-{
-	int fd = get_unused_fd_flags(0);
-
-	if (fd >= 0) {
-		get_file(file);
-		fsnotify_open(file->f_path.dentry);
-		fd_install(fd, file);
-	}
-	return fd;
-}
-
-#define CKPT_SETFL_MASK  \
-	(O_APPEND | O_NONBLOCK | O_NDELAY | FASYNC | O_DIRECT | O_NOATIME)
-
-int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
-			struct ckpt_hdr_file *h)
-{
-	fmode_t new_mode = file->f_mode;
-	fmode_t saved_mode = (__force fmode_t) h->f_mode;
-	int ret;
-	struct cred *cred;
-
-	/* FIX: need to restore owner etc */
-
-	/* restore the cred */
-	cred = ckpt_obj_fetch(ctx, h->f_credref, CKPT_OBJ_CRED);
-	if (IS_ERR(cred))
-		return PTR_ERR(cred);
-	put_cred(file->f_cred);
-	file->f_cred = get_cred(cred);
-
-	ret = security_restore_obj(ctx, (void *) file, CKPT_SECURITY_FILE,
-				   h->f_secref);
-	if (ret < 0) {
-		ckpt_err(ctx, ret, "file secref %(O)%(P)\n", h->f_secref,
-			 file);
-		return ret;
-	}
-
-	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
-	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
-	if (ret < 0)
-		return ret;
-
-	/*
-	 * Normally f_mode is set by open, and modified only via
-	 * fcntl(), so its value now should match that at checkpoint.
-	 * However, a file may be downgraded from (read-)write to
-	 * read-only, e.g:
-	 *  - mark_files_ro() unsets FMODE_WRITE
-	 *  - nfs4_file_downgrade() too, and also sert FMODE_READ
-	 * Validate the new f_mode against saved f_mode, allowing:
-	 *  - new with FMODE_WRITE, saved without FMODE_WRITE
-	 *  - new without FMODE_READ, saved with FMODE_READ
-	 */
-	if ((new_mode & FMODE_WRITE) && !(saved_mode & FMODE_WRITE)) {
-		new_mode &= ~FMODE_WRITE;
-		if (!(new_mode & FMODE_READ) && (saved_mode & FMODE_READ))
-			new_mode |= FMODE_READ;
-	}
-	/* finally, at this point new mode should match saved mode */
-	if (new_mode ^ saved_mode)
-		return -EINVAL;
-
-	if (file->f_mode & FMODE_LSEEK)
-		ret = vfs_llseek(file, h->f_pos, SEEK_SET);
-
-	return ret;
-}
-
-static struct file *generic_file_restore(struct ckpt_ctx *ctx,
-					 struct ckpt_hdr_file *ptr)
-{
-	struct file *file;
-	int ret;
-
-	if (ptr->h.type != CKPT_HDR_FILE  ||
-	    ptr->h.len != sizeof(*ptr) || ptr->f_type != CKPT_FILE_GENERIC)
-		return ERR_PTR(-EINVAL);
-
-	file = restore_open_fname(ctx, ptr->f_flags);
-	if (IS_ERR(file))
-		return file;
-
-	ret = restore_file_common(ctx, file, ptr);
-	if (ret < 0) {
-		fput(file);
-		file = ERR_PTR(ret);
-	}
-	return file;
-}
-
-struct restore_file_ops {
-	char *file_name;
-	enum file_type file_type;
-	struct file * (*restore) (struct ckpt_ctx *ctx,
-				  struct ckpt_hdr_file *ptr);
-};
-
-static struct restore_file_ops restore_file_ops[] = {
-	/* ignored file */
-	{
-		.file_name = "IGNORE",
-		.file_type = CKPT_FILE_IGNORE,
-		.restore = NULL,
-	},
-	/* regular file/directory */
-	{
-		.file_name = "GENERIC",
-		.file_type = CKPT_FILE_GENERIC,
-		.restore = generic_file_restore,
-	},
-	/* pipes */
-	{
-		.file_name = "PIPE",
-		.file_type = CKPT_FILE_PIPE,
-		.restore = pipe_file_restore,
-	},
-	/* fifo */
-	{
-		.file_name = "FIFO",
-		.file_type = CKPT_FILE_FIFO,
-		.restore = fifo_file_restore,
-	},
-	/* socket */
-	{
-		.file_name = "SOCKET",
-		.file_type = CKPT_FILE_SOCKET,
-		.restore = sock_file_restore,
-	},
-	/* tty */
-	{
-		.file_name = "TTY",
-		.file_type = CKPT_FILE_TTY,
-		.restore = tty_file_restore,
-	},
-	/* epoll */
-	{
-		.file_name = "EPOLL",
-		.file_type = CKPT_FILE_EPOLL,
-		.restore = ep_file_restore,
-	},
-	/* eventfd */
-	{
-		.file_name = "EVENTFD",
-		.file_type = CKPT_FILE_EVENTFD,
-		.restore = eventfd_restore,
-	},
-};
-
-static struct file *do_restore_file(struct ckpt_ctx *ctx)
-{
-	struct restore_file_ops *ops;
-	struct ckpt_hdr_file *h;
-	struct file *file = ERR_PTR(-EINVAL);
-
-	/*
-	 * All 'struct ckpt_hdr_file_...' begin with ckpt_hdr_file,
-	 * but the actual object depends on the file type. The length
-	 * should never be more than page.
-	 */
-	h = ckpt_read_buf_type(ctx, PAGE_SIZE, CKPT_HDR_FILE);
-	if (IS_ERR(h))
-		return (struct file *) h;
-	ckpt_debug("flags %#x mode %#x type %d\n",
-		 h->f_flags, h->f_mode, h->f_type);
-
-	if (h->f_type >= CKPT_FILE_MAX)
-		goto out;
-
-	ops = &restore_file_ops[h->f_type];
-	BUG_ON(ops->file_type != h->f_type);
-
-	if (ops->restore)
-		file = ops->restore(ctx, h);
- out:
-	ckpt_hdr_put(ctx, h);
-	return file;
-}
-
-/* restore callback for file pointer */
-void *restore_file(struct ckpt_ctx *ctx)
-{
-	return (void *) do_restore_file(ctx);
-}
-
-/**
- * ckpt_read_file_desc - restore the state of a given file descriptor
- * @ctx: checkpoint context
- *
- * Restores the state of a file descriptor; looks up the objref (in the
- * header) in the hash table, and if found picks the matching file and
- * use it; otherwise calls restore_file to restore the file too.
- */
-static int restore_file_desc(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_file_desc *h;
-	struct file *file;
-	int newfd, ret;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-	ckpt_debug("ref %d fd %d c.o.e %d\n",
-		 h->fd_objref, h->fd_descriptor, h->fd_close_on_exec);
-
-	ret = -EINVAL;
-	if (h->fd_objref <= 0 || h->fd_descriptor < 0)
-		goto out;
-
-	file = ckpt_obj_fetch(ctx, h->fd_objref, CKPT_OBJ_FILE);
-	if (IS_ERR(file)) {
-		ret = PTR_ERR(file);
-		goto out;
-	}
-
-	newfd = attach_file(file);
-	if (newfd < 0) {
-		ret = newfd;
-		goto out;
-	}
-
-	ckpt_debug("newfd got %d wanted %d\n", newfd, h->fd_descriptor);
-
-	/* reposition if newfd isn't desired fd */
-	if (newfd != h->fd_descriptor) {
-		ret = sys_dup2(newfd, h->fd_descriptor);
-		if (ret < 0)
-			goto out;
-		sys_close(newfd);
-	}
-
-	set_close_on_exec(h->fd_descriptor, h->fd_close_on_exec);
-	ret = 0;
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-/* restore callback for file table */
-static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_file_table *h;
-	struct files_struct *files;
-	int i, ret;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_TABLE);
-	if (IS_ERR(h))
-		return (struct files_struct *) h;
-
-	ckpt_debug("nfds %d\n", h->fdt_nfds);
-
-	ret = -EMFILE;
-	if (h->fdt_nfds < 0 || h->fdt_nfds > sysctl_nr_open)
-		goto out;
-
-	/*
-	 * We assume that restarting tasks, as created in user-space,
-	 * have distinct files_struct objects each. If not, we need to
-	 * call dup_fd() to make sure we don't overwrite an already
-	 * restored one.
-	 */
-
-	/* point of no return -- close all file descriptors */
-	ret = close_all_fds(current->files);
-	if (ret < 0)
-		goto out;
-
-	for (i = 0; i < h->fdt_nfds; i++) {
-		ret = restore_file_desc(ctx);
-		if (ret < 0)
-			goto out;
-	}
-
-	ret = deferqueue_run(ctx->files_deferq);
-	ckpt_debug("files_deferq ran %d entries\n", ret);
-	if (ret > 0)
-		ret = 0;
- out:
-	ckpt_hdr_put(ctx, h);
-	if (!ret) {
-		files = current->files;
-		atomic_inc(&files->count);
-	} else {
-		files = ERR_PTR(ret);
-	}
-	return files;
-}
-
-void *restore_file_table(struct ckpt_ctx *ctx)
-{
-	return (void *) do_restore_file_table(ctx);
-}
-
-int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref)
-{
-	struct files_struct *files;
-
-	files = ckpt_obj_fetch(ctx, files_objref, CKPT_OBJ_FILE_TABLE);
-	if (IS_ERR(files))
-		return PTR_ERR(files);
-
-	if (files != current->files) {
-		task_lock(current);
-		put_files_struct(current->files);
-		current->files = files;
-		task_unlock(current);
-		atomic_inc(&files->count);
-	}
-
-	return 0;
-}
-
-/*
- * Called by task restore code to set the restarted task's
- * current->fs to an entry on the hash
- */
-int restore_obj_fs(struct ckpt_ctx *ctx, int fs_objref)
-{
-	struct fs_struct *newfs, *oldfs;
-
-	newfs = ckpt_obj_fetch(ctx, fs_objref, CKPT_OBJ_FS);
-	if (IS_ERR(newfs))
-		return PTR_ERR(newfs);
-
-	task_lock(current);
-	get_fs_struct(newfs);
-	oldfs = current->fs;
-	current->fs = newfs;
-	task_unlock(current);
-	put_fs_struct(oldfs);
-
-	return 0;
-}
-
-static int restore_chroot(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
-{
-	struct nameidata nd;
-	int ret;
-
-	ckpt_debug("attempting chroot to %s\n", name);
-	ret = path_lookup(name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &nd);
-	if (ret) {
-		ckpt_err(ctx, ret, "%(T)Opening chroot dir %s", name);
-		return ret;
-	}
-	ret = do_chroot(fs, &nd.path);
-	path_put(&nd.path);
-	if (ret) {
-		ckpt_err(ctx, ret, "%(T)Setting chroot %s", name);
-		return ret;
-	}
-	return 0;
-}
-
-static int restore_cwd(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
-{
-	struct nameidata nd;
-	int ret;
-
-	ckpt_debug("attempting chdir to %s\n", name);
-	ret = path_lookup(name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &nd);
-	if (ret) {
-		ckpt_err(ctx, ret, "%(T)Opening cwd %s", name);
-		return ret;
-	}
-	ret = do_chdir(fs, &nd.path);
-	path_put(&nd.path);
-	if (ret) {
-		ckpt_err(ctx, ret, "%(T)Setting cwd %s", name);
-		return ret;
-	}
-	return 0;
-}
-
-/*
- * Called by objhash when it runs into a CKPT_OBJ_FS entry. Creates
- * an fs_struct with desired chroot/cwd and places it in the hash.
- */
-static struct fs_struct *do_restore_fs(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_fs *h;
-	struct fs_struct *fs;
-	char *path;
-	int ret = 0;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FS);
-	if (IS_ERR(h))
-		return ERR_PTR(PTR_ERR(h));
-	ckpt_hdr_put(ctx, h);
-
-	fs = copy_fs_struct(current->fs);
-	if (!fs)
-		return ERR_PTR(-ENOMEM);
-
-	ret = ckpt_read_fname(ctx, &path);
-	if (ret < 0)
-		goto out;
-	ret = restore_cwd(ctx, fs, path);
-	kfree(path);
-	if (ret)
-		goto out;
-
-	ret = ckpt_read_fname(ctx, &path);
-	if (ret < 0)
-		goto out;
-	ret = restore_chroot(ctx, fs, path);
-	kfree(path);
-
-out:
-	if (ret) {
-		free_fs_struct(fs);
-		return ERR_PTR(ret);
-	}
-	return fs;
-}
-
-void *restore_fs(struct ckpt_ctx *ctx)
-{
-	return (void *) do_restore_fs(ctx);
-}
diff --git a/fs/Makefile b/fs/Makefile
index af6d047..93c4775 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_EVENTFD)		+= eventfd.o
 obj-$(CONFIG_AIO)               += aio.o
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
+obj-$(CONFIG_CHECKPOINT)	+= checkpoint.o
 
 nfsd-$(CONFIG_NFSD)		:= nfsctl.o
 obj-y				+= $(nfsd-y) $(nfsd-m)
diff --git a/fs/checkpoint.c b/fs/checkpoint.c
new file mode 100644
index 0000000..2859cf9
--- /dev/null
+++ b/fs/checkpoint.c
@@ -0,0 +1,1041 @@
+/*
+ *  Checkpoint file descriptors
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DFILE
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/namei.h>
+#include <linux/fs_struct.h>
+#include <linux/fs.h>
+#include <linux/fdtable.h>
+#include <linux/fsnotify.h>
+#include <linux/pipe_fs_i.h>
+#include <linux/syscalls.h>
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/eventpoll.h>
+#include <linux/eventfd.h>
+#include <net/sock.h>
+
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/**
+ * ckpt_fill_fname - return pathname of a given file
+ * @path: path name
+ * @root: relative root
+ * @buf: buffer for pathname
+ * @len: buffer length (in) and pathname length (out)
+ */
+char *ckpt_fill_fname(struct path *path, struct path *root, char *buf, int *len)
+{
+	struct path tmp = *root;
+	char *fname;
+
+	BUG_ON(!buf);
+	spin_lock(&dcache_lock);
+	fname = __d_path(path, &tmp, buf, *len);
+	spin_unlock(&dcache_lock);
+	if (IS_ERR(fname))
+		return fname;
+	*len = (buf + (*len) - fname);
+	/*
+	 * FIX: if __d_path() changed these, it must have stepped out of
+	 * init's namespace. Since currently we require a unified namespace
+	 * within the container: simply fail.
+	 */
+	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
+		fname = ERR_PTR(-EBADF);
+
+	return fname;
+}
+
+/**
+ * checkpoint_fname - write a file name
+ * @ctx: checkpoint context
+ * @path: path name
+ * @root: relative root
+ */
+int checkpoint_fname(struct ckpt_ctx *ctx, struct path *path, struct path *root)
+{
+	char *buf, *fname;
+	int ret, flen;
+
+	/*
+	 * FIXME: we can optimize and save memory (and storage) if we
+	 * share strings (through objhash) and reference them instead
+	 */
+
+	flen = PATH_MAX;
+	buf = kmalloc(flen, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	fname = ckpt_fill_fname(path, root, buf, &flen);
+	if (!IS_ERR(fname)) {
+		ret = ckpt_write_obj_type(ctx, fname, flen,
+					  CKPT_HDR_FILE_NAME);
+	} else {
+		ret = PTR_ERR(fname);
+		ckpt_err(ctx, ret, "%(T)%(S)Obtain filename\n",
+			 path->dentry->d_name.name);
+	}
+
+	kfree(buf);
+	return ret;
+}
+
+#define CKPT_DEFAULT_FDTABLE  256		/* an initial guess */
+
+/**
+ * scan_fds - scan file table and construct array of open fds
+ * @files: files_struct pointer
+ * @fdtable: (output) array of open fds
+ *
+ * Returns the number of open fds found, and also the file table
+ * array via *fdtable. The caller should free the array.
+ *
+ * The caller must validate the file descriptors collected in the
+ * array before using them, e.g. by using fcheck_files(), in case
+ * the task's fdtable changes in the meantime.
+ */
+static int scan_fds(struct files_struct *files, int **fdtable)
+{
+	struct fdtable *fdt;
+	int *fds = NULL;
+	int i = 0, n = 0;
+	int tot = CKPT_DEFAULT_FDTABLE;
+
+	/*
+	 * We assume that all tasks possibly sharing the file table are
+	 * frozen (or we are a single process and we checkpoint ourselves).
+	 * Therefore, we can safely proceed after krealloc() from where we
+	 * left off. Otherwise the file table may be modified by another
+	 * task after we scan it. The behavior is this case is undefined,
+	 * and either checkpoint or restart will likely fail.
+	 */
+ retry:
+	fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
+	if (!fds)
+		return -ENOMEM;
+
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	for (/**/; i < fdt->max_fds; i++) {
+		if (!fcheck_files(files, i))
+			continue;
+		if (n == tot) {
+			rcu_read_unlock();
+			tot *= 2;	/* won't overflow: kmalloc will fail */
+			goto retry;
+		}
+		fds[n++] = i;
+	}
+	rcu_read_unlock();
+
+	*fdtable = fds;
+	return n;
+}
+
+#ifdef CONFIG_SECURITY
+int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
+{
+	return security_checkpoint_obj(ctx, file->f_security,
+				       CKPT_SECURITY_FILE);
+}
+#else
+int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
+{
+	return SECURITY_CTX_NONE;
+}
+#endif
+
+int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+			   struct ckpt_hdr_file *h)
+{
+	struct cred *f_cred = (struct cred *) file->f_cred;
+
+	h->f_flags = file->f_flags;
+	h->f_mode = file->f_mode;
+	h->f_pos = file->f_pos;
+	h->f_version = file->f_version;
+
+	h->f_credref = checkpoint_obj(ctx, f_cred, CKPT_OBJ_CRED);
+	if (h->f_credref < 0)
+		return h->f_credref;
+
+	h->f_secref = checkpoint_file_security(ctx, file);
+	if (h->f_secref < 0) {
+		ckpt_err(ctx, h->f_secref, "%(T)file->f_security");
+		return h->f_secref;
+	}
+
+	ckpt_debug("file %s credref %d secref %d\n",
+		file->f_dentry->d_name.name, h->f_credref, h->f_secref);
+
+	/* FIX: need also file->f_owner, etc */
+
+	return 0;
+}
+
+int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_generic *h;
+	int ret;
+
+	/*
+	 * FIXME: when we'll add support for unlinked files/dirs, we'll
+	 * need to distinguish between unlinked filed and unlinked dirs.
+	 */
+	if (d_unlinked(file->f_dentry)) {
+		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
+			 file);
+		return -EBADF;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_GENERIC;
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, &h->common.h);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+EXPORT_SYMBOL(generic_file_checkpoint);
+
+/* checkpoint callback for file pointer */
+int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct file *file = (struct file *) ptr;
+	int ret;
+
+	if (!file->f_op || !file->f_op->checkpoint) {
+		ckpt_err(ctx, -EBADF, "%(T)%(P)%(V)f_op lacks checkpoint\n",
+			       file, file->f_op);
+		return -EBADF;
+	}
+
+	if (is_dnotify_attached(file)) {
+		ckpt_err(ctx, -EBADF, "%(T)%(P)dnotify unsupported\n", file);
+		return -EBADF;
+	}
+
+	ret = file->f_op->checkpoint(ctx, file);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "%(T)%(P)file checkpoint failed\n", file);
+	return ret;
+}
+
+/**
+ * ckpt_write_file_desc - dump the state of a given file descriptor
+ * @ctx: checkpoint context
+ * @files: files_struct pointer
+ * @fd: file descriptor
+ *
+ * Saves the state of the file descriptor; looks up the actual file
+ * pointer in the hash table, and if found saves the matching objref,
+ * otherwise calls ckpt_write_file to dump the file pointer too.
+ */
+static int checkpoint_file_desc(struct ckpt_ctx *ctx,
+				struct files_struct *files, int fd)
+{
+	struct ckpt_hdr_file_desc *h;
+	struct file *file = NULL;
+	struct fdtable *fdt;
+	int objref, ret;
+	int coe = 0;	/* avoid gcc warning */
+	pid_t pid;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
+	if (!h)
+		return -ENOMEM;
+
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	file = fcheck_files(files, fd);
+	if (file) {
+		coe = FD_ISSET(fd, fdt->close_on_exec);
+		get_file(file);
+	}
+	rcu_read_unlock();
+
+	ret = find_locks_with_owner(file, files);
+	/*
+	 * find_locks_with_owner() returns an error when there
+	 * are no locks found, so we *want* it to return an error
+	 * code.  Its success means we have to fail the checkpoint.
+	 */
+	if (!ret) {
+		ret = -EBADF;
+		ckpt_err(ctx, ret, "%(T)fd %d has file lock or lease\n", fd);
+		goto out;
+	}
+
+	/* sanity check (although this shouldn't happen) */
+	ret = -EBADF;
+	if (!file) {
+		ckpt_err(ctx, ret, "%(T)fd %d gone?\n", fd);
+		goto out;
+	}
+
+	/*
+	 * TODO: Implement c/r of fowner and f_sigio.  Should be
+	 * trivial, but for now we just refuse its checkpoint
+	 */
+	pid = f_getown(file);
+	if (pid) {
+		ret = -EBUSY;
+		ckpt_err(ctx, ret, "%(T)fd %d has an owner (%d)\n", fd);
+		goto out;
+	}
+
+	/*
+	 * if seen first time, this will add 'file' to the objhash, keep
+	 * a reference to it, dump its state while at it.
+	 */
+	objref = checkpoint_obj(ctx, file, CKPT_OBJ_FILE);
+	ckpt_debug("fd %d objref %d file %p coe %d)\n", fd, objref, file, coe);
+	if (objref < 0) {
+		ret = objref;
+		goto out;
+	}
+
+	h->fd_objref = objref;
+	h->fd_descriptor = fd;
+	h->fd_close_on_exec = coe;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+out:
+	ckpt_hdr_put(ctx, h);
+	if (file)
+		fput(file);
+	return ret;
+}
+
+static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
+				    struct files_struct *files)
+{
+	struct ckpt_hdr_file_table *h;
+	int *fdtable = NULL;
+	int nfds, n, ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_TABLE);
+	if (!h)
+		return -ENOMEM;
+
+	nfds = scan_fds(files, &fdtable);
+	if (nfds < 0) {
+		ret = nfds;
+		goto out;
+	}
+
+	h->fdt_nfds = nfds;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		goto out;
+
+	ckpt_debug("nfds %d\n", nfds);
+	for (n = 0; n < nfds; n++) {
+		ret = checkpoint_file_desc(ctx, files, fdtable[n]);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = deferqueue_run(ctx->files_deferq);
+	ckpt_debug("files_deferq ran %d entries\n", ret);
+	if (ret > 0)
+		ret = 0;
+ out:
+	kfree(fdtable);
+	return ret;
+}
+
+/* checkpoint callback for file table */
+int checkpoint_file_table(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_file_table(ctx, (struct files_struct *) ptr);
+}
+
+/* checkpoint wrapper for file table */
+int checkpoint_obj_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct files_struct *files;
+	int objref;
+
+	files = get_files_struct(t);
+	if (!files)
+		return -EBUSY;
+	objref = checkpoint_obj(ctx, files, CKPT_OBJ_FILE_TABLE);
+	put_files_struct(files);
+
+	return objref;
+}
+
+int checkpoint_obj_fs(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct fs_struct *fs;
+	int fs_objref;
+
+	task_lock(current);
+	fs = t->fs;
+	get_fs_struct(fs);
+	task_unlock(current);
+
+	fs_objref = checkpoint_obj(ctx, fs, CKPT_OBJ_FS);
+	put_fs_struct(fs);
+
+	return fs_objref;
+}
+
+/* called with fs refcount bumped so it won't disappear */
+static int do_checkpoint_fs(struct ckpt_ctx *ctx, struct fs_struct *fs)
+{
+	struct ckpt_hdr_fs *h;
+	struct fs_struct *fscopy;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FS);
+	if (!h)
+		return -ENOMEM;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret)
+		return ret;
+
+	fscopy = copy_fs_struct(fs);
+	if (!fs)
+		return -ENOMEM;
+
+	ret = checkpoint_fname(ctx, &fscopy->pwd, &ctx->root_fs_path);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T)writing path of cwd");
+		goto out;
+	}
+	ret = checkpoint_fname(ctx, &fscopy->root, &ctx->root_fs_path);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T)writing path of fs root");
+		goto out;
+	}
+	ret = 0;
+ out:
+	free_fs_struct(fscopy);
+	return ret;
+}
+
+int checkpoint_fs(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_fs(ctx, (struct fs_struct *) ptr);
+}
+
+/***********************************************************************
+ * Collect
+ */
+
+int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file)
+{
+	int ret;
+
+	ret = ckpt_obj_collect(ctx, file, CKPT_OBJ_FILE);
+	if (ret <= 0)
+		return ret;
+	/* if first time for this file (ret > 0), invoke ->collect() */
+	if (file->f_op->collect)
+		ret = file->f_op->collect(ctx, file);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "%(T)%(P)File collect\n", file);
+	return ret;
+}
+
+static int collect_file_desc(struct ckpt_ctx *ctx,
+			     struct files_struct *files, int fd)
+{
+	struct fdtable *fdt;
+	struct file *file;
+	int ret;
+
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	file = fcheck_files(files, fd);
+	if (file)
+		get_file(file);
+	rcu_read_unlock();
+
+	if (!file) {
+		ckpt_err(ctx, -EBUSY, "%(T)%(P)File removed\n", file);
+		return -EBUSY;
+	}
+
+	ret = ckpt_collect_file(ctx, file);
+	fput(file);
+
+	return ret;
+}
+
+static int collect_file_table(struct ckpt_ctx *ctx, struct files_struct *files)
+{
+	int *fdtable;
+	int nfds, n;
+	int ret;
+
+	/* if already exists (ret == 0), nothing to do */
+	ret = ckpt_obj_collect(ctx, files, CKPT_OBJ_FILE_TABLE);
+	if (ret <= 0)
+		return ret;
+
+	/* if first time for this file table (ret > 0), proceed inside */
+	nfds = scan_fds(files, &fdtable);
+	if (nfds < 0)
+		return nfds;
+
+	for (n = 0; n < nfds; n++) {
+		ret = collect_file_desc(ctx, files, fdtable[n]);
+		if (ret < 0)
+			break;
+	}
+
+	kfree(fdtable);
+	return ret;
+}
+
+int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct files_struct *files;
+	int ret;
+
+	files = get_files_struct(t);
+	if (!files) {
+		ckpt_err(ctx, -EBUSY, "%(T)files_struct missing\n");
+		return -EBUSY;
+	}
+	ret = collect_file_table(ctx, files);
+	put_files_struct(files);
+
+	return ret;
+}
+
+int ckpt_collect_fs(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct fs_struct *fs;
+	int ret;
+
+	task_lock(t);
+	fs = t->fs;
+	get_fs_struct(fs);
+	task_unlock(t);
+
+	ret = ckpt_obj_collect(ctx, fs, CKPT_OBJ_FS);
+
+	put_fs_struct(fs);
+	return ret;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+static int ckpt_read_fname(struct ckpt_ctx *ctx, char **fname)
+{
+	int len;
+
+	len = ckpt_read_payload(ctx, (void **) fname,
+				PATH_MAX, CKPT_HDR_FILE_NAME);
+	if (len < 0)
+		return len;
+
+	(*fname)[len - 1] = '\0';	/* always play if safe */
+	ckpt_debug("read filename '%s'\n", *fname);
+
+	return len;
+}
+
+/**
+ * restore_open_fname - read a file name and open a file
+ * @ctx: checkpoint context
+ * @flags: file flags
+ */
+struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
+{
+	struct file *file;
+	char *fname;
+	int len;
+
+	/* prevent bad input from doing bad things */
+	if (flags & (O_CREAT | O_EXCL | O_NOCTTY | O_TRUNC))
+		return ERR_PTR(-EINVAL);
+
+	len = ckpt_read_fname(ctx, &fname);
+	if (len < 0)
+		return ERR_PTR(len);
+	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
+
+	file = filp_open(fname, flags, 0);
+	kfree(fname);
+
+	return file;
+}
+
+static int close_all_fds(struct files_struct *files)
+{
+	int *fdtable;
+	int nfds;
+
+	nfds = scan_fds(files, &fdtable);
+	if (nfds < 0)
+		return nfds;
+	while (nfds--)
+		sys_close(fdtable[nfds]);
+	kfree(fdtable);
+	return 0;
+}
+
+/**
+ * attach_file - attach a lonely file ptr to a file descriptor
+ * @file: lonely file pointer
+ */
+static int attach_file(struct file *file)
+{
+	int fd = get_unused_fd_flags(0);
+
+	if (fd >= 0) {
+		get_file(file);
+		fsnotify_open(file->f_path.dentry);
+		fd_install(fd, file);
+	}
+	return fd;
+}
+
+#define CKPT_SETFL_MASK  \
+	(O_APPEND | O_NONBLOCK | O_NDELAY | FASYNC | O_DIRECT | O_NOATIME)
+
+int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
+			struct ckpt_hdr_file *h)
+{
+	fmode_t new_mode = file->f_mode;
+	fmode_t saved_mode = (__force fmode_t) h->f_mode;
+	int ret;
+	struct cred *cred;
+
+	/* FIX: need to restore owner etc */
+
+	/* restore the cred */
+	cred = ckpt_obj_fetch(ctx, h->f_credref, CKPT_OBJ_CRED);
+	if (IS_ERR(cred))
+		return PTR_ERR(cred);
+	put_cred(file->f_cred);
+	file->f_cred = get_cred(cred);
+
+	ret = security_restore_obj(ctx, (void *) file, CKPT_SECURITY_FILE,
+				   h->f_secref);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "file secref %(O)%(P)\n", h->f_secref,
+			 file);
+		return ret;
+	}
+
+	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
+	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Normally f_mode is set by open, and modified only via
+	 * fcntl(), so its value now should match that at checkpoint.
+	 * However, a file may be downgraded from (read-)write to
+	 * read-only, e.g:
+	 *  - mark_files_ro() unsets FMODE_WRITE
+	 *  - nfs4_file_downgrade() too, and also sert FMODE_READ
+	 * Validate the new f_mode against saved f_mode, allowing:
+	 *  - new with FMODE_WRITE, saved without FMODE_WRITE
+	 *  - new without FMODE_READ, saved with FMODE_READ
+	 */
+	if ((new_mode & FMODE_WRITE) && !(saved_mode & FMODE_WRITE)) {
+		new_mode &= ~FMODE_WRITE;
+		if (!(new_mode & FMODE_READ) && (saved_mode & FMODE_READ))
+			new_mode |= FMODE_READ;
+	}
+	/* finally, at this point new mode should match saved mode */
+	if (new_mode ^ saved_mode)
+		return -EINVAL;
+
+	if (file->f_mode & FMODE_LSEEK)
+		ret = vfs_llseek(file, h->f_pos, SEEK_SET);
+
+	return ret;
+}
+
+static struct file *generic_file_restore(struct ckpt_ctx *ctx,
+					 struct ckpt_hdr_file *ptr)
+{
+	struct file *file;
+	int ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE  ||
+	    ptr->h.len != sizeof(*ptr) || ptr->f_type != CKPT_FILE_GENERIC)
+		return ERR_PTR(-EINVAL);
+
+	file = restore_open_fname(ctx, ptr->f_flags);
+	if (IS_ERR(file))
+		return file;
+
+	ret = restore_file_common(ctx, file, ptr);
+	if (ret < 0) {
+		fput(file);
+		file = ERR_PTR(ret);
+	}
+	return file;
+}
+
+struct restore_file_ops {
+	char *file_name;
+	enum file_type file_type;
+	struct file * (*restore) (struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_file *ptr);
+};
+
+static struct restore_file_ops restore_file_ops[] = {
+	/* ignored file */
+	{
+		.file_name = "IGNORE",
+		.file_type = CKPT_FILE_IGNORE,
+		.restore = NULL,
+	},
+	/* regular file/directory */
+	{
+		.file_name = "GENERIC",
+		.file_type = CKPT_FILE_GENERIC,
+		.restore = generic_file_restore,
+	},
+	/* pipes */
+	{
+		.file_name = "PIPE",
+		.file_type = CKPT_FILE_PIPE,
+		.restore = pipe_file_restore,
+	},
+	/* fifo */
+	{
+		.file_name = "FIFO",
+		.file_type = CKPT_FILE_FIFO,
+		.restore = fifo_file_restore,
+	},
+	/* socket */
+	{
+		.file_name = "SOCKET",
+		.file_type = CKPT_FILE_SOCKET,
+		.restore = sock_file_restore,
+	},
+	/* tty */
+	{
+		.file_name = "TTY",
+		.file_type = CKPT_FILE_TTY,
+		.restore = tty_file_restore,
+	},
+	/* epoll */
+	{
+		.file_name = "EPOLL",
+		.file_type = CKPT_FILE_EPOLL,
+		.restore = ep_file_restore,
+	},
+	/* eventfd */
+	{
+		.file_name = "EVENTFD",
+		.file_type = CKPT_FILE_EVENTFD,
+		.restore = eventfd_restore,
+	},
+};
+
+static struct file *do_restore_file(struct ckpt_ctx *ctx)
+{
+	struct restore_file_ops *ops;
+	struct ckpt_hdr_file *h;
+	struct file *file = ERR_PTR(-EINVAL);
+
+	/*
+	 * All 'struct ckpt_hdr_file_...' begin with ckpt_hdr_file,
+	 * but the actual object depends on the file type. The length
+	 * should never be more than page.
+	 */
+	h = ckpt_read_buf_type(ctx, PAGE_SIZE, CKPT_HDR_FILE);
+	if (IS_ERR(h))
+		return (struct file *) h;
+	ckpt_debug("flags %#x mode %#x type %d\n",
+		 h->f_flags, h->f_mode, h->f_type);
+
+	if (h->f_type >= CKPT_FILE_MAX)
+		goto out;
+
+	ops = &restore_file_ops[h->f_type];
+	BUG_ON(ops->file_type != h->f_type);
+
+	if (ops->restore)
+		file = ops->restore(ctx, h);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return file;
+}
+
+/* restore callback for file pointer */
+void *restore_file(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_file(ctx);
+}
+
+/**
+ * ckpt_read_file_desc - restore the state of a given file descriptor
+ * @ctx: checkpoint context
+ *
+ * Restores the state of a file descriptor; looks up the objref (in the
+ * header) in the hash table, and if found picks the matching file and
+ * use it; otherwise calls restore_file to restore the file too.
+ */
+static int restore_file_desc(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_file_desc *h;
+	struct file *file;
+	int newfd, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+	ckpt_debug("ref %d fd %d c.o.e %d\n",
+		 h->fd_objref, h->fd_descriptor, h->fd_close_on_exec);
+
+	ret = -EINVAL;
+	if (h->fd_objref <= 0 || h->fd_descriptor < 0)
+		goto out;
+
+	file = ckpt_obj_fetch(ctx, h->fd_objref, CKPT_OBJ_FILE);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto out;
+	}
+
+	newfd = attach_file(file);
+	if (newfd < 0) {
+		ret = newfd;
+		goto out;
+	}
+
+	ckpt_debug("newfd got %d wanted %d\n", newfd, h->fd_descriptor);
+
+	/* reposition if newfd isn't desired fd */
+	if (newfd != h->fd_descriptor) {
+		ret = sys_dup2(newfd, h->fd_descriptor);
+		if (ret < 0)
+			goto out;
+		sys_close(newfd);
+	}
+
+	set_close_on_exec(h->fd_descriptor, h->fd_close_on_exec);
+	ret = 0;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/* restore callback for file table */
+static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_file_table *h;
+	struct files_struct *files;
+	int i, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_TABLE);
+	if (IS_ERR(h))
+		return (struct files_struct *) h;
+
+	ckpt_debug("nfds %d\n", h->fdt_nfds);
+
+	ret = -EMFILE;
+	if (h->fdt_nfds < 0 || h->fdt_nfds > sysctl_nr_open)
+		goto out;
+
+	/*
+	 * We assume that restarting tasks, as created in user-space,
+	 * have distinct files_struct objects each. If not, we need to
+	 * call dup_fd() to make sure we don't overwrite an already
+	 * restored one.
+	 */
+
+	/* point of no return -- close all file descriptors */
+	ret = close_all_fds(current->files);
+	if (ret < 0)
+		goto out;
+
+	for (i = 0; i < h->fdt_nfds; i++) {
+		ret = restore_file_desc(ctx);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = deferqueue_run(ctx->files_deferq);
+	ckpt_debug("files_deferq ran %d entries\n", ret);
+	if (ret > 0)
+		ret = 0;
+ out:
+	ckpt_hdr_put(ctx, h);
+	if (!ret) {
+		files = current->files;
+		atomic_inc(&files->count);
+	} else {
+		files = ERR_PTR(ret);
+	}
+	return files;
+}
+
+void *restore_file_table(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_file_table(ctx);
+}
+
+int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref)
+{
+	struct files_struct *files;
+
+	files = ckpt_obj_fetch(ctx, files_objref, CKPT_OBJ_FILE_TABLE);
+	if (IS_ERR(files))
+		return PTR_ERR(files);
+
+	if (files != current->files) {
+		task_lock(current);
+		put_files_struct(current->files);
+		current->files = files;
+		task_unlock(current);
+		atomic_inc(&files->count);
+	}
+
+	return 0;
+}
+
+/*
+ * Called by task restore code to set the restarted task's
+ * current->fs to an entry on the hash
+ */
+int restore_obj_fs(struct ckpt_ctx *ctx, int fs_objref)
+{
+	struct fs_struct *newfs, *oldfs;
+
+	newfs = ckpt_obj_fetch(ctx, fs_objref, CKPT_OBJ_FS);
+	if (IS_ERR(newfs))
+		return PTR_ERR(newfs);
+
+	task_lock(current);
+	get_fs_struct(newfs);
+	oldfs = current->fs;
+	current->fs = newfs;
+	task_unlock(current);
+	put_fs_struct(oldfs);
+
+	return 0;
+}
+
+static int restore_chroot(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
+{
+	struct nameidata nd;
+	int ret;
+
+	ckpt_debug("attempting chroot to %s\n", name);
+	ret = path_lookup(name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &nd);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)Opening chroot dir %s", name);
+		return ret;
+	}
+	ret = do_chroot(fs, &nd.path);
+	path_put(&nd.path);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)Setting chroot %s", name);
+		return ret;
+	}
+	return 0;
+}
+
+static int restore_cwd(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
+{
+	struct nameidata nd;
+	int ret;
+
+	ckpt_debug("attempting chdir to %s\n", name);
+	ret = path_lookup(name, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &nd);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)Opening cwd %s", name);
+		return ret;
+	}
+	ret = do_chdir(fs, &nd.path);
+	path_put(&nd.path);
+	if (ret) {
+		ckpt_err(ctx, ret, "%(T)Setting cwd %s", name);
+		return ret;
+	}
+	return 0;
+}
+
+/*
+ * Called by objhash when it runs into a CKPT_OBJ_FS entry. Creates
+ * an fs_struct with desired chroot/cwd and places it in the hash.
+ */
+static struct fs_struct *do_restore_fs(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_fs *h;
+	struct fs_struct *fs;
+	char *path;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+	ckpt_hdr_put(ctx, h);
+
+	fs = copy_fs_struct(current->fs);
+	if (!fs)
+		return ERR_PTR(-ENOMEM);
+
+	ret = ckpt_read_fname(ctx, &path);
+	if (ret < 0)
+		goto out;
+	ret = restore_cwd(ctx, fs, path);
+	kfree(path);
+	if (ret)
+		goto out;
+
+	ret = ckpt_read_fname(ctx, &path);
+	if (ret < 0)
+		goto out;
+	ret = restore_chroot(ctx, fs, path);
+	kfree(path);
+
+out:
+	if (ret) {
+		free_fs_struct(fs);
+		return ERR_PTR(ret);
+	}
+	return fs;
+}
+
+void *restore_fs(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_fs(ctx);
+}
-- 
1.6.3.3
