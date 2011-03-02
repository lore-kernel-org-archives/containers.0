From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] [RFC] Add transient filesystem support to user-cr
Date: Wed,  2 Mar 2011 13:35:25 -0800
Message-ID: <1299101725-17603-4-git-send-email-danms@us.ibm.com>
References: <1299101725-17603-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1299101725-17603-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This patch is based on one by Nathan Lynch.  It shoves one or more
cpio archives into the front of the checkpoint stream, and strips
it back off at restart.  It does this to support saving and restoring
transient filesystem contents, such as /dev/shm, /dev/mqueue, and the
like.  The intent is not to perform general-purpose filesystem capture
or checkpoint, although it could provide some convenience in that
regard for limited uses.

I introduced "payload.{c,h}" files which encapsulate most of the work.
While only cpio archives are supported at the moment, I imagine there
are potentially other types that may be desirable (like a signature or
config file).

This depends on setns(), which isn't in the tree just yet, but I'm
sending this on for RFC purposes.  I'm sure it still has some issues.

Also note that this uses the regular cpio archive format, which isn't
portable.  I'll change that, but I wanted to get this out for comments
quickly.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile     |    7 +-
 checkpoint.c |   34 ++++
 checkpoint.h |    2 +
 payload.c    |  541 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 payload.h    |   49 ++++++
 restart.c    |   33 ++++
 6 files changed, 663 insertions(+), 3 deletions(-)
 create mode 100644 payload.c
 create mode 100644 payload.h

diff --git a/Makefile b/Makefile
index 42ea74b..d403b0e 100644
--- a/Makefile
+++ b/Makefile
@@ -13,7 +13,8 @@ CKPT_HEADERS = include/linux/checkpoint.h \
 		include/linux/checkpoint_hdr.h \
 		include/asm/checkpoint_hdr.h
 
-CR_OBJS = checkpoint.o checkpoint-main.o restart.o restart-main.o common.o
+CR_OBJS = checkpoint.o checkpoint-main.o restart.o restart-main.o common.o \
+	payload.o
 
 # detect architecture (for eclone)
 SUBARCH ?= $(patsubst i%86,x86_32,$(shell uname -m))
@@ -61,9 +62,9 @@ restart: CFLAGS += -D__REENTRANT -pthread
 
 $(CR_OBJS): common.h checkpoint.h
 
-restart: restart.o restart-main.o common.o
+restart: restart.o restart-main.o common.o payload.o
 
-checkpoint: checkpoint.o checkpoint-main.o common.o
+checkpoint: checkpoint.o checkpoint-main.o common.o payload.o
 
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
diff --git a/checkpoint.c b/checkpoint.c
index 3054cd4..edc1d75 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -23,6 +23,30 @@
 
 #include "checkpoint.h"
 #include "common.h"
