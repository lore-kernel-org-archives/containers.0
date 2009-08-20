From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 11/11] cr_tests: Exit with failure when appropriate.
Date: Wed, 19 Aug 2009 21:58:14 -0700
Message-ID: <0f8a0d94dcf8e26ce5b9421a6a3d34a0f1cdede3.1250744013.git.matthltc@us.ibm.com>
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

Without this change it's virtually impossible indicate failure.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/plain.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/futex/plain.c b/futex/plain.c
index daf1bef..3b51176 100644
--- a/futex/plain.c
+++ b/futex/plain.c
@@ -110,7 +110,7 @@ void sig_dump(int signum)
 int main(int argc, char **argv)
 {
 	pid_t kids[N];
-	int i, num_killed = 0;
+	int i, num_killed = 0, excode = EXIT_FAILURE;
 
 	/* FIXME eventually stdio streams should be harmless */
 	close(0);
@@ -180,11 +180,12 @@ int main(int argc, char **argv)
 		if (num_killed)
 			log("INFO", "killed %d remaining child tasks.\n",
 				num_killed);
-	}
+	} else
+		excode = EXIT_SUCCESS;
 	dump("After 2:");
 
 	do_wait(N);
 	dump("After 3:");
 	fclose(logfp);
-	exit(0);
+	exit(excode);
 }
-- 
1.5.6.3
