From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] user-cr: Fix compile without CLONE_NEWPID
Date: Tue,  6 Oct 2009 19:51:50 -0700
Message-ID: <1254883910-8472-1-git-send-email-matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

If CLONE_NEWPID is not defined the compile breaks because the parameter
list for this stub was not updated.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Note: Same patch was sent earlier without a To: field. Sorry for all the
noise.
---
 restart.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index c3f4349..e6e72ac 100644
--- a/restart.c
+++ b/restart.c
@@ -894,7 +894,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 		return 0;
 }
 #else
-static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx, int *status)
+static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 {
 	printf("logical error: ckpt_coordinator_pidns unexpected\n");
 	exit(1);
-- 
1.5.6.3
