From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] ptrace fix for v4.12-rc3
Date: Wed, 24 May 2017 03:54:20 -0500
Message-ID: <878tlmeitf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: c70d9d809fdeecedb96972457ee45c49a232d97f ptrace: Properly initialize ptracer_cred on fork

This fixes a brown paper bag bug.  When I fixed the ptrace interaction
with user namespaces I added a new field ptracer_cred in struct_task
and I failed to properly initialize it on fork.

This dangling pointer wound up breaking runing setuid applications run from
the enlightenment window manager.

As this is the worst sort of bug.  A regression breaking user space for
no good reason let's get this fixed.

Eric

Eric W. Biederman (1):
      ptrace: Properly initialize ptracer_cred on fork

 include/linux/ptrace.h |  7 +++++--
 kernel/ptrace.c        | 20 +++++++++++++-------
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index 422bc2e4cb6a..ef3eb8bbfee4 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -54,7 +54,8 @@ extern int ptrace_request(struct task_struct *child, long request,
 			  unsigned long addr, unsigned long data);
 extern void ptrace_notify(int exit_code);
 extern void __ptrace_link(struct task_struct *child,
-			  struct task_struct *new_parent);
+			  struct task_struct *new_parent,
+			  const struct cred *ptracer_cred);
 extern void __ptrace_unlink(struct task_struct *child);
 extern void exit_ptrace(struct task_struct *tracer, struct list_head *dead);
 #define PTRACE_MODE_READ	0x01
@@ -206,7 +207,7 @@ static inline void ptrace_init_task(struct task_struct *child, bool ptrace)
 
 	if (unlikely(ptrace) && current->ptrace) {
 		child->ptrace = current->ptrace;
-		__ptrace_link(child, current->parent);
+		__ptrace_link(child, current->parent, current->ptracer_cred);
 
 		if (child->ptrace & PT_SEIZED)
 			task_set_jobctl_pending(child, JOBCTL_TRAP_STOP);
@@ -215,6 +216,8 @@ static inline void ptrace_init_task(struct task_struct *child, bool ptrace)
 
 		set_tsk_thread_flag(child, TIF_SIGPENDING);
 	}
+	else
+		child->ptracer_cred = NULL;
 }
 
 /**
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 266ddcc1d8bb..60f356d91060 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -60,19 +60,25 @@ int ptrace_access_vm(struct task_struct *tsk, unsigned long addr,
 }
 
 
+void __ptrace_link(struct task_struct *child, struct task_struct *new_parent,
+		   const struct cred *ptracer_cred)
+{
+	BUG_ON(!list_empty(&child->ptrace_entry));
+	list_add(&child->ptrace_entry, &new_parent->ptraced);
+	child->parent = new_parent;
+	child->ptracer_cred = get_cred(ptracer_cred);
+}
+
 /*
  * ptrace a task: make the debugger its new parent and
  * move it to the ptrace list.
  *
  * Must be called with the tasklist lock write-held.
  */
-void __ptrace_link(struct task_struct *child, struct task_struct *new_parent)
+static void ptrace_link(struct task_struct *child, struct task_struct *new_parent)
 {
-	BUG_ON(!list_empty(&child->ptrace_entry));
-	list_add(&child->ptrace_entry, &new_parent->ptraced);
-	child->parent = new_parent;
 	rcu_read_lock();
-	child->ptracer_cred = get_cred(__task_cred(new_parent));
+	__ptrace_link(child, new_parent, __task_cred(new_parent));
 	rcu_read_unlock();
 }
 
@@ -386,7 +392,7 @@ static int ptrace_attach(struct task_struct *task, long request,
 		flags |= PT_SEIZED;
 	task->ptrace = flags;
 
-	__ptrace_link(task, current);
+	ptrace_link(task, current);
 
 	/* SEIZE doesn't trap tracee on attach */
 	if (!seize)
@@ -459,7 +465,7 @@ static int ptrace_traceme(void)
 		 */
 		if (!ret && !(current->real_parent->flags & PF_EXITING)) {
 			current->ptrace = PT_PTRACED;
-			__ptrace_link(current, current->real_parent);
+			ptrace_link(current, current->real_parent);
 		}
 	}
 	write_unlock_irq(&tasklist_lock);
-- 
2.10.1
