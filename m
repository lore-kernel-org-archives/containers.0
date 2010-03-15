From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/10] cr_tests: Factor out close_all_fds()
Date: Mon, 15 Mar 2010 16:01:01 -0700
Message-ID: <e3169d2bce6c54899bc9a7658d983ac14712583f.1268694050.git.matthltc@us.ibm.com>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc@us.ibm.com>
	<39d445e0d6bb5b1420daf672aa48ebabf8648ffe.1268694050.git.matthltc@us.ibm.com>
	<0c89f69bdb86538762c5e8a5e03fab71bb2e3963.1268694050.git.matthltc@us.ibm.com>
	<15d3e6bcb9a476add53b72998b45dd62a529871d.1268694050.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <15d3e6bcb9a476add53b72998b45dd62a529871d.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <69be886209c375c99b00b0745c1b0efdf334dcc3.1268694050.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fileio/fileio1.c      |   11 ++++-------
 fileio/filelease1.c   |    6 +-----
 fileio/filelease2.c   |    8 +-------
 fileio/filelock1.c    |    8 ++------
 fileio/filelock2.c    |    8 ++------
 fileio/fsetown1.c     |    8 ++------
 libcrtest/common.c    |   27 ++++++++++++++++++++++++++-
 libcrtest/libcrtest.h |    1 +
 8 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/fileio/fileio1.c b/fileio/fileio1.c
index 9a25176..fbce118 100644
--- a/fileio/fileio1.c
+++ b/fileio/fileio1.c
@@ -9,6 +9,8 @@
 #include <errno.h>
 #include <string.h>
 
+extern void close_all_fds(void);
+
 /*
  * Create a 'test-input' input file.
  *
@@ -244,9 +246,7 @@ enum test_mode {
 
 int main(int argc, char *argv[])
 {
-	int c;
-	int fd;
-	int i;
+	int fd, c;
 	char *srcfile;
 	char *destfile;
 	enum test_mode mode;
@@ -273,10 +273,7 @@ int main(int argc, char *argv[])
 	 * Cannot checkpoint process with open device files yet;
 	 */
 	printf("Closing stdio fds and writing messages to %s\n", log_fnam);
