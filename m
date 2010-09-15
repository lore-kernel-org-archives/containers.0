From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 3/3] perf events: Cleanup pid passing
Date: Wed, 15 Sep 2010 10:18:30 +0200
Message-ID: <1284538710.3764.245.camel__4348.3444177129$1284538776$gmane$org@twins>
References: <1284408080-2135-1-git-send-email-matthltc@us.ibm.com>
	<f63454af09fb1915717251570423eb9ddd338340.1284407762.git.matthltc@us.ibm.com>
	<561205417b450b8a4bf7488374541d64b4690431.1284407762.git.matthltc@us.ibm.com>
	<a134e5e392ab0204961fd1a62c84a222bf5874a9.1284407763.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a134e5e392ab0204961fd1a62c84a222bf5874a9.1284407763.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mahesh Salgaonkar <mahesh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Robin Green <greenrd-tZez7oB1z75AfugRpC6u6w@public.gmane.org>, Prasad <prasad-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2010-09-13 at 13:01 -0700, Matt Helsley wrote:
> The kernel perf event creation path shouldn't use find_task_by_vpid()
> because a vpid exists in a specific namespace. find_task_by_vpid() uses
> current's pid namespace which isn't always the correct namespace to use
> for the vpid in all the places perf_event_create_kernel_counter() (and
> thus find_get_context()) is called.
> 
> The goal is to clean up pid namespace handling and prevent bugs like:
> 
>         https://bugzilla.kernel.org/show_bug.cgi?id=17281
> 
> Instead of using pids switch find_get_context() to use task struct
> pointers directly. The syscall is responsible for resolving the pid to
> a task struct. This moves the pid namespace resolution into the syscall
> much like every other syscall that takes pid parameters.


I took the three patches with the following change to this patch:

---
Index: linux-2.6/kernel/perf_event.c
===================================================================
--- linux-2.6.orig/kernel/perf_event.c
+++ linux-2.6/kernel/perf_event.c
@@ -5522,7 +5522,7 @@ SYSCALL_DEFINE5(perf_event_open,
 	struct perf_event_context *ctx;
 	struct file *event_file = NULL;
 	struct file *group_file = NULL;
-	struct task_struct *task;
+	struct task_struct *task = NULL;
 	struct pmu *pmu;
 	int event_fd;
 	int fput_needed = 0;
@@ -5577,14 +5577,12 @@ SYSCALL_DEFINE5(perf_event_open,
 	if ((pmu->task_ctx_nr == perf_sw_context) && group_leader)
 		pmu = group_leader->pmu;
 
+	if (pid != -1)
+		task = find_lively_task_by_vpid(pid);
+
 	/*
 	 * Get the target context (task or percpu):
 	 */
-	if (pid == -1 && cpu != -1)
-		task = NULL;
-	else
-		task = find_lively_task_by_vpid(pid);
-
 	ctx = find_get_context(pmu, task, cpu);
 	if (IS_ERR(ctx)) {
 		err = PTR_ERR(ctx);
