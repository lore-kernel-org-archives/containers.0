From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 2/4]: Test3: continous read/write to pipe
Date: Mon, 23 Jun 2008 20:33:25 -0700
Message-ID: <20080624033325.GB27709@us.ibm.com>
References: <20080624033133.GA27649@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080624033133.GA27649-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


From ade1b719f7d9968e0f934daf736ca1746cb6747d Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Sun, 22 Jun 2008 22:26:18 -0700
Subject: [PATCH] Testcase 3: continous read/write to pipe

---
 tests/pipe.c |   82 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 81 insertions(+), 1 deletions(-)

diff --git a/tests/pipe.c b/tests/pipe.c
index 76be6cc..c81ac2a 100644
--- a/tests/pipe.c
+++ b/tests/pipe.c
@@ -6,6 +6,8 @@
 #include <string.h>
 #include <errno.h>
 
+#define min(a, b)	((a) < (b) ? (a) : (b))
+static char *temp_file;
 char *test_descriptions[] = {
 	NULL,
 	"Test with an empty pipe",
@@ -18,7 +20,7 @@ char *test_descriptions[] = {
 	"Test with all-fds in use for pipes",
 };
 
-static int last_num = 2;
+static int last_num = 3;
 usage(char *argv[])
 {
 	int i;
@@ -82,12 +84,89 @@ int test2()
 	}
 }
 
+int read_write_pipe()
+{
+	int i = 0;
+	int rc;
+	int fds[2];
+	int fd1, fd2;
+	int c;
+	char *wbufp;
+	char wbuf[256];
+	char rbuf[256];
+	char *rbufp;
+
+	rbufp = &rbuf[0];
+	wbufp = &wbuf[0];
+
+	strcpy(wbufp, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
+	memset(rbufp, '\0', sizeof(rbuf));
+
+	if (pipe(fds) < 0) {
+		perror("pipe()");
+		exit(1);
+	}
+	printf("fds[0] %d, fds[1] %d\n", fds[0], fds[1]);
+
+	if (fcntl(fds[0], F_SETFL, O_NONBLOCK) < 0) {
+		perror("fcntl()");
+		exit(1);
+	}
+
+	printf("Running as %d\n", getpid());
+	for (i = 0; i < 50; i++) {
+		sleep(1);
+		if (i%2 == 0) {
+			c = errno = 0;
+			rc = read(fds[0], rbufp, 3);
+
+			if (rc < 0)
+				perror("read() failed");
+			else {
+				printf("i is %d (pid %d), rbufp %p read %s\n",
+						i, getpid(), rbufp, rbufp);
+				rbufp += rc;
+			}
+
+			if (*wbufp == '\0')
+				continue;
+
+			errno = 0;
+			rc = write(fds[1], wbufp, min(3, strlen(wbufp)));
+			if (rc < 0) {
+				perror("write() to pipe");
+			} else {
+				if (rc != 3) {
+					printf("Wrote %d of 3 bytes, "
+						"error %d\n", rc, errno);
+				}
+				wbufp += rc;
+			}
+		}
+	}
+
+	if (strncmp(wbuf, rbuf, strlen(wbufp))) {
+		printf("Wrote: %s\n", wbuf);
+		printf("Read : %s\n", rbuf);
+		printf("Test FAILED\n");
+	} else {
+		printf("Test passed\n");
+	}
+}
+
+static void test3()
+{
+	read_write_pipe();
+}
+
 int
 main(int argc, char *argv[])
 {
 	int c;
 	int tc_num;
 
+	temp_file = argv[0];
+
 	while((c = getopt(argc, argv, "t:")) != EOF) {
 		switch(c) {
 		case 't':
@@ -102,6 +181,7 @@ main(int argc, char *argv[])
 	switch(tc_num) {
 	case 1: test1(); break;
 	case 2: test2(); break;
+	case 3: test3(); break;
 	default:
 		printf("Unsupported test case %d\n", tc_num);
 		usage(argv);
-- 
1.5.2.5
