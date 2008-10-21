From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 3/4] freezer_cg: use thaw_process() in unfreeze_cgroup()
Date: Tue, 21 Oct 2008 13:58:13 -0700
Message-ID: <20081021135813.e77d3015.akpm__46903.4241083593$1224622838$gmane$org@linux-foundation.org>
References: <48FD26F5.1070809@cn.fujitsu.com> <48FD273F.3040505@cn.fujitsu.com>
	<48FD2784.30906@cn.fujitsu.com> <48FD81B8.5030103@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FD81B8.5030103-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 21 Oct 2008 09:16:08 +0200
Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:

> Li Zefan wrote:
> > Don't duplicate the implementation of thaw_process().
> 
> looks OK but you should remove  __thaw_process() which is unused 
> now.

It's called by thaw_process().

But that's the only callsite, I believe, so...

--- a/include/linux/freezer.h~freezer_cg-use-thaw_process-in-unfreeze_cgroup-fix
+++ a/include/linux/freezer.h
@@ -44,11 +44,6 @@ static inline bool should_send_signal(st
 	return !(p->flags & PF_FREEZER_NOSIG);
 }
 
-/*
- * Wake up a frozen process
- */
-extern int __thaw_process(struct task_struct *p);
-
 /* Takes and releases task alloc lock using task_lock() */
 extern int thaw_process(struct task_struct *p);
 
diff -puN kernel/freezer.c~freezer_cg-use-thaw_process-in-unfreeze_cgroup-fix kernel/freezer.c
--- a/kernel/freezer.c~freezer_cg-use-thaw_process-in-unfreeze_cgroup-fix
+++ a/kernel/freezer.c
@@ -121,16 +121,7 @@ void cancel_freezing(struct task_struct 
 	}
 }
 
-/*
- * Wake up a frozen process
- *
- * task_lock() is needed to prevent the race with refrigerator() which may
- * occur if the freezing of tasks fails.  Namely, without the lock, if the
- * freezing of tasks failed, thaw_tasks() might have run before a task in
- * refrigerator() could call frozen_process(), in which case the task would be
- * frozen and no one would thaw it.
- */
-int __thaw_process(struct task_struct *p)
+static int __thaw_process(struct task_struct *p)
 {
 	if (frozen(p)) {
 		p->flags &= ~PF_FROZEN;
@@ -140,6 +131,15 @@ int __thaw_process(struct task_struct *p
 	return 0;
 }
 
+/*
+ * Wake up a frozen process
+ *
+ * task_lock() is needed to prevent the race with refrigerator() which may
+ * occur if the freezing of tasks fails.  Namely, without the lock, if the
+ * freezing of tasks failed, thaw_tasks() might have run before a task in
+ * refrigerator() could call frozen_process(), in which case the task would be
+ * frozen and no one would thaw it.
+ */
 int thaw_process(struct task_struct *p)
 {
 	task_lock(p);
_
