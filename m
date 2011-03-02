From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] Export some things from restart.c
Date: Wed,  2 Mar 2011 13:35:24 -0800
Message-ID: <1299101725-17603-3-git-send-email-danms@us.ibm.com>
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

ckpt_read() and ckpt_write() are useful elsewhere, so export them in
common.h.  Also, make common.h include stdarg.h so that it can be
#include'd from other files and not break.  The log functions use
_gettid() and the global file descriptors, neither of which are local
to common.h, so fix that too.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile          |    6 ++--
 checkpoint-main.c |    3 +-
 checkpoint.c      |    2 -
 common.c          |   74 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 common.h          |   13 +++++++++
 restart-main.c    |    2 -
 restart.c         |   72 +--------------------------------------------------
 7 files changed, 94 insertions(+), 78 deletions(-)
 create mode 100644 common.c

diff --git a/Makefile b/Makefile
index 0932519..42ea74b 100644
--- a/Makefile
+++ b/Makefile
@@ -13,7 +13,7 @@ CKPT_HEADERS = include/linux/checkpoint.h \
 		include/linux/checkpoint_hdr.h \
 		include/asm/checkpoint_hdr.h
 
-CR_OBJS = checkpoint.o checkpoint-main.o restart.o restart-main.o
+CR_OBJS = checkpoint.o checkpoint-main.o restart.o restart-main.o common.o
 
 # detect architecture (for eclone)
 SUBARCH ?= $(patsubst i%86,x86_32,$(shell uname -m))
@@ -61,9 +61,9 @@ restart: CFLAGS += -D__REENTRANT -pthread
 
 $(CR_OBJS): common.h checkpoint.h
 
-restart: restart.o restart-main.o
+restart: restart.o restart-main.o common.o
 
-checkpoint: checkpoint.o checkpoint-main.o
+checkpoint: checkpoint.o checkpoint-main.o common.o
 
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
diff --git a/checkpoint-main.c b/checkpoint-main.c
index a2a7d94..6f8acf2 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -12,7 +12,8 @@
 #include "checkpoint.h"
 #include "common.h"
 
-static int global_uerrfd = -1;
+int global_uerrfd = -1;
+int global_debug = -1;
 
 static char usage_str[] =
 "usage: ckpt [opts] PID\n"
diff --git a/checkpoint.c b/checkpoint.c
index cce3d9d..3054cd4 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -24,8 +24,6 @@
 #include "checkpoint.h"
 #include "common.h"
 
-static int global_uerrfd = -1;
-
 inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 {
 	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
diff --git a/common.c b/common.c
new file mode 100644
index 0000000..f9d3d92
--- /dev/null
+++ b/common.c
@@ -0,0 +1,74 @@
+/*
+ *  common.c: shared utility functions
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <stdio.h>
+#include <errno.h>
+#include <unistd.h>
+
+/*
+ * low-level read
+ *   _ckpt_read - read 'count' bytes to 'buf', or EOF
+ *   ckpt_read - read 'count' bytes to 'buf' (EOF disallowed)
+ *   ckpt_read_obj - read up to 'n' bytes of object into 'buf'
+ *   ckpt_read_obj_type - read up to 'n' bytes of object type 'type' into 'buf'
+ *   ckpt_read_obj_ptr - like ckpt_read_obj_type, but discards header
+ */
+int _ckpt_read(int fd, void *buf, int count)
+{
+	ssize_t nread;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nread) {
+		nread = read(fd, buf, nleft);
+		if (nread < 0 && errno == EAGAIN)
+			continue;
+		if (nread == 0 && nleft == count)
+			return 0;
+		if (nread <= 0)
+			return -1;
+		buf += nread;
+	}
+	return count;
+}
+
+int ckpt_read(int fd, void *buf, int count)
+{
+	int ret;
+
+	ret = _ckpt_read(fd, buf, count);
+	if (ret == 0 && count) {
+		errno = EINVAL;
+		ret = -1;
+	}
+	return (ret < 0 ? ret : 0);
+}
+
+/*
+ * low-level write
+ *   ckpt_write - write 'count' bytes to 'buf'
+ *   ckpt_write_obj - write object
+ *   ckpt_write_obj_buffer - write buffer object
+ */
+int ckpt_write(int fd, void *buf, int count)
+{
+	ssize_t nwrite;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nwrite) {
+		nwrite = write(fd, buf, nleft);
+		if (nwrite < 0 && errno == EAGAIN)
+			continue;
+		if (nwrite < 0)
+			return -1;
+		buf += nwrite;
+	}
+	return 0;
+}
+
diff --git a/common.h b/common.h
index b4736bb..b46c895 100644
--- a/common.h
+++ b/common.h
@@ -1,8 +1,18 @@
 #include <stdio.h>
 #include <signal.h>
+#include <stdarg.h>
+#include <asm/unistd.h>
 
 #define BUFSIZE  (4096)
 
