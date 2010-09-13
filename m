From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] perf events: Split out task search into helper
Date: Mon, 13 Sep 2010 13:01:19 -0700
Message-ID: <561205417b450b8a4bf7488374541d64b4690431.1284407762.git.matthltc__30750.6315097728$1284408165$gmane$org@us.ibm.com>
References: <1284408080-2135-1-git-send-email-matthltc@us.ibm.com>
	<f63454af09fb1915717251570423eb9ddd338340.1284407762.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <f63454af09fb1915717251570423eb9ddd338340.1284407762.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <f63454af09fb1915717251570423eb9ddd338340.1284407762.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <f63454af09fb1915717251570423eb9ddd338340.1284407762.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Mahesh Salgaonkar <mahesh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Robin Green <greenrd-tZez7oB1z75AfugRpC6u6w@public.gmane.org>, Prasad <prasad-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Split out the code which searches for non-exiting tasks into its own
helper. Creating this helper not only makes the code slightly more
readable it prepares to move the search out of find_get_context() in
a subsequent commit.

Cc: Robin Green <greenrd-tZez7oB1z75AfugRpC6u6w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Prasad <prasad-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>
Cc: Mahesh Salgaonkar <mahesh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/perf_event.c |   63 ++++++++++++++++++++++++++++++++------------------
 1 files changed, 40 insertions(+), 23 deletions(-)

diff --git a/kernel/perf_event.c b/kernel/perf_event.c
index 440f9ca..3f5309d 100644
--- a/kernel/perf_event.c
+++ b/kernel/perf_event.c
@@ -2015,6 +2015,43 @@ alloc_perf_context(struct pmu *pmu, struct task_struct *task)
 	return ctx;
 }
 
+static struct task_struct *
+find_lively_task_by_vpid(pid_t vpid)
+{
+	struct task_struct *task;
+	int err;
+
+	rcu_read_lock();
+	if (!vpid)
+		task = current;
+	else
+		task = find_task_by_vpid(vpid);
+	if (task)
+		get_task_struct(task);
+	rcu_read_unlock();
+
+	if (!task)
+		return ERR_PTR(-ESRCH);
+
+	/*
+	 * Can't attach events to a dying task.
+	 */
+	err = -ESRCH;
+	if (task->flags & PF_EXITING)
+		goto errout;
+
+	/* Reuse ptrace permission checks for now. */
+	err = -EACCES;
+	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+		goto errout;
+
+	return task;
+errout:
+	put_task_struct(task);
+	return ERR_PTR(err);
+
+}
+
 static struct perf_event_context *
 find_get_context(struct pmu *pmu, pid_t pid, int cpu)
 {
@@ -2047,29 +2084,9 @@ find_get_context(struct pmu *pmu, pid_t pid, int cpu)
 		return ctx;
 	}
 
-	rcu_read_lock();
-	if (!pid)
-		task = current;
-	else
-		task = find_task_by_vpid(pid);
-	if (task)
-		get_task_struct(task);
-	rcu_read_unlock();
-
-	if (!task)
-		return ERR_PTR(-ESRCH);
-
-	/*
-	 * Can't attach events to a dying task.
-	 */
-	err = -ESRCH;
-	if (task->flags & PF_EXITING)
-		goto errout;
-
-	/* Reuse ptrace permission checks for now. */
-	err = -EACCES;
-	if (!ptrace_may_access(task, PTRACE_MODE_READ))
-		goto errout;
+	task = find_lively_task_by_vpid(pid);
+	if (IS_ERR(task))
+		return (void*)task;
 
 	err = -EINVAL;
 	ctxn = pmu->task_ctx_nr;
-- 
1.6.3.3
