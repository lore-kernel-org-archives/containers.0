From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC] cr: pts: detect use of multiple devpts mounts in container
Date: Thu, 29 Apr 2010 10:28:48 -0500
Message-ID: <20100429152848.GA7090@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

We don't support multiple devpts mounts in a container.  So
bail on checkpoint if a container has them.  This will cause
checkpoint to fail of a container which still has a pty from
parent container in use.

Note one issue with this is the register_checkpoint_obj(&&ckpt_obj_ptsns_ops)
done from module_init().  We either need to add a matching unregister,
or maybe move this into drivers/char/tty_io.c.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 drivers/char/tty_io.c            |   27 +++++++++++++++++++++++++++
 fs/devpts/inode.c                |    9 ++++++++-
 include/linux/checkpoint_hdr.h   |    2 ++
 include/linux/checkpoint_types.h |    2 ++
 include/linux/devpts_fs.h        |   22 ++++++++++++++++++++--
 5 files changed, 59 insertions(+), 3 deletions(-)

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index d264000..d24752e 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -96,6 +96,7 @@
 #include <linux/bitops.h>
 #include <linux/delay.h>
 #include <linux/seq_file.h>
+#include <linux/mount.h>
 
 #include <linux/uaccess.h>
 #include <asm/system.h>
@@ -2687,6 +2688,27 @@ static int tty_can_checkpoint(struct ckpt_ctx *ctx, struct tty_struct *tty)
 	return 1;
 }
 
+/*
+ * If tty_file_checkpoint() ever supports more than unix98 ptys we'll have
+ * to check for that
+ */
+static int detect_multiple_ptsns(struct ckpt_ctx *ctx, struct file *file)
+{
+	int objref;
+	int new;
+
+	objref = ckpt_obj_lookup_add(ctx, file->f_path.mnt->mnt_sb,
+				  CKPT_OBJ_PTS_NS, &new);
+	if (objref < 0)
+		return objref;
+	if (new && ctx->num_devpts_ns)
+		return -EBUSY;
+	if (file->f_path.mnt->mnt_ns != ctx->root_nsproxy->mnt_ns)
+		return -EBUSY;
+	ctx->num_devpts_ns++;
+	return 0;
+}
+
 static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 {
 	struct ckpt_hdr_file_tty *h;
@@ -2732,6 +2754,11 @@ static int tty_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 		ret = ckpt_write_obj(ctx, &h->common.h);
 
 	ckpt_hdr_put(ctx, h);
+
+	ret = detect_multiple_ptsns(ctx, file);
+	if (ret)
+		ckpt_err(ctx, ret, "Open pty from alien ptsns\n");
+
 	return ret;
 }
 
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 75fb8c5..83f42b9 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -572,7 +572,14 @@ out:
 
 static int __init init_devpts_fs(void)
 {
-	int err = register_filesystem(&devpts_fs_type);
+	int err;
+#ifdef CONFIG_CHECKPOINT
+	err = register_checkpoint_obj(&ckpt_obj_ptsns_ops);
+	if (err)
+		return err;
+#endif
+
+	err = register_filesystem(&devpts_fs_type);
 	if (!err) {
 		devpts_mnt = kern_mount(&devpts_fs_type);
 		if (IS_ERR(devpts_mnt)) {
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index eb5e1b4..694fdfe 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -271,6 +271,8 @@ enum obj_type {
 #define CKPT_OBJ_NET_NS CKPT_OBJ_NET_NS
 	CKPT_OBJ_NETDEV,
 #define CKPT_OBJ_NETDEV CKPT_OBJ_NETDEV
+	CKPT_OBJ_PTS_NS,
+#define CKPT_OBJ_PTS_NS CKPT_OBJ_PTS_NS
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index eb3fdac..84782b0 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -86,6 +86,8 @@ struct ckpt_ctx {
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 	struct list_head listen_sockets;/* listening parent sockets */
 
+	int num_devpts_ns;		/* must not become > 1 at the moment */
+
 	struct ckpt_stats stats;	/* statistics */
 
 #define CKPT_MSG_LEN 1024
diff --git a/include/linux/devpts_fs.h b/include/linux/devpts_fs.h
index 163a70e..63fbee2 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -14,6 +14,7 @@
 #define _LINUX_DEVPTS_FS_H
 
 #include <linux/errno.h>
+#include <linux/checkpoint.h>
 
 #define UNSPECIFIED_PTY_INDEX -1
 
@@ -30,7 +31,24 @@ struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number);
 /* unlink */
 void devpts_pty_kill(struct tty_struct *tty);
 
-#else
+#ifdef CONFIG_CHECKPOINT
+/*
+ * We don't yet support multiple pts mounts in a container, so
+ * all we're doing here is detecting pty's in >1 ptsns.  We'll
+ * actually stick the sb on the objhash because that's all there
+ * is.  Note that means that when we start checkpointing mounts
+ * and filesystems we'll need to change this.
+ *
+ * We don't need to pin these bc they are pinned by the pty,
+ * which we do have pinned.
+ */
+static const struct ckpt_obj_ops ckpt_obj_ptsns_ops = {
+	.obj_name = "PTS NS",
+	.obj_type = CKPT_OBJ_PTS_NS,
+};
+#endif /* CONFIG_CHECKPOINT */
+
+#else /* CONFIG_UNIX98_PTYS */
 
 /* Dummy stubs in the no-pty case */
 static inline int devpts_new_index(struct inode *ptmx_inode) { return -EINVAL; }
@@ -47,7 +65,7 @@ static inline struct tty_struct *devpts_get_tty(struct inode *pts_inode,
 }
 static inline void devpts_pty_kill(struct tty_struct *tty) { }
 
-#endif
+#endif /* CONFIG_UNIX98_PTYS */
 
 
 #endif /* _LINUX_DEVPTS_FS_H */
-- 
1.7.0.4