-	for (i=0; i<100; i++)  {
-		if (i != fileno(logfp))
-			close(i);
-	}
+	close_all_fds();
 
 	/*
 	 * Announce that we are now prepared for a checkpoint 
diff --git a/fileio/filelease1.c b/fileio/filelease1.c
index a6731b8..4d5ce5c 100644
--- a/fileio/filelease1.c
+++ b/fileio/filelease1.c
@@ -218,11 +218,7 @@ int main(int argc, char *argv[])
 
 	printf("%s: Closing stdio fds and writing messages to %s\n",
 			argv[0], LOG_FILE);
-
-	for (i=0; i<100; i++)  {
-		if (fileno(logfp) != i)
-			close(i);
-	}
+	close_all_fds();
 
 	setup_test_data();
 	event_fd1 = setup_notification();
diff --git a/fileio/filelease2.c b/fileio/filelease2.c
index bf18ad9..0e3ffe9 100644
--- a/fileio/filelease2.c
+++ b/fileio/filelease2.c
@@ -348,8 +348,6 @@ failed:
 
 int main(int argc, char *argv[])
 {
-	int i;
-
 	if (test_done()) {
 		printf("Remove %s before running test\n", TEST_DONE);
 		do_exit(1);
@@ -363,11 +361,7 @@ int main(int argc, char *argv[])
 
 	printf("%s: Closing stdio fds and writing messages to %s\n",
 			argv[0], LOG_FILE);
-
-	for (i=0; i<100; i++)  {
-		if (fileno(logfp) != i)
-			close(i);
-	}
+	close_all_fds();
 
 	setup_test_data();
 	event_fd1 = setup_notification();
diff --git a/fileio/filelock1.c b/fileio/filelock1.c
index 77060e9..248eb40 100644
--- a/fileio/filelock1.c
+++ b/fileio/filelock1.c
@@ -293,7 +293,7 @@ void usage(char *argv[])
 
 int main(int argc, char *argv[])
 {
-	int i, c;
+	int c;
 
 	logfp = fopen(LOG_FILE, "w");
 	if (!logfp) {
@@ -316,11 +316,7 @@ int main(int argc, char *argv[])
 
 	printf("%s: Closing stdio fds and writing messages to %s\n",
 			argv[0], LOG_FILE);
-
-	for (i=0; i<100; i++)  {
-		if (fileno(logfp) != i)
-			close(i);
-	}
+	close_all_fds();
 
 	setup_test_file();
 	event_fd1 = setup_notification();
diff --git a/fileio/filelock2.c b/fileio/filelock2.c
index 992aaee..e2e69ef 100644
--- a/fileio/filelock2.c
+++ b/fileio/filelock2.c
@@ -319,7 +319,7 @@ int create_child(int idx, void (*child_func)(int))
 
 int main(int argc, char *argv[])
 {
-	int i, c;
+	int c;
 
 	logfp = fopen(LOG_FILE, "w");
 	if (!logfp) {
@@ -345,11 +345,7 @@ int main(int argc, char *argv[])
 
 	printf("%s: Closing stdio fds and writing messages to %s\n",
 			argv[0], LOG_FILE);
-
-	for (i=0; i<100; i++)  {
-		if (fileno(logfp) != i)
-			close(i);
-	}
+	close_all_fds();
 
 	setup_test_file();
 	event_fd1 = setup_notification();
diff --git a/fileio/fsetown1.c b/fileio/fsetown1.c
index 57f9bb6..05ddcee 100644
--- a/fileio/fsetown1.c
+++ b/fileio/fsetown1.c
@@ -190,7 +190,7 @@ void usr1_handler(int sig)
 
 int main(int argc, char *argv[])
 {
-	int i, rc;
+	int rc;
 	int pid;
 
 	if (test_done()) {
@@ -206,11 +206,7 @@ int main(int argc, char *argv[])
 
 	printf("%s: Closing stdio fds and writing messages to %s\n",
 			argv[0], LOG_FILE);
-
-	for (i=0; i<100; i++)  {
-		if (fileno(logfp) != i)
-			close(i);
-	}
+	close_all_fds();
 
 	setup_test_data();
 	event_fd1 = setup_notification();
diff --git a/libcrtest/common.c b/libcrtest/common.c
index c496889..7672189 100644
--- a/libcrtest/common.c
+++ b/libcrtest/common.c
@@ -5,6 +5,7 @@
 #include <errno.h>
 #include <string.h>
 #include <malloc.h>
+#include <dirent.h>
 #include "libcrtest.h"
 #include <sys/eventfd.h>
 #include <sys/stat.h>
@@ -138,7 +139,7 @@ int do_wait(int num_children)
 	return 0;
 }
 
-static void do_sync(FILE *fp)
+void do_sync(FILE *fp)
 {
 	int rc;
 
@@ -148,6 +149,30 @@ static void do_sync(FILE *fp)
 		fprintf(logfp, "ERROR: fsync %s\n", strerror(errno));
 }
 
+void close_all_fds(void)
+{
+	/* Close everything but stdin, stdout, and stderr */
+	DIR *proc_self_fd;
+	struct dirent *dent;
+
+	proc_self_fd = opendir("/proc/self/fd");
+	if (!proc_self_fd) {
+		perror("opendir");
+		do_exit(1);
+	}
+
+	while ((dent = readdir(proc_self_fd)) != NULL) {
+		int fd;
+
+		if (sscanf(dent->d_name, "%12d", &fd) != 1)
+			continue;
+		if ((logfp && fileno(logfp) == fd) || \
+		    (dirfd(proc_self_fd) == fd))
+			continue;
+		close(fd);
+	}
+	closedir(proc_self_fd);
+}
 
 /*
  * Return 0 if data in srcfp matches data in destfp);
diff --git a/libcrtest/libcrtest.h b/libcrtest/libcrtest.h
index 9723c74..8e68261 100644
--- a/libcrtest/libcrtest.h
+++ b/libcrtest/libcrtest.h
@@ -15,6 +15,7 @@ struct record {
 
 typedef unsigned long long u64;
 
+extern void close_all_fds(void);
 extern void do_exit(int status);
 extern int test_done(void);
 extern int test_checkpoint_done();
-- 
1.6.3.3
