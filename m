From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/9] cr_tests: fs: Add tests for checkpoint/restart of
	unlinked files.
Date: Fri, 19 Feb 2010 18:18:49 -0800
Message-ID: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266632337-13792-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

These tests create unlinked files and produce conflicting file system
objects which complicate restart for naieve implementations of
checkpoint/restart. It further complicates matters by allowing test
driver scripts to set special inode flags (append, immutable, undelete).

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/dir.c       |  134 ++++++++++++++++++++++++++++++++
 fs/file.c      |  236 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/libfstest.c |   12 +++
 fs/libfstest.h |   34 ++++++++
 fs/module.mk   |   12 +++
 5 files changed, 428 insertions(+), 0 deletions(-)
 create mode 100644 fs/dir.c
 create mode 100644 fs/file.c
 create mode 100644 fs/libfstest.c
 create mode 100644 fs/libfstest.h
 create mode 100644 fs/module.mk

diff --git a/fs/dir.c b/fs/dir.c
new file mode 100644
index 0000000..daa85fc
--- /dev/null
+++ b/fs/dir.c
@@ -0,0 +1,134 @@
+/*
+ * Test checkpoint/restart of unlinked files.
+ * Currently expected to fail.
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <getopt.h>
+#include <sys/syscall.h> /* SYS_getdents */
+
+/* open() */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+/* waitpid() and W* status macros */
+#include <sys/wait.h>
+
+#define LOG_FILE	"log.unlinked.dir"
+#include "libfstest.h"
+
+const char *descr = "Create an unlinked file to checkpoint/restore.";
+
+void usage(FILE *pout, const char *prog)
+{
+	fprintf(pout, "\n%s [-L] [-N] [-h|--help] [-l LABEL] [-n NUM]\n"
+"%s\n"
+"\n"
+"\t-L\tPrint the valid LABELs in order and exit.\n"
+"\t-l\tWait for checkpoint at LABEL.\n"
+"\t-N\tPrint the maximum label number and exit.\n"
+"\t-n\tWait for checkpoint at NUM.\n"
+"\n"
+"You may only specify one LABEL or NUM and you may not specify both.\n"
+"Label numbers are integers in the range 0-%d\n"
+"Valid label numbers and their corresponding LABELs are:\n", prog,
+		descr, num_labels - 1);
+	print_labels(pout);
+}
+
+const struct option long_options[] = {
+	{ "print-labels",	0, 0, 'L'},
+	{ "print-max-label-no",	0, 0, 'N'},
+	{ "help",		0, 0, 'h'},
+	{ "label",		1, 0, 'l'},
+	{ "num",		1, 0, 'n'},
+	{0, 0, 0, 0},
+};
+
+void parse_args(int argc, char **argv)
+{
+	ckpt_op_num = num_labels - 1;
+	ckpt_label = labels[ckpt_op_num];
+	while (1) {
+		char c;
+		c = getopt_long(argc, argv, "LNhl:n:", long_options, NULL);
+		if (c == -1)
+			break;
+		switch(c) {
+			case 'L':
+				print_labels(stdout);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'N':
+				printf("%d\n", num_labels - 1);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'h':
+				usage(stdout, argv[0]);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'l':
+				ckpt_label = optarg;
+				break;
+			case 'n':
+				if ((sscanf(optarg, "%d", &ckpt_op_num) < 1) ||
+				    (ckpt_op_num < 0) ||
+				    (ckpt_op_num >= num_labels)) {
+					fprintf(stderr, "Option -n requires an argument in the range 0-%d. Got %d\n", num_labels - 1, ckpt_op_num);
+					usage(stderr, argv[0]);
+					exit(EXIT_FAILURE);
+				}
+				break;
+			default: /* unknown option */
+				break;
+		}
+	}
+}
+
+/*
+ * A LABEL is a point in the program we can goto where it's interesting to
+ * checkpoint. These enable us to have a set of labels that can be specified
+ * on the commandline.
+ */
+int main (int argc, char **argv)
+{
+	const char *pathname = "trash";
+	const char buffer[] = "hello world!\n";
+	char fdcontents[sizeof(buffer)];
+	int fd, ret, op_num = 0;
+
+	parse_args(argc, argv);
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("could not open logfile");
+		exit(1);
+	}
+	dup2(fileno(logfp), 1); /* redirect stdout and stderr to the log file */
+	dup2(fileno(logfp), 2);
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		exit(2);
+	}
+
+label(mkdir,  ret, mkdir(pathname, S_IRWXU));
+label(open,    fd, open(pathname, O_RDONLY|O_DIRECTORY));
+label(rmdir,  ret, rmdir(pathname));
+label(getdent,ret, syscall(SYS_getdents, fd, buffer, sizeof(buffer)));
+label(close,  ret, close(fd));
+
+	if (strcmp(buffer, fdcontents) != 0) {
+		log("FAIL", "contents don't match.");
+		ret = EXIT_FAILURE;
+	} else
+		ret = EXIT_SUCCESS;
+out:
+	close(fd);
+	fclose(logfp);
+	exit(ret);
+}
diff --git a/fs/file.c b/fs/file.c
new file mode 100644
index 0000000..bb17058
--- /dev/null
+++ b/fs/file.c
@@ -0,0 +1,236 @@
+/*
+ * Test checkpoint/restart of unlinked files.
+ *
+ * TODO with append extended attribute, with immutable extended attribute,
+ *      with undelete extended attribute (not honored by extX)
+ * Currently expected to fail.
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <getopt.h>
+
+/* open() */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+/* set inode flags */
+#include <sys/ioctl.h>
+#include <linux/fs.h>
+
+/* waitpid() and W* status macros */
+#include <sys/wait.h>
+
+#define LOG_FILE	"log.unlinked.file"
+#include "libfstest.h"
+
+const char *descr = "Create an unlinked file to checkpoint/restore.";
+
+void usage(FILE *pout, const char *prog)
+{
+	fprintf(pout, "\n%s [-L] [-N] [-h|--help] [-l LABEL] [-n NUM]\n"
+"%s\n"
+"\n"
+"\t-L\tPrint the valid LABELs in order and exit.\n"
+"\t-l\tWait for checkpoint at LABEL.\n"
+"\t-N\tPrint the maximum label number and exit.\n"
+"\t-n\tWait for checkpoint at NUM.\n"
+"\t-a\tSet the append-only flag (extX filesystems, needs cap_linux_immutable).\n"
+"\t-i\tSet the immutable flag (extX filesystems, needs cap_linux_immutable).\n"
+"\t-u\tSet the undeleteable (recoverable) flag (extX filesystems).\n"
+"\n"
+"You may only specify one LABEL or NUM and you may not specify both.\n"
+"Label numbers are integers in the range 0-%d\n"
+"Valid label numbers and their corresponding LABELs are:\n", prog,
+		descr, num_labels - 1);
+	print_labels(pout);
+}
+
+const struct option long_options[] = {
+	{ "print-labels",	0, 0, 'L'},
+	{ "print-max-label-no",	0, 0, 'N'},
+	{ "help",		0, 0, 'h'},
+	{ "append",		0, 0, 'a'}, /* Need CAP_LINUX_IMMUTABLE */
+	{ "immutable",		0, 0, 'i'}, /* Need CAP_LINUX_IMMUTABLE */
+	{ "undelete",		0, 0, 'u'}, /* unsupported */
+	{ "label",		1, 0, 'l'},
+	{ "num",		1, 0, 'n'},
+	{0, 0, 0, 0},
+};
+
+static int inode_flags = 0;
+static int oflags = O_RDWR;
+
+void parse_args(int argc, char **argv)
+{
+	ckpt_op_num = num_labels - 1;
+	ckpt_label = labels[ckpt_op_num];
+	while (1) {
+		char c;
+		c = getopt_long(argc, argv, "LNhl:n:aiu", long_options, NULL);
+		if (c == -1)
+			break;
+		switch(c) {
+			case 'L':
+				print_labels(stdout);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'N':
+				printf("%d\n", num_labels - 1);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'h':
+				usage(stdout, argv[0]);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'a':
+				oflags |= O_APPEND;
+				inode_flags |= FS_APPEND_FL;
+				break;
+			case 'i':
+				inode_flags |= FS_IMMUTABLE_FL;
+				break;
+			case 'u':
+				inode_flags |= FS_UNRM_FL;
+				break;
+			case 'l':
+				ckpt_label = optarg;
+				break;
+			case 'n':
+				if ((sscanf(optarg, "%d", &ckpt_op_num) < 1) ||
+				    (ckpt_op_num < 0) ||
+				    (ckpt_op_num >= num_labels)) {
+					fprintf(stderr, "Option -n requires an argument in the range 0-%d. Got %d\n", num_labels - 1, ckpt_op_num);
+					usage(stderr, argv[0]);
+					exit(EXIT_FAILURE);
+				}
+				break;
+			default: /* unknown option */
+				break;
+		}
+	}
+}
+
+static int setflags(int fd)
+{
+	int flags = inode_flags;
+
+	if (!flags)
+		return 0;
+#ifdef FS_IOC_SETFLAGS
+	return ioctl(fd, FS_IOC_SETFLAGS, &flags);
+#else
+	errno = ENOTSUP;
+	return -1;
+#endif
+}
+
+int main (int argc, char **argv)
+{
+	const char *pathname = "trash";
+	const char buffer[] = "hello world!\n";
+	const char buffer2[] = "goodbye old world, hello new world!\n";
+	char fdcontents[sizeof(buffer)];
+	char fdcontents2[sizeof(buffer2)];
+	int fd, fd2 = -1, ret, op_num = 0;
+
+	parse_args(argc, argv);
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("could not open logfile");
+		exit(1);
+	}
+	dup2(fileno(logfp), 1); /* redirect stdout and stderr to the log file */
+	dup2(fileno(logfp), 2);
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		exit(2);
+	}
+
+label(creat1,fd, creat(pathname, oflags));
+	if (fd < 0)
+		exit(EXIT_FAILURE);
+label(setflags1, ret, setflags(fd));
+	if (ret < 0)
+		goto out;
+label(write1, ret, write(fd, buffer, sizeof(buffer)));
+	if (ret < 0)
+		goto out;
+label(unlink, ret, unlink(pathname));
+	if (ret < 0)
+		goto out;
+
+	/* Simple unlinked file */
+	/* This is a good time to do_ckpt(); */
+
+	/* Check file contents */
+label(lseek, ret, lseek(fd, 0, SEEK_SET));
+	if (ret < 0)
+		goto out;
+label(read, ret, read(fd, fdcontents, sizeof(fdcontents)));
+	if (ret < 0)
+		goto out;
+	if (strcmp(buffer, fdcontents) != 0) {
+		log("FAIL", "original file contents don't match.");
+		ret = EXIT_FAILURE;
+		goto out;
+	}
+
+	/*
+	 * Create a second file where the first used to be but do not
+	 * destroy the data of the original.
+	 */
+label(creat2,fd2, creat(pathname, O_RDWR));
+	ret = fd2;
+	if (fd2 < 0)
+		goto out;
+label(setflags2, ret, setflags(fd));
+	if (ret < 0)
+		goto out;
+label(write2, ret, write(fd2, buffer2, sizeof(buffer2)));
+	if (ret < 0)
+		goto out;
+
+	/* This is a good time to do_ckpt(); */
+
+	/* Check file contents (both this time) */
+label(lseek2, ret, lseek(fd, 0, SEEK_SET));
+	if (ret < 0)
+		goto out;
+label(read2, ret, read(fd, fdcontents, sizeof(fdcontents)));
+	if (ret < 0)
+		goto out;
+
+	if (strcmp(buffer, fdcontents) != 0) {
+		log("FAIL", "original file contents don't match.");
+		ret = EXIT_FAILURE;
+		goto out;
+	}
+label(lseek3, ret, lseek(fd2, 0, SEEK_SET));
+	if (ret < 0)
+		goto out;
+label(read3, ret, read(fd2, fdcontents2, sizeof(fdcontents2)));
+	if (ret < 0)
+		goto out;
+
+	if (strcmp(buffer2, fdcontents2) != 0) {
+		log("FAIL", "second file contents don't match.");
+		ret = EXIT_FAILURE;
+		goto out;
+	}
+	ret = EXIT_SUCCESS;
+out:
+	if (ret != EXIT_SUCCESS)
+		perror("ERROR");
+	close(fd);
+	if (fd2 > -1)
+		close(fd2);
+	unlink(pathname);
+	fclose(logfp);
+	exit(ret);
+}
diff --git a/fs/libfstest.c b/fs/libfstest.c
new file mode 100644
index 0000000..200dc23
--- /dev/null
+++ b/fs/libfstest.c
@@ -0,0 +1,12 @@
+#include "libfstest.h"
+
+FILE *logfp = NULL;
+
+/* Signal ready for and await the checkpoint */
+void do_ckpt(void)
+{
+	set_checkpoint_ready();
+	while (!test_checkpoint_done())
+		usleep(10000);
+
+}
diff --git a/fs/libfstest.h b/fs/libfstest.h
new file mode 100644
index 0000000..1ef3c5c
--- /dev/null
+++ b/fs/libfstest.h
@@ -0,0 +1,34 @@
+/* epoll syscalls */
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+
+#include <sys/epoll.h>
+
+#include "libcrtest/libcrtest.h"
+#include "libcrtest/labels.h"
+
+extern FILE *logfp;
+
+/*
+ * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
+ * Adds information about the thread originating the message.
+ *
+ * Flush the log after every write to make sure we get consistent, and
+ * complete logs.
+ */
+#define log(tag, fmt, ...) \
+do { \
+	pid_t __tid = getpid(); \
+	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
+	fflush(logfp); \
+	fsync(fileno(logfp)); \
+} while(0)
+
+/* like perror() except to the log */
+#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
+
+/* Signal ready for and await the checkpoint */
+void do_ckpt(void);
+
+#define HELLO "Hello world!\n"
diff --git a/fs/module.mk b/fs/module.mk
new file mode 100644
index 0000000..d0a9f26
--- /dev/null
+++ b/fs/module.mk
@@ -0,0 +1,12 @@
+local_dir := fs
+local_progs := $(addprefix $(local_dir)/, file dir)
+
+sources += $(addprefix $(local_dir)/,libeptest.c)
+progs += $(local_progs)
+test_clean += $(local_dir)/cr_fs*
+
+# fs tests include libcrtest/libcrtest.h
+$(local_progs): CFLAGS += -D_GNU_SOURCE=1
+$(local_progs): CPPFLAGS += -I .
+$(local_progs): LDFLAGS += -Xlinker -dT -Xlinker libcrtest/labels.lds
+$(local_progs): $(local_dir)/libfstest.o libcrtest/libcrtest.a
-- 
1.6.3.3
