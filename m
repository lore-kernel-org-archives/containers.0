From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 1/3] Pid ns helpers for signals
Date: Wed, 29 Aug 2007 23:19:10 -0700
Message-ID: <20070830061910.GA29340@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH] Pid namespace helpers for signals.

Define some helper functions that will be used to implement signal
semantics with multiple pid namespaces. 

	ancestor_pid_ns(ns1, ns2):
		TRUE if @ns1 is an ancestor of @ns2.

	descendant_pid_ns(ns1, ns2):
		TRUE if @ns1 is an descendant of @ns2.

		(Note that "not an ancestor" does not mean descendant and
		vice versa - could be a cousin)

	pid_ns_equal(tsk)
		TRUE if active pid ns of @tsk is same as active pid ns of
		caller.  

This patch also extends task_active_pid_ns() to try to return the pid ns
of processes that have exited but not been reaped. Appreciate comments
on that :-)

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/pid.h           |    5 +++
 include/linux/pid_namespace.h |   13 +++++++-
 include/linux/sched.h         |   17 +++++++++++
 kernel/pid.c                  |   64 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 98 insertions(+), 1 deletion(-)

Index: 2.6.23-rc3-mm1/kernel/pid.c
===================================================================
--- 2.6.23-rc3-mm1.orig/kernel/pid.c	2007-08-28 22:59:13.000000000 -0700
+++ 2.6.23-rc3-mm1/kernel/pid.c	2007-08-29 22:55:39.000000000 -0700
@@ -199,6 +199,70 @@ static int next_pidmap(struct pid_namesp
 	return -1;
 }
 
+/*
+ * Return TRUE if pid namespace @ns1 is an ancestor of pid namespace @ns2.
+ * Return FALSE otherwise (Eg: @ns1 is either a descendant or a distant
+ * cousin of @ns2)
+ */
+static int ancestor_pid_ns(struct pid_namespace *ns1, struct pid_namespace *ns2)
+{
+	int i;
+	struct pid_namespace *tmp;
+
+	if (ns1 == NULL || ns2 == NULL)
+		return 0;
+
+	if (ns1->level >= ns2->level)
+		return 0;
+
+	tmp = ns2->parent;
+	for (i = tmp->level; i >= ns1->level; i--) {
+		if (tmp == ns1)
+			return 1;
+		tmp = tmp->parent;
+	}
+
+	return 0;
+}
+
+/*
+ * Return TRUE if pid namespace @ns1 is a descendant of pid namespace
+ * of @ns2. Return FALSE otherwise (Eg: @ns1 is either in an ancestor
+ * or a distant cousin of @ns2).
+ */
+static int descendant_pid_ns(struct pid_namespace *ns1,
+			     struct pid_namespace *ns2)
+{
+	int i;
+	struct pid_namespace *tmp;
+
+	if (ns1 == NULL || ns2 == NULL)
+		return 0;
+
+	if (ns1->level < ns2->level)
+		return 0;
+
+	tmp = ns1;
+	for (i = tmp->level; i >= ns2->level; i--) {
+		if (tmp == ns2)
+			return 1;
+		tmp = tmp->parent;
+	}
+	return 0;
+}
+
+int task_ancestor_pid_ns(struct task_struct *tsk1, struct task_struct *tsk2)
+{
+	return ancestor_pid_ns(task_active_pid_ns(tsk1),
+			       task_active_pid_ns(tsk2));
+}
+
+int task_descendant_pid_ns(struct task_struct *tsk1, struct task_struct *tsk2)
+{
+	return descendant_pid_ns(task_active_pid_ns(tsk1),
+				 task_active_pid_ns(tsk2));
+}
+
 fastcall void put_pid(struct pid *pid)
 {
 	struct pid_namespace *ns;
Index: 2.6.23-rc3-mm1/include/linux/pid.h
===================================================================
--- 2.6.23-rc3-mm1.orig/include/linux/pid.h	2007-08-28 23:00:24.000000000 -0700
+++ 2.6.23-rc3-mm1/include/linux/pid.h	2007-08-29 17:36:00.000000000 -0700
@@ -99,6 +99,11 @@ extern void FASTCALL(transfer_pid(struct
 struct pid_namespace;
 extern struct pid_namespace init_pid_ns;
 
+extern int task_ancestor_pid_ns(struct task_struct *tsk1,
+				struct task_struct *tsk2);
+extern int task_descendant_pid_ns(struct task_struct *tsk1,
+				  struct task_struct *tsk2);
+
 /*
  * look up a PID in the hash table. Must be called with the tasklist_lock
  * or rcu_read_lock() held.
Index: 2.6.23-rc3-mm1/include/linux/sched.h
===================================================================
--- 2.6.23-rc3-mm1.orig/include/linux/sched.h	2007-08-27 20:04:23.000000000 -0700
+++ 2.6.23-rc3-mm1/include/linux/sched.h	2007-08-28 23:12:54.000000000 -0700
@@ -1290,6 +1290,23 @@ static inline pid_t task_ppid_nr_ns(stru
 	return pid_nr_ns(task_pid(rcu_dereference(tsk->real_parent)), ns);
 }
 
+static inline struct pid_namespace *pid_active_ns(struct pid *pid)
+{
+       if (pid == NULL)
+               return NULL;
+
+       return pid->numbers[pid->level].ns;
+}
+
+/*
+ * Return TRUE if the active pid namespace of @tsk is same as active
+ * pid namespace of 'current'
+ */
+static inline int pid_ns_equal(struct task_struct *tsk)
+{
+       return pid_active_ns(task_pid(tsk)) == pid_active_ns(task_pid(current));
+}
+
 /**
  * pid_alive - check that a task structure is not stale
  * @p: Task structure to be checked.
Index: 2.6.23-rc3-mm1/include/linux/pid_namespace.h
===================================================================
--- 2.6.23-rc3-mm1.orig/include/linux/pid_namespace.h	2007-08-27 20:04:23.000000000 -0700
+++ 2.6.23-rc3-mm1/include/linux/pid_namespace.h	2007-08-29 23:00:38.000000000 -0700
@@ -47,7 +47,18 @@ static inline void put_pid_ns(struct pid
 
 static inline struct pid_namespace *task_active_pid_ns(struct task_struct *tsk)
 {
-	return tsk->nsproxy->pid_ns;
+	/*
+	 * If task still has its namespaces (i.e it is not exiting)
+	 * get the pid ns from nsproxy.
+	 */
+	if (tsk->nsproxy)
+		return tsk->nsproxy->pid_ns;
+
+	/*
+	 * If it is exiting but has not been reaped, get pid ns from
+	 * pid->numbers[]. Otherwise return NULL.
+	 */
+	return pid_active_ns(task_pid(tsk));
 }
 
 static inline struct task_struct *task_child_reaper(struct task_struct *tsk)
