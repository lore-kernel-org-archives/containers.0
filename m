From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/10] Introduce function for restarting a container
Date: Sat, 18 Oct 2008 03:11:35 +0400
Message-ID: <1224285098-573-8-git-send-email-major@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-2-git-send-email-major@openvz.org>
	<1224285098-573-3-git-send-email-major@openvz.org>
	<1224285098-573-4-git-send-email-major@openvz.org>
	<1224285098-573-5-git-send-email-major@openvz.org>
	<1224285098-573-6-git-send-email-major@openvz.org>
	<1224285098-573-7-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224285098-573-7-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Actually, right now this function will restart only one process.
Function to read head of dump file is introduced.

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 checkpoint/Makefile     |    2 +-
 checkpoint/checkpoint.h |    1 +
 checkpoint/restart.c    |   87 +++++++++++++++++++++++++++++++++++++++++++++++
 checkpoint/sys.c        |    2 +-
 4 files changed, 90 insertions(+), 2 deletions(-)
 create mode 100644 checkpoint/restart.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index bbb0e37..47c7852 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,4 +2,4 @@ obj-y += sys_core.o
 
 obj-$(CONFIG_CHECKPOINT) += cptrst.o
 
-cptrst-objs := sys.o checkpoint.o cpt_process.o cpt_mm.o
+cptrst-objs := sys.o checkpoint.o cpt_process.o cpt_mm.o restart.o
diff --git a/checkpoint/checkpoint.h b/checkpoint/checkpoint.h
index e3e6b66..0608bb9 100644
--- a/checkpoint/checkpoint.h
+++ b/checkpoint/checkpoint.h
@@ -62,3 +62,4 @@ extern int debug_level;
 int dump_container(struct cpt_context *ctx);
 int cpt_dump_task(struct task_struct *tsk, struct cpt_context *ctx);
 int cpt_dump_mm(struct task_struct *tsk, struct cpt_context *ctx);
+int restart_container(struct cpt_context *ctx);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
new file mode 100644
index 0000000..acfcadb
--- /dev/null
+++ b/checkpoint/restart.c
@@ -0,0 +1,87 @@
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
+#include "checkpoint.h"
+#include "cpt_image.h"
+
+int rst_get_object(int type, void *tmp, int size, struct cpt_context *ctx)
+{
+	int err;
+	struct cpt_object_hdr *hdr = tmp;
+	err = ctx->read(hdr, sizeof(struct cpt_object_hdr), ctx);
+	if (err)
+		return err;
+	if (type > 0 && type != hdr->cpt_type)
+		return -EINVAL;
+	if (hdr->cpt_hdrlen < sizeof(struct cpt_object_hdr))
+		return -EINVAL;
+	if (size < sizeof(struct cpt_object_hdr))
+		return -EINVAL;
+	if (hdr->cpt_len < hdr->cpt_hdrlen)
+		return -EINVAL;
+	if (size > hdr->cpt_hdrlen)
+		size = hdr->cpt_hdrlen;
+	if (size > sizeof(*hdr))
+		err = ctx->read(hdr + 1, size - sizeof(*hdr), ctx);
+	return err;
+}
+
+static int rst_read_head(struct cpt_context *ctx)
+{
+	struct cpt_head hdr;
+	int err;
+
+	err = -EBADF;
+	if (!ctx->file)
+		return err;
+
+	err = ctx->read(&hdr, sizeof(hdr), ctx);
+	if (err < 0)
+		return err;
+
+	if (hdr.cpt_signature[0] != CPT_SIGNATURE0 ||
+	    hdr.cpt_signature[1] != CPT_SIGNATURE1 ||
+	    hdr.cpt_signature[2] != CPT_SIGNATURE2 ||
+	    hdr.cpt_signature[3] != CPT_SIGNATURE3) {
+		return -EINVAL;
+	}
+	if (KERNEL_VERSION(hdr.cpt_image_major, hdr.cpt_image_minor,
+				hdr.cpt_image_sublevel) != LINUX_VERSION_CODE)
+		return -EINVAL;
+
+#if defined(CONFIG_X86_32)
+	if (hdr.cpt_arch != CPT_ARCH_I386)
+		return -ENOSYS;
+#else
+#error  Arch is not supported
+#endif
+
+	return 0;
+}
+
+int restart_container(struct cpt_context *ctx)
+{
+	int err;
+
+	err = rst_read_head(ctx);
+
+	/* Restart process */
+	if (!err)
+		err = -ENOSYS;
+
+	return err;
+}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 1902fef..b92312a 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -140,7 +140,7 @@ static int restart(int ctid, int fd, unsigned long flags)
 	ctx->ctx_state = CPT_CTX_UNDUMPING;
 
 	/* restart */
-	err = -ENOSYS;
+	err = restart_container(ctx);
 
 	context_put(ctx);
 
-- 
1.5.6
