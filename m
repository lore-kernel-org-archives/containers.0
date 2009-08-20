From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/11] cr_tests: Remove redundant move_to_cgroup() calls.
Date: Wed, 19 Aug 2009 21:58:07 -0700
Message-ID: <6946c8f883842592a56ce9b7b4a5ab7c6bba9745.1250744013.git.matthltc@us.ibm.com>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/pi.c     |    4 ----
 futex/plain.c  |    4 ----
 futex/robust.c |    4 ----
 3 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/futex/pi.c b/futex/pi.c
index e06ddfb..595b9e7 100644
--- a/futex/pi.c
+++ b/futex/pi.c
@@ -558,10 +558,6 @@ int main(int argc, char **argv)
 	pid_t finished;
 	int i = 0, status = 0, excode;
 
-	if (!move_to_cgroup("freezer", "1", getpid())) {
-		printf("Failed to move myself to cgroup /1\n");
-		exit(1);
-	}
 	/* FIXME eventually stdio streams should be harmless */
 	close(0);
 	logfp = fopen(LOG_FILE, "w");
diff --git a/futex/plain.c b/futex/plain.c
index 5fef84d..bc7f50c 100644
--- a/futex/plain.c
+++ b/futex/plain.c
@@ -112,10 +112,6 @@ int main(int argc, char **argv)
 	pid_t kids[N];
 	int i, num_killed = 0;
 
-	if (!move_to_cgroup("freezer", "1", getpid())) {
-		printf("Failed to move myself to cgroup /1\n");
-		exit(1);
-	}
 	/* FIXME eventually stdio streams should be harmless */
 	close(0);
 	logfp = fopen(LOG_FILE, "w");
diff --git a/futex/robust.c b/futex/robust.c
index f63b7d1..e703147 100644
--- a/futex/robust.c
+++ b/futex/robust.c
@@ -309,10 +309,6 @@ int main(int argc, char **argv)
 	pid_t kids[N];
 	int i, excode = EXIT_FAILURE;
 
-	if (!move_to_cgroup("freezer", "1", getpid())) {
-		printf("Failed to move myself to cgroup /1\n");
-		exit(1);
-	}
 	/* FIXME eventually stdio streams should be harmless */
 	close(0);
 	logfp = fopen(LOG_FILE, "w");
-- 
1.5.6.3
