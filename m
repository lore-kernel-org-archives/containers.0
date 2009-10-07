From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] don't call pre_restore_task twice
Date: Wed, 7 Oct 2009 18:47:50 -0500
Message-ID: <20091007234750.GA6881@us.ibm.com>
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

Pre_restore_task is being called both before and inside
restore_task, causing a memory leak at
current->checkpoint_data.

Only call it once, outside restore_task.

This fixes a memory leak spotted by Dan Smith, and the
actual bug was deduced by Matt Helsley.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Reported-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/process.c |    4 ----
 checkpoint/restart.c |    1 +
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 424f688..c51e036 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -864,10 +864,6 @@ int restore_task(struct ckpt_ctx *ctx)
 {
 	int ret;
 
-	ret = pre_restore_task(ctx);
-	if (ret < 0)
-		goto out;
-
 	ret = restore_task_struct(ctx);
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 3a58a76..fc94374 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -967,6 +967,7 @@ static int do_restore_task(void)
 	 */
 	if (zombie) {
 		restore_debug_exit(ctx);
+		post_restore_task(ctx);
 		ckpt_ctx_put(ctx);
 		do_exit(current->exit_code);
 	}
-- 
1.5.4.3
