From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 2/7] vfs: Introduce the fd closing helper
Date: Fri, 15 Jul 2011 17:46:15 +0400
Message-ID: <4E2044A7.4030103@parallels.com>
References: <4E204466.8010204@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4E204466.8010204-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

This is nothing but making is possible to call the sys_close from the kernel.

Signed-off-by: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

---
 fs/open.c          |   32 ++++++++++++++++++++------------
 include/linux/fs.h |    1 +
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index b52cf01..126aa8b 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -1078,17 +1078,11 @@ int filp_close(struct file *filp, fl_owner_t id)
 
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
@@ -1101,7 +1095,25 @@ SYSCALL_DEFINE1(close, unsigned int, fd)
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
@@ -1111,10 +1123,6 @@ SYSCALL_DEFINE1(close, unsigned int, fd)
 		retval = -EINTR;
 
 	return retval;
-
-out_unlock:
-	spin_unlock(&files->file_lock);
-	return -EBADF;
 }
 EXPORT_SYMBOL(sys_close);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index cdf9495..77a5d3e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1991,6 +1991,7 @@ extern struct file *file_open_root(struct dentry *, struct vfsmount *,
 extern struct file * dentry_open(struct dentry *, struct vfsmount *, int,
 				 const struct cred *);
 extern int filp_close(struct file *, fl_owner_t id);
+extern int do_close(unsigned int fd);
 extern char * getname(const char __user *);
 
 /* fs/ioctl.c */
-- 
1.5.5.6
