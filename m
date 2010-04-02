From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Invert the NETNS checkpoint flag
Date: Fri,  2 Apr 2010 06:34:25 -0700
Message-ID: <1270215265-29081-1-git-send-email-danms@us.ibm.com>
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

Change CHECKPOINT_NONETNS to CHECKPOINT_NETNS.  This makes it the default
to ignore network namespaces and devices, unless specifically asked for
by the caller.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h |    4 ++--
 kernel/nsproxy.c           |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6da0a2e..96693e2 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -14,7 +14,7 @@
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
-#define CHECKPOINT_NONETNS	0x2
+#define CHECKPOINT_NETNS	0x2
 
 /* restart user flags */
 #define RESTART_TASKSELF	0x1
@@ -59,7 +59,7 @@ extern long do_sys_restart(pid_t pid, int fd,
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS \
 	(CHECKPOINT_SUBTREE | \
-	 CHECKPOINT_NONETNS)
+	 CHECKPOINT_NETNS)
 
 #define RESTART_USER_FLAGS  \
 	(RESTART_TASKSELF | \
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index c19f5fa..041fb09 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -249,7 +249,7 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (ret < 0)
 		goto out;
 #ifdef CONFIG_NETNS_CHECKPOINT
-	if (!(ctx->uflags & CHECKPOINT_NONETNS))
+	if (ctx->uflags & CHECKPOINT_NETNS)
 		ret = ckpt_obj_collect(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
 	if (ret < 0)
 		goto out;
@@ -295,7 +295,7 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 		goto out;
 	h->ipc_objref = ret;
 #ifdef CONFIG_NETNS_CHECKPOINT
-	if (!(ctx->uflags & CHECKPOINT_NONETNS))
+	if (ctx->uflags & CHECKPOINT_NETNS)
 		ret = checkpoint_obj(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
 	else
 		ret = 0;
-- 
1.6.2.5
