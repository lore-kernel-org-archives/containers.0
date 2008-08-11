From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/5] Container Freezer: Implement freezer cgroup subsystem
Date: Mon, 11 Aug 2008 16:53:26 -0700
Message-ID: <20080811235325.121356317__43239.1935414218$1218499476$gmane$org@us.ibm.com>
References: <20080811235323.872291138@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch implements a new freezer subsystem in the control groups framework.
It provides a way to stop and resume execution of all tasks in a cgroup by
writing in the cgroup filesystem.

The freezer subsystem in the container filesystem defines a file named
freezer.state. Writing "FROZEN" to the state file will freeze all tasks in the
cgroup. Subsequently writing "RUNNING" will unfreeze the tasks in the cgroup.
Reading will return the current state.

* Examples of usage :

   # mkdir /containers/freezer
   # mount -t cgroup -ofreezer freezer  /containers
   # mkdir /containers/0
   # echo $some_pid > /containers/0/tasks

to get status of the freezer subsystem :

   # cat /containers/0/freezer.state
   RUNNING

to freeze all tasks in the container :

   # echo FROZEN > /containers/0/freezer.state
   # cat /containers/0/freezer.state
   FREEZING
   # cat /containers/0/freezer.state
   FROZEN

to unfreeze all tasks in the container :

   # echo RUNNING > /containers/0/freezer.state
   # cat /containers/0/freezer.state
   RUNNING

This is the basic mechanism which should do the right thing for user space task
in a simple scenario.

It's important to note that freezing can be incomplete. In that case we return
EBUSY. This means that some tasks in the cgroup are busy doing something that
prevents us from completely freezing the cgroup at this time. After EBUSY,
the cgroup will remain partially frozen -- reflected by freezer.state reporting
"FREEZING" when read. The state will remain "FREEZING" until one of these
things happens:

	1) Userspace cancels the freezing operation by writing "RUNNING" to
		the freezer.state file
	2) Userspace retries the freezing operation by writing "FROZEN" to
		the freezer.state file (writing "FREEZING" is not legal
		and returns EIO)
	3) The tasks that blocked the cgroup from entering the "FROZEN"
		state disappear from the cgroup's set of tasks.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
Changes since v5:
v6:
	Use the new cgroup write_string method.
	Conditionally build and link the freezer code.
	Fix a lock ordering problem with the freezer->lock reacquire code
		Required order: freezer->lock, css_set_lock, task->alloc_lock
		Reacquiring: css_set_lock, task->alloc_lock, freezer->lock
		Solution: change freezer_fork() to not require any ordering
			between task->alloc_lock and freezer->lock

 include/linux/cgroup_subsys.h |    6 
 include/linux/freezer.h       |   22 ++
 init/Kconfig                  |    7 
 kernel/Makefile               |    1 
 kernel/cgroup_freezer.c       |  366 ++++++++++++++++++++++++++++++++++++++++++
 kernel/power/Kconfig          |    2 
 6 files changed, 399 insertions(+), 5 deletions(-)
 create mode 100644 include/linux/cgroup_freezer.h
 create mode 100644 kernel/cgroup_freezer.c

Index: linux-2.6.27-rc1-mm1/include/linux/cgroup_subsys.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/linux/cgroup_subsys.h
+++ linux-2.6.27-rc1-mm1/include/linux/cgroup_subsys.h
@@ -52,3 +52,9 @@ SUBSYS(memrlimit_cgroup)
 #endif
 
 /* */