+extern int global_uerrfd;
+extern int global_debug;
+
+static inline pid_t _gettid(void)
+{
+	return syscall(__NR_gettid);
+}
+
 static inline void ckpt_msg(int fd, char *format, ...)
 {
 	char buf[BUFSIZE];
@@ -127,3 +137,6 @@ struct signal_array {
 			    CKPT_COND_MNTPTY)
 #define CKPT_COND_FAIL     (CKPT_COND_NONE)
 
+int _ckpt_read(int fd, void *buf, int count);
+int ckpt_read(int fd, void *buf, int count);
+int ckpt_write(int fd, void *buf, int count);
diff --git a/restart-main.c b/restart-main.c
index 6eed101..ea92633 100644
--- a/restart-main.c
+++ b/restart-main.c
@@ -12,8 +12,6 @@
 #include "common.h"
 
 static int global_ulogfd;
-static int global_uerrfd;
-static int global_debug;
 static int global_verbose;
 static struct signal_array signal_array[] = INIT_SIGNAL_ARRAY;
 
diff --git a/restart.c b/restart.c
index 78d21c0..6dc102f 100644
--- a/restart.c
+++ b/restart.c
@@ -169,8 +169,8 @@ struct pid_swap {
  * 	 fds (like stdout and stderr) or can we just use one ?
  */
 static int global_ulogfd;
-static int global_uerrfd;
-static int global_debug;
+int global_uerrfd;
+int global_debug;
 static int global_verbose;
 static pid_t global_child_pid;
 static int global_child_status;
@@ -206,7 +206,6 @@ static void ckpt_abort(struct ckpt_ctx *ctx, char *str);
 static int ckpt_do_feeder(void *data);
 static int ckpt_fork_feeder(struct ckpt_ctx *ctx);
 
-static int ckpt_write(int fd, void *buf, int count);
 static int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
 
 static int ckpt_write_header(struct ckpt_ctx *ctx);
@@ -215,8 +214,6 @@ static int ckpt_write_container(struct ckpt_ctx *ctx);
 static int ckpt_write_tree(struct ckpt_ctx *ctx);
 static int ckpt_write_vpids(struct ckpt_ctx *ctx);
 
-static int _ckpt_read(int fd, void *buf, int count);
-static int ckpt_read(int fd, void *buf, int count);
 static int ckpt_read_obj(struct ckpt_ctx *ctx,
 			 struct ckpt_hdr *h, void *buf, int n);
 static int ckpt_read_obj_type(struct ckpt_ctx *ctx, void *b, int n, int type);
@@ -232,11 +229,6 @@ static void hash_exit(struct ckpt_ctx *ctx);
 static int hash_insert(struct ckpt_ctx *ctx, long key, void *data);
 static void *hash_lookup(struct ckpt_ctx *ctx, long key);
 
-static inline pid_t _gettid(void)
-{
-	return syscall(__NR_gettid);
-}
-
 static inline pid_t _getpid(void)
 {
 	return syscall(__NR_getpid);
@@ -2169,28 +2161,6 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 	return 0;
 }
 
-/*
- * low-level write
- *   ckpt_write - write 'count' bytes to 'buf'
- *   ckpt_write_obj - write object
- *   ckpt_write_obj_buffer - write buffer object
- */
-static int ckpt_write(int fd, void *buf, int count)
-{
-	ssize_t nwrite;
-	int nleft;
-
-	for (nleft = count; nleft; nleft -= nwrite) {
-		nwrite = write(fd, buf, nleft);
-		if (nwrite < 0 && errno == EAGAIN)
-			continue;
-		if (nwrite < 0)
-			return -1;
-		buf += nwrite;
-	}
-	return 0;
-}
-
 int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 {
 	/* called by the feeder, so use stdout */
@@ -2215,44 +2185,6 @@ int ckpt_write_obj_ptr(struct ckpt_ctx *ctx, void *buf, int n, int type)
 	return ret;
 }
 
-/*
- * low-level read
- *   _ckpt_read - read 'count' bytes to 'buf', or EOF
- *   ckpt_read - read 'count' bytes to 'buf' (EOF disallowed)
- *   ckpt_read_obj - read up to 'n' bytes of object into 'buf'
- *   ckpt_read_obj_type - read up to 'n' bytes of object type 'type' into 'buf'
- *   ckpt_read_obj_ptr - like ckpt_read_obj_type, but discards header
- */
-static int _ckpt_read(int fd, void *buf, int count)
-{
-	ssize_t nread;
-	int nleft;
-
-	for (nleft = count; nleft; nleft -= nread) {
-		nread = read(fd, buf, nleft);
-		if (nread < 0 && errno == EAGAIN)
-			continue;
-		if (nread == 0 && nleft == count)
-			return 0;
-		if (nread <= 0)
-			return -1;
-		buf += nread;
-	}
-	return count;
-}
-
-static int ckpt_read(int fd, void *buf, int count)
-{
-	int ret;
-
-	ret = _ckpt_read(fd, buf, count);
-	if (ret == 0 && count) {
-		errno = EINVAL;
-		ret = -1;
-	}
-	return (ret < 0 ? ret : 0);
-}
-
 static int ckpt_read_obj(struct ckpt_ctx *ctx,
 			 struct ckpt_hdr *h, void *buf, int n)
 {
-- 
1.7.2.2
