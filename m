From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 038/100] c/r: checkpoint and restart open file descriptors
Date: Sat,  1 May 2010 10:15:20 -0400
Message-ID: <1272723382-19470-39-git-send-email-orenl__8882.39959390393$1272727890$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

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

Changelog[v21]:
  - Do not include checkpoint_hdr.h explicitly
  - Replace __initcall() with late_initcall()
  - [Serge] Print out full path of file which crossed mnt_ns
  - Reorganize code into fs/*
  - Merge files dump/restore into a single patch
  - Put file_ops->checkpoint under CONFIG_CHECKPOINT
Changelog[v19]:
  - Fix false negative of test for unlinked files at checkpoint
Changelog[v19-rc3]:
  - [Serge Hallyn] Rename fs_mnt to root_fs_path
  - [Dave Hansen] Error out on file locks and leases
  - [Serge Hallyn] Refuse checkpoint of file with f_owner
Changelog[v19-rc1]:
  - Fix lockdep complaint in restore_obj_files()
  - [Matt Helsley] Add cpp definitions for enums
  - Restore thread/cpu state early
  - Ensure null-termination of file names read from image
  - Fix compile warning in restore_open_fname()
Changelog[v18]:
  - Add a few more ckpt_write_err()s
  - [Dan Smith] Export fill_fname() as ckpt_fill_fname()
  - Introduce ckpt_collect_file() that also uses file->collect method
  - In collect_file_stabl() use retval from ckpt_obj_collect() to
    test for first-time-object
  - Invoke set_close_on_exec() unconditionally on restart
Changelog[v17]:
  - Validate f_mode after restore against saved f_mode
  - Fail if f_flags have O_CREAT|O_EXCL|O_NOCTTY|O_TRUNC
  - Reorder patch (move earlier in series)
  - Handle shared files_struct objects
  - Only collect sub-objects of files_struct once
  - Better file error debugging
  - Use (new) d_unlinked()
Changelog[v16]:
  - Fix compile warning in checkpoint_bad()
Changelog[v16]:
  - Reorder patch (move earlier in series)
  - Handle shared files_struct objects
Changelog[v14]:
  - File objects are dumped/restored prior to the first reference
  - Introduce a per file-type restore() callback
  - Use struct file_operations->checkpoint()
  - Put code for generic file descriptors in a separate function
  - Use one CKPT_FILE_GENERIC for both regular files and dirs
  - Revert change to pr_debug(), back to ckpt_debug()
  - Use only unsigned fields in checkpoint headers
  - Rename:  ckpt_write_files() => checkpoint_fd_table()
  - Rename:  ckpt_write_fd_data() => checkpoint_file()
  - Rename:  ckpt_read_fd_data() => restore_file()
  - Rename:  restore_files() => restore_fd_table()
  - Check whether calls to ckpt_hbuf_get() fail
  - Discard field 'h->parent'
Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()
Changelog[v11]:
  - Discard handling of opened symlinks (there is no such thing)
  - ckpt_scan_fds() retries from scratch if hits size limits
Changelog[v9]:
  - Fix a couple of leaks in ckpt_write_files()
  - Drop useless kfree from ckpt_scan_fds()
Changelog[v8]:
  - initialize 'coe' to workaround gcc false warning
Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (even though it's not really needed)

Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/Makefile                      |    1 +
 fs/checkpoint.c                  |  816 ++++++++++++++++++++++++++++++++++++++
 fs/locks.c                       |   35 ++
 include/linux/checkpoint.h       |   22 +
 include/linux/checkpoint_hdr.h   |   59 +++
 include/linux/checkpoint_types.h |    5 +
 include/linux/fs.h               |   10 +
 kernel/checkpoint/checkpoint.c   |   11 +
 kernel/checkpoint/process.c      |   53 +++-
 kernel/checkpoint/sys.c          |    9 +
 10 files changed, 1020 insertions(+), 1 deletions(-)
 create mode 100644 fs/checkpoint.c

diff --git a/fs/Makefile b/fs/Makefile
index 97f340f..aa25755 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_EVENTFD)		+= eventfd.o
 obj-$(CONFIG_AIO)               += aio.o
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
+obj-$(CONFIG_CHECKPOINT)        += checkpoint.o
 
 nfsd-$(CONFIG_NFSD)		:= nfsctl.o
 obj-y				+= $(nfsd-y) $(nfsd-m)
diff --git a/fs/checkpoint.c b/fs/checkpoint.c
new file mode 100644
index 0000000..95a51e9
--- /dev/null
+++ b/fs/checkpoint.c
@@ -0,0 +1,816 @@
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
+#include <linux/fdtable.h>
+#include <linux/fsnotify.h>
+#include <linux/syscalls.h>
+#include <linux/deferqueue.h>
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
+	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry) {
+		ckpt_debug("file %s was opened in an alien mnt_ns\n", fname);
+		fname = ERR_PTR(-EBADF);
+	}
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
+static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
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
+	ckpt_hdr_put(ctx, h);
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
+	ckpt_hdr_put(ctx, h);
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
+static int obj_file_table_users(void *ptr)
+{
+	return atomic_read(&((struct files_struct *) ptr)->count);
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
+static int obj_file_users(void *ptr)
+{
+	return atomic_long_read(&((struct file *) ptr)->f_count);
+}
+
+/* files_struct object */
+static const struct ckpt_obj_ops ckpt_obj_files_struct_ops = {
+	.obj_name = "FILE_TABLE",
+	.obj_type = CKPT_OBJ_FILE_TABLE,
+	.ref_drop = obj_file_table_drop,
+	.ref_grab = obj_file_table_grab,
+	.ref_users = obj_file_table_users,
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
+	.ref_users = obj_file_users,
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
diff --git a/fs/locks.c b/fs/locks.c
index ab24d49..9cd859e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1995,6 +1995,41 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 
 EXPORT_SYMBOL(locks_remove_posix);
 
+int find_locks_with_owner(struct file *filp, fl_owner_t owner)
+{
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct file_lock **inode_fl;
+	int ret = -EEXIST;
+
+	lock_kernel();
+	for_each_lock(inode, inode_fl) {
+		struct file_lock *fl = *inode_fl;
+		/*
+		 * We could use posix_same_owner() along with a 'fake'
+		 * file_lock.  But, the fake file will never have the
+		 * same fl_lmops as the fl that we are looking for and
+		 * posix_same_owner() would just fall back to this
+		 * check anyway.
+		 */
+		if (IS_POSIX(fl)) {
+			if (fl->fl_owner == owner) {
+				ret = 0;
+				break;
+			}
+		} else if (IS_FLOCK(fl) || IS_LEASE(fl)) {
+			if (fl->fl_file == filp) {
+				ret = 0;
+				break;
+			}
+		} else {
+			WARN(1, "unknown file lock type, fl_flags: %x",
+				fl->fl_flags);
+		}
+	}
+	unlock_kernel();
+	return ret;
+}
+
 /*
  * This function is called on the last close of an open file.
  */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d438d08..f07209c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -80,6 +80,9 @@ extern int ckpt_read_payload(struct ckpt_ctx *ctx,
 extern char *ckpt_read_string(struct ckpt_ctx *ctx, int max);
 extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 
+extern char *ckpt_fill_fname(struct path *path, struct path *root,
+			     char *buf, int *len);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
@@ -158,6 +161,24 @@ extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
 extern int restore_restart_block(struct ckpt_ctx *ctx);
 
+/* file table */
+extern int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
+				     struct task_struct *t);
+extern int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref);
+
+/* files */
+extern int checkpoint_fname(struct ckpt_ctx *ctx,
+			    struct path *path, struct path *root);
+extern struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags);
+
+extern int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file);
+
+extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+				  struct ckpt_hdr_file *h);
+extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
+			       struct ckpt_hdr_file *h);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
@@ -168,6 +189,7 @@ static inline int ckpt_validate_errno(int errno)
 #define CKPT_DSYS	0x2		/* generic (system) */
 #define CKPT_DRW	0x4		/* image read/write */
 #define CKPT_DOBJ	0x8		/* shared objects */
