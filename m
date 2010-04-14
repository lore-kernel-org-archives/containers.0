From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 4/6][usercr] Move checkpoint() into restart.c
Date: Tue, 13 Apr 2010 17:52:54 -0700
Message-ID: <20100414005254.GD13532@us.ibm.com>
References: <20100414004927.GA13012@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100414004927.GA13012-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 13 Apr 2010 14:35:32 -0700
Subject: [RFC][PATCH 4/6][usercr] Move checkpoint() into restart.c

checkpoint() function is pretty small and the file checkpoint.c mostly
has includes/declarations that are common to restart.c. We could just
fold both checkpoint() and restart() into a single file.

To keep the diff simple, this patch just does the move and the next
patch renames 'restart.c' to 'cr_checkpoint.c'.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Makefile     |   10 ++++++--
 checkpoint.c |   62 ----------------------------------------------------------
 restart.c    |   35 ++++++++++++++++++++++++++++++++
 3 files changed, 42 insertions(+), 65 deletions(-)
 delete mode 100644 checkpoint.c

diff --git a/Makefile b/Makefile
index afe144f..674b112 100644
--- a/Makefile
+++ b/Makefile
@@ -13,7 +13,7 @@ CKPT_HEADERS = include/linux/checkpoint.h \
 		include/linux/checkpoint_hdr.h \
 		include/asm/checkpoint_hdr.h
 
-CR_OBJS = checkpoint.o checkpoint-main.o restart.o restart-main.o
+CR_OBJS = restart.o checkpoint-main.o restart-main.o
 
 # detect architecture (for eclone)
 SUBARCH ?= $(patsubst i%86,x86_32,$(shell uname -m))
@@ -32,7 +32,7 @@ PREFIX ?= /usr/local
 BIN_INSTALL_DIR := $(PREFIX)/bin
 LIB_INSTALL_DIR := $(PREFIX)/lib
 
-ECLONE_PROGS = restart nsexec
+ECLONE_PROGS = checkpoint restart nsexec
 PROGS =	checkpoint ckptinfo $(ECLONE_PROGS)
 LIB_ECLONE = libeclone.a
 
@@ -55,8 +55,10 @@ restart: CFLAGS += -D__REENTRANT -pthread
 $(CR_OBJS): common.h cr_checkpoint.h
 
 restart: restart.o restart-main.o
+	$(CC) -o $@ $^
 
-checkpoint: checkpoint.o checkpoint-main.o
+checkpoint: restart.o checkpoint-main.o
+	$(CC) -o $@ $^
 
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
@@ -77,6 +79,8 @@ ASFLAGS += -m64
 $(LIB_ECLONE): clone_$(SUBARCH)_.o
 endif
 
+restart.o: $(LIB_ECLONE)
+
 # ckptinfo dependencies
 ckptinfo: ckptinfo_types.o
 
diff --git a/checkpoint.c b/checkpoint.c
deleted file mode 100644
index 90d4d35..0000000
--- a/checkpoint.c
+++ /dev/null
@@ -1,62 +0,0 @@
-/*
- *  checkpoint.c: checkpoint one or multiple processes
- *
- *  Copyright (C) 2008-2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <errno.h>
-#include <getopt.h>
-#include <unistd.h>
-#include <stdarg.h>
-#include <fcntl.h>
-#include <sys/types.h>
-#include <sys/syscall.h>
-
-#include <linux/checkpoint.h>
-
-#include "cr_checkpoint.h"
-#include "common.h"
-
-static int global_uerrfd = -1;
-
-inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
-{
-	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
-}
-
-int cr_checkpoint(int pid, struct cr_checkpoint_args *args)
-{
-	int ret;
-	unsigned long flags;
-
-	global_uerrfd = args->uerrfd;
-
-	/* output file descriptor (default: stdout) */
-	if (args->outfd < 0)
-		args->outfd = STDOUT_FILENO;
-
-	/* output file descriptor (default: none) */
-	if (args->logfd < 0)
-		args->logfd = CHECKPOINT_FD_NONE;
-
-	if (!args->container)
-		flags |= CHECKPOINT_SUBTREE;
-
-	ret = checkpoint(pid, args->outfd, flags, args->logfd);
-
-	if (ret < 0) {
-		ckpt_perror("checkpoint");
-		ckpt_err("(you may use 'ckptinfo -e' for more info)\n"); 
-	} else if (args->verbose) {
-		ckpt_err("checkpoint id %d\n", ret);
-	}
-
-	return ret;
-}
diff --git a/restart.c b/restart.c
index 11628e0..e01c08e 100644
--- a/restart.c
+++ b/restart.c
@@ -232,6 +232,11 @@ static inline pid_t _getpid(void)
 	return syscall(__NR_getpid);
 }
 
+inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
+{
+	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
+}
+
 static inline int restart(pid_t pid, int fd, unsigned long flags, int klogfd)
 {
 	return syscall(__NR_restart, pid, fd, flags, klogfd);
@@ -2582,3 +2587,33 @@ static void *hash_lookup(struct ckpt_ctx *ctx, long key)
 	}
 	return NULL;
 }
+
+int cr_checkpoint(int pid, struct cr_checkpoint_args *args)
+{
+	int ret;
+	unsigned long flags;
+
+	global_uerrfd = args->uerrfd;
+
+	/* output file descriptor (default: stdout) */
+	if (args->outfd < 0)
+		args->outfd = STDOUT_FILENO;
+
+	/* log file descriptor (default: none) */
+	if (args->logfd < 0)
+		args->logfd = CHECKPOINT_FD_NONE;
+
+	if (!args->container)
+		flags |= CHECKPOINT_SUBTREE;
+
+	ret = checkpoint(pid, args->outfd, flags, args->logfd);
+
+	if (ret < 0) {
+		ckpt_perror("checkpoint");
+		ckpt_err("(you may use 'ckptinfo -e' for more info)\n"); 
+	} else if (args->verbose) {
+		ckpt_err("checkpoint id %d\n", ret);
+	}
+
+	return ret;
+}
-- 
1.6.6.1
