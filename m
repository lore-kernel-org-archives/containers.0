From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/8] cr: fix memory leak on lsm error on restart
Date: Thu, 3 Sep 2009 17:26:49 -0500
Message-ID: <20090903222648.GA27377@us.ibm.com>
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

(this is a bugfix for the patch
cr: checkpoint the active LSM and add RESTART_KEEP_LSM flag
)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 67edf39..f51838b 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -431,7 +431,8 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 		if (strncmp(cur, ctx->lsm_name, SECURITY_NAME_MAX + 1) != 0) {
 			pr_warning("c/r: checkpointed LSM %s, current is %s.\n",
 				ctx->lsm_name, cur);
-			return -EINVAL;
+			ret = -EINVAL;
+			goto out;
 		}
 		/* to be implemented later, per-lsm */
 		if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
@@ -440,7 +441,8 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 				strcmp(ctx->lsm_name, "default") != 0) {
 			pr_warning("c/r: RESTART_KEEP_LSM unsupported for %s\n",
 					ctx->lsm_name);
-			return -ENOSYS;
+			ret = -ENOSYS;
+			goto out;
 		}
 	}
 
-- 
1.6.1
