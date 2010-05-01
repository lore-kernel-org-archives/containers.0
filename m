From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 064/100] c/r: checkpoint and restore (shared) task's
	sighand_struct
Date: Sat,  1 May 2010 10:15:46 -0400
Message-ID: <1272723382-19470-65-git-send-email-orenl__18494.8046612137$1272728271$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds the checkpointing and restart of signal handling
state - 'struct sighand_struct'. Since the contents of this state
only affect userspace, no input validation is required.

Add _NSIG to kernel constants saved/tested with image header.

Number of signals (_NSIG) is arch-dependent, but is within __KERNEL__
and not visibile to userspace compile. Therefore, define per arch
CKPT_ARCH_NSIG in <asm/checkpoint_hdr.h>.

Changelog[v21]:
  - Do not include checkpoint_hdr.h explicitly
  - [Matt Helsley] Move the signal handler c/r code into kernel/signal.c
Changelog[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
Changelog[v1]:
  - Rename headerless struct ckpt_hdr_* to struct ckpt_*

Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/checkpoint_hdr.h |    8 ++
 arch/x86/include/asm/checkpoint_hdr.h  |    8 ++
 include/linux/checkpoint.h             |    6 +
 include/linux/checkpoint_hdr.h         |   24 +++++
 kernel/checkpoint/checkpoint.c         |    2 +
 kernel/checkpoint/process.c            |   19 ++++
 kernel/checkpoint/restart.c            |    3 +
 kernel/signal.c                        |  179 ++++++++++++++++++++++++++++++++
 8 files changed, 249 insertions(+), 0 deletions(-)

diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
index e3312c0..7d30317 100644
--- a/arch/s390/include/asm/checkpoint_hdr.h
+++ b/arch/s390/include/asm/checkpoint_hdr.h
@@ -91,6 +91,14 @@ struct ckpt_hdr_mm_context {
 	unsigned long asce_limit;
 };
 
+#define CKPT_ARCH_NSIG  64
+#ifdef __KERNEL__
+#include <asm/signal.h>
+#if CKPT_ARCH_NSIG != _SIGCONTEXT_NSIG
+#error CKPT_ARCH_NSIG size is wrong (asm/sigcontext.h and asm/checkpoint_hdr.h)
+#endif
+#endif
+
 struct ckpt_hdr_header_arch {
 	struct ckpt_hdr h;
 };
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 292bf50..44737b8 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -52,6 +52,14 @@ enum {
 #define CKPT_HDR_MM_CONTEXT_LDT CKPT_HDR_MM_CONTEXT_LDT
 };
 
+#define CKPT_ARCH_NSIG  64
+#ifdef __KERNEL__
+#include <asm/signal.h>
+#if CKPT_ARCH_NSIG != _NSIG
+#error CKPT_ARCH_NSIG size is wrong per asm/signal.h and asm/checkpoint_hdr.h
+#endif
+#endif
+
 struct ckpt_hdr_header_arch {
 	struct ckpt_hdr h;
 	/* FIXME: add HAVE_HWFP */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 776de99..8e8cf6e 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -242,6 +242,12 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
 	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
+/* signals */
+extern int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref);
+
+extern int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 261badb..2dea11e 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -136,6 +136,9 @@ enum {
 	CKPT_HDR_IPC_SEM,
 #define CKPT_HDR_IPC_SEM CKPT_HDR_IPC_SEM
 
+	CKPT_HDR_SIGHAND = 601,
+#define CKPT_HDR_SIGHAND CKPT_HDR_SIGHAND
+
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
 
@@ -173,6 +176,8 @@ enum obj_type {
 #define CKPT_OBJ_FILE CKPT_OBJ_FILE
 	CKPT_OBJ_MM,
 #define CKPT_OBJ_MM CKPT_OBJ_MM
+	CKPT_OBJ_SIGHAND,
+#define CKPT_OBJ_SIGHAND CKPT_OBJ_SIGHAND
 	CKPT_OBJ_NS,
 #define CKPT_OBJ_NS CKPT_OBJ_NS
 	CKPT_OBJ_UTS_NS,
@@ -197,6 +202,8 @@ struct ckpt_const {
 	__u16 task_comm_len;
 	/* mm */
 	__u16 at_vector_size;
+	/* signal */
+	__u16 signal_nsig;
 	/* uts */
 	__u16 uts_sysname_len;
 	__u16 uts_nodename_len;
@@ -370,6 +377,7 @@ struct ckpt_hdr_task_objs {
 
 	__s32 files_objref;
 	__s32 mm_objref;
+	__s32 sighand_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
@@ -511,6 +519,22 @@ struct ckpt_hdr_pgarr {
 	__u64 nr_pages;		/* number of pages to saved */
 } __attribute__((aligned(8)));
 
+/* signals */
+struct ckpt_sigset {
+	__u8 sigset[CKPT_ARCH_NSIG / 8];
+} __attribute__((aligned(8)));
+
+struct ckpt_sigaction {
+	__u64 _sa_handler;
+	__u64 sa_flags;
+	__u64 sa_restorer;
+	struct ckpt_sigset sa_mask;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_sighand {
+	struct ckpt_hdr h;
+	struct ckpt_sigaction action[0];
+} __attribute__((aligned(8)));
 
 /* ipc commons */
 struct ckpt_hdr_ipcns {
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 9743866..d75f753 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -114,6 +114,8 @@ static void fill_kernel_const(struct ckpt_const *h)
 	h->task_comm_len = sizeof(tsk->comm);
 	/* mm->saved_auxv size */
 	h->at_vector_size = AT_VECTOR_SIZE;
+	/* signal */
+	h->signal_nsig = _NSIG;
 	/* uts */
 	h->uts_sysname_len = sizeof(uts->sysname);
 	h->uts_nodename_len = sizeof(uts->nodename);
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index 4bc76e0..5927b7b 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -180,6 +180,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct ckpt_hdr_task_objs *h;
 	int files_objref;
 	int mm_objref;
+	int sighand_objref;
 	int ret;
 
 	/*
@@ -218,11 +219,19 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return mm_objref;
 	}
 
+	sighand_objref = checkpoint_obj_sighand(ctx, t);
+	ckpt_debug("sighand: objref %d\n", sighand_objref);
+	if (sighand_objref < 0) {
+		ckpt_err(ctx, sighand_objref, "%(T)sighand_struct\n");
+		return sighand_objref;
+	}
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (!h)
 		return -ENOMEM;
 	h->files_objref = files_objref;
 	h->mm_objref = mm_objref;
+	h->sighand_objref = sighand_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
 
@@ -385,6 +394,9 @@ int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (ret < 0)
 		return ret;
 	ret = ckpt_collect_mm(ctx, t);
+	if (ret < 0)
+		return ret;
+	ret = ckpt_collect_sighand(ctx, t);
 
 	return ret;
 }
@@ -544,10 +556,17 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
+	if (ret < 0)
+		goto out;
 
 	ret = restore_obj_mm(ctx, h->mm_objref);
 	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
+	if (ret < 0)
+		goto out;
 
+	ret = restore_obj_sighand(ctx, h->sighand_objref);
+	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
+ out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index a511fda..c9a667d 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -569,6 +569,9 @@ static int check_kernel_const(struct ckpt_const *h)
 	/* mm->saved_auxv size */
 	if (h->at_vector_size != AT_VECTOR_SIZE)
 		return -EINVAL;
+	/* signal */
+	if (h->signal_nsig != _NSIG)
+		return -EINVAL;
 	/* uts */
 	if (h->uts_sysname_len != sizeof(uts->sysname))
 		return -EINVAL;
diff --git a/kernel/signal.c b/kernel/signal.c
index be447c8..fdd760a 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -30,6 +30,9 @@
 #include <linux/nsproxy.h>
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
+#define CKPT_DFLAG  CKPT_DSYS
+#include <linux/errno.h>
+#include <linux/checkpoint.h>
 
 #include <asm/param.h>
 #include <asm/uaccess.h>
@@ -2735,7 +2738,183 @@ __attribute__((weak)) const char *arch_vma_name(struct vm_area_struct *vma)
 	return NULL;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
+{
+	memcpy(&h->sigset, sigset, sizeof(*sigset));
+}
+
+static inline void load_sigset(sigset_t *sigset, struct ckpt_sigset *h)
+{
+	memcpy(sigset, &h->sigset, sizeof(*sigset));
+}
+
+/***********************************************************************
+ * sighand checkpoint/collect/restart
+ */
+
+static int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct sighand_struct *sighand = ptr;
+	struct ckpt_hdr_sighand *h;
+	struct ckpt_sigaction *hh;
+	struct sigaction *sa;
+	int i, ret;
+
+	h = ckpt_hdr_get_type(ctx, _NSIG * sizeof(*hh) + sizeof(*h),
+			      CKPT_HDR_SIGHAND);
+	if (!h)
+		return -ENOMEM;
+
+	hh = h->action;
+	spin_lock_irq(&sighand->siglock);
+	for (i = 0; i < _NSIG; i++) {
+		sa = &sighand->action[i].sa;
+		hh[i]._sa_handler = (unsigned long) sa->sa_handler;
+		hh[i].sa_flags = sa->sa_flags;
+		hh[i].sa_restorer = (unsigned long) sa->sa_restorer;
+		fill_sigset(&hh[i].sa_mask, &sa->sa_mask);
+	}
+	spin_unlock_irq(&sighand->siglock);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct sighand_struct *sighand;
+	int objref;
+
+	read_lock(&tasklist_lock);
+	sighand = rcu_dereference(t->sighand);
+	atomic_inc(&sighand->count);
+	read_unlock(&tasklist_lock);
+
+	objref = checkpoint_obj(ctx, sighand, CKPT_OBJ_SIGHAND);
+	__cleanup_sighand(sighand);
+
+	return objref;
+}
+
+int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct sighand_struct *sighand;
+	int ret;
+
+	read_lock(&tasklist_lock);
+	sighand = rcu_dereference(t->sighand);
+	atomic_inc(&sighand->count);
+	read_unlock(&tasklist_lock);
+
+	ret = ckpt_obj_collect(ctx, sighand, CKPT_OBJ_SIGHAND);
+	__cleanup_sighand(sighand);
+
+	return ret;
+}
+
+static void *restore_sighand(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_sighand *h;
+	struct ckpt_sigaction *hh;
+	struct sighand_struct *sighand;
+	struct sigaction *sa;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, _NSIG * sizeof(*hh) + sizeof(*h),
+			       CKPT_HDR_SIGHAND);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	sighand = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
+	if (!sighand) {
+		sighand = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	atomic_set(&sighand->count, 1);
+
+	hh = h->action;
+	for (i = 0; i < _NSIG; i++) {
+		sa = &sighand->action[i].sa;
+		sa->sa_handler = (void *) (unsigned long) hh[i]._sa_handler;
+		sa->sa_flags = hh[i].sa_flags;
+		sa->sa_restorer = (void *) (unsigned long) hh[i].sa_restorer;
+		load_sigset(&sa->sa_mask, &hh[i].sa_mask);
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	return (void *) sighand;
+}
+
+int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
+{
+	struct sighand_struct *sighand;
+	struct sighand_struct *old_sighand;
+
+	sighand = ckpt_obj_fetch(ctx, sighand_objref, CKPT_OBJ_SIGHAND);
+	if (IS_ERR(sighand))
+		return PTR_ERR(sighand);
+
+	if (sighand == current->sighand)
+		return 0;
+
+	atomic_inc(&sighand->count);
+
+	/* manipulate tsk->sighand with tasklist lock write-held */
+	write_lock_irq(&tasklist_lock);
+	old_sighand = rcu_dereference(current->sighand);
+	spin_lock(&old_sighand->siglock);
+	rcu_assign_pointer(current->sighand, sighand);
+	spin_unlock(&old_sighand->siglock);
+	write_unlock_irq(&tasklist_lock);
+	__cleanup_sighand(old_sighand);
+
+	return 0;
+}
+
+/*
+ * signal-related checkpoint objects
+ */
+
+static int obj_sighand_grab(void *ptr)
+{
+	atomic_inc(&((struct sighand_struct *) ptr)->count);
+	return 0;
+}
+
+static void obj_sighand_drop(void *ptr, int lastref)
+{
+	__cleanup_sighand((struct sighand_struct *) ptr);
+}
+
+static int obj_sighand_users(void *ptr)
+{
+	return atomic_read(&((struct sighand_struct *) ptr)->count);
+}
+
+/* sighand object */
+static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
+	.obj_name = "SIGHAND",
+	.obj_type = CKPT_OBJ_SIGHAND,
+	.ref_drop = obj_sighand_drop,
+	.ref_grab = obj_sighand_grab,
+	.ref_users = obj_sighand_users,
+	.checkpoint = checkpoint_sighand,
+	.restore = restore_sighand,
+};
+
+static int __init checkpoint_register_signal(void)
+{
+	return register_checkpoint_obj(&ckpt_obj_sighand_ops);
+}
+#endif /* CONFIG_CHECKPOINT */
+
 void __init signals_init(void)
 {
 	sigqueue_cachep = KMEM_CACHE(sigqueue, SLAB_PANIC);
+#ifdef CONFIG_CHECKPOINT
+	checkpoint_register_signal();
+#endif
 }
-- 
1.6.3.3