+#define CKPT_DFILE	0x10		/* files and filesystem */
 
 #define CKPT_DDEFAULT	0xffff		/* default debug level */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 5545ef6..ec3257a 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -76,6 +76,8 @@ enum {
 #define CKPT_HDR_TREE CKPT_HDR_TREE
 	CKPT_HDR_TASK,
 #define CKPT_HDR_TASK CKPT_HDR_TASK
+	CKPT_HDR_TASK_OBJS,
+#define CKPT_HDR_TASK_OBJS CKPT_HDR_TASK_OBJS
 	CKPT_HDR_RESTART_BLOCK,
 #define CKPT_HDR_RESTART_BLOCK CKPT_HDR_RESTART_BLOCK
 	CKPT_HDR_THREAD,
@@ -85,6 +87,15 @@ enum {
 
 	/* 201-299: reserved for arch-dependent */
 
+	CKPT_HDR_FILE_TABLE = 301,
+#define CKPT_HDR_FILE_TABLE CKPT_HDR_FILE_TABLE
+	CKPT_HDR_FILE_DESC,
+#define CKPT_HDR_FILE_DESC CKPT_HDR_FILE_DESC
+	CKPT_HDR_FILE_NAME,
+#define CKPT_HDR_FILE_NAME CKPT_HDR_FILE_NAME
+	CKPT_HDR_FILE,
+#define CKPT_HDR_FILE CKPT_HDR_FILE
+
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
 
@@ -111,6 +122,10 @@ struct ckpt_hdr_objref {
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
 #define CKPT_OBJ_IGNORE CKPT_OBJ_IGNORE
+	CKPT_OBJ_FILE_TABLE,
+#define CKPT_OBJ_FILE_TABLE CKPT_OBJ_FILE_TABLE
+	CKPT_OBJ_FILE,
+#define CKPT_OBJ_FILE CKPT_OBJ_FILE
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -193,6 +208,12 @@ struct ckpt_hdr_task {
 	__u64 clear_child_tid;
 } __attribute__((aligned(8)));
 
+/* task's shared resources */
+struct ckpt_hdr_task_objs {
+	struct ckpt_hdr h;
+	__s32 files_objref;
+} __attribute__((aligned(8)));
+
 /* restart blocks */
 struct ckpt_hdr_restart_block {
 	struct ckpt_hdr h;
@@ -225,4 +246,42 @@ enum restart_block_type {
 #define CKPT_RESTART_BLOCK_FUTEX CKPT_RESTART_BLOCK_FUTEX
 };
 
+/* file system */
+struct ckpt_hdr_file_table {
+	struct ckpt_hdr h;
+	__s32 fdt_nfds;
+} __attribute__((aligned(8)));
+
+/* file descriptors */
+struct ckpt_hdr_file_desc {
+	struct ckpt_hdr h;
+	__s32 fd_objref;
+	__s32 fd_descriptor;
+	__u32 fd_close_on_exec;
+} __attribute__((aligned(8)));
+
+enum file_type {
+	CKPT_FILE_IGNORE = 0,
+#define CKPT_FILE_IGNORE CKPT_FILE_IGNORE
+	CKPT_FILE_GENERIC,
+#define CKPT_FILE_GENERIC CKPT_FILE_GENERIC
+	CKPT_FILE_MAX
+#define CKPT_FILE_MAX CKPT_FILE_MAX
+};
+
+/* file objects */
+struct ckpt_hdr_file {
+	struct ckpt_hdr h;
+	__u32 f_type;
+	__u32 f_mode;
+	__u32 f_flags;
+	__u32 _padding;
+	__u64 f_pos;
+	__u64 f_version;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_generic {
+	struct ckpt_hdr_file common;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index ce68f54..ce46a59 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -14,6 +14,8 @@
 
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
+#include <linux/list.h>
+#include <linux/path.h>
 #include <linux/fs.h>
 #include <linux/ktime.h>
 #include <linux/wait.h>
@@ -40,6 +42,9 @@ struct ckpt_ctx {
 	atomic_t refcount;
 
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
+	struct deferqueue_head *files_deferq;	/* deferred file-table work */
+
+	struct path root_fs_path;     /* container root (FIXME) */
 
 	struct task_struct *tsk;/* checkpoint: current target task */
 	char err_string[256];	/* checkpoint: error string */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c06c157..c0a59ea 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1123,6 +1123,7 @@ extern void locks_remove_posix(struct file *, fl_owner_t);
 extern void locks_remove_flock(struct file *);
 extern void locks_release_private(struct file_lock *);
 extern void posix_test_lock(struct file *, struct file_lock *);
+extern int find_locks_with_owner(struct file *filp, fl_owner_t owner);
 extern int posix_lock_file(struct file *, struct file_lock *, struct file_lock *);
 extern int posix_lock_file_wait(struct file *, struct file_lock *);
 extern int posix_unblock_lock(struct file *, struct file_lock *);
@@ -1191,6 +1192,11 @@ static inline void locks_remove_posix(struct file *filp, fl_owner_t owner)
 	return;
 }
 
+static inline int find_locks_with_owner(struct file *filp, fl_owner_t owner)
+{
+	return -ENOENT;
+}
+
 static inline void locks_remove_flock(struct file *filp)
 {
 	return;
@@ -2323,6 +2329,10 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
 loff_t inode_get_bytes(struct inode *inode);
 void inode_set_bytes(struct inode *inode, loff_t bytes);
 
+#ifdef CONFIG_CHECKPOINT
+extern int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+#endif
+
 extern int vfs_readdir(struct file *, filldir_t, void *);
 
 extern int vfs_stat(char __user *, struct kstat *);
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 4640e80..a4f6854 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -20,6 +20,7 @@
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/fs_struct.h>
 #include <linux/dcache.h>
 #include <linux/mount.h>
 #include <linux/utsname.h>
@@ -491,6 +492,7 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 {
 	struct task_struct *task;
 	struct nsproxy *nsproxy;
+	struct fs_struct *fs;
 
 	/*
 	 * No need for explicit cleanup here, because if an error
@@ -532,6 +534,15 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 	}
 
+	/* root vfs (FIX: WILL CHANGE with mnt-ns etc */
+	task_lock(ctx->root_task);
+	fs = ctx->root_task->fs;
+	read_lock(&fs->lock);
+	ctx->root_fs_path = fs->root;
+	path_get(&ctx->root_fs_path);
+	read_unlock(&fs->lock);
+	task_unlock(ctx->root_task);
+
 	return 0;
 }
 
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index f17f040..3880fa6 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -103,6 +103,29 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task_objs *h;
+	int files_objref;
+	int ret;
+
+	files_objref = checkpoint_obj_file_table(ctx, t);
+	ckpt_debug("files: objref %d\n", files_objref);
+	if (files_objref < 0) {
+		ckpt_err(ctx, files_objref, "%(T)files_struct\n");
+		return files_objref;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (!h)
+		return -ENOMEM;
+	h->files_objref = files_objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
 /* dump the task_struct of a given task */
 int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -239,6 +262,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		goto out;
 	ret = checkpoint_cpu(ctx, t);
 	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task_objs(ctx, t);
+	ckpt_debug("objs %d\n", ret);
  out:
 	ctx->tsk = NULL;
 	return ret;
@@ -246,7 +273,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
-	return 0;
+	int ret;
+
+	ret = ckpt_collect_file_table(ctx, t);
+
+	return ret;
 }
 
 /***********************************************************************
@@ -316,6 +347,22 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_objs(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_objs *h;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = restore_obj_file_table(ctx, h->files_objref);
+	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 int restore_restart_block(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_restart_block *h;
@@ -445,6 +492,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_cpu(ctx);
 	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_task_objs(ctx);
+	ckpt_debug("objs %d\n", ret);
  out:
 	return ret;
 }
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index 5e84915..0f4a74f 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -22,6 +22,7 @@
 #include <linux/file.h>
 #include <linux/uaccess.h>
 #include <linux/capability.h>
+#include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
 
 /*
@@ -198,12 +199,16 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->kflags & CKPT_CTX_RESTART)
 		restore_debug_free(ctx);
 
+	if (ctx->files_deferq)
+		deferqueue_destroy(ctx->files_deferq);
+
 	if (ctx->file)
 		fput(ctx->file);
 	if (ctx->logfile)
 		fput(ctx->logfile);
 
 	ckpt_obj_hash_free(ctx);
+	path_put(&ctx->root_fs_path);
 
 	if (ctx->tasks_arr)
 		task_arr_free(ctx);
@@ -262,6 +267,10 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (ckpt_obj_hash_alloc(ctx) < 0)
 		goto err;
 
+	ctx->files_deferq = deferqueue_create();
+	if (!ctx->files_deferq)
+		goto err;
+
 	atomic_inc(&ctx->refcount);
 	return ctx;
  err:
-- 
1.6.3.3
