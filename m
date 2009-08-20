From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/11] cr_tests: Extend the "INFO" tag to the samples
Date: Wed, 19 Aug 2009 21:58:13 -0700
Message-ID: <268af3eef5ce4494dbf0438fa4b4caf6cc865c40.1250744013.git.matthltc@us.ibm.com>
References: <de6ca903a5d388cc10694ff95530b27d5142f1eb.1250744013.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <de6ca903a5d388cc10694ff95530b27d5142f1eb.1250744013.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

When we dump samples during a signal use the INFO tag. This
should extend the use of LTP-style tags throughout all of the
log output.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/plain.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/futex/plain.c b/futex/plain.c
index bc7f50c..daf1bef 100644
--- a/futex/plain.c
+++ b/futex/plain.c
@@ -95,7 +95,7 @@ again:
 
 void dump (const char *prefix)
 {
-	fprintf(logfp, "%s children past 1: %d\t children past 2: %d\t futex: %d\n",
+	log("INFO","%s children past 1: %d\t children past 2: %d\t futex: %d\n",
 	       prefix,
 	       atomic_read(&dumb_barrier[0]),
 	       atomic_read(&dumb_barrier[1]),
-- 
1.5.6.3
