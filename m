From: xemul@openvz.org
Subject: [PATCH 20/20] Remove the struct pid unneeded fields
Date: Fri, 10 Aug 2007 15:48:30 +0400
Message-ID: <46BC508E.mailGLP17CM9M@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S937297AbXHJLzB@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@osdl.org
Cc: xemul@openvz.org, devel@openvz.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, oleg@tv-sign.ru, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

Since we've switched from using pid->nr to pid->upids->nr some
fields on struct pid are no longer needed

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>

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
