From: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Subject: [PATCH 07/10] Checkpoint/restart vfs support
Date: Mon, 28 Feb 2011 17:40:29 -0600
Message-ID: <1298936432-29607-8-git-send-email-ntl__36001.0656797842$1298937090$gmane$org@pobox.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298936432-29607-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

While we assume all normal files and directories can be checkpointed,
there are, as usual in the VFS, specialized places that will always
need an ability to override these defaults. Although we could do this
completely in the checkpoint code, that would bitrot quickly.

This adds a new 'file_operations' function for checkpointing a file.
It is assumed that there should be a dirt-simple way to make something
(un)checkpointable that fits in with current code.

As you can see in the ext[234] patches down the road, all that we have
to do to make something simple be supported is add a single "generic"
f_op entry.

Also adds a new 'file_operations' function for 'collecting' a file for
leak-detection during full-container checkpoint. This is useful for
those files that hold references to other "collectable" objects. Two
examples are pty files that point to corresponding tty objects, and
eventpoll files that refer to the files they are monitoring.

Checkpoint: dump the file table with 'struct ckpt_hdr_file_table,
followed by all open file descriptors. Because the 'struct file'
corresponding to an fd can be shared, they are assigned an objref and
registered in the object hash. A reference to the 'file *' is kept for
as long as it lives in the hash (the hash is only cleaned up at the
end of the checkpoint).

Also provide generic_checkpoint_file() and generic_restore_file()
which is good for normal files and directories. It does not support
yet unlinked files or directories.

Restart: for each fd read 'struct ckpt_hdr_file_desc' and lookup
objref in the hash table; If not found in the hash table, (first
occurence), read in 'struct ckpt_hdr_file', create a new file and
register in the hash.  Otherwise attach the file pointer from the hash
as an FD.

Based on original code by Oren Laadan.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
[ntl: remove unused obj_file_users]
[ntl: rearrange error path, prevent null pointer deref in checkpoint_file_desc]
[ntl: pass file, not dentry, to fsnotify_open]
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 Documentation/filesystems/vfs.txt |   13 +-
 fs/Makefile                       |    1 +
 fs/checkpoint.c                   |  695 +++++++++++++++++++++++++++++++++++++
 include/linux/fs.h                |    7 +
 4 files changed, 715 insertions(+), 1 deletions(-)
 create mode 100644 fs/checkpoint.c

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 20899e0..23025bb 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -722,7 +722,7 @@ struct file_operations
 ----------------------
 
 This describes how the VFS can manipulate an open file. As of kernel
-2.6.22, the following members are defined:
+2.6.38, the following members are defined:
 
 struct file_operations {
 	struct module *owner;
@@ -752,6 +752,10 @@ struct file_operations {
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, struct pipe_inode_info *, size_t, unsigned int);
+#ifdef CONFIG_CHECKPOINT
+	int (*checkpoint)(struct ckpt_ctx *, struct file *);
+	int (*collect)(struct ckpt_ctx *, struct file *);
+#endif
 };
 
 Again, all methods are called without any locks being held, unless
@@ -820,6 +824,13 @@ otherwise noted.
   splice_read: called by the VFS to splice data from file to a pipe. This
 	       method is used by the splice(2) system call
 
+  checkpoint: called by checkpoint(2) system call to checkpoint the
+              state of a file descriptor.
+
+  collect: called by the checkpoint(2) system call to track references to
+           file descriptors, to detect leaks in full-container checkpoint
+	   (see Documentation/checkpoint/readme.txt).
+
 Note that the file operations are implemented by the specific
 filesystem in which the inode resides. When opening a device node
 (character or block special) most filesystems will call special
diff --git a/fs/Makefile b/fs/Makefile
index a7f7cef..d7a49b7 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -30,6 +30,7 @@ obj-$(CONFIG_AIO)               += aio.o
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
 obj-$(CONFIG_NFSD_DEPRECATED)	+= nfsctl.o
+obj-$(CONFIG_CHECKPOINT)        += checkpoint.o
 obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
 obj-$(CONFIG_BINFMT_EM86)	+= binfmt_em86.o
 obj-$(CONFIG_BINFMT_MISC)	+= binfmt_misc.o
