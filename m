From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 050/100] c/r: refuse to checkpoint if monitoring
	directories with dnotify
Date: Sat,  1 May 2010 10:15:32 -0400
Message-ID: <1272723382-19470-51-git-send-email-orenl__27737.1493088596$1272724907$gmane$org@cs.columbia.edu>
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

From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

We do not support restarting fsnotify watches. inotify and fanotify utilize
anon_inodes for pseudofiles which lack the .checkpoint operation. So they
already cleanly prevent checkpoint. dnotify on the other hand registers
its watches using fcntl() which does not require the userspace task to
hold an fd with an empty .checkpoint operation. This means userspace
could use dnotify to set up fsnotify watches which won't be re-created during
restart.

Check for fsnotify watches created with dnotify and reject checkpoint
if there are any.

Changelog [v21]:
  - [Stanislav O. Bezzubtsev] Fix omitted parameter name error

Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/checkpoint.c             |    5 +++++
 fs/notify/dnotify/dnotify.c |   18 ++++++++++++++++++
 include/linux/dnotify.h     |    6 ++++++
 3 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 06f1130..874be00 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -206,6 +206,11 @@ static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 		return -EBADF;
 	}
 
+	if (is_dnotify_attached(file)) {
+		ckpt_err(ctx, -EBADF, "%(T)%(P)dnotify unsupported\n", file);
+		return -EBADF;
+	}
+
 	ret = file->f_op->checkpoint(ctx, file);
 	if (ret < 0)
 		ckpt_err(ctx, ret, "%(T)%(P)file checkpoint failed\n", file);
diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 7e54e52..0a63bf6 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -289,6 +289,24 @@ static int attach_dn(struct dnotify_struct *dn, struct dnotify_mark_entry *dnent
 	return 0;
 }
 
+int is_dnotify_attached(struct file *filp)
+{
+	struct fsnotify_mark_entry *entry;
+	struct inode *inode;
+
+	inode = filp->f_path.dentry->d_inode;
+	if (!S_ISDIR(inode->i_mode))
+		return 0;
+
+	spin_lock(&inode->i_lock);
+	entry = fsnotify_find_mark_entry(dnotify_group, inode);
+	spin_unlock(&inode->i_lock);
+	if (!entry)
+		return 0;
+	fsnotify_put_mark(entry);
+	return 1;
+}
+
 /*
  * When a process calls fcntl to attach a dnotify watch to a directory it ends
  * up here.  Allocate both a mark for fsnotify to add and a dnotify_struct to be
diff --git a/include/linux/dnotify.h b/include/linux/dnotify.h
index ecc0628..7093052 100644
--- a/include/linux/dnotify.h
+++ b/include/linux/dnotify.h
@@ -29,6 +29,7 @@ struct dnotify_struct {
 			    FS_MOVED_FROM | FS_MOVED_TO)
 
 extern void dnotify_flush(struct file *, fl_owner_t);
+extern int is_dnotify_attached(struct file *);
 extern int fcntl_dirnotify(int, struct file *, unsigned long);
 
 #else
@@ -37,6 +38,11 @@ static inline void dnotify_flush(struct file *filp, fl_owner_t id)
 {
 }
 
+static inline int is_dnotify_attached(struct file *filp)
+{
+	return 0;
+}
+
 static inline int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
 {
 	return -EINVAL;
-- 
1.6.3.3
