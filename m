From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v21 032/100] c/r: Save and restore the
	[compat_]robust_list member of the task struct
Date: Mon, 3 May 2010 11:02:34 -0700
Message-ID: <20100503180234.GD31830__32623.2092491866$1272918382$gmane$org@count0.beaverton.ibm.com>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
	<1272723382-19470-33-git-send-email-orenl@cs.columbia.edu>
	<4BDEF582.2040806@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BDEF582.2040806-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Darren Hart <dvhltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, May 03, 2010 at 09:10:42AM -0700, Darren Hart wrote:
> Oren Laadan wrote:
> >From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >
> >These lists record which futexes the task holds. To keep the overhead of
> >robust futexes low the list is kept in userspace. When the task exits the
> >kernel carefully walks these lists to recover held futexes that
> >other tasks may be attempting to acquire with FUTEX_WAIT.
> >
> >Because they point to userspace memory that is saved/restored by
> >checkpoint/restart saving the list pointers themselves is safe.
> >
> >While saving the pointers is safe during checkpoint, restart is tricky
> >because the robust futex ABI contains provisions for changes based on
> >checking the size of the list head. So we need to save the length of
> >the list head too in order to make sure that the kernel used during
> >restart is capable of handling that ABI. Since there is only one ABI
> >supported at the moment taking the list head's size is simple. Should
> >the ABI change we will need to use the same size as specified during
> >sys_set_robust_list() and hence some new means of determining the length
> >of this userspace structure in sys_checkpoint would be required.
> >
> >Rather than rewrite the logic that checks and handles the ABI we reuse
> >sys_set_robust_list() by factoring out the body of the function and
> >calling it during restart.
> >
> 
> The approach looks sound to me. I presume there is no way for the
> task to wake and set the robust list to something else after the
> checkpoint has started?

Hi Darren,

	sys_checkpoint verifies that the tasks are frozen in the same
cgroup throughout the checkpoint.

	The cgroup freezer can be in the FROZEN state, which means that
all the tasks in the group are in TASK_UNINTERRUPTIBLE and cannot be
moved out of the group. Leaving the FROZEN state requires writing THAWED
to group/freezer.state and can be done from userspace.

Patch 16 - Adds the CHECKPOINTING cgroup state which ensures that
	   userspace can't move the cgroup out of the frozen state.

Patch 25 - Calls a function to move the cgroup into the CHECKPOINTING
	   state then checks that the tasks to-be-checkpointed share the
	   same freezer cgroup.

Inside do_checkpoint() we have:

+       if (ctx->root_freezer) {
+               ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
+               if (ret < 0)
+                       return ret;
+       }

Inside may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
we check that tasks must be frozen for the duration of checkpoint
by ensuring they are in the same cgroup freezer:

+       /* verify that all tasks belongs to same freezer cgroup */
+       if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
+               _ckpt_err(ctx, -EBUSY, "%(T)Not frozen or wrong cgroup\n");
+               return -EBUSY;
+       }

(Call stack:
	do_checkpoint -> build_tree -> walk_task_subtree
		-> tree_count_tasks -> __tree_count_tasks -> may_checkpoint 
and build_tree() is called after
	cgroup_freezer_begin_checkpoint(ctx->root_freezer))

At the end of do_checkpoint() we have the corresponding:

  out:
+       if (ctx->root_freezer)
+               cgroup_freezer_end_checkpoint(ctx->root_freezer);
        return ret;