+#include "payload.h"
+
+static int ckpt_count_fs(char **list)
+{
+	int i;
+
+	for (i = 0; list[i]; i++);
+
+	return i;
+}
+
+static int ckpt_save_fs(int pid, char **list, int fd)
+{
+	int i;
+	int ret;
+
+	for (i = 0; list[i]; i++) {
+		ret = ckpt_save_fs_state(pid, list[i], fd);
+		if (ret != 0)
+			return ret;
+	}
+
+	return 0;
+}
 
 inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 {
@@ -46,6 +70,16 @@ int cr_checkpoint(int pid, struct cr_checkpoint_args *args)
 	if (!args->container)
 		args->flags |= CHECKPOINT_SUBTREE;
 
+	/* Right now, the only payloads we have are filesystems */
+
+	ret = ckpt_declare_payloads(ckpt_count_fs(args->save_fs), args->outfd);
+	if (ret)
+		return ret;
+
+	ret = ckpt_save_fs(pid, args->save_fs, args->outfd);
+	if  (ret)
+		return ret;
+
 	ret = checkpoint(pid, args->outfd, args->flags, args->logfd);
 
 	if (ret < 0) {
diff --git a/checkpoint.h b/checkpoint.h
index 4d0d035..e39adfb 100644
--- a/checkpoint.h
+++ b/checkpoint.h
@@ -8,6 +8,7 @@ struct cr_checkpoint_args {
 	int container;
 	int verbose;
 	int flags;
+	char **save_fs;
 };
 
 struct cr_restart_args {
@@ -32,6 +33,7 @@ struct cr_restart_args {
 	int verbose;
 	long fail;
 	int keep_lsm;
+	char **restore_fs;
 };
 
 /*
diff --git a/payload.c b/payload.c
new file mode 100644
index 0000000..72e4f33
--- /dev/null
+++ b/payload.c
@@ -0,0 +1,541 @@
+/*
+ *  payload.c: Multiplex payloads in and out of the checkpoint stream
+ *
+ *  Copyright (C) 2011 IBM Corp.
+ *
+ *  This file is subject to the terms and conditions of the GNU
+ *  General Public License.  See the file COPYING in the main
+ *  directory of the Linux distribution for more details.
+ */
+
+#define _GNU_SOURCE
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <mntent.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <sys/mount.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+
+#include "common.h"
+#include "payload.h"
+#include "linux/checkpoint.h"
+#include "linux/checkpoint_hdr.h"
+
+static inline int setns(int nstype, int fd)
+{
+	return syscall(__NR_setns, nstype, fd);
+}
+
+static int attach_ns(pid_t pid, const char *ns)
+{
+	char *path;
+	int fd;
+	int ret;
+
+	if (asprintf(&path, "/proc/%i/ns/%s", pid, ns) == -1)
+		return -ENOMEM;
+
+	fd = open(path, O_RDONLY);
+	free(path);
+	if (fd == -1)
+		return -errno;
+
+	ret = setns(0, fd);
+	close(fd);
+
+	return ret;
+}
+
+static int ckpt_write_string(int fd, char *string)
+{
+	struct ckpt_hdr h;
+	int ret;
+
+	h.type = CKPT_HDR_STRING;
+	h.len = strlen(string);
+
+	ret = ckpt_write(fd, &h, sizeof(h));
+	if (ret < 0)
+		return ret;
+
+	ret = ckpt_write(fd, string, h.len);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static char *ckpt_read_string(int fd)
+{
+	struct ckpt_hdr h;
+	char *string = NULL;
+	int ret;
+
+	ret = ckpt_read(fd, &h, sizeof(h));
+	if (ret < 0)
+		return NULL;
+
+	if (h.type != CKPT_HDR_STRING)
+		return NULL;
+
+	string = calloc(1, h.len + 1);
+	if (!string)
+		return NULL;
+
+	ret = ckpt_read(fd, string, h.len);
+	if (ret < 0) {
+		free(string);
+		string = NULL;
+	}
+
+	return string;
+}
+
+/* Find the filesystem mounted at @path in fstab and write the device,
+ * mount point, and type strings
+ */
+static int ckpt_write_fs_info(int fd, char *path)
+{
+	int ret;
+	struct mntent *ent;
+	FILE *fstab;
+
+	fstab = setmntent("/etc/fstab", "r");
+	if (!fstab)
+		return -errno;
+
+	while ((ent = getmntent(fstab)) != NULL) {
+		if (strcmp(path, ent->mnt_dir) == 0)
+			break;
+	}
+
+	endmntent(fstab);
+
+	if (!ent)
+		return -ENOENT;
+
+	ret = ckpt_write_string(fd, ent->mnt_fsname);
+	if (ret < 0)
+		return ret;
+
+	ret = ckpt_write_string(fd, path);
+	if (ret < 0)
+		return ret;
+
+	ret = ckpt_write_string(fd, ent->mnt_type);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+/* Read the device, mount point, and type strings.  Returns three
+ * malloc()'d strings, which must be freed by the caller if return
+ * value is zero
+ */
+int ckpt_read_fs_info(int fd, char **name, char **path, char **type)
+{
+	*name = ckpt_read_string(fd);
+	if (!*name)
+		goto err0;
+
+	*path = ckpt_read_string(fd);
+	if (!*path)
+		goto err1;
+
+	*type = ckpt_read_string(fd);
+	if (!*type)
+		goto err2;
+
+	return 0;
+ err2:
+	free(*path);
+ err1:
+	free(*name);
+ err0:
+	return -EINVAL;
+}
+
+/* This is kinda silly, but copy the fs info strings from infd to outfd */
+int ckpt_copy_fs_info(int infd, int outfd)
+{
+	char *name = NULL;
+	char *path = NULL;
+	char *type = NULL;
+	int ret;
+
+	ret = ckpt_read_fs_info(infd, &name, &path, &type);
+	if (ret)
+		return ret;
+
+	ret = ckpt_write_string(outfd, name);
+	if (ret)
+		goto out;
+
+	ret = ckpt_write_string(outfd, path);
+	if (ret)
+		goto out;
+
+	ret = ckpt_write_string(outfd, type);
+ out:
+	free(name);
+	free(path);
+	free(type);
+	return ret;
+}
+
+static int find_files(pid_t cinit_pid, char *path, int *pipefd)
+{
+	if (attach_ns(cinit_pid, "mnt")) {
+		ckpt_err("unable to attach to %ld's namespace",
+		      (unsigned long)cinit_pid);
+		exit(1);
+	}
+
+	if (chdir(path) < 0) {
+		ckpt_err("chdir(%s): %m", path);
+		exit(1);
+	}
+
+	if (dup2(pipefd[1], STDOUT_FILENO) < 0) {
+		ckpt_err("dup2(): %m");
+		exit(1);
+	}
+
+	close(pipefd[0]);
+
+	execlp("find", "find", "-depth", "-print0", NULL);
+	ckpt_err("Failed to exec find: %m");
+	exit(1);
+}
+
+static int write_payload_hdr(int fd, uint32_t type, uint32_t size)
+{
+	struct ckpt_hdr_payload hdr;
+
+	hdr.type = type;
+	hdr.payload_size = size;
+
+	return ckpt_write(fd, &hdr, sizeof(hdr));
+}
+
+static int cpio_files(pid_t cinit_pid, char *path, int *pipefd, int outfd)
+{
+	int ret;
+
+	if (attach_ns(cinit_pid, "mnt")) {
+		ckpt_err("unable to attach to %ld's namespace",
+			(unsigned long)cinit_pid);
+		exit(1);
+	}
+
+	ret = write_payload_hdr(outfd, CKPT_PAYLOAD_CPIOFS, 0);
+	if (ret < 0) {
+		ckpt_err("write payload header: %m\n");
+		exit(1);
+	}
+
+	ret = ckpt_write_fs_info(outfd, path);
+	if (ret < 0) {
+		ckpt_err("write fs info: %m\n");
+		exit(1);
+	}
+
+	if (chdir(path) < 0) {
+		ckpt_err("chdir(%s): %m", path);
+		exit(1);
+	}
+
+	if (dup2(pipefd[0], STDIN_FILENO) < 0) {
+		ckpt_err("dup2(STDIN): %m");
+		exit(1);
+	}
+
+	if (dup2(outfd, STDOUT_FILENO) < 0) {
+		ckpt_err("dup2(STDOUT): %m");
+		exit(1);
+	}
+
+	close(pipefd[1]);
+
+	execlp("cpio", "cpio", "--quiet", "-0o", NULL);
+	ckpt_err("Failed to exec cpio: %m");
+	exit(1);
+}
+
+static int wait_for_child(int pid)
+{
+	int ret;
+	int status;
+
+	while (1) {
+		ret = waitpid(pid, &status, 0);
+		if (ret < 0) {
+			if (errno == EINTR)
+				continue;
+			ckpt_err("waitpid(%i) = %i (%m)", pid, ret);
+			ret = errno;
+			break;
+		}
+
+		if (WIFEXITED(status)) {
+			ret = WEXITSTATUS(status);
+			ckpt_err("child %i exited with status %i",
+				pid, ret);
+			break;
+		} else if (WIFSIGNALED(status)) {
+			ret = WTERMSIG(status);
+			ckpt_err("child %i received signal %i", pid, ret);
+			ret += 128;
+			break;
+		}
+	}
+
+	return -ret;
+}
+
+int ckpt_save_fs_state(pid_t cinit_pid, char *path, int fd)
+{
+	pid_t find_pid, cpio_pid;
+	int pipefd[2];
+	int ret;
+
+	ret = pipe(pipefd);
+	if (ret < 0) {
+		ckpt_err("pipe(): %m");
+		return -errno;
+	}
+
+	fflush(NULL);
+
+	find_pid = fork();
+	if (find_pid == 0)
+		find_files(cinit_pid, path, pipefd);
+
+	cpio_pid = fork();
+	if (cpio_pid == 0)
+		cpio_files(cinit_pid, path, pipefd, fd);
+
+	close(pipefd[0]);
+	close(pipefd[1]);
+
+	if (find_pid == -1 || cpio_pid == -1) {
+		ckpt_err("fork");
+		return -1;
+	}
+
+	wait_for_child(find_pid);
+
+	return wait_for_child(cpio_pid);
+}
+
+int ckpt_declare_payloads(uint32_t count, int fd)
+{
+	struct ckpt_hdr_payloads hdr;
+
+	hdr.magic = CKPT_HDR_PAYLOADS_MAGIC;
+	hdr.payload_count = count;
+
+	return ckpt_write(fd, &hdr, sizeof(hdr));
+}
+
+static int ckpt_is_cpio_header(const char *buf, int len)
+{
+	return buf[0] == 0x71 && buf[1] == 0xC7;
+}
+
+static int ckpt_is_cpio_trailer(const char *buf, int len)
+{
+	const char *ptr;
+	const char needle[] = "TRAILER!!!";
+	int nlen = strlen(needle);
+
+	ptr = buf + (len - nlen);
+
+	while (--ptr > buf)
+		if (memcmp(ptr, needle, nlen) == 0)
+			return 1;
+
+	return 0;
+}
+
+static int ckpt_grab_cpio(int infd, struct ckpt_payload_holder *hold)
+{
+	char buf[512]; /* cpio block size */
+	int block;
+	int ret;
+	int outfd;
+
+	if (!hold->cpio_stream) {
+		hold->cpio_stream = tmpfile();
+		if (!hold->cpio_stream) {
+			ckpt_perror("tmpfile");
+			return -errno;
+		}
+	}
+
+	outfd = fileno(hold->cpio_stream);
+
+	ret = ckpt_copy_fs_info(infd, outfd);
+	if (ret)
+		return ret;
+
+	for (block = 0; ; block++) {
+		int ret;
+
+		ret = ckpt_read(infd, buf, sizeof(buf));
+		if (ret)
+			return -EINVAL;
+
+		if ((block == 0) && !ckpt_is_cpio_header(buf, sizeof(buf))) {
+			ckpt_err("Leading block is not a cpio archive!\n");
+			return -EINVAL;
+		}
+
+		ret = ckpt_write(outfd, buf, sizeof(buf));
+		if (ret < 0)
+			return -ENOSPC;
+
+		if (ckpt_is_cpio_trailer(buf, sizeof(buf)))
+			break;
+	}
+
+	return 0;
+}
+
+static int ckpt_restore_payload(int fd, struct ckpt_payload_holder *hold)
+{
+	struct ckpt_hdr_payload h;
+	int ret;
+
+	ret = ckpt_read(fd, &h, sizeof(h));
+	if (ret < 0)
+		return ret;
+
+	if (h.type == CKPT_PAYLOAD_CPIOFS)
+		return ckpt_grab_cpio(fd, hold);
+	else
+		return -EINVAL; /* Only cpio payloads supported right now */
+}
+
+int ckpt_restore_payloads(int fd, struct ckpt_payload_holder *hold)
+{
+	int i;
+	int ret;
+	struct ckpt_hdr_payloads hdr;
+
+	memset(hold, 0, sizeof(*hold));
+
+	ret = ckpt_read(fd, &hdr, sizeof(hdr));
+	if (ret < 0) {
+		ckpt_err("Error reading payloads header\n");
+		return ret;
+	}
+
+	if (hdr.magic != CKPT_HDR_PAYLOADS_MAGIC) {
+		ckpt_err("Invalid payload header magic!\n");
+		return -EINVAL;
+	}
+
+	if (hdr.payload_count != 1) {
+		ckpt_err("Unexpected payload count %i (%i)\n",
+			 hdr.payload_count, 1);
+		return -EINVAL;
+	}
+
+	for (i = 0; i < hdr.payload_count; i++) {
+		ret = ckpt_restore_payload(fd, hold);
+		if (ret < 0) {
+			ckpt_err("Error restoring payload %i\n", i);
+			return ret;
+		}
+	}
+
+	ret = 0;
+	if (hold->cpio_stream) {
+		ret = fseek(hold->cpio_stream, 0, SEEK_SET);
+		ckpt_err("fseek: %i\n", ret);
+	}
+
+	return ret;
+}
+
+static int ckpt_cpio_create(const char *path)
+{
+	if (chdir(path) < 0) {
+		ckpt_perror("cpio chdir");
+		return -errno;
+	}
+
+	execlp("cpio", "cpio", "-id", NULL);
+	exit(1);
+}
+
+int ckpt_restore_fs_state(struct ckpt_payload_holder *hold, char *path)
+{
+	pid_t pid;
+	int ret;
+	char *fs_name = NULL;
+	char *fs_path = NULL;
+	char *fs_type = NULL;
+
+	ret = ckpt_read_fs_info(fileno(hold->cpio_stream),
+				&fs_name, &fs_path, &fs_type);
+	if (ret < 0)
+		return ret;
+
+	/* FIXME: Maybe make this tolerant in the future? */
+	if (strcmp(path, fs_path) != 0) {
+		ckpt_err("Unexpected filesystem: %s\n", fs_path);
+		goto parent_out;
+	}
+
+	/* Don't let the image request mounting of a device (could do more) */
+	if (fs_name[0] == '/') {
+		ckpt_err("Invalid filesystem name: %s\n", fs_name);
+		goto parent_out;
+	}
+
+	if (mount(fs_name, fs_path, fs_type, 0, NULL)) {
+		ckpt_err("Failed to mount %s %s (%s): %m",
+			 fs_name, fs_path, fs_type);
+		ret = -1;
+		goto parent_out;
+	}
+
+	fflush(NULL);
+	pid = fork();
+	if (pid == -1) {
+		ckpt_err("fork");
+		goto parent_out;
+	}
+
+	/* child does the dirty work */
+	if (pid == 0) {
+		if (dup2(fileno(hold->cpio_stream), STDIN_FILENO) < 0) {
+			ckpt_err("Unable to dup to STDIN");
+			exit(1);
+		}
+
+		ret = ckpt_cpio_create("/dev/shm");
+		if (ret != 0)
+			ckpt_err("ckpt_cpio_create(/dev/shm) returned %d", ret);
+
+		exit(ret);
+	}
+
+	ret = wait_for_child(pid);
+	ckpt_dbg("child exited with status %d", ret);
+
+parent_out:
+	free(fs_name);
+	free(fs_path);
+	free(fs_type);
+
+	return ret;
+}
diff --git a/payload.h b/payload.h
new file mode 100644
index 0000000..ff923a3
--- /dev/null
+++ b/payload.h
@@ -0,0 +1,49 @@
+/*
+ *  payload.h: Interface for payload.c
+ *
+ *  Copyright (C) 2011 IBM Corp.
+ *
+ *  This file is subject to the terms and conditions of the GNU
+ *  General Public License.  See the file COPYING in the main
+ *  directory of the Linux distribution for more details.
+ */
+
+#ifndef __PAYLOAD_H
+#define __PAYLOAD_H
+
+#include <stdint.h>
+
+#define CKPT_HDR_PAYLOADS_MAGIC 0x43526372
+struct ckpt_hdr_payloads {
+	uint32_t magic;
+	uint32_t payload_count;
+};
+
+enum {
+	CKPT_PAYLOAD_NONE,
+	CKPT_PAYLOAD_CPIOFS,
+	CKPT_PAYLOAD_MAX
+};
+
+#define CKPT_PAYLOAD_MAX CKPT_PAYLOAD_MAX
+
+struct ckpt_hdr_payload {
+	uint32_t type;
+	uint32_t payload_size; /* If known, zero otherwise */
+};
+
+struct ckpt_payload_holder {
+	FILE *cpio_stream;
+};
+
+int ckpt_save_fs_state(pid_t cinit_pid, char *path, int fd);
+int ckpt_restore_fs_state(struct ckpt_payload_holder *hold, char *path);
+
+/* declare how many payloads we have at the front of the stream */
+int ckpt_declare_payloads(uint32_t count, int fd);
+
+/* Restore payload data to a holding area */
+int ckpt_restore_payloads(int fd, struct ckpt_payload_holder *hold);
+
+
+#endif
diff --git a/restart.c b/restart.c
index 6dc102f..0b92113 100644
--- a/restart.c
+++ b/restart.c
@@ -43,6 +43,7 @@
 #include "compat.h"
 #include "checkpoint.h"
 #include "common.h"
+#include "payload.h"
 
 /*
  * By default, 'restart' creates a new pid namespace in which the
@@ -134,6 +135,8 @@ struct ckpt_ctx {
 	int pipe_feed[2];	/* for feeder to provide input */
 	int pipe_coord[2];	/* for coord to report status (if needed) */
 
+	struct ckpt_payload_holder payloads;
+
 	struct ckpt_pids *pids_arr;
 	struct ckpt_pids *copy_arr;
 	__s32 *vpids_arr;
@@ -541,6 +544,12 @@ int cr_restart(struct cr_restart_args *args)
 		goto cleanup;
 	}
 
+	ret = ckpt_restore_payloads(STDIN_FILENO, &ctx.payloads);
+	if (ret < 0) {
+		ckpt_perror("read cpio header");
+		exit(1);
+	}
+
 	ret = ckpt_read_header(&ctx);
 	if (ret < 0) {
 		ckpt_perror("read c/r header");
@@ -938,6 +947,8 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	if (ret == 0 && ctx->args->wait)
 		ret = ckpt_collect_child(ctx);
 
+	fclose(ctx->payloads.cpio_stream);
+
 	return ret;
 }
 #else /* CLONE_NEWPID */
@@ -1710,6 +1721,19 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	return ret;
 }
 
+static int ckpt_restore_fs(struct ckpt_ctx *ctx)
+{
+	int i;
+
+	for (i = 0; ctx->args->restore_fs[i]; i++) {
+		char *path = ctx->args->restore_fs[i];
+		if (ckpt_restore_fs_state(&ctx->payloads, path))
+			return -1;
+	}
+
+	return 0;
+}
+
 int ckpt_fork_stub(void *data)
 {
 	struct task *task = (struct task *) data;
@@ -1727,6 +1751,15 @@ int ckpt_fork_stub(void *data)
 	if ((task->flags & TASK_NEWPTS) && ckpt_remount_devpts(ctx) < 0)
 		return -1;
 
+	if (task->flags & TASK_NEWNS) {
+		/* The container root task restores the filesystem
+		 * state.  FIXME: Is there a better way to do this?
+		 * What about nested mntns?
+		 */
+		if (ckpt_restore_fs(ctx) < 0)
+			return -1;
+	}
+
 	/*
 	 * In restart into a new pid namespace (--pidns), coordinator
 	 * is the container init, hence if it terminated permatutely
-- 
1.7.2.2
