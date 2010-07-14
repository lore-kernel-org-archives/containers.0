From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Checkpoint and restore task->fs->umask
Date: Wed, 14 Jul 2010 13:10:43 -0700
Message-ID: <1279138243-25087-1-git-send-email-danms@us.ibm.com>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Without this, a task's umask will likely be different before and after
a c/r cycle.  Since the user is able to set their umask to anything
(within reason) this is a rather trivial addition.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/checkpoint.c                |   18 +++++++++++++-----
 include/linux/checkpoint_hdr.h |    1 +
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index 70248b1..08b727f 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -418,6 +418,9 @@ static int checkpoint_fs(struct ckpt_ctx *ctx, void *ptr)
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FS);
 	if (!h)
 		return -ENOMEM;
+
+	h->umask = fs->umask;
+
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
 	if (ret)
@@ -984,18 +987,21 @@ static int restore_cwd(struct ckpt_ctx *ctx, struct fs_struct *fs, char *name)
 static void *restore_fs(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_fs *h;
-	struct fs_struct *fs;
+	struct fs_struct *fs = NULL;
 	char *path;
 	int ret = 0;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FS);
 	if (IS_ERR(h))
 		return ERR_PTR(PTR_ERR(h));
-	ckpt_hdr_put(ctx, h);
 
 	fs = copy_fs_struct(current->fs);
-	if (!fs)
-		return ERR_PTR(-ENOMEM);
+	if (!fs) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	fs->umask = h->umask & S_IRWXUGO;
 
 	ret = ckpt_read_fname(ctx, &path);
 	if (ret < 0)
@@ -1012,8 +1018,10 @@ static void *restore_fs(struct ckpt_ctx *ctx)
 	kfree(path);
 
 out:
+	ckpt_hdr_put(ctx, h);
 	if (ret) {
-		free_fs_struct(fs);
+		if (fs)
+			free_fs_struct(fs);
 		return ERR_PTR(ret);
 	}
 	return fs;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 16b1723..a0eb2bb 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -524,6 +524,7 @@ enum restart_block_type {
 /* file system */
 struct ckpt_hdr_fs {
 	struct ckpt_hdr h;
+	__u32 umask;
 	/* char *fs_root */
 	/* char *fs_pwd */
 } __attribute__((aligned(8)));
-- 
1.7.1.1
