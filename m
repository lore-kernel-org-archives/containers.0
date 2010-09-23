From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/6] Move sys-wrappers
Date: Thu, 23 Sep 2010 14:53:27 -0700
Message-ID: <6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc@us.ibm.com>
References: <1285278812-16972-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285278812-16972-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Checkpoint/restart code will be using the sys-wrappers. Move it to a more
appropriate location.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/sys-wrapper.h |  216 +++++++++++++++++++++++++++++++++++++++++++
 init/sys-wrapper.h          |  216 -------------------------------------------
 2 files changed, 216 insertions(+), 216 deletions(-)
 create mode 100644 include/linux/sys-wrapper.h
 delete mode 100644 init/sys-wrapper.h

diff --git a/include/linux/sys-wrapper.h b/include/linux/sys-wrapper.h
new file mode 100644
index 0000000..10109b6
--- /dev/null
+++ b/include/linux/sys-wrapper.h
@@ -0,0 +1,216 @@
+/*
+ * wrappers for various syscalls for use in the init code
+ *
+ * Copyright (C) 2010  Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ *
+ * This file is released under the GPLv2.
+ */
+
+#include <linux/syscalls.h>
+#include <linux/uaccess.h>
+#include <linux/dirent.h>
+#include <linux/types.h>
+#include <linux/fs.h>
+
+
+#define kernel_sys_call(call, ...)		\
+({						\
+	long result;				\
+	mm_segment_t old_fs = get_fs();		\
+	set_fs(KERNEL_DS);			\
+	result = call(__VA_ARGS__);		\
+	set_fs(old_fs);				\
+	result;					\
+})
+
+static inline int kernel_sys_mount(char *dev_name, char *dir_name, char *type,
+				   unsigned long flags, void *data)
+{
+	return kernel_sys_call(sys_mount,
+			       (char __user __force *) dev_name,
+			       (char __user __force *) dir_name,
+			       (char __user __force *) type,
+			       flags,
+			       (void __user __force *) data);
+}
+
+static inline int kernel_sys_umount(char *name, int flags)
+{
+	return kernel_sys_call(sys_umount,
+			       (char __user __force *) name, flags);
+}
+
+static inline int kernel_sys_chroot(const char *pathname)
+{
+	return kernel_sys_call(sys_chroot,
+			       (const char __user __force *) pathname);
+}
+
+static inline int kernel_sys_link(const char *oldname, const char *newname)
+{
+	return kernel_sys_call(sys_link,
+			       (const char __user __force *) oldname,
+			       (const char __user __force *) newname);
+}
+
+static inline int kernel_sys_unlink(const char *pathname)
+{
+	return kernel_sys_call(sys_unlink,
+			       (const char __user __force *) pathname);
+}
+
+static inline int kernel_sys_newlstat(const char *filename,
+				      struct stat *statbuf)
+{
+	return kernel_sys_call(sys_newlstat,
+			       (const char __user __force *) filename,
+			       (struct stat __user __force *) statbuf);
+}
+
+static inline int kernel_sys_mkdir(const char *pathname, int mode)
+{
+	return kernel_sys_call(sys_mkdir,
+			       (const char __user __force *) pathname, mode);
+}
+
+static inline int kernel_sys_rmdir(const char *pathname)
+{
+	return kernel_sys_call(sys_rmdir,
+			       (const char __user __force *) pathname);
+}
+
+static inline int kernel_sys_chdir(const char *pathname)
+{
+	return kernel_sys_call(sys_chdir,
+			       (const char __user __force *) pathname);
+}
+
+static inline int kernel_sys_mknod(const char *filename,
+				   int mode, unsigned dev)
+{
+	return kernel_sys_call(sys_mknod,
+			       (const char __user __force *) filename,
+			       mode, dev);
+}
+
+static inline int kernel_sys_chown(const char *filename,
+				   uid_t user, gid_t group)
+{
+	return kernel_sys_call(sys_chown,
+			       (const char __user __force *) filename,
+			       user, group);
+}
+
+static inline int kernel_sys_chmod(const char *filename, mode_t mode)
+{
+	return kernel_sys_call(sys_chmod,
+			       (const char __user __force *) filename, mode);
+}
+
+static inline int kernel_sys_open(const char *filename, int flags, int mode)
+{
+	return kernel_sys_call(sys_open,
+			       (const char __user __force *) filename,
+			       flags, mode);
+}
+
+static inline int kernel_sys_fchown(unsigned int fd, uid_t user, gid_t group)
+{
+	return sys_fchown(fd, user, group);
+}
+
+static inline int kernel_sys_fchmod(unsigned int fd, mode_t mode)
+{
+	return sys_fchmod(fd, mode);
+}
+
+static inline int kernel_sys_fchdir(unsigned int fd)
+{
+	return sys_fchdir(fd);
+}
+
+static inline int kernel_sys_ftruncate(unsigned int fd, unsigned long length)
+{
+	return sys_ftruncate(fd, length);
+}
+
+static inline int kernel_sys_read(unsigned int fd, char *buf, size_t count)
+{
+	return kernel_sys_call(sys_read,
+			       fd, (char __user __force *) buf, count);
+}
+
+static inline int kernel_sys_write(unsigned int fd, const char *buf,
+				   size_t count)
+{
+	return kernel_sys_call(sys_write,
+			       fd, (const char __user __force *) buf, count);
+}
+
+static inline int kernel_sys_lseek(unsigned int fd, off_t offset,
+				   unsigned int origin)
+{
+	return sys_lseek(fd, offset, origin);
+}
+
+static inline int kernel_sys_ioctl(unsigned int fd, unsigned int cmd,
+				   unsigned long arg)
+{
+	return sys_ioctl(fd, cmd, arg);
+}
+
+static inline int kernel_sys_dup(unsigned int fd)
+{
+	return sys_dup(fd);
+}
+
+static inline int kernel_sys_close(unsigned int fd)
+{
+	return sys_close(fd);
+}
+
+static inline int kernel_sys_symlink(const char *oldname, const char *newname)
+{
+	return kernel_sys_call(sys_symlink,
+			       (const char __user __force *) oldname,
+			       (const char __user __force *) newname);
+}
+
+static inline int kernel_sys_lchown(const char *filename, uid_t user,
+				    gid_t group)
+{
+	return kernel_sys_call(sys_lchown,
+			       (const char __user __force *) filename,
+			       user, group);
+}
+
+static inline int kernel_sys_getdents64(unsigned int fd,
+					struct linux_dirent64 *dirent,
+					unsigned int count)
+{
+	return kernel_sys_call(sys_getdents64,
+			       fd,
+			       (struct linux_dirent64 __user __force *) dirent,
+			       count);
+}
+
+static inline int kernel_sys_access(const char *filename, int mode)
+{
+	return kernel_sys_call(sys_access,
+			       (const char __user __force *) filename, mode);
+}
+
+static inline int kernel_sys_setsid(void)
+{
+	return sys_setsid();
+}
+
+static inline int kernel_sys_wait4(pid_t upid, int *stat_addr, int options,
+				   struct rusage *ru)
+{
+	return kernel_sys_call(sys_wait4,
+			       upid,
+			       (int __user __force *) stat_addr,
+			       options,
+			       (struct rusage __user __force *) ru);
+}
diff --git a/init/sys-wrapper.h b/init/sys-wrapper.h
deleted file mode 100644
index 10109b6..0000000
--- a/init/sys-wrapper.h
+++ /dev/null
@@ -1,216 +0,0 @@
-/*
- * wrappers for various syscalls for use in the init code
- *
- * Copyright (C) 2010  Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
- *
- * This file is released under the GPLv2.
- */
-
-#include <linux/syscalls.h>
-#include <linux/uaccess.h>
-#include <linux/dirent.h>
-#include <linux/types.h>
-#include <linux/fs.h>
-
-
-#define kernel_sys_call(call, ...)		\
-({						\
-	long result;				\
-	mm_segment_t old_fs = get_fs();		\
-	set_fs(KERNEL_DS);			\
-	result = call(__VA_ARGS__);		\
-	set_fs(old_fs);				\
-	result;					\
-})
-
-static inline int kernel_sys_mount(char *dev_name, char *dir_name, char *type,
-				   unsigned long flags, void *data)
-{
-	return kernel_sys_call(sys_mount,
-			       (char __user __force *) dev_name,
-			       (char __user __force *) dir_name,
-			       (char __user __force *) type,
-			       flags,
-			       (void __user __force *) data);
-}
-
-static inline int kernel_sys_umount(char *name, int flags)
-{
-	return kernel_sys_call(sys_umount,
-			       (char __user __force *) name, flags);
-}
-
-static inline int kernel_sys_chroot(const char *pathname)
-{
-	return kernel_sys_call(sys_chroot,
-			       (const char __user __force *) pathname);
-}
-
-static inline int kernel_sys_link(const char *oldname, const char *newname)
-{
-	return kernel_sys_call(sys_link,
-			       (const char __user __force *) oldname,
-			       (const char __user __force *) newname);
-}
-
-static inline int kernel_sys_unlink(const char *pathname)
-{
-	return kernel_sys_call(sys_unlink,
-			       (const char __user __force *) pathname);
-}
-
-static inline int kernel_sys_newlstat(const char *filename,
-				      struct stat *statbuf)
-{
-	return kernel_sys_call(sys_newlstat,
-			       (const char __user __force *) filename,
-			       (struct stat __user __force *) statbuf);
-}
-
-static inline int kernel_sys_mkdir(const char *pathname, int mode)
-{
-	return kernel_sys_call(sys_mkdir,
-			       (const char __user __force *) pathname, mode);
-}
-
-static inline int kernel_sys_rmdir(const char *pathname)
-{
-	return kernel_sys_call(sys_rmdir,
-			       (const char __user __force *) pathname);
-}
-
-static inline int kernel_sys_chdir(const char *pathname)
-{
-	return kernel_sys_call(sys_chdir,
-			       (const char __user __force *) pathname);
-}
-
-static inline int kernel_sys_mknod(const char *filename,
-				   int mode, unsigned dev)
-{
-	return kernel_sys_call(sys_mknod,
-			       (const char __user __force *) filename,
-			       mode, dev);
-}
-
-static inline int kernel_sys_chown(const char *filename,
-				   uid_t user, gid_t group)
-{
-	return kernel_sys_call(sys_chown,
-			       (const char __user __force *) filename,
-			       user, group);
-}
-
-static inline int kernel_sys_chmod(const char *filename, mode_t mode)
-{
-	return kernel_sys_call(sys_chmod,
-			       (const char __user __force *) filename, mode);
-}
-
-static inline int kernel_sys_open(const char *filename, int flags, int mode)
-{
-	return kernel_sys_call(sys_open,
-			       (const char __user __force *) filename,
-			       flags, mode);
-}
-
-static inline int kernel_sys_fchown(unsigned int fd, uid_t user, gid_t group)
-{
-	return sys_fchown(fd, user, group);
-}
-
-static inline int kernel_sys_fchmod(unsigned int fd, mode_t mode)
-{
-	return sys_fchmod(fd, mode);
-}
-
-static inline int kernel_sys_fchdir(unsigned int fd)
-{
-	return sys_fchdir(fd);
-}
-
-static inline int kernel_sys_ftruncate(unsigned int fd, unsigned long length)
-{
-	return sys_ftruncate(fd, length);
-}
-
-static inline int kernel_sys_read(unsigned int fd, char *buf, size_t count)
-{
-	return kernel_sys_call(sys_read,
-			       fd, (char __user __force *) buf, count);
-}
-
-static inline int kernel_sys_write(unsigned int fd, const char *buf,
-				   size_t count)
-{
-	return kernel_sys_call(sys_write,
-			       fd, (const char __user __force *) buf, count);
-}
-
-static inline int kernel_sys_lseek(unsigned int fd, off_t offset,
-				   unsigned int origin)
-{
-	return sys_lseek(fd, offset, origin);
-}
-
-static inline int kernel_sys_ioctl(unsigned int fd, unsigned int cmd,
-				   unsigned long arg)
-{
-	return sys_ioctl(fd, cmd, arg);
-}
-
-static inline int kernel_sys_dup(unsigned int fd)
-{
-	return sys_dup(fd);
-}
-
-static inline int kernel_sys_close(unsigned int fd)
-{
-	return sys_close(fd);
-}
-
-static inline int kernel_sys_symlink(const char *oldname, const char *newname)
-{
-	return kernel_sys_call(sys_symlink,
-			       (const char __user __force *) oldname,
-			       (const char __user __force *) newname);
-}
-
-static inline int kernel_sys_lchown(const char *filename, uid_t user,
-				    gid_t group)
-{
-	return kernel_sys_call(sys_lchown,
-			       (const char __user __force *) filename,
-			       user, group);
-}
-
-static inline int kernel_sys_getdents64(unsigned int fd,
-					struct linux_dirent64 *dirent,
-					unsigned int count)
-{
-	return kernel_sys_call(sys_getdents64,
-			       fd,
-			       (struct linux_dirent64 __user __force *) dirent,
-			       count);
-}
-
-static inline int kernel_sys_access(const char *filename, int mode)
-{
-	return kernel_sys_call(sys_access,
-			       (const char __user __force *) filename, mode);
-}
-
-static inline int kernel_sys_setsid(void)
-{
-	return sys_setsid();
-}
-
-static inline int kernel_sys_wait4(pid_t upid, int *stat_addr, int options,
-				   struct rusage *ru)
-{
-	return kernel_sys_call(sys_wait4,
-			       upid,
-			       (int __user __force *) stat_addr,
-			       options,
-			       (struct rusage __user __force *) ru);
-}
-- 
1.6.3.3
