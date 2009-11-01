From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [v10][PATCH 4/9] Add target_pids parameter to alloc_pid()
Date: Sun, 1 Nov 2009 12:44:36 -0800
Message-ID: <20091101204436.GC23168@us.ibm.com>
References: <20091101204132.GA22116@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091101204132.GA22116-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 20 Oct 2009 21:35:07 -0700
Subject: [v10][PATCH 4/9] Add target_pids parameter to alloc_pid()

This parameter is currently NULL, but will be used in a follow-on patch.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/pid.h |    2 +-
 kernel/fork.c       |    3 ++-
 kernel/pid.c        |    9 +++++++--
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/pid.h b/include/linux/pid.h
index 49f1c2f..914185d 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -119,7 +119,7 @@ extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, int last);
 
-extern struct pid *alloc_pid(struct pid_namespace *ns);
+extern struct pid *alloc_pid(struct pid_namespace *ns, pid_t *target_pids);
 extern void free_pid(struct pid *pid);
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index 93626b2..3f1dddf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -980,6 +980,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	int retval;
 	struct task_struct *p;
 	int cgroup_callbacks_done = 0;
+	pid_t *target_pids = NULL;
 
 	if ((clone_flags & (CLONE_NEWNS|CLONE_FS)) == (CLONE_NEWNS|CLONE_FS))
 		return ERR_PTR(-EINVAL);
@@ -1156,7 +1157,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		goto bad_fork_cleanup_io;
 
 	if (pid != &init_struct_pid) {
-		pid = alloc_pid(p->nsproxy->pid_ns);
+		pid = alloc_pid(p->nsproxy->pid_ns, target_pids);
 		if (IS_ERR(pid)) {
 			retval = PTR_ERR(pid);
 			goto bad_fork_cleanup_io;
diff --git a/kernel/pid.c b/kernel/pid.c
index c849327..7c73096 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -281,13 +281,14 @@ void free_pid(struct pid *pid)
 	call_rcu(&pid->rcu, delayed_put_pid);
 }
 
-struct pid *alloc_pid(struct pid_namespace *ns)
+struct pid *alloc_pid(struct pid_namespace *ns, pid_t *target_pids)
 {
 	struct pid *pid;
 	enum pid_type type;
 	int i, nr;
 	struct pid_namespace *tmp;
 	struct upid *upid;
+	pid_t tpid;
 
 	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
 	if (!pid) {
@@ -297,7 +298,11 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 
 	tmp = ns;
 	for (i = ns->level; i >= 0; i--) {
-		nr = alloc_pidmap(tmp);
+		tpid = 0;
+		if (target_pids)
+			tpid = target_pids[i];
+
+		nr = set_pidmap(tmp, tpid);
 		if (nr < 0)
 			goto out_free;
 
-- 
1.6.0.4
