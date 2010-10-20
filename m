From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 06/11] checkpoint: enable c/r for bsr driver
Date: Wed, 20 Oct 2010 13:56:41 -0500
Message-ID: <1287601006-13794-7-git-send-email-ntl@pobox.com>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287601006-13794-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

BSR (Barrier Synchronization Register) is a IBM POWER-specific
register which can be used for fast synchronization on large systems
without cacheline bouncing.  This is a system-wide register and it is
not virtualized or context-switched.

Enable checkpoint and restart of BSR device mappings.  It is up to the
user/admin to initialize a job's BSR correctly when restarting or
migrating.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 drivers/char/bsr.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/char/bsr.c b/drivers/char/bsr.c
index 7fef305..e4ca911 100644
--- a/drivers/char/bsr.c
+++ b/drivers/char/bsr.c
@@ -24,6 +24,7 @@
 #include <linux/of_device.h>
 #include <linux/of_platform.h>
 #include <linux/module.h>
+#include <linux/checkpoint.h>
 #include <linux/cdev.h>
 #include <linux/list.h>
 #include <linux/mm.h>
@@ -116,6 +117,12 @@ static struct device_attribute bsr_dev_attrs[] = {
 	__ATTR_NULL
 };
 
+#ifdef CONFIG_CHECKPOINT
+static const struct vm_operations_struct bsr_vm_ops = {
+       .checkpoint = device_vma_checkpoint,
+};
+#endif 
+
 static int bsr_mmap(struct file *filp, struct vm_area_struct *vma)
 {
 	unsigned long size   = vma->vm_end - vma->vm_start;
@@ -138,6 +145,9 @@ static int bsr_mmap(struct file *filp, struct vm_area_struct *vma)
 	if (ret)
 		return -EAGAIN;
 
+#ifdef CONFIG_CHECKPOINT
+	vma->vm_ops = &bsr_vm_ops;
+#endif
 	return 0;
 }
 
@@ -154,6 +164,9 @@ static const struct file_operations bsr_fops = {
 	.owner = THIS_MODULE,
 	.mmap  = bsr_mmap,
 	.open  = bsr_open,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 static void bsr_cleanup_devs(void)
-- 
1.7.2.2
