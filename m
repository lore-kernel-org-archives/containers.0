From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] cr: handle CONFIG_SYSVIPC=n
Date: Fri,  9 Apr 2010 16:12:58 -0500
Message-ID: <1270847578-26250-3-git-send-email-serue@us.ibm.com>
References: <1270847578-26250-1-git-send-email-serue@us.ibm.com>
	<1270847578-26250-2-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1270847578-26250-2-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

If CONFIG_IPC_NS=n, then checkpoint a sysvipcns of 0.  If we
end up restarted on a CONFIG_SYSVIPC=y host, we'll just end up
using the parent sysvipcns, which is fine as we won't be trying
to restore any sysvipc objects.

(The existing code worked fine with CONFIG_IPC_NS=n, but not
with CONFIG_SYSVIPC=n and CONFIG_POSIX_MQUEUE=n.  But we
trigger on CONFIG_IPC_NS since even if CONFIG_SYSVIPC=y but
CONFIG_IPC_NS=n, checkpointing 0 is right).

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/nsproxy.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 5f9d809..0b43f4d 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -290,9 +290,13 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 	if (ret <= 0)
 		goto out;
 	h->uts_objref = ret;
+#ifdef CONFIG_IPC_NS
 	ret = checkpoint_obj(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
 	if (ret < 0)
 		goto out;
+#else	/* CONFIG_IPC_NS */
+	ret = 0;
+#endif	/* CONFIG_IPC_NS */
 	h->ipc_objref = ret;
 #ifdef CONFIG_NETNS_CHECKPOINT
 	if (!(ctx->uflags & CHECKPOINT_NONETNS))
-- 
1.7.0.4
