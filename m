From: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/5] pid: add new iterative macros to list processes in a
	namespace
Date: Thu, 18 Dec 2008 22:12:29 +0530
Message-ID: <1229618553-6348-2-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
References: <1229618553-6348-1-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1229618553-6348-1-git-send-email-gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Dave <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Eric <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Below patch addresses a common solution for any place where a process
should be checked if it is associated to caller namespace. At present,
we use 'task_pid_vnr(t) > 0' to further proceed with task 't' in current
namespace.

To avoid applying this check in every userspace code related to PID namespace,
this patch provides two new iterative macros;for_each_process_in_ns and
do_each_thread_in_ns.

Signed-off-by: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 include/linux/pid.h   |    1 +
 include/linux/sched.h |   12 ++++++++++++
 kernel/pid.c          |   17 +++++++++++++++++
 3 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/pid.h b/include/linux/pid.h
index d7e98ff..1c6b24f 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -117,6 +117,7 @@ extern struct pid *find_vpid(int nr);
  */
 extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
+extern struct pid *find_ge_tgid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, int last);
 
 extern struct pid *alloc_pid(struct pid_namespace *ns);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2e46189..bdd9f0d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1919,16 +1919,28 @@ static inline unsigned long wait_task_inactive(struct task_struct *p,
 
 #define next_task(p)	list_entry(rcu_dereference((p)->tasks.next), struct task_struct, tasks)
 
+#define next_task_in_ns(p, ns) \
+	pid_task(find_ge_tgid(task_pid_nr_ns(p, ns) + 1, ns), PIDTYPE_PID)
+
 #define for_each_process(p) \
 	for (p = &init_task ; (p = next_task(p)) != &init_task ; )
 
+#define for_each_process_in_ns(p, ns) \
+	for (p = find_task_by_pid_ns(1, ns) ; p != NULL ; \
+	     p = next_task_in_ns(p, ns))
+
 /*
  * Careful: do_each_thread/while_each_thread is a double loop so
  *          'break' will not work as expected - use goto instead.
+ *          same applies to do_each_thread_in_ns.
  */
 #define do_each_thread(g, t) \
 	for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do
 
+#define do_each_thread_in_ns(g, t, ns) \
+	for (g = t = find_task_by_pid_ns(1, ns) ; g != NULL ; \
+	    (g = t = next_task_in_ns(g, ns))) do
+
 #define while_each_thread(g, t) \
 	while ((t = next_thread(t)) != g)
 
diff --git a/kernel/pid.c b/kernel/pid.c
index 064e76a..15f707a 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -493,6 +493,23 @@ struct pid *find_ge_pid(int nr, struct pid_namespace *ns)
 	return pid;
 }
 
+struct pid *find_ge_tgid(int nr,  struct pid_namespace *ns)
+{
+	struct pid *pid;
+	struct task_struct *task;
+
+retry:
+	pid = find_ge_pid(nr, ns);
+	if (pid) {
+		task = pid_task(pid, PIDTYPE_PID);
+		if (!task || !has_group_leader_pid(task)) {
+			nr += 1;
+			goto retry;
+		}
+	}
+	return pid;
+}
+
 /*
  * The pid hash table is scaled according to the amount of memory in the
  * machine.  From a minimum of 16 slots up to 4096 slots at one gigabyte or
-- 
1.5.5.1
