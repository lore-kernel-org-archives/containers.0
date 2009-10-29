From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 17/17] ckpt_error in ipc/checkpoint_shm.c
Date: Thu, 29 Oct 2009 15:54:42 -0500
Message-ID: <1256849682-858-18-git-send-email-serue@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256849682-858-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint_shm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 826e430..eb9dc50 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -266,7 +266,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
  mutex:
 	fput(file);
 	if (ret < 0) {
-		ckpt_debug("shm: need to remove (%d)\n", ret);
+		ckpt_error(ctx, "%(T)shm: need to remove (%d)\n", ret);
 		do_shm_rmid(ns, perms);
 	} else
 		ipc_unlock(perms);
-- 
1.6.1
