From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 4/4] restart thread-safety: avoid malloc in ckpt_msg()
Date: Fri, 30 Jul 2010 13:08:33 -0400
Message-ID: <1280509713-6745-4-git-send-email-orenl@cs.columbia.edu>
References: <1280169472.7875.4290.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280169472.7875.4290.camel@localhost>
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
Cc: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
List-Id: containers.vger.kernel.org

We use clone and eclone directly and not through glibc, therefore
must explicitly care about thread-safety of malloc.

This patch removes the use of malloc in ckpt_msg() and instead
allocate a buffer on the stack. Also convert calls to strerr() to
to calls to strerr_r() which are thread-safe.

This patch is based on Nathan Lynch's patch:
"""
  I have tried patching user-cr to create the feeder thread with
  pthread_create, but it's not trivial -- I think the program's
  correct functioning depends heavily on the threads having separate
  file descriptor tables.

  The best I can come up with right now is to allocate ckpt_msg's
  buffer on the stack - I think this avoids most if not all of the
  concurrent malloc activity associated with the crashes/hangs I've
  been seing.
"""

Todo ??

Now the only remaining non-thread-safe behavior that I'm aware of is
the use of @errno: it is possible that an error in one thread will be
incorrectly reported by another thread. I think we can tolerate this
because it does not impact correctness when restart should succeed; at
worst it may confuse us about userspace errors in the restart.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 common.h  |   25 +++++++++++--------------
 restart.c |    7 +++++--
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/common.h b/common.h
index 99b224d..faf180e 100644
--- a/common.h
+++ b/common.h
@@ -1,31 +1,28 @@
 #include <stdio.h>
 #include <signal.h>
 
-#define BUFSIZE  (4 * 4096)
+#define BUFSIZE  (4096)
 
 static inline void ckpt_msg(int fd, char *format, ...)
 {
+	char buf[BUFSIZE];
 	va_list ap;
-	char *bufp;
+
 	if (fd < 0)
 		return;
 
 	va_start(ap, format);
-
-	bufp = malloc(BUFSIZE);
-	if(bufp) {
-		vsnprintf(bufp, BUFSIZE, format, ap);
-		write(fd, bufp, strlen(bufp));
-	}
-	free(bufp);
-
+	vsnprintf(buf, BUFSIZE, format, ap);
 	va_end(ap);
+
+	write(fd, buf, strlen(buf));
 }
 
-#define ckpt_perror(s) 							\
-	do {								\
-		ckpt_msg(global_uerrfd, s);				\
-		ckpt_msg(global_uerrfd, ": %s\n", strerror(errno));	\
+#define ckpt_perror(s)						\
+	do {							\
+		char __buf[256];				\
+		strerror_r(errno, __buf, 256);			\
+		ckpt_msg(global_uerrfd, "%s: %s\n", s, __buf);	\
 	} while (0)
 
 #ifdef CHECKPOINT_DEBUG
diff --git a/restart.c b/restart.c
index b274e37..9cb7430 100644
--- a/restart.c
+++ b/restart.c
@@ -739,6 +739,7 @@ static int ckpt_pretend_reaper(struct ckpt_ctx *ctx)
 static int ckpt_probe_child(pid_t pid, char *str)
 {
 	int status, ret;
+	char buf[256];
 
 	/* use waitpid() to probe that a child is still alive */
 	ret = waitpid(pid, &status, WNOHANG);
@@ -746,11 +747,13 @@ static int ckpt_probe_child(pid_t pid, char *str)
 		report_exit_status(status, str, 0);
 		exit(1);
 	} else if (ret < 0 && errno == ECHILD) {
+		strerror_r(errno, buf, 256);
 		ckpt_err("WEIRD: %s exited without trace (%s)\n",
-			 str, strerror(errno));
+			 str, buf);
 		exit(1);
 	} else if (ret != 0) {
-		ckpt_err("waitpid for %s (%s)", str, strerror(errno));
+		strerror_r(errno, buf, 256);
+		ckpt_err("waitpid for %s (%s)", str, buf);
 		exit(1);
 	}
 	return 0;
-- 
1.7.0.4
