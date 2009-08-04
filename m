From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Use the CHECKPOINT_SUBTREE definition from cr.h
Date: Tue,  4 Aug 2009 16:43:09 -0700
Message-ID: <1249429388-12900-2-git-send-email-matthltc@us.ibm.com>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 simple/ckpt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/simple/ckpt.c b/simple/ckpt.c
index 50085f4..ec51510 100644
--- a/simple/ckpt.c
+++ b/simple/ckpt.c
@@ -40,7 +40,7 @@ int main(int argc, char *argv[])
 	fprintf(file, "hello, world!\n");
 	fflush(file);
 
-	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 1);
+	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, CHECKPOINT_SUBTREE);
 	if (ret < 0) {
 		perror("checkpoint");
 		exit(2);
-- 
1.5.6.3
