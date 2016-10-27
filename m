From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH v2] mm: Add a user_ns owner to mm_struct and fix
	ptrace permission checks
Date: Thu, 27 Oct 2016 10:54:34 -0500
Message-ID: <87d1ilrdmt.fsf_-___161.35909031636$1477583860$gmane$org@xmission.com>
References: <20161024105959.GQ1847@uranus.lan> <8760oh8tbp.fsf@xmission.com>
	<20161024202925.GS1847@uranus.lan>
	<CAGXu5jK4p4bbQU1Bu-p9aM1GJ+CAR-FAHZcXXRH0De_M4VQ3wA@mail.gmail.com>
	<8760oh737b.fsf@xmission.com> <20161025090213.GX1847@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161025090213.GX1847-ZmlpmtaulQd+urZeOPWqwQ@public.gmane.org> (Cyrill Gorcunov's message of
	"Tue, 25 Oct 2016 12:02:13 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andrey Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
List-Id: containers.vger.kernel.org


During exec dumpable is cleared if the file that is being executed is
not readable by the user executing the file.  A bug in
ptrace_may_access allows reading the file if the executable happens to
enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).

This problem is fixed with only necessary userspace breakage by adding
a user namespace owner to mm_struct, captured at the time of exec, so
it is clear in which user namespace CAP_SYS_PTRACE must be present in
to be able to safely give read permission to the executable.

The function ptrace_may_access is modified to verify that the ptracer
has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
This ensures that if the task changes it's cred into a subordinate
user namespace it does not become ptraceable.

The function ptrace_attach is modified to only set PT_PTRACE_CAP when
CAP_SYS_PTRACE is held over task->mm->user_ns.  The intent of
PT_PTRACE_CAP is to be a flag to note that whatever permission changes
the task might go through the tracer has sufficient permissions for
it not to be an issue.  task->cred->user_ns is always the same
as or descendent of mm->user_ns.  Which guarantees that having
CAP_SYS_PTRACE over mm->user_ns is the worst case for the tasks
credentials.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Fixes: 8409cca70561 ("userns: allow ptrace from non-init user namespaces")
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

Jann or anyone who looked at my last version of this that I thought
was ready to go, I have change the test in ptrace_may_access from:
	if (!mm ||
	    ((get_dumpable(mm) != SUID_DUMP_USER) &&
	     !ptrace_has_cap(mm->user_ns, mode)))
	    return -EPERM;
to:
	if (mm &&
	    ((get_dumpable(mm) != SUID_DUMP_USER) &&
	     !ptrace_has_cap(mm->user_ns, mode)))
	    return -EPERM;

As enforcing the dumpablity check without an mm caused a regression for
Cyrill (he could not read task->exit code of a zomebie even with a full
set of caps).

Further I have moved the setting of PT_PTRACE_CAP up in ptrace_attach
so that I can easily use the mm->user_ns.

I can't imagine either of these changes making a practical difference
to anyone but I am calling them out in case someone can.

 include/linux/mm_types.h |  1 +
 kernel/fork.c            |  9 ++++++---
 kernel/ptrace.c          | 26 +++++++++++---------------
 mm/init-mm.c             |  2 ++
 4 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4a8acedf4b7d..08d947fc4c59 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -473,6 +473,7 @@ struct mm_struct {
 	 */
 	struct task_struct __rcu *owner;
 #endif
+	struct user_namespace *user_ns;
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
 	struct file __rcu *exe_file;
diff --git a/kernel/fork.c b/kernel/fork.c
index 623259fc794d..fd85c68c2791 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -742,7 +742,8 @@ static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
 #endif
 }
 
-static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
+static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
+	struct user_namespace *user_ns)
 {
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
@@ -782,6 +783,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	if (init_new_context(p, mm))
 		goto fail_nocontext;
 
+	mm->user_ns = get_user_ns(user_ns);
 	return mm;
 
 fail_nocontext:
@@ -827,7 +829,7 @@ struct mm_struct *mm_alloc(void)
 		return NULL;
 
 	memset(mm, 0, sizeof(*mm));
-	return mm_init(mm, current);
+	return mm_init(mm, current, current_user_ns());
 }
 
 /*
@@ -842,6 +844,7 @@ void __mmdrop(struct mm_struct *mm)
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
+	put_user_ns(mm->user_ns);
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
@@ -1123,7 +1126,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 
 	memcpy(mm, oldmm, sizeof(*mm));
 
-	if (!mm_init(mm, tsk))
+	if (!mm_init(mm, tsk, mm->user_ns))
 		goto fail_nomem;
 
 	err = dup_mmap(mm, oldmm);
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 2a99027312a6..44a25a1e6e83 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -220,7 +220,7 @@ static int ptrace_has_cap(struct user_namespace *ns, unsigned int mode)
 static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 {
 	const struct cred *cred = current_cred(), *tcred;
-	int dumpable = 0;
+	struct mm_struct *mm;
 	kuid_t caller_uid;
 	kgid_t caller_gid;
 
@@ -271,16 +271,11 @@ static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 	return -EPERM;
 ok:
 	rcu_read_unlock();
-	smp_rmb();
-	if (task->mm)
-		dumpable = get_dumpable(task->mm);
-	rcu_read_lock();
-	if (dumpable != SUID_DUMP_USER &&
-	    !ptrace_has_cap(__task_cred(task)->user_ns, mode)) {
-		rcu_read_unlock();
-		return -EPERM;
-	}
-	rcu_read_unlock();
+	mm = task->mm;
+	if (mm &&
+	    ((get_dumpable(mm) != SUID_DUMP_USER) &&
+	     !ptrace_has_cap(mm->user_ns, mode)))
+	    return -EPERM;
 
 	return security_ptrace_access_check(task, mode);
 }
@@ -331,6 +326,11 @@ static int ptrace_attach(struct task_struct *task, long request,
 
 	task_lock(task);
 	retval = __ptrace_may_access(task, PTRACE_MODE_ATTACH_REALCREDS);
+	if (!retval) {
+		struct mm_struct *mm = task->mm;
+		if (mm && ns_capable(mm->user_ns, CAP_SYS_PTRACE))
+			flags |= PT_PTRACE_CAP;
+	}
 	task_unlock(task);
 	if (retval)
 		goto unlock_creds;
@@ -344,10 +344,6 @@ static int ptrace_attach(struct task_struct *task, long request,
 
 	if (seize)
 		flags |= PT_SEIZED;
-	rcu_read_lock();
-	if (ns_capable(__task_cred(task)->user_ns, CAP_SYS_PTRACE))
-		flags |= PT_PTRACE_CAP;
-	rcu_read_unlock();
 	task->ptrace = flags;
 
 	__ptrace_link(task, current);
diff --git a/mm/init-mm.c b/mm/init-mm.c
index a56a851908d2..975e49f00f34 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -6,6 +6,7 @@
 #include <linux/cpumask.h>
 
 #include <linux/atomic.h>
+#include <linux/user_namespace.h>
 #include <asm/pgtable.h>
 #include <asm/mmu.h>
 
@@ -21,5 +22,6 @@ struct mm_struct init_mm = {
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
+	.user_ns	= &init_user_ns,
 	INIT_MM_CONTEXT(init_mm)
 };
-- 
2.10.1
