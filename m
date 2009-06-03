From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/9] exec_path 5/9: make struct spu_context::owner task_struct
Date: Thu, 4 Jun 2009 03:06:37 +0400
Message-ID: <20090603230637.GF853__5910.23676465756$1244070434$gmane$org@x200.localdomain>
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

Cell SPU code is going to use ->exec_path to get dcookies and stuff
so it needs task_struct saved, not mm_struct.

Export __put_task_struct() to allow link.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/platforms/cell/spufs/context.c |    9 +++++----
 arch/powerpc/platforms/cell/spufs/file.c    |    2 +-
 arch/powerpc/platforms/cell/spufs/sched.c   |    2 +-
 arch/powerpc/platforms/cell/spufs/spufs.h   |    2 +-
 kernel/fork.c                               |    1 +
 5 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/context.c b/arch/powerpc/platforms/cell/spufs/context.c
index db5398c..7ad45e1 100644
--- a/arch/powerpc/platforms/cell/spufs/context.c
+++ b/arch/powerpc/platforms/cell/spufs/context.c
@@ -57,7 +57,8 @@ struct spu_context *alloc_spu_context(struct spu_gang *gang)
 	init_waitqueue_head(&ctx->run_wq);
 	ctx->state = SPU_STATE_SAVED;
 	ctx->ops = &spu_backing_ops;
-	ctx->owner = get_task_mm(current);
+	get_task_struct(current);
+	ctx->owner = current;
 	INIT_LIST_HEAD(&ctx->rq);
 	INIT_LIST_HEAD(&ctx->aff_list);
 	if (gang)
@@ -111,7 +112,7 @@ int put_spu_context(struct spu_context *ctx)
 /* give up the mm reference when the context is about to be destroyed */
 void spu_forget(struct spu_context *ctx)
 {
-	struct mm_struct *mm;
+	struct task_struct *tsk;
 
 	/*
 	 * This is basically an open-coded spu_acquire_saved, except that
@@ -122,9 +123,9 @@ void spu_forget(struct spu_context *ctx)
 	if (ctx->state != SPU_STATE_SAVED)
 		spu_deactivate(ctx);
 
-	mm = ctx->owner;
+	tsk = ctx->owner;
 	ctx->owner = NULL;
-	mmput(mm);
+	put_task_struct(tsk);
 	spu_release(ctx);
 }
 
diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index d6a519e..d781304 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -1545,7 +1545,7 @@ static int spufs_mfc_open(struct inode *inode, struct file *file)
 	struct spu_context *ctx = i->i_ctx;
 
 	/* we don't want to deal with DMA into other processes */
-	if (ctx->owner != current->mm)
+	if (ctx->owner != current)
 		return -EINVAL;
 
 	if (atomic_read(&inode->i_count) != 1)
diff --git a/arch/powerpc/platforms/cell/spufs/sched.c b/arch/powerpc/platforms/cell/spufs/sched.c
index f085369..9fbd87a 100644
--- a/arch/powerpc/platforms/cell/spufs/sched.c
+++ b/arch/powerpc/platforms/cell/spufs/sched.c
@@ -230,7 +230,7 @@ static void spu_bind_context(struct spu *spu, struct spu_context *ctx)
 	ctx->stats.slb_flt_base = spu->stats.slb_flt;
 	ctx->stats.class2_intr_base = spu->stats.class2_intr;
 
-	spu_associate_mm(spu, ctx->owner);
+	spu_associate_mm(spu, ctx->owner->mm);
 
 	spin_lock_irq(&spu->register_lock);
 	spu->ctx = ctx;
diff --git a/arch/powerpc/platforms/cell/spufs/spufs.h b/arch/powerpc/platforms/cell/spufs/spufs.h
index ae31573..70a7813 100644
--- a/arch/powerpc/platforms/cell/spufs/spufs.h
+++ b/arch/powerpc/platforms/cell/spufs/spufs.h
@@ -95,7 +95,7 @@ struct spu_context {
 	struct mutex state_mutex;
 	struct mutex run_mutex;
 
-	struct mm_struct *owner;
+	struct task_struct *owner;
 
 	struct kref kref;
 	wait_queue_head_t ibox_wq;
diff --git a/kernel/fork.c b/kernel/fork.c
index c0ee931..b396c07 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -160,6 +160,7 @@ void __put_task_struct(struct task_struct *tsk)
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
+EXPORT_SYMBOL(__put_task_struct);
 
 /*
  * macro override instead of weak attribute alias, to workaround
