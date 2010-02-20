From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 8/9] cr_tests: fs: Add unlinked fifo test
Date: Fri, 19 Feb 2010 18:18:56 -0800
Message-ID: <dbe8e8154db60f36f7f22c5ec1c3218d765c5b62.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
	<72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
	<a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc@us.ibm.com>
	<7f04acbefe832b0bfaa832222da150c33af76ca8.1266632319.git.matthltc@us.ibm.com>
	<0efaca297a696880440a982210325dc7c473b13d.1266632319.git.matthltc@us.ibm.com>
	<dfc5e84b2c8940b07be485b8df1e530e4128e253.1266632319.git.matthltc@us.ibm.com>
	<970e1b8ed6c9322e3c069bae404b6d8cd17a7a94.1266632319.git.matthltc@us.ibm.com>
	<275a3dfd54a441b21e338bd4856c61be214ae12a.1266632319.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <275a3dfd54a441b21e338bd4856c61be214ae12a.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
---
 fs/fifo.c    |  190 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/module.mk |    2 +-
 2 files changed, 191 insertions(+), 1 deletions(-)
 create mode 100644 fs/fifo.c

diff --git a/fs/fifo.c b/fs/fifo.c
new file mode 100644
index 0000000..d0e08eb
--- /dev/null
+++ b/fs/fifo.c
@@ -0,0 +1,190 @@
+/*
+ * Test checkpoint/restart of unlinked fifos. fifos are an interesting
+ * case for unlinked file support because they offer limited buffer space
+ * but are not seekable.
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
+static int oflags = O_RDWR; /* rely on Linux-specific behavior (man 7 fifo) */
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
+	const char buffer1[] = "hello world!\n";
+	const char buffer2[] = "goodbye old world, hello new world!\n";
+	char fdcontents1[sizeof(buffer1)];
+	char fdcontents2[sizeof(buffer2)];
+	int fifo1 = -1, fifo2 = -1, ret, op_num = 0;
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
+/* Open a first fifo, write to it, and unlink it */
+label(mkfifo1,   ret, mkfifo(pathname, S_IRUSR|S_IWUSR));
+label(open1,   fifo1, open(pathname, oflags));
+label(setflags1, ret, setflags(fifo1));
+label(write1,    ret, write(fifo1, buffer1, sizeof(buffer1)));
+label(unlink,    ret, unlink(pathname));
+
+/* Open a second fifo, write to it */
+label(mkfifo2,   ret, mkfifo(pathname, S_IRUSR|S_IWUSR));
+label(open2,   fifo2, open(pathname, oflags));
+label(setflags2, ret, setflags(fifo2));
+label(write2,    ret, write(fifo2, buffer2, sizeof(buffer2)));
+
+/* Check fifo contents */
+label(read1,     ret, read(fifo1, fdcontents1, sizeof(fdcontents1)));
+	if (strcmp(buffer1, fdcontents1) != 0) {
+		log("FAIL", "original fifo contents don't match.");
+		ret = EXIT_FAILURE;
+		goto out;
+	}
+label(read2,     ret, read(fifo2, fdcontents2, sizeof(fdcontents2)));
+	if (strcmp(buffer2, fdcontents2) != 0) {
+		log("FAIL", "new fifo contents don't match.");
+		ret = EXIT_FAILURE;
+		goto out;
+	}
+	ret = EXIT_SUCCESS;
+out:
+	if (ret != EXIT_SUCCESS)
+		perror("ERROR");
+	if (fifo1 > -1)
+		close(fifo1);
+	if (fifo2 > -1)
+		close(fifo2);
+	unlink(pathname);
+	fclose(logfp);
+	exit(ret);
+}
diff --git a/fs/module.mk b/fs/module.mk
index 1af5815..8aeaad2 100644
--- a/fs/module.mk
+++ b/fs/module.mk
@@ -1,5 +1,5 @@
 local_dir := fs
-local_progs := $(addprefix $(local_dir)/, file dir do_ckpt)
+local_progs := $(addprefix $(local_dir)/, file dir do_ckpt fifo)
 
 sources += $(addprefix $(local_dir)/,libeptest.c)
 progs += $(local_progs)
-- 
1.6.3.3
