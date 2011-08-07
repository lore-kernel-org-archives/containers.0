From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 2/4] vfs: Introduce the fd closing helper
Date: Mon, 08 Aug 2011 01:01:14 +0400
Message-ID: <20110807210526.994391865@openvz.org>
References: <20110807210112.245578619@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=cr-2
Sender: linux-kernel-owner@vger.kernel.org
To: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akp>
Cc: Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Cyrill Gorcunov <gorcunov@openvz.org>
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>

This is nothing but making is possible to call the
sys_close from the kernel.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 fs/open.c          |   32 ++++++++++++++++++++------------
 include/linux/fs.h |    1 +
 2 files changed, 21 insertions(+), 12 deletions(-)

Index: linux-2.6.git/fs/open.c
===================================================================
--- linux-2.6.git.orig/fs/open.c
+++ linux-2.6.git/fs/open.c
@@ -1056,17 +1056,11 @@ int filp_close(struct file *filp, fl_own
 
 EXPORT_SYMBOL(filp_close);
 
-/*
- * Careful here! We test whether the file pointer is NULL before
- * releasing the fd. This ensures that one clone task can't release
- * an fd while another clone is opening it.
- */
-SYSCALL_DEFINE1(close, unsigned int, fd)
+int do_close(unsigned int fd)
 {
 	struct file * filp;
 	struct files_struct *files = current->files;
 	struct fdtable *fdt;
-	int retval;
 
 	spin_lock(&files->file_lock);
 	fdt = files_fdtable(files);
@@ -1079,7 +1073,25 @@ SYSCALL_DEFINE1(close, unsigned int, fd)
 	FD_CLR(fd, fdt->close_on_exec);
 	__put_unused_fd(files, fd);
 	spin_unlock(&files->file_lock);
-	retval = filp_close(filp, files);
+
+	return filp_close(filp, files);
+
+out_unlock:
+	spin_unlock(&files->file_lock);
+	return -EBADF;
+}
+EXPORT_SYMBOL_GPL(do_close);
+
+/*
+ * Careful here! We test whether the file pointer is NULL before
+ * releasing the fd. This ensures that one clone task can't release
+ * an fd while another clone is opening it.
+ */
+SYSCALL_DEFINE1(close, unsigned int, fd)
+{
+	int retval;
+
+	retval = do_close(fd);
 
 	/* can't restart close syscall because file table entry was cleared */
 	if (unlikely(retval == -ERESTARTSYS ||
@@ -1089,10 +1101,6 @@ SYSCALL_DEFINE1(close, unsigned int, fd)
 		retval = -EINTR;
 
 	return retval;
-
-out_unlock:
-	spin_unlock(&files->file_lock);
-	return -EBADF;
 }
 EXPORT_SYMBOL(sys_close);
 
Index: linux-2.6.git/include/linux/fs.h
===================================================================
--- linux-2.6.git.orig/include/linux/fs.h
+++ linux-2.6.git/include/linux/fs.h
@@ -2012,6 +2012,7 @@ extern struct file *file_open_root(struc
 extern struct file * dentry_open(struct dentry *, struct vfsmount *, int,
 				 const struct cred *);
 extern int filp_close(struct file *, fl_owner_t id);
+extern int do_close(unsigned int fd);
 extern char * getname(const char __user *);
 
 /* fs/ioctl.c */
