From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] s390 c/r: fix up v14 (v2)
Date: Tue, 24 Mar 2009 11:39:11 -0500
Message-ID: <20090324163911.GA20268@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Uh, discard the previous version :)

Make a few changes to the s390 c/r code to reflect v14 changes.
CONFIG_CHECKPOINT_RESTART is now CONFIG_CHECKPOINT, and 'parent'
is gone.

Compiler missed another use of parent.  This version actually
is tested with a working c/r  :)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/mm/Makefile     |    2 +-
 arch/s390/mm/checkpoint.c |    5 +----
 arch/s390/mm/restart.c    |   11 ++++-------
 3 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/arch/s390/mm/Makefile b/arch/s390/mm/Makefile
index 040fbb7..b16161e 100644
--- a/arch/s390/mm/Makefile
+++ b/arch/s390/mm/Makefile
@@ -6,4 +6,4 @@ obj-y	 := init.o fault.o extmem.o mmap.o vmem.o pgtable.o
 obj-$(CONFIG_CMM) += cmm.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_PAGE_STATES) += page-states.o
-obj-$(CONFIG_CHECKPOINT_RESTART) += checkpoint.o restart.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o restart.o
diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
index 216bdd8..c4e3719 100644
--- a/arch/s390/mm/checkpoint.c
+++ b/arch/s390/mm/checkpoint.c
@@ -79,7 +79,6 @@ int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
 
 	h.type = CR_HDR_CPU;
 	h.len = sizeof(*hh);
-	h.parent = task_pid_vnr(t);
 
 	cr_s390_regs(CR_CPT, hh, t);
 
@@ -98,7 +97,6 @@ int cr_write_head_arch(struct cr_ctx *ctx)
 
 	h.type = CR_HDR_HEAD_ARCH;
 	h.len = sizeof(*hh);
-	h.parent = 0;
 
 	ret = cr_write_obj(ctx, &h, &hh);
 	cr_hbuf_put(ctx, sizeof(*hh));
@@ -106,7 +104,7 @@ int cr_write_head_arch(struct cr_ctx *ctx)
 	return ret;
 }
 
-int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
+int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
 {
 	struct cr_hdr h;
 	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
@@ -114,7 +112,6 @@ int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
 
 	h.type = CR_HDR_MM_CONTEXT;
 	h.len = sizeof(*hh);
-	h.parent = parent;
 
 	cr_s390_mm(CR_CPT, hh, mm);
 
diff --git a/arch/s390/mm/restart.c b/arch/s390/mm/restart.c
index 7da4111..6892a2a 100644
--- a/arch/s390/mm/restart.c
+++ b/arch/s390/mm/restart.c
@@ -60,18 +60,15 @@ int cr_read_head_arch(struct cr_ctx *ctx)
 }
 
 
-int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int rparent)
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
 {
 	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
-	int parent, ret = -EINVAL;
+	int ret;
 
-	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
-	if (parent < 0) {
-		ret = parent;
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
+	if (ret < 0) {
 		goto out;
 	}
-	if (parent != rparent)
-		goto out;
 
 	cr_s390_mm(CR_RST, hh, mm);
 	ret = 0;
-- 
1.6.1
