From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 2/3] c/r: kread/kwrite() to abort if CKPT_CTX_ERROR is set
Date: Sun,  6 Dec 2009 15:09:11 -0500
Message-ID: <1260130151-2500-1-git-send-email-orenl@cs.columbia.edu>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is useful particularly in restart to force a task that is
restoring to respond quickly to an error condition due to another
task, instead of only detecting it when it completes (or fails).
For example, when a restarting tasks activates the next task, and
then fails.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/sys.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index dbee469..afcfa1e 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -65,6 +65,9 @@ int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, int count)
 	mm_segment_t fs;
 	int ret;
 
+	if (ckpt_test_ctx_error(ctx))
+		return ckpt_get_error(ctx);
+
 	fs = get_fs();
 	set_fs(KERNEL_DS);
 	ret = _ckpt_kwrite(ctx->file, addr, count);
@@ -102,6 +105,9 @@ int ckpt_kread(struct ckpt_ctx *ctx, void *addr, int count)
 	mm_segment_t fs;
 	int ret;
 
+	if (ckpt_test_ctx_error(ctx))
+		return ckpt_get_error(ctx);
+
 	fs = get_fs();
 	set_fs(KERNEL_DS);
 	ret = _ckpt_kread(ctx->file , addr, count);
-- 
1.6.3.3
