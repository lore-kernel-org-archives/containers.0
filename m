From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add a simple UTS test program
Date: Mon, 16 Mar 2009 11:13:04 -0700
Message-ID: <1237227184-2757-3-git-send-email-danms@us.ibm.com>
References: <1237227184-2757-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237227184-2757-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This program creates a top-level UTS namespace and then forks a child.  The
parent sets the hostname to a different value every second and the child
prints the value.  If the child's value changes with the parent, even after
restart, then the pair are running in the same UTS namespace.  The test
self-checkpoints every iteration.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 utstest.c |  114 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 114 insertions(+), 0 deletions(-)
 create mode 100644 utstest.c

diff --git a/utstest.c b/utstest.c
new file mode 100644
index 0000000..1afca49
--- /dev/null
+++ b/utstest.c
@@ -0,0 +1,114 @@
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <sched.h>
+#include <string.h>
+#include <stdlib.h>
+#include <asm/unistd.h>
+
+#define OUTFILE "/tmp/cr-test.out"
+#define CKPTDIR "/tmp"
+
+int ckpt = 0;
+
+int do_checkpoint(void)
+{
+	char fn[256];
+	int fd;
+	int ret;
+
+	snprintf(fn, sizeof(fn)-1, CKPTDIR "/ckpt-%i", ckpt++);
+
+	fd = open(fn, O_WRONLY | O_CREAT | O_TRUNC, 0666);
+	if (fd < 0) {
+		perror(fn);
+		return -1;
+	}
+
+	ret = syscall(__NR_checkpoint, getpid(), fd, 0);
+	if (ret < 0)
+		printf("Checkpoint to %s returned %i (%m)\n", fn, ret);
+
+	close(fd);
+
+	return ret;
+}
+
+void child(int fd, int subunshare)
+{
+	char hostname[256] = "foo";
+	int ret;
+
+	if (subunshare) {
+		ret = unshare(CLONE_NEWUTS);
+		if (ret) {
+			printf("unshare: %m");
+			exit(1);
+		}
+	}
+
+	while (1) {
+		ret = gethostname(hostname, sizeof(hostname));
+		if (ret) {
+			perror("gethostname");
+			_exit(1);
+		}
+
+		printf("Hostname in child is:  %s\n", hostname);
+		sleep(1);
+	}
+}
+
+int main(int argc, char **argv)
+{
+	int ret;
+	int fd;
+	int i = 0;
+	int subunshare = 0;
+
+#ifndef NOUTS
+	ret = unshare(CLONE_NEWUTS);
+	if (ret) {
+		perror("unshare");
+		return 1;
+	}
+#endif
+
+	/* Pass '-u' to test nested namespace */
+	if ((argc == 2) && (strcmp(argv[1], "-u") == 0))
+		subunshare = 1;
+
+	fd = open(OUTFILE, O_RDWR | O_CREAT | O_TRUNC, 0666);
+	if (fd < 0) {
+		perror(OUTFILE);
+		return 1;
+	}
+
+	dup2(fd, 1);
+	dup2(fd, 2);
+	close(0);
+
+	setlinebuf(stdout);
+	setlinebuf(stderr);
+
+	if (fork() == 0)
+		child(fd, subunshare);
+
+	while (1) {
+#ifndef NOUTS
+		char hostname[256];
+
+		snprintf(hostname, sizeof(hostname)-1, "test%i", i++);
+		ret = sethostname(hostname, strlen(hostname));
+		if (ret) {
+			perror("sethostname");
+			return 1;
+		}
+
+		printf("Hostname in parent is: %s\n", hostname);
+#endif
+		do_checkpoint();
+		sleep(1);
+	}
+}
-- 
1.5.6.3
