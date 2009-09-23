From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v18 29/80] c/r: Save and restore the [compat_]robust_list
	member of the task struct
Date: Wed, 23 Sep 2009 19:51:09 -0400
Message-ID: <1253749920-18673-30-git-send-email-orenl__37041.2498283715$1253756335$gmane$org@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

These lists record which futexes the task holds. To keep the overhead of
robust futexes low the list is kept in userspace. When the task exits the
kernel carefully walks these lists to recover held futexes that
other tasks may be attempting to acquire with FUTEX_WAIT.

Because they point to userspace memory that is saved/restored by
checkpoint/restart saving the list pointers themselves is safe.

While saving the pointers is safe during checkpoint, restart is tricky
because the robust futex ABI contains provisions for changes based on
checking the size of the list head. So we need to save the length of
the list head too in order to make sure that the kernel used during
restart is capable of handling that ABI. Since there is only one ABI
supported at the moment taking the list head's size is simple. Should
the ABI change we will need to use the same size as specified during
sys_set_robust_list() and hence some new means of determining the length
of this userspace structure in sys_checkpoint would be required.

Rather than rewrite the logic that checks and handles the ABI we reuse
sys_set_robust_list() by factoring out the body of the function and
calling it during restart.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
[orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org: move save/restore code to checkpoint/process.c]
---
 checkpoint/process.c           |   49 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    5 ++++
 include/linux/compat.h         |    3 +-
 include/linux/futex.h          |    1 +
 kernel/futex.c                 |   19 +++++++++-----
 kernel/futex_compat.c          |   13 ++++++++--
 6 files changed, 79 insertions(+), 11 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 62ae72d..2580b31 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -14,10 +14,57 @@
 #include <linux/sched.h>
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
+#include <linux/compat.h>
 #include <linux/poll.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+
+#ifdef CONFIG_FUTEX
+static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
+					struct task_struct *t)
+{
+	/*
+	 * These are __user pointers and thus can be saved without
+	 * the objhash.
+	 */
+	h->robust_futex_list = (unsigned long)t->robust_list;
+	h->robust_futex_head_len = sizeof(*t->robust_list);
+#ifdef CONFIG_COMPAT
+	h->compat_robust_futex_list = ptr_to_compat(t->compat_robust_list);
+	h->compat_robust_futex_head_len = sizeof(*t->compat_robust_list);
+#endif
+}
+
+static void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
+{
+	/* Since we restore the memory map the address remains the same and
+	 * this is safe. This is the same as [compat_]sys_set_robust_list() */
+	if (h->robust_futex_list) {
+		struct robust_list_head __user *rfl;
+		rfl = (void __user *)(unsigned long) h->robust_futex_list;
+		do_set_robust_list(rfl, h->robust_futex_head_len);
+	}
+#ifdef CONFIG_COMPAT
+	if (h->compat_robust_futex_list) {
+		struct compat_robust_list_head __user *crfl;
+		crfl = compat_ptr(h->compat_robust_futex_list);
+		do_compat_set_robust_list(crfl, h->compat_robust_futex_head_len);
+	}
+#endif
+}
+#else /* !CONFIG_FUTEX */
+static inline void save_task_robust_futex_list(struct ckpt_hdr_task *h,
+					       struct task_struct *t)
+{
+}
+
+static inline void restore_task_robust_futex_list(struct ckpt_hdr_task *h)
+{
+}
+#endif /* CONFIG_FUTEX */
+
+
 /***********************************************************************
  * Checkpoint
  */
@@ -46,6 +93,7 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 
 		h->set_child_tid = (unsigned long) t->set_child_tid;
 		h->clear_child_tid = (unsigned long) t->clear_child_tid;
+		save_task_robust_futex_list(h, t);
 	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -250,6 +298,7 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 			(int __user *) (unsigned long) h->set_child_tid;
 		t->clear_child_tid =
 			(int __user *) (unsigned long) h->clear_child_tid;
+		restore_task_robust_futex_list(h);
 	}
 
 	memset(t->comm, 0, TASK_COMM_LEN);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 8ae3bbe..b56fe71 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -136,6 +136,11 @@ struct ckpt_hdr_task {
 
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
+
+	__u32 compat_robust_futex_head_len;
+	__u32 compat_robust_futex_list; /* a compat __user ptr */
+	__u32 robust_futex_head_len;
+	__u64 robust_futex_list; /* a __user ptr */
 } __attribute__((aligned(8)));
 
 /* restart blocks */
diff --git a/include/linux/compat.h b/include/linux/compat.h
index af931ee..f444cf0 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -165,7 +165,8 @@ struct compat_robust_list_head {
 };
 
 extern void compat_exit_robust_list(struct task_struct *curr);
-
+extern long do_compat_set_robust_list(struct compat_robust_list_head __user *head,
+				      compat_size_t len);
 asmlinkage long
 compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
 			   compat_size_t len);
diff --git a/include/linux/futex.h b/include/linux/futex.h
index 4326f81..2e126a9 100644
--- a/include/linux/futex.h
+++ b/include/linux/futex.h
@@ -185,6 +185,7 @@ union futex_key {
 #define FUTEX_KEY_INIT (union futex_key) { .both = { .ptr = NULL } }
 
 #ifdef CONFIG_FUTEX
+extern long do_set_robust_list(struct robust_list_head __user *head, size_t len);
 extern void exit_robust_list(struct task_struct *curr);
 extern void exit_pi_state_list(struct task_struct *curr);
 extern int futex_cmpxchg_enabled;
diff --git a/kernel/futex.c b/kernel/futex.c
index def86c8..1ef7c8e 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -2278,13 +2278,7 @@ out:
  * the list. There can only be one such pending lock.
  */
 
-/**
- * sys_set_robust_list - set the robust-futex list head of a task
- * @head: pointer to the list-head
- * @len: length of the list-head, as userspace expects
- */
-SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
-		size_t, len)
+long do_set_robust_list(struct robust_list_head __user *head, size_t len)
 {
 	if (!futex_cmpxchg_enabled)
 		return -ENOSYS;
@@ -2300,6 +2294,17 @@ SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
 }
 
 /**
+ * sys_set_robust_list - set the robust-futex list head of a task
+ * @head: pointer to the list-head
+ * @len: length of the list-head, as userspace expects
+ */
+SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
+		size_t, len)
+{
+	return do_set_robust_list(head, len);
+}
+
+/**
  * sys_get_robust_list - get the robust-futex list head of a task
  * @pid: pid of the process [zero for current task]
  * @head_ptr: pointer to a list-head pointer, the kernel fills it in
diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
index 2357165..5e1a169 100644
--- a/kernel/futex_compat.c
+++ b/kernel/futex_compat.c
@@ -114,9 +114,9 @@ void compat_exit_robust_list(struct task_struct *curr)
 	}
 }
 
-asmlinkage long
-compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
-			   compat_size_t len)
+long
+do_compat_set_robust_list(struct compat_robust_list_head __user *head,
+			  compat_size_t len)
 {
 	if (!futex_cmpxchg_enabled)
 		return -ENOSYS;
@@ -130,6 +130,13 @@ compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
 }
 
 asmlinkage long
+compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
+			   compat_size_t len)
+{
+	return do_compat_set_robust_list(head, len);
+}
+
+asmlinkage long
 compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
 			   compat_size_t __user *len_ptr)
 {
-- 
1.6.0.4
