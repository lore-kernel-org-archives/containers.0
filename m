From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/9] exec_path 6/9: add struct spu::tsk
Date: Thu, 4 Jun 2009 03:06:56 +0400
Message-ID: <20090603230656.GG853@x200.localdomain>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
	<20090531215427.GA29534@x200.localdomain>
	<20090531151953.8f8b14b5.akpm@linux-foundation.org>
	<20090603230422.GB853@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090603230422.GB853-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Pass down task_struct too.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/include/asm/spu.h            |    3 ++-
 arch/powerpc/platforms/cell/spu_base.c    |   11 ++++++-----
 arch/powerpc/platforms/cell/spufs/sched.c |    4 ++--
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/include/asm/spu.h b/arch/powerpc/include/asm/spu.h
index 0ab8d86..f9b1bcf 100644
--- a/arch/powerpc/include/asm/spu.h
+++ b/arch/powerpc/include/asm/spu.h
@@ -135,6 +135,7 @@ struct spu {
 	u64 class_1_dsisr;
 	size_t ls_size;
 	unsigned int slb_replace;
+	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct spu_context *ctx;
 	struct spu_runqueue *rq;
@@ -212,7 +213,7 @@ static inline void crash_register_spus(struct list_head *list)
 #endif
 
 extern void spu_invalidate_slbs(struct spu *spu);
-extern void spu_associate_mm(struct spu *spu, struct mm_struct *mm);
+extern void spu_associate_task(struct spu *spu, struct task_struct *tsk);
 int spu_64k_pages_available(void);
 
 /* Calls from the memory management to the SPU */
diff --git a/arch/powerpc/platforms/cell/spu_base.c b/arch/powerpc/platforms/cell/spu_base.c
index 9abd210..46f4a63 100644
--- a/arch/powerpc/platforms/cell/spu_base.c
+++ b/arch/powerpc/platforms/cell/spu_base.c
@@ -117,17 +117,18 @@ static inline void mm_needs_global_tlbie(struct mm_struct *mm)
 	bitmap_fill(cpumask_bits(mm_cpumask(mm)), nr);
 }
 
-void spu_associate_mm(struct spu *spu, struct mm_struct *mm)
+void spu_associate_task(struct spu *spu, struct task_struct *tsk)
 {
 	unsigned long flags;
 
 	spin_lock_irqsave(&spu_full_list_lock, flags);
-	spu->mm = mm;
+	spu->tsk = tsk;
+	spu->mm = tsk ? tsk->mm : NULL;
 	spin_unlock_irqrestore(&spu_full_list_lock, flags);
-	if (mm)
-		mm_needs_global_tlbie(mm);
+	if (tsk && tsk->mm)
+		mm_needs_global_tlbie(tsk->mm);
 }
-EXPORT_SYMBOL_GPL(spu_associate_mm);
+EXPORT_SYMBOL_GPL(spu_associate_task);
 
 int spu_64k_pages_available(void)
 {
diff --git a/arch/powerpc/platforms/cell/spufs/sched.c b/arch/powerpc/platforms/cell/spufs/sched.c
index 9fbd87a..2f7e497 100644
--- a/arch/powerpc/platforms/cell/spufs/sched.c
+++ b/arch/powerpc/platforms/cell/spufs/sched.c
@@ -230,7 +230,7 @@ static void spu_bind_context(struct spu *spu, struct spu_context *ctx)
 	ctx->stats.slb_flt_base = spu->stats.slb_flt;
 	ctx->stats.class2_intr_base = spu->stats.class2_intr;
 
-	spu_associate_mm(spu, ctx->owner->mm);
+	spu_associate_task(spu, ctx->owner);
 
 	spin_lock_irq(&spu->register_lock);
 	spu->ctx = ctx;
@@ -470,7 +470,7 @@ static void spu_unbind_context(struct spu *spu, struct spu_context *ctx)
 	spu->ctx = NULL;
 	spin_unlock_irq(&spu->register_lock);
 
-	spu_associate_mm(spu, NULL);
+	spu_associate_task(spu, NULL);
 
 	ctx->stats.slb_flt +=
 		(spu->stats.slb_flt - ctx->stats.slb_flt_base);
