From: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Subject: [PATCH 20/20] Remove the struct pid unneeded fields
Date: Tue, 07 Aug 2007 13:30:14 +0400
Message-ID: <46B83BA6.mailG6N11ISBM@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Since we've switched from using pid->nr to pid->upids->nr some
fields on struct pid are no longer needed

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

 include/linux/init_task.h |    3 ---
 include/linux/pid.h       |    3 ---
 kernel/pid.c              |    1 -
 3 files changed, 7 deletions(-)

--- ./include/linux/init_task.h.ve17	2007-08-06 14:14:02.000000000 +0400
+++ ./include/linux/init_task.h	2007-08-06 14:14:02.000000000 +0400
@@ -93,9 +93,6 @@ extern struct group_info init_groups;
 
 #define INIT_STRUCT_PID {						\
 	.count 		= ATOMIC_INIT(1),				\
-	.nr		= 0, 						\
-	/* Don't put this struct pid in pid_hash */			\
-	.pid_chain	= { .next = NULL, .pprev = NULL },		\
 	.tasks		= {						\
 		{ .first = &init_task.pids[PIDTYPE_PID].node },		\
 		{ .first = &init_task.pids[PIDTYPE_PGID].node },	\
--- ./include/linux/pid.h.ve17	2007-08-06 14:14:02.000000000 +0400
+++ ./include/linux/pid.h	2007-08-06 14:14:02.000000000 +0400
@@ -57,9 +57,6 @@ struct upid {
 struct pid
 {
 	atomic_t count;
-	/* Try to keep pid_chain in the same cacheline as nr for find_pid */
-	int nr;
-	struct hlist_node pid_chain;
 	/* lists of tasks that use this pid */
 	struct hlist_head tasks[PIDTYPE_MAX];
 	struct rcu_head rcu;
--- ./kernel/pid.c.ve17	2007-08-06 14:14:02.000000000 +0400
+++ ./kernel/pid.c	2007-08-06 14:14:18.000000000 +0400
@@ -259,7 +259,6 @@ struct pid *alloc_pid(struct pid_namespa
 
 	get_pid_ns(ns);
 	pid->level = ns->level;
-	pid->nr = pid->numbers[0].nr;
 	atomic_set(&pid->count, 1);
 	for (type = 0; type < PIDTYPE_MAX; ++type)
 		INIT_HLIST_HEAD(&pid->tasks[type]);
