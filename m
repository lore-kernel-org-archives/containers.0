From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/6] Add CHECKPOINT_NONETNS flag
Date: Mon, 22 Mar 2010 12:33:32 -0700
Message-ID: <1269286415-24851-4-git-send-email-danms@us.ibm.com>
References: <1269286415-24851-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269286415-24851-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

This flag allows you to checkpoint a process without its network namespace,
ignoring all the devices within.  The restart will then depend on either:

 1. Userspace recreating the interfaces necessary to rebind sockets
 2. The only open sockets are those listening on 0.0.0.0

With this patch, I can checkpoint a network application with this flag
enabled and restart it on a kernel without CONFIG_CHECKPOINT_NETNS support.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h |    3 ++-
 kernel/nsproxy.c           |    8 ++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 0fb647b..1e7f8d3 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -14,6 +14,7 @@
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
+#define CHECKPOINT_NONETNS	0x2
 
 /* restart user flags */
 #define RESTART_TASKSELF	0x1
@@ -56,7 +57,7 @@ extern long do_sys_restart(pid_t pid, int fd,
 #define CKPT_CTX_ERROR		(1 << CKPT_CTX_ERROR_BIT)
 
 /* ckpt_ctx: uflags */
-#define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
+#define CHECKPOINT_USER_FLAGS	(CHECKPOINT_SUBTREE | CHECKPOINT_NONETNS)
 #define RESTART_USER_FLAGS  \
 	(RESTART_TASKSELF | \
 	 RESTART_FROZEN | \
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b0e67ff..e6a748b 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -249,7 +249,8 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (ret < 0)
 		goto out;
 #ifdef CONFIG_CHECKPOINT_NETNS
-	ret = ckpt_obj_collect(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
+	if (!(ctx->uflags & CHECKPOINT_NONETNS))
+		ret = ckpt_obj_collect(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
 	if (ret < 0)
 		goto out;
 #endif
@@ -294,7 +295,10 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 		goto out;
 	h->ipc_objref = ret;
 #ifdef CONFIG_CHECKPOINT_NETNS
-	ret = checkpoint_obj(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
+	if (!(ctx->uflags & CHECKPOINT_NONETNS))
+		ret = checkpoint_obj(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
+	else
+		ret = 0;
 	if (ret < 0)
 		goto out;
 	h->net_objref = ret;
-- 
1.6.2.5
