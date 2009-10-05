From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] debug: add a few ckpt_debugs
Date: Mon, 5 Oct 2009 16:51:14 -0500
Message-ID: <20091005215114.GA26052@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

These were pulled out of the lsm-related patches into which they
had been embedded.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c   |    3 +++
 checkpoint/process.c |   20 ++++++++++++++++----
 kernel/cred.c        |    2 ++
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 27e29a0..f6de07e 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -159,6 +159,9 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	if (h->f_credref < 0)
 		return h->f_credref;
 
+	ckpt_debug("file %s credref %d", file->f_dentry->d_name.name,
+		h->f_credref);
+
 	/* FIX: need also file->f_owner, etc */
 
 	return 0;
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 424f688..8a7459d 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -581,11 +581,15 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
 
 	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(realcred)) {
+		ckpt_debug("Error %ld fetching realcred (ref %d)\n",
+			PTR_ERR(realcred), h->cred_ref);
 		ret = PTR_ERR(realcred);
 		goto out;
 	}
 	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(ecred)) {
+		ckpt_debug("Error %ld fetching ecred (ref %d)\n",
+			PTR_ERR(ecred), h->ecred_ref);
 		ret = PTR_ERR(ecred);
 		goto out;
 	}
@@ -593,6 +597,7 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
 	ctx->ecred = ecred;
 
 out:
+	ckpt_debug("Returning %d\n", ret);
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
@@ -608,14 +613,21 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	 * referenced. See comment in checkpoint_task_objs.
 	 */
 	ret = restore_task_creds(ctx);
-	if (!ret)
-		ret = restore_task_ns(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("restore_task_creds returned %d\n", ret);
+		return ret;
+	}
+	ret = restore_task_ns(ctx);
+	if (ret < 0) {
+		ckpt_debug("restore_task_ns returned %d\n", ret);
 		return ret;
+	}
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
-	if (IS_ERR(h))
+	if (IS_ERR(h)) {
+		ckpt_debug("Error fetching task obj\n");
 		return PTR_ERR(h);
+	}
 
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
diff --git a/kernel/cred.c b/kernel/cred.c
index 9710cae..62d28a4 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -724,6 +724,8 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	if (!h)
 		return -ENOMEM;
 
+	ckpt_debug("cred uid %d fsuid %d gid %d\n", cred->uid, cred->fsuid,
+			cred->gid);
 	h->uid = cred->uid;
 	h->suid = cred->suid;
 	h->euid = cred->euid;
-- 
1.6.1
