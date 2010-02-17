From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH][RFC] checkpoint: refuse to checkpoint if monitoring
	directories with dnotify
Date: Wed, 17 Feb 2010 14:10:58 -0800
Message-ID: <06e8a57fc278e96c909ff3c0f1a167cee7a48dd5.1266444614.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

We do not support restarting fsnotify watches. inotify and fanotify utilize
anon_inodes for pseudofiles which lack the .checkpoint operation. So they
already cleanly prevent checkpoint. dnotify on the other hand registers
its watches using fcntl() which does not require the userspace task to
hold an fd with an empty .checkpoint operation. This means userspace
could use dnotify to set up fsnotify watches which won't be re-created during
restart.

Check for fsnotify watches created with dnotify and reject checkpoint
if there are any.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

NOTE: Totally untested.
---
 checkpoint/files.c          |    5 +++++
 fs/notify/dnotify/dnotify.c |   22 ++++++++++++++++++++++
 include/linux/dnotify.h     |    7 ++++++-
 3 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index d1242f2..c264987 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -236,6 +236,11 @@ int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 			 file);
 		return -EBADF;
 	}
+	if (is_dnotify_attached(file)) {
+		ckpt_err(ctx, -EBADF, "%(T)%(P)dnotify directory monitoring unsupported\n",
+			 file);
+		return -EBADF;
+	}
 
 	ret = file->f_op->checkpoint(ctx, file);
 	if (ret < 0)
diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
index 7e54e52..9ce85f5 100644
--- a/fs/notify/dnotify/dnotify.c
+++ b/fs/notify/dnotify/dnotify.c
@@ -289,6 +289,28 @@ static int attach_dn(struct dnotify_struct *dn, struct dnotify_mark_entry *dnent
 	return 0;
 }
 
+int is_dnotify_attached(struct file *filp)
+{
+	struct fsnotify_mark_entry *entry;
+	struct dnotify_mark_entry *dnentry;
+	struct dnotify_struct *dn;
+	struct dnotify_struct **prev;
+	struct inode *inode;
+
+	inode = filp->f_path.dentry->d_inode;
+	if (!S_ISDIR(inode->i_mode))
+		return 0;
+
+	spin_lock(&inode->i_lock);
+	entry = fsnotify_find_mark_entry(dnotify_group, inode);
+	spin_unlock(&inode->i_lock);
+	if (entry) {
+		fsnotify_put_mark(new_entry);
+		return 1;
+	}
+	return 0;
+}
+
 /*
  * When a process calls fcntl to attach a dnotify watch to a directory it ends
  * up here.  Allocate both a mark for fsnotify to add and a dnotify_struct to be
diff --git a/include/linux/dnotify.h b/include/linux/dnotify.h
index ecc0628..841c065 100644
--- a/include/linux/dnotify.h
+++ b/include/linux/dnotify.h
@@ -29,10 +29,15 @@ struct dnotify_struct {
 			    FS_MOVED_FROM | FS_MOVED_TO)
 
 extern void dnotify_flush(struct file *, fl_owner_t);
+extern int is_dnotify_attached(struct file *);
 extern int fcntl_dirnotify(int, struct file *, unsigned long);
-
 #else
 
+static inline int is_dnotify_attached(struct file *)
+{
+	return 0;
+}
+
 static inline void dnotify_flush(struct file *filp, fl_owner_t id)
 {
 }
-- 
1.6.3.3
