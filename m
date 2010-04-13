From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cr: don't try to collect or fetch ipc_ns
Date: Tue, 13 Apr 2010 18:55:41 -0500
Message-ID: <20100413235541.GA5869@us.ibm.com>
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
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This is just the completion of the patch i sent a few days
ago to prevent checkpoint_obj()ing the ipc_ns.  With
CONFIG_SYSVIPC=n and CONFIG_POSIX_MQUEUE=n, and without
this patch, the pthread1 testcase fails.  (The only reason
that one fails while the others succeed, i think is because
it uses 'nsexec -n', forcing a new net-ns and therefore
forcing a new nsproxy, which the other testcases do not
do).

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/nsproxy.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 8f2d0b7..92c84b8 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -254,6 +254,7 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (ret < 0)
 		goto out;
 #endif
+#ifdef CONFIG_IPC_NS
 	ret = ckpt_obj_collect(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
 	if (ret < 0)
 		goto out;
@@ -266,6 +267,7 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 		if (ret < 0)
 			goto out;
 	}
+#endif
 
 	ret = ckpt_obj_collect(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
 	if (ret < 0)
@@ -353,8 +355,13 @@ static void *restore_ns(struct ckpt_ctx *ctx)
 
 	if (h->ipc_objref == 0)
 		ipc_ns = ctx->root_nsproxy->ipc_ns;
+#ifdef CONFIG_IPC_NS
 	else
 		ipc_ns = ckpt_obj_fetch(ctx, h->ipc_objref, CKPT_OBJ_IPC_NS);
+#else
+	else
+		ipc_ns = ERR_PTR(-EINVAL);
+#endif
 	if (IS_ERR(ipc_ns)) {
 		ret = PTR_ERR(ipc_ns);
 		goto out;
-- 
1.7.0.4
