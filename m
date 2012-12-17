From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 6/9] pidns: move next_tgid to kernel/pid.c
Date: Mon, 17 Dec 2012 14:43:32 +0800
Message-ID: <1355726615-15224-7-git-send-email-gaofeng__26137.1255423457$1355726690$gmane$org@cn.fujitsu.com>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355726615-15224-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup will use next_tgid to iterate tasks in pid namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/proc/base.c        |   43 -------------------------------------------
 include/linux/sched.h |    8 ++++++++
 kernel/pid.c          |   39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 43 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 144a967..868c4ed 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2795,49 +2795,6 @@ out:
 	return result;
 }
 
-/*
- * Find the first task with tgid >= tgid
- *
- */
-struct tgid_iter {
-	unsigned int tgid;
-	struct task_struct *task;
-};
-static struct tgid_iter next_tgid(struct pid_namespace *ns, struct tgid_iter iter)
-{
-	struct pid *pid;
-
-	if (iter.task)
-		put_task_struct(iter.task);
-	rcu_read_lock();
-retry:
-	iter.task = NULL;
-	pid = find_ge_pid(iter.tgid, ns);
-	if (pid) {
-		iter.tgid = pid_nr_ns(pid, ns);
-		iter.task = pid_task(pid, PIDTYPE_PID);
-		/* What we to know is if the pid we have find is the
-		 * pid of a thread_group_leader.  Testing for task
-		 * being a thread_group_leader is the obvious thing
-		 * todo but there is a window when it fails, due to
-		 * the pid transfer logic in de_thread.
-		 *
-		 * So we perform the straight forward test of seeing
-		 * if the pid we have found is the pid of a thread
-		 * group leader, and don't worry if the task we have
-		 * found doesn't happen to be a thread group leader.
-		 * As we don't care in the case of readdir.
-		 */
-		if (!iter.task || !has_group_leader_pid(iter.task)) {
-			iter.tgid += 1;
-			goto retry;
-		}
-		get_task_struct(iter.task);
-	}
-	rcu_read_unlock();
-	return iter;
-}
-
 #define TGID_OFFSET (FIRST_PROCESS_ENTRY + ARRAY_SIZE(proc_base_stuff))
 
 static int proc_pid_fill_cache(struct file *filp, void *dirent, filldir_t filldir,
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0dd42a0..9fde2ed 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2128,6 +2128,14 @@ extern struct task_struct *find_task_by_vpid(pid_t nr);
 extern struct task_struct *find_task_by_pid_ns(pid_t nr,
 		struct pid_namespace *ns);
 
+struct tgid_iter {
+	unsigned int tgid;
+	struct task_struct *task;
+};
+
+extern struct tgid_iter next_tgid(struct pid_namespace *ns,
+				  struct tgid_iter iter);
+
 extern void __set_special_pids(struct pid *pid);
 
 /* per-UID process charging. */
diff --git a/kernel/pid.c b/kernel/pid.c
index aebd4f5..7a1341d 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -538,6 +538,45 @@ struct pid *find_ge_pid(int nr, struct pid_namespace *ns)
 }
 
 /*
+ * Find the first task with tgid >= tgid
+ *
+ */
+struct tgid_iter next_tgid(struct pid_namespace *ns, struct tgid_iter iter)
+{
+	struct pid *pid;
+
+	if (iter.task)
+		put_task_struct(iter.task);
+	rcu_read_lock();
+retry:
+	iter.task = NULL;
+	pid = find_ge_pid(iter.tgid, ns);
+	if (pid) {
+		iter.tgid = pid_nr_ns(pid, ns);
+		iter.task = pid_task(pid, PIDTYPE_PID);
+		/* What we to know is if the pid we have find is the
+		 * pid of a thread_group_leader.  Testing for task
+		 * being a thread_group_leader is the obvious thing
+		 * todo but there is a window when it fails, due to
+		 * the pid transfer logic in de_thread.
+		 *
+		 * So we perform the straight forward test of seeing
+		 * if the pid we have found is the pid of a thread
+		 * group leader, and don't worry if the task we have
+		 * found doesn't happen to be a thread group leader.
+		 * As we don't care in the case of readdir.
+		 */
+		if (!iter.task || !has_group_leader_pid(iter.task)) {
+			iter.tgid += 1;
+			goto retry;
+		}
+		get_task_struct(iter.task);
+	}
+	rcu_read_unlock();
+	return iter;
+}
+
+/*
  * The pid hash table is scaled according to the amount of memory in the
  * machine.  From a minimum of 16 slots up to 4096 slots at one gigabyte or
  * more.
-- 
1.7.7.6
