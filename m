From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/11] cr_tests: Fix potential double close of pipe
	descriptors.
Date: Wed, 19 Aug 2009 21:58:05 -0700
Message-ID: <f9c5e9db602b732f8c3ddaf52c0b34c14db6a336.1250744013.git.matthltc@us.ibm.com>
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

Don't double-close the pipe. Also there's only one pipe so get rid of
the plural form of the label :).

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/robust.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/futex/robust.c b/futex/robust.c
index 304c35f..05fd4e9 100644
--- a/futex/robust.c
+++ b/futex/robust.c
@@ -347,7 +347,7 @@ int main(int argc, char **argv)
 			  MAP_ANONYMOUS|MAP_SHARED, -1, 0);
 	if (test_futex == MAP_FAILED) {
 		log_error("mmap shared futex");
-		goto exit_pipes;
+		goto exit_pipe;
 	}
 
 	/* Should already be zero but let's be clear about that. */
@@ -356,7 +356,7 @@ int main(int argc, char **argv)
 
 	if (set_robust_list(&rlist, sizeof(rlist))) {
 		log_error("set_robust_list");
-		goto exit_pipes;
+		goto exit_pipe;
 	}
 	check_rlist(0);
 
@@ -384,10 +384,9 @@ int main(int argc, char **argv)
 		log("INFO", "killing %d child tasks.\n", i);
 		for (; --i > -1;)
 			kill(kids[i], SIGTERM);
-		goto exit_pipes;
+		goto exit_pipe;
 	}
 
-	close(children_ready[1]);
 	do {
 		char status;
 
@@ -398,7 +397,6 @@ int main(int argc, char **argv)
 		else
 			fail++;
 	} while (pass + fail < N);
-	close(children_ready[0]);
 
 	/* Now that all the children are waiting on the futex, wake one. */
 	log("INFO", "Parent waking one child\n");
@@ -408,7 +406,7 @@ int main(int argc, char **argv)
 	log("INFO", "Parent exiting.\n");
 	if (pass && !fail)
 		excode = EXIT_SUCCESS;
-exit_pipes:
+exit_pipe:
 	close(children_ready[0]);
 	close(children_ready[1]);
 exit_logs:
-- 
1.5.6.3
