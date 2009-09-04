From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/3] test/pgrp.c: add test case for process-groups
Date: Fri,  4 Sep 2009 10:20:53 -0400
Message-ID: <1252074054-22241-9-git-send-email-orenl@librato.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252074054-22241-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

---
 test/Makefile |    2 +-
 test/pgrp.c   |   79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+), 1 deletions(-)
 create mode 100644 test/pgrp.c

diff --git a/test/Makefile b/test/Makefile
index 0ad576f..cad40e0 100644
--- a/test/Makefile
+++ b/test/Makefile
@@ -7,7 +7,7 @@ CFLAGS += -g $(WARNS)
 
 TESTS=	onetask multitask bigmem pipes pipes2 fifo shmem \
 	ipcshm ipcmsq ipcsem ipcshm_multi zombie sigpending \
-	itimer pty
+	itimer pty pgrp
 
 LDLIBS = -lm
 
diff --git a/test/pgrp.c b/test/pgrp.c
new file mode 100644
index 0000000..e685d12
--- /dev/null
+++ b/test/pgrp.c
@@ -0,0 +1,79 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+
+#define OUTFILE  "/tmp/cr-test.out"
+
+pid_t do_fork(void)
+{
+	pid_t pid = fork();
+
+	if (pid < 0) {
+		perror("fork");
+		exit(1);
+	}
+
+	return pid;
+}
+
+int main(int argc, char *argv[])
+{
+	FILE *file;
+	pid_t p1, p2;
+	int i;
+
+	close(0);
+	close(1);
+	close(2);
+
+	setsid();
+
+	unlink(OUTFILE);
+	file = fopen(OUTFILE, "w+");
+	if (!file) {
+		perror("open");
+		exit(1);
+	}
+	if (dup2(0,2) < 0) {
+		perror("dup2");
+		exit(1);
+	}
+
+	fprintf(file, "hello, world\n");
+	fflush(file);
+
+	p1 = do_fork();
+	if (p1 == 0) {
+		fprintf(file, "[%d] child born 0\n", getpid());
+		fflush(file);
+		sleep(1);
+		fprintf(file, "[%d] child exit 0\n", getpid());
+		exit(0);
+	}
+
+	p2 = do_fork();
+	if (p2 == 0) {
+		fprintf(file, "[%d] child born 1\n", getpid());
+		sleep(1);
+	} else {
+		if (setpgid(p2, p1) < 0) {
+			perror("setpgid");
+			exit(1);
+		}
+	}
+
+	for (i = 0; i < 15; i++) {
+		fprintf(file, "[%d] count %d\n", getpid(), i);
+		fflush(file);
+		sleep(1);
+		fflush(file);
+	}
+
+	fprintf(file, "[pid %d] world, hello\n", getpid());
+	fflush(file);
+
+	return 0;
+}
-- 
1.6.0.4