+
+#ifdef CONFIG_CGROUP_FREEZER
+SUBSYS(freezer)
+#endif
+
+/* */
Index: linux-2.6.27-rc1-mm1/include/linux/freezer.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/linux/freezer.h
+++ linux-2.6.27-rc1-mm1/include/linux/freezer.h
@@ -47,22 +47,30 @@ static inline bool should_send_signal(st
 /*
  * Wake up a frozen process
  *
- * task_lock() is taken to prevent the race with refrigerator() which may
+ * task_lock() is needed to prevent the race with refrigerator() which may
  * occur if the freezing of tasks fails.  Namely, without the lock, if the
  * freezing of tasks failed, thaw_tasks() might have run before a task in
  * refrigerator() could call frozen_process(), in which case the task would be
  * frozen and no one would thaw it.
  */
-static inline int thaw_process(struct task_struct *p)
+static inline int __thaw_process(struct task_struct *p)
 {
-	task_lock(p);
 	if (frozen(p)) {
 		p->flags &= ~PF_FROZEN;
+		return 1;
+	}
+	clear_freeze_flag(p);
+	return 0;
+}
+
+static inline int thaw_process(struct task_struct *p)
+{
+	task_lock(p);
+	if (__thaw_process(p) == 1) {
 		task_unlock(p);
 		wake_up_process(p);
 		return 1;
 	}
-	clear_freeze_flag(p);
 	task_unlock(p);
 	return 0;
 }
@@ -83,6 +91,12 @@ static inline int try_to_freeze(void)
 extern bool freeze_task(struct task_struct *p, bool sig_only);
 extern void cancel_freezing(struct task_struct *p);
 
+#ifdef CONFIG_CGROUP_FREEZER
+extern int cgroup_frozen(struct task_struct *task);
+#else /* !CONFIG_CGROUP_FREEZER */
+static inline int cgroup_frozen(struct task_struct *task) { return 0; }
+#endif /* !CONFIG_CGROUP_FREEZER */
+
 /*
  * The PF_FREEZER_SKIP flag should be set by a vfork parent right before it
  * calls wait_for_completion(&vfork) and reset right after it returns from this
Index: linux-2.6.27-rc1-mm1/init/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/init/Kconfig
+++ linux-2.6.27-rc1-mm1/init/Kconfig
@@ -299,6 +299,13 @@ config CGROUP_NS
           for instance virtual servers and checkpoint/restart
           jobs.
 
+config CGROUP_FREEZER
+        bool "control group freezer subsystem"
+        depends on CGROUPS
+        help
+          Provides a way to freeze and unfreeze all tasks in a
+	  cgroup.
+
 config CGROUP_DEVICE
 	bool "Device controller for cgroups"
 	depends on CGROUPS && EXPERIMENTAL
Index: linux-2.6.27-rc1-mm1/kernel/Makefile
===================================================================
--- linux-2.6.27-rc1-mm1.orig/kernel/Makefile
+++ linux-2.6.27-rc1-mm1/kernel/Makefile
@@ -54,6 +54,7 @@ obj-$(CONFIG_KEXEC) += kexec.o
 obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
+obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
 obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
 obj-$(CONFIG_UTS_NS) += utsname.o
Index: linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
===================================================================
--- /dev/null
+++ linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
@@ -0,0 +1,366 @@
+/*
+ * cgroup_freezer.c -  control group freezer subsystem
+ *
+ * Copyright IBM Corporation, 2007
+ *
+ * Author : Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2.1 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ */
+
+#include <linux/module.h>
+#include <linux/cgroup.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/freezer.h>
+#include <linux/seq_file.h>
+
+enum freezer_state {
+	STATE_RUNNING = 0,
+	STATE_FREEZING,
+	STATE_FROZEN,
+};
+
+struct freezer {
+	struct cgroup_subsys_state css;
+	enum freezer_state state;
+	spinlock_t lock; /* protects _writes_ to state */
+};
+
+static inline struct freezer *cgroup_freezer(
+		struct cgroup *cgroup)
+{
+	return container_of(
+		cgroup_subsys_state(cgroup, freezer_subsys_id),
+		struct freezer, css);
+}
+
+static inline struct freezer *task_freezer(struct task_struct *task)
+{
+	return container_of(task_subsys_state(task, freezer_subsys_id),
+			    struct freezer, css);
+}
+
+int cgroup_frozen(struct task_struct *task)
+{
+	struct freezer *freezer;
+	enum freezer_state state;
+
+	task_lock(task);
+	freezer = task_freezer(task);
+	state = freezer->state;
+	task_unlock(task);
+
+	return state == STATE_FROZEN;
+}
+
+/*
+ * Buffer size for freezer state is limited by cgroups write_string()
+ * interface. See cgroups code for the current size.
+ */
+static const char *freezer_state_strs[] = {
+	"RUNNING",
+	"FREEZING",
+	"FROZEN",
+};
+
+/*
+ * State diagram
+ * Transitions are caused by userspace writes to the freezer.state file.
+ * The values in parenthesis are state labels. The rest are edge labels.
+ *
+ * (RUNNING) --FROZEN--> (FREEZING) --FROZEN--> (FROZEN)
+ *    ^ ^                     |                       |
+ *    | \_______RUNNING_______/                       |
+ *    \_____________________________RUNNING___________/
+ */
+
+struct cgroup_subsys freezer_subsys;
+
+/* Locks taken and their ordering
+ * ------------------------------
+ * css_set_lock
+ * cgroup_mutex (AKA cgroup_lock)
+ * task->alloc_lock (AKA task_lock)
+ * freezer->lock
+ * task->sighand->siglock
+ *
+ * cgroup code forces css_set_lock to be taken before task->alloc_lock
+ *
+ * freezer_create(), freezer_destroy():
+ * cgroup_mutex [ by cgroup core ]
+ *
+ * can_attach():
+ * cgroup_mutex
+ *
+ * cgroup_frozen():
+ * task->alloc_lock (to get task's cgroup)
+ *
+ * freezer_fork() (preserving fork() performance means can't take cgroup_mutex):
+ * task->alloc_lock (to get task's cgroup)
+ * freezer->lock
+ *  sighand->siglock (if the cgroup is freezing)
+ *
+ * freezer_read():
+ * cgroup_mutex
+ *  freezer->lock
+ *   read_lock css_set_lock (cgroup iterator start)
+ *
+ * freezer_write() (freeze):
+ * cgroup_mutex
+ *  freezer->lock
+ *   read_lock css_set_lock (cgroup iterator start)
+ *    sighand->siglock
+ *
+ * freezer_write() (unfreeze):
+ * cgroup_mutex
+ *  freezer->lock
+ *   read_lock css_set_lock (cgroup iterator start)
+ *    task->alloc_lock (to prevent races with freeze_task())
+ *     sighand->siglock
+ */
+static struct cgroup_subsys_state *freezer_create(struct cgroup_subsys *ss,
+						  struct cgroup *cgroup)
+{
+	struct freezer *freezer;
+
+	freezer = kzalloc(sizeof(struct freezer), GFP_KERNEL);
+	if (!freezer)
+		return ERR_PTR(-ENOMEM);
+
+	spin_lock_init(&freezer->lock);
+	freezer->state = STATE_RUNNING;
+	return &freezer->css;
+}
+
+static void freezer_destroy(struct cgroup_subsys *ss,
+			    struct cgroup *cgroup)
+{
+	kfree(cgroup_freezer(cgroup));
+}
+
+
+static int freezer_can_attach(struct cgroup_subsys *ss,
+			      struct cgroup *new_cgroup,
+			      struct task_struct *task)
+{
+	struct freezer *freezer;
+	int retval = 0;
+
+	/*
+	 * The call to cgroup_lock() in the freezer.state write method prevents
+	 * a write to that file racing against an attach, and hence the
+	 * can_attach() result will remain valid until the attach completes.
+	 */
+	freezer = cgroup_freezer(new_cgroup);
+	if (freezer->state == STATE_FROZEN)
+		retval = -EBUSY;
+	return retval;
+}
+
+static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
+{
+	struct freezer *freezer;
+
+	task_lock(task);
+	freezer = task_freezer(task);
+	task_unlock(task);
+
+	BUG_ON(freezer->state == STATE_FROZEN);
+	spin_lock_irq(&freezer->lock);
+	/* Locking avoids race with FREEZING -> RUNNING transitions. */
+	if (freezer->state == STATE_FREEZING)
+		freeze_task(task, true);
+	spin_unlock_irq(&freezer->lock);
+}
+
+/*
+ * caller must hold freezer->lock
+ */
+static void check_if_frozen(struct cgroup *cgroup,
+			     struct freezer *freezer)
+{
+	struct cgroup_iter it;
+	struct task_struct *task;
+	unsigned int nfrozen = 0, ntotal = 0;
+
+	cgroup_iter_start(cgroup, &it);
+	while ((task = cgroup_iter_next(cgroup, &it))) {
+		ntotal++;
+		/*
+		 * Task is frozen or will freeze immediately when next it gets
+		 * woken
+		 */
+		if (frozen(task) ||
+		    (task_is_stopped_or_traced(task) && freezing(task)))
+			nfrozen++;
+	}
+
+	/*
+	 * Transition to FROZEN when no new tasks can be added ensures
+	 * that we never exist in the FROZEN state while there are unfrozen
+	 * tasks.
+	 */
+	if (nfrozen == ntotal)
+		freezer->state = STATE_FROZEN;
+	cgroup_iter_end(cgroup, &it);
+}
+
+static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
+    			struct seq_file *m)
+{
+	struct freezer *freezer;
+	enum freezer_state state;
+
+	if (!cgroup_lock_live_group(cgroup))
+		return -ENODEV;
+
+	freezer = cgroup_freezer(cgroup);
+	spin_lock_irq(&freezer->lock);
+	state = freezer->state;
+	if (state == STATE_FREEZING) {
+		/* We change from FREEZING to FROZEN lazily if the cgroup was
+		 * only partially frozen when we exitted write. */
+		check_if_frozen(cgroup, freezer);
+		state = freezer->state;
+	}
+	spin_unlock_irq(&freezer->lock);
+	cgroup_unlock();
+
+	seq_puts(m, freezer_state_strs[state]);
+	seq_putc(m, '\n');
+	return 0;
+}
+
+static int try_to_freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
+{
+	struct cgroup_iter it;
+	struct task_struct *task;
+	unsigned int num_cant_freeze_now = 0;
+
+	freezer->state = STATE_FREEZING;
+	cgroup_iter_start(cgroup, &it);
+	while ((task = cgroup_iter_next(cgroup, &it))) {
+		if (!freeze_task(task, true))
+			continue;
+		if (task_is_stopped_or_traced(task) && freezing(task))
+			/*
+			 * The freeze flag is set so these tasks will
+			 * immediately go into the fridge upon waking.
+			 */
+			continue;
+		if (!freezing(task) && !freezer_should_skip(task))
+			num_cant_freeze_now++;
+	}
+	cgroup_iter_end(cgroup, &it);
+
+	return num_cant_freeze_now ? -EBUSY : 0;
+}
+
+static int unfreeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
+{
+	struct cgroup_iter it;
+	struct task_struct *task;
+
+	cgroup_iter_start(cgroup, &it);
+	while ((task = cgroup_iter_next(cgroup, &it))) {
+		int do_wake;
+
+		task_lock(task);
+		do_wake = __thaw_process(task);
+		task_unlock(task);
+		if (do_wake)
+			wake_up_process(task);
+	}
+	cgroup_iter_end(cgroup, &it);
+	freezer->state = STATE_RUNNING;
+
+	return 0;
+}
+
+static int freezer_change_state(struct cgroup *cgroup,
+				enum freezer_state goal_state)
+{
+	struct freezer *freezer;
+	int retval = 0;
+
+	freezer = cgroup_freezer(cgroup);
+	spin_lock_irq(&freezer->lock);
+	check_if_frozen(cgroup, freezer); /* may update freezer->state */
+	if (goal_state == freezer->state)
+		goto out;
+	switch (freezer->state) {
+	case STATE_RUNNING:
+		retval = try_to_freeze_cgroup(cgroup, freezer);
+		break;
+	case STATE_FREEZING:
+		if (goal_state == STATE_FROZEN) {
+			/* Userspace is retrying after
+			 * "/bin/echo FROZEN > freezer.state" returned -EBUSY */
+			retval = try_to_freeze_cgroup(cgroup, freezer);
+			break;
+		}
+		/* state == FREEZING and goal_state == RUNNING, so unfreeze */
+	case STATE_FROZEN:
+		retval = unfreeze_cgroup(cgroup, freezer);
+		break;
+	default:
+		break;
+	}
+out:
+	spin_unlock_irq(&freezer->lock);
+
+	return retval;
+}
+
+static int freezer_write(struct cgroup *cgroup,
+			 struct cftype *cft,
+			 const char *buffer)
+{
+	int retval;
+	enum freezer_state goal_state;
+
+	if (strcmp(buffer, freezer_state_strs[STATE_RUNNING]) == 0)
+		goal_state = STATE_RUNNING;
+	else if (strcmp(buffer, freezer_state_strs[STATE_FROZEN]) == 0)
+		goal_state = STATE_FROZEN;
+	else
+		return -EIO;
+
+	if (!cgroup_lock_live_group(cgroup))
+		return -ENODEV;
+	retval = freezer_change_state(cgroup, goal_state);
+	cgroup_unlock();
+	return retval;
+}
+
+static struct cftype files[] = {
+	{
+		.name = "state",
+		.read_seq_string = freezer_read,
+		.write_string = freezer_write,
+	},
+};
+
+static int freezer_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
+{
+	return cgroup_add_files(cgroup, ss, files, ARRAY_SIZE(files));
+}
+
+struct cgroup_subsys freezer_subsys = {
+	.name		= "freezer",
+	.create		= freezer_create,
+	.destroy	= freezer_destroy,
+	.populate	= freezer_populate,
+	.subsys_id	= freezer_subsys_id,
+	.can_attach	= freezer_can_attach,
+	.attach		= NULL,
+	.fork		= freezer_fork,
+	.exit		= NULL,
+};
Index: linux-2.6.27-rc1-mm1/kernel/power/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/kernel/power/Kconfig
+++ linux-2.6.27-rc1-mm1/kernel/power/Kconfig
@@ -86,7 +86,7 @@ config PM_SLEEP
 	default y
 
 config FREEZER
-	def_bool PM_SLEEP
+	def_bool PM_SLEEP || CGROUP_FREEZER
 
 config SUSPEND
 	bool "Suspend to RAM and standby"

-- 