diff --git a/fs/checkpoint.c b/fs/checkpoint.c
new file mode 100644
index 0000000..9b7c5ab
--- /dev/null
+++ b/fs/checkpoint.c
@@ -0,0 +1,695 @@
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
+#define DEBUG
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
+#include <linux/fsnotify.h>
+#include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/checkpoint.h>
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
+	fname = __d_path(path, &tmp, buf, *len);
+	if (IS_ERR(fname))
+		return fname;
+	*len = (buf + (*len) - fname);
+	/*
+	 * FIX: if __d_path() changed these, it must have stepped out of
+	 * init's namespace. Since currently we require a unified namespace
+	 * within the container: simply fail.
+	 */
+	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
+		ckpt_debug("file %s was opened in an alien mnt_ns, "
+			   "proceeding anyway\n", fname);
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
+		ckpt_debug("ckpt_fill_fname failed (%s)\n",
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
+int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+			   struct ckpt_hdr_file *h)
+{
+	h->f_flags = file->f_flags;
+	h->f_mode = file->f_mode;
+	h->f_pos = file->f_pos;
+	h->f_version = file->f_version;
+
+	ckpt_debug("file %s", file->f_dentry->d_name.name);
+
+	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
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
+		ckpt_debug("Unlinked files unsupported\n");
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
+	kfree(h);
+	return ret;
+}
+EXPORT_SYMBOL(generic_file_checkpoint);
+
+/* checkpoint callback for file pointer */
+static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct file *file = (struct file *) ptr;
+	int ret;
+
+	if (!file->f_op || !file->f_op->checkpoint) {
+		ckpt_debug("f_op %ps lacks checkpoint\n", file->f_op);
+		return -EBADF;
+	}
+
+	ret = file->f_op->checkpoint(ctx, file);
+	if (ret < 0)
+		ckpt_debug("file checkpoint failed\n");
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
+
+	/* sanity check (although this shouldn't happen) */
+	if (WARN_ON(!file)) {
+		rcu_read_unlock();
+		ckpt_debug("fd %d gone?\n", fd);
+		ret = -EBADF;
+		goto out;
+	}
+
+	coe = FD_ISSET(fd, fdt->close_on_exec);
+	get_file(file);
+	rcu_read_unlock();
+
+	if (has_locks_with_owner(file, files)) {
+		ret = -EBADF;
+		ckpt_debug("fd %d has file lock or lease\n", fd);
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
+		ckpt_debug("fd %d has an owner\n", fd);
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
+	kfree(h);
+	if (file)
+		fput(file);
+	return ret;
+}
+
+/* checkpoint callback for file table */
+static int checkpoint_file_table(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct files_struct *files = ptr;
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
+	kfree(h);
+	if (ret < 0)
+		goto out;
+
+	ckpt_debug("nfds %d\n", nfds);
+	for (n = 0; n < nfds; n++) {
+		ret = checkpoint_file_desc(ctx, files, fdtable[n]);
+		if (ret < 0)
+			break;
+	}
+ out:
+	kfree(fdtable);
+	return ret;
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
+/**************************************************************************
+ * Restart
+ */
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
+	len = ckpt_read_payload(ctx, (void **) &fname,
+				PATH_MAX, CKPT_HDR_FILE_NAME);
+	if (len < 0)
+		return ERR_PTR(len);
+	fname[len - 1] = '\0';	/* always play if safe */
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
+		fsnotify_open(file);
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
+
+	/* FIX: need to restore uid, gid, owner etc */
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
+};
+
+static void *restore_file(struct ckpt_ctx *ctx)
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
+		return (void *)h;
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
+	kfree(h);
+	return (void *)file;
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
+	kfree(h);
+	return ret;
+}
+
+/* restore callback for file table */
+static void *restore_file_table(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_file_table *h;
+	struct files_struct *files;
+	int i, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_TABLE);
+	if (IS_ERR(h))
+		return (void *)h;
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
+			break;
+	}
+ out:
+	kfree(h);
+	if (!ret) {
+		files = current->files;
+		atomic_inc(&files->count);
+	} else {
+		files = ERR_PTR(ret);
+	}
+	return (void *)files;
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
+		struct files_struct *prev;
+
+		task_lock(current);
+		prev = current->files;
+		current->files = files;
+		atomic_inc(&files->count);
+		task_unlock(current);
+
+		put_files_struct(prev);
+	}
+
+	return 0;
+}
+
+/*
+ * fs-related checkpoint objects
+ */
+static int obj_file_table_grab(void *ptr)
+{
+	atomic_inc(&((struct files_struct *) ptr)->count);
+	return 0;
+}
+
+static void obj_file_table_drop(void *ptr, int lastref)
+{
+	put_files_struct((struct files_struct *) ptr);
+}
+
+static int obj_file_grab(void *ptr)
+{
+	get_file((struct file *) ptr);
+	return 0;
+}
+
+static void obj_file_drop(void *ptr, int lastref)
+{
+	fput((struct file *) ptr);
+}
+
+/* files_struct object */
+static const struct ckpt_obj_ops ckpt_obj_files_struct_ops = {
+	.obj_name = "FILE_TABLE",
+	.obj_type = CKPT_OBJ_FILE_TABLE,
+	.ref_drop = obj_file_table_drop,
+	.ref_grab = obj_file_table_grab,
+	.checkpoint = checkpoint_file_table,
+	.restore = restore_file_table,
+};
+
+/* file object */
+static const struct ckpt_obj_ops ckpt_obj_file_ops = {
+	.obj_name = "FILE",
+	.obj_type = CKPT_OBJ_FILE,
+	.ref_drop = obj_file_drop,
+	.ref_grab = obj_file_grab,
+	.checkpoint = checkpoint_file,
+	.restore = restore_file,
+};
+
+static __init int checkpoint_register_fs(void)
+{
+	int ret;
+
+	ret = register_checkpoint_obj(&ckpt_obj_files_struct_ops);
+	if (ret < 0)
+		return ret;
+	ret = register_checkpoint_obj(&ckpt_obj_file_ops);
+	if (ret < 0)
+		return ret;
+	return 0;
+}
+late_initcall(checkpoint_register_fs);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 175bb75..b7c088f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -407,6 +407,7 @@ struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
 struct cred;
+struct ckpt_ctx;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -1551,6 +1552,10 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+#ifdef CONFIG_CHECKPOINT
+	int (*checkpoint)(struct ckpt_ctx *, struct file *);
+	int (*collect)(struct ckpt_ctx *, struct file *);
+#endif
 };
 
 struct inode_operations {
@@ -2367,6 +2372,8 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
 loff_t inode_get_bytes(struct inode *inode);
 void inode_set_bytes(struct inode *inode, loff_t bytes);
 
+extern int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+
 extern int vfs_readdir(struct file *, filldir_t, void *);
 
 extern int vfs_stat(const char __user *, struct kstat *);
-- 
1.7.4
