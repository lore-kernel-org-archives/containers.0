From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/9] Introduce container dump function
Date: Wed,  3 Sep 2008 14:57:51 +0400
Message-ID: <1220439476-16465-5-git-send-email-major__6646.73290816626$1220439498$gmane$org@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-2-git-send-email-major@openvz.org>
	<1220439476-16465-3-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220439476-16465-4-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Actually right now we are going to dump only one process.
Function for dumping head of image file are added.

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 cpt/Makefile     |    2 +-
 cpt/checkpoint.c |   74 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 cpt/cpt.h        |    3 ++
 cpt/sys.c        |    3 +-
 kernel/fork.c    |    2 +
 5 files changed, 82 insertions(+), 2 deletions(-)
 create mode 100644 cpt/checkpoint.c

diff --git a/cpt/Makefile b/cpt/Makefile
index bfe75d5..173346b 100644
--- a/cpt/Makefile
+++ b/cpt/Makefile
@@ -2,4 +2,4 @@ obj-y += sys_core.o
 
 obj-$(CONFIG_CHECKPOINT) += cptrst.o
 
-cptrst-objs := sys.o
+cptrst-objs := sys.o checkpoint.o
diff --git a/cpt/checkpoint.c b/cpt/checkpoint.c
new file mode 100644
index 0000000..b4d9686
--- /dev/null
+++ b/cpt/checkpoint.c
@@ -0,0 +1,74 @@
+/*
+ *  Copyright (C) 2008 Parallels, Inc.
+ *
+ *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/version.h>
+
+#include "cpt.h"
+
+static int cpt_write_head(struct cpt_context *ctx)
+{
+	struct cpt_head hdr;
+
+	memset(&hdr, 0, sizeof(hdr));
+	hdr.cpt_signature[0] = CPT_SIGNATURE0;
+	hdr.cpt_signature[1] = CPT_SIGNATURE1;
+	hdr.cpt_signature[2] = CPT_SIGNATURE2;
+	hdr.cpt_signature[3] = CPT_SIGNATURE3;
+	hdr.cpt_hdrlen = sizeof(hdr);
+	hdr.cpt_image_major = (LINUX_VERSION_CODE >> 16) & 0xff;
+	hdr.cpt_image_minor = (LINUX_VERSION_CODE >> 8) & 0xff;
+	hdr.cpt_image_sublevel = (LINUX_VERSION_CODE) & 0xff;
+	hdr.cpt_image_extra = 0;
+#if defined(CONFIG_X86_32)
+	hdr.cpt_arch = CPT_ARCH_I386;
+#else
+#error  Arch is not supported
+#endif
+	return ctx->write(&hdr, sizeof(hdr), ctx);
+}
+
+int dump_container(struct cpt_context *ctx)
+{
+	int err;
+	struct task_struct *root;
+
+	read_lock(&tasklist_lock);
+	root = find_task_by_vpid(ctx->pid);
+	if (root)
+		get_task_struct(root);
+	read_unlock(&tasklist_lock);
+
+	err = -ESRCH;
+	if (!root) {
+		eprintk("can not find root task\n");
+		return err;
+	}
+	ctx->nsproxy = root->nsproxy;
+	if (!ctx->nsproxy) {
+		eprintk("nsproxy is null\n");
+		goto out;
+	}
+
+	err = cpt_write_head(ctx);
+	
+	/* Dump task here */
+	if (!err)
+		err = -ENOSYS;	
+
+out:
+	ctx->nsproxy = NULL;
+	put_task_struct(root);
+	return err;
+}
diff --git a/cpt/cpt.h b/cpt/cpt.h
index 607ac1b..b421a11 100644
--- a/cpt/cpt.h
+++ b/cpt/cpt.h
@@ -33,6 +33,7 @@ typedef struct cpt_context
 	int		refcount;
 	int		ctx_state;
 	struct semaphore main_sem;
+	struct nsproxy	*nsproxy;
 
 	int		errno;
 
@@ -54,3 +55,5 @@ extern int debug_level;
 
 #define eprintk(a...) cpt_printk(1, "CPT ERR: " a)
 #define dprintk(a...) cpt_printk(1, "CPT DBG: " a)
+
+int dump_container(struct cpt_context *ctx);
diff --git a/cpt/sys.c b/cpt/sys.c
index 8334c4c..6801c22 100644
--- a/cpt/sys.c
+++ b/cpt/sys.c
@@ -109,9 +109,10 @@ static int checkpoint(pid_t pid, int fd, unsigned long flags)
 
 	ctx->file = file;
 	ctx->ctx_state = CPT_CTX_DUMPING;
+	ctx->pid = pid;
 
 	/* checkpoint */
-	err = -ENOSYS;
+	err = dump_container(ctx);
 
 	context_put(ctx);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 52b5037..f38b43d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -77,6 +77,7 @@ int max_threads;		/* tunable limit on nr_threads */
 DEFINE_PER_CPU(unsigned long, process_counts) = 0;
 
 __cacheline_aligned DEFINE_RWLOCK(tasklist_lock);  /* outer */
+EXPORT_SYMBOL(tasklist_lock);
 
 int nr_processes(void)
 {
@@ -153,6 +154,7 @@ void __put_task_struct(struct task_struct *tsk)
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
+EXPORT_SYMBOL(__put_task_struct);
 
 /*
  * macro override instead of weak attribute alias, to workaround
-- 
1.5.6