> 
> Couple of comments re documentation below.
> 
> Thanks,
> 
> Darren
> 
> >Changelog [v19]:
> >  - Keep __u32s in even groups for 32-64 bit compatibility
> >
> >Cc: Darren Hart <dvhltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> >Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> >Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
> >Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> >Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >---
> > include/linux/checkpoint_hdr.h |    5 ++++
> > include/linux/compat.h         |    3 +-
> > include/linux/futex.h          |    1 +
> > kernel/checkpoint/process.c    |   49 ++++++++++++++++++++++++++++++++++++++++
> > kernel/futex.c                 |   19 +++++++++-----
> > kernel/futex_compat.c          |   13 ++++++++--
> > 6 files changed, 79 insertions(+), 11 deletions(-)
> >
> >diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> >index 68ee0f3..c7d34a6 100644
> >--- a/include/linux/checkpoint_hdr.h
> >+++ b/include/linux/checkpoint_hdr.h
> >@@ -167,6 +167,11 @@ struct ckpt_hdr_task {
> > 	__u32 exit_signal;
> > 	__u32 pdeath_signal;
> >
> >+	__u32 compat_robust_futex_head_len;
> >+	__u32 compat_robust_futex_list; /* a compat __user ptr */
> >+	__u32 robust_futex_head_len;
> >+	__u64 robust_futex_list; /* a __user ptr */
> >+
> > 	__u64 set_child_tid;
> > 	__u64 clear_child_tid;
> > } __attribute__((aligned(8)));
> >diff --git a/include/linux/compat.h b/include/linux/compat.h
> >index 717c691..89125dd 100644
> >--- a/include/linux/compat.h
> >+++ b/include/linux/compat.h
> >@@ -210,7 +210,8 @@ struct compat_robust_list_head {
> > };
> >
> > extern void compat_exit_robust_list(struct task_struct *curr);
> >-
> >+extern long do_compat_set_robust_list(struct compat_robust_list_head __user *head,
> >+				      compat_size_t len);
> > asmlinkage long
> > compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
> > 			   compat_size_t len);
> >diff --git a/include/linux/futex.h b/include/linux/futex.h
> >index ae755f6..c825790 100644
> >--- a/include/linux/futex.h
> >+++ b/include/linux/futex.h
> >@@ -185,6 +185,7 @@ union futex_key {
> > #define FUTEX_KEY_INIT (union futex_key) { .both = { .ptr = NULL } }
> >
> > #ifdef CONFIG_FUTEX
> >+extern long do_set_robust_list(struct robust_list_head __user *head, size_t len);
> > extern void exit_robust_list(struct task_struct *curr);
> > extern void exit_pi_state_list(struct task_struct *curr);
> > extern int futex_cmpxchg_enabled;
> >diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
> >index ce009cb..aabefb6 100644
> >--- a/kernel/checkpoint/process.c
> >+++ b/kernel/checkpoint/process.c
> >@@ -14,9 +14,56 @@
> > #include <linux/sched.h>
> > #include <linux/posix-timers.h>
> > #include <linux/futex.h>
> >+#include <linux/compat.h>
> > #include <linux/poll.h>
> > #include <linux/checkpoint.h>
> >
> >+
> >+#ifdef CONFIG_FUTEX
> >+static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
> >+					struct task_struct *t)
> >+{
> >+	/*
> >+	 * These are __user pointers and thus can be saved without
> >+	 * the objhash.
> >+	 */
> >+	h->robust_futex_list = (unsigned long)t->robust_list;
> >+	h->robust_futex_head_len = sizeof(*t->robust_list);
> >+#ifdef CONFIG_COMPAT
> >+	h->compat_robust_futex_list = ptr_to_compat(t->compat_robust_list);
> >+	h->compat_robust_futex_head_len = sizeof(*t->compat_robust_list);
> >+#endif
> >+}
> >+
> >+static void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
> >+{
> >+	/* Since we restore the memory map the address remains the same and
> >+	 * this is safe. This is the same as [compat_]sys_set_robust_list() */
> >+	if (h->robust_futex_list) {
> >+		struct robust_list_head __user *rfl;
> >+		rfl = (void __user *)(unsigned long) h->robust_futex_list;
> >+		do_set_robust_list(rfl, h->robust_futex_head_len);
> >+	}
> >+#ifdef CONFIG_COMPAT
> >+	if (h->compat_robust_futex_list) {
> >+		struct compat_robust_list_head __user *crfl;
> >+		crfl = compat_ptr(h->compat_robust_futex_list);
> >+		do_compat_set_robust_list(crfl, h->compat_robust_futex_head_len);
> >+	}
> >+#endif
> >+}
> >+#else /* !CONFIG_FUTEX */
> >+static inline void save_task_robust_futex_list(struct ckpt_hdr_task *h,
> >+					       struct task_struct *t)
> >+{
> >+}
> >+
> >+static inline void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
> >+{
> >+}
> >+#endif /* CONFIG_FUTEX */
> >+
> >+
> > /***********************************************************************
> >  * Checkpoint
> >  */
> >@@ -45,6 +92,7 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
> >
> > 		h->set_child_tid = (unsigned long) t->set_child_tid;
> > 		h->clear_child_tid = (unsigned long) t->clear_child_tid;
> >+		save_task_robust_futex_list(h, t);
> > 	}
> >
> > 	ret = ckpt_write_obj(ctx, &h->h);
> >@@ -248,6 +296,7 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
> > 			(int __user *) (unsigned long) h->set_child_tid;
> > 		t->clear_child_tid =
> > 			(int __user *) (unsigned long) h->clear_child_tid;
> >+		restore_task_robust_futex_list(h);
> > 	}
> >
> > 	memset(t->comm, 0, TASK_COMM_LEN);
> >diff --git a/kernel/futex.c b/kernel/futex.c
> >index 23419c9..baaecb4 100644
> >--- a/kernel/futex.c
> >+++ b/kernel/futex.c
> >@@ -2342,13 +2342,7 @@ out:
> >  * the list. There can only be one such pending lock.
> >  */
> >
> >-/**
> >- * sys_set_robust_list() - Set the robust-futex list head of a task
> >- * @head:	pointer to the list-head
> >- * @len:	length of the list-head, as userspace expects
> >- */
> >-SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
> >-		size_t, len)
> >+long do_set_robust_list(struct robust_list_head __user *head, size_t len)
> 
> 
> Please provide a full kerneldoc header for the new function.

OK, will do. It'll be almost exactly the same as what precedes the
SYSCALL_DEFINE.

> > {
> > 	if (!futex_cmpxchg_enabled)
> > 		return -ENOSYS;
> >@@ -2364,6 +2358,17 @@ SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
> > }
> >
> > /**
> >+ * sys_set_robust_list() - Set the robust-futex list head of a task
> >+ * @head:	pointer to the list-head
> >+ * @len:	length of the list-head, as userspace expects
> >+ */
> >+SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
> >+		size_t, len)
> >+{
> >+	return do_set_robust_list(head, len);
> >+}
> >+
> >+/**
> >  * sys_get_robust_list() - Get the robust-futex list head of a task
> >  * @pid:	pid of the process [zero for current task]
> >  * @head_ptr:	pointer to a list-head pointer, the kernel fills it in
> >diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
> >index d49afb2..900bb2b 100644
> >--- a/kernel/futex_compat.c
> >+++ b/kernel/futex_compat.c
> >@@ -114,9 +114,9 @@ void compat_exit_robust_list(struct task_struct *curr)
> > 	}
> > }
> >
> >-asmlinkage long
> >-compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
> >-			   compat_size_t len)
> >+long
> >+do_compat_set_robust_list(struct compat_robust_list_head __user *head,
> 
> 
> I know futex_compat.c doesn't have as much kerneldoc as futex.c
> does, but I'd like to see that improved. Please include a kerneldoc
> here too.

OK, sounds good to me.

Thanks for the review!

Cheers,
	-Matt Helsley
