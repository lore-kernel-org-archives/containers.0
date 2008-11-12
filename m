From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 2/3] Generalize task_active_pid_ns()
Date: Tue, 11 Nov 2008 22:44:20 -0800
Message-ID: <20081112064420.GB27806@us.ibm.com>
References: <20081112064139.GA27806@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081112064139.GA27806-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Mon, 10 Nov 2008 19:12:02 -0800
Subject: [PATCH 2/3] pid: Generalize task_active_pid_ns

Currently task_active_pid_ns is not safe to call after a
task becomes a zombie and exit_task_namespaces is called,
as nsproxy becomes NULL.  By reading the pid namespace from
the pid of the task we can trivially solve this problem at
the cost of one extra memory read in what should be the
same cacheline as we read the namespace from.

When moving things around I have made task_active_pid_ns
out of line because keeping it in pid_namespace.h would
require adding includes of pid.h and sched.h that I
don't think we want.

This change does make task_active_pid_ns unsafe to call during
copy_process until we attach a pid on the task_struct which
seems to be a reasonable trade off.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/pid_namespace.h |    6 +-----
 kernel/fork.c                 |    4 ++--
 kernel/pid.c                  |    6 ++++++
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index d82fe82..38d1032 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -79,11 +79,7 @@ static inline void zap_pid_ns_processes(struct pid_namespace *ns)
 }
 #endif /* CONFIG_PID_NS */
 
-static inline struct pid_namespace *task_active_pid_ns(struct task_struct *tsk)
-{
-	return tsk->nsproxy->pid_ns;
-}
-
+extern struct pid_namespace *task_active_pid_ns(struct task_struct *tsk);
 void pidhash_init(void);
 void pidmap_init(void);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index f608356..28be39a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1111,12 +1111,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 	if (pid != &init_struct_pid) {
 		retval = -ENOMEM;
-		pid = alloc_pid(task_active_pid_ns(p));
+		pid = alloc_pid(p->nsproxy->pid_ns);
 		if (!pid)
 			goto bad_fork_cleanup_io;
 
 		if (clone_flags & CLONE_NEWPID) {
-			retval = pid_ns_prepare_proc(task_active_pid_ns(p));
+			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
 			if (retval < 0)
 				goto bad_fork_free_pid;
 		}
diff --git a/kernel/pid.c b/kernel/pid.c
index 064e76a..c5513fe 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -474,6 +474,12 @@ pid_t task_session_nr_ns(struct task_struct *tsk, struct pid_namespace *ns)
 }
 EXPORT_SYMBOL(task_session_nr_ns);
 
+struct pid_namespace *task_active_pid_ns(struct task_struct *tsk)
+{
+	return ns_of_pid(task_pid(tsk));
+}
+EXPORT_SYMBOL_GPL(task_active_pid_ns);
+
 /*
  * Used by proc to find the first pid that is greater then or equal to nr.
  *
-- 
1.5.2.5
