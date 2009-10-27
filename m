From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 16/17] ckpt_error in ipc/checkpoint_sem.c
Date: Tue, 27 Oct 2009 17:46:26 -0500
Message-ID: <1256683587-23961-17-git-send-email-serge@us.ibm.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256683587-23961-1-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint_sem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 76eb2b9..0b610ee 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -209,7 +209,7 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 
 	ret = load_ipc_sem_hdr(ctx, h, sem);
 	if (ret < 0) {
-		ckpt_debug("sem: need to remove (%d)\n", ret);
+		ckpt_error(ctx, "%(T)sem: need to remove (%d)\n", ret);
 		freeary(ns, perms);
 	} else
 		ipc_unlock(perms);
-- 
1.6.1
