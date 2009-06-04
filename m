From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup freezer: --- replacement patch 4/4 (a)
Date: Wed, 3 Jun 2009 20:10:24 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0906032008490.19096@takamine.ncl.cs.columbia.edu>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<89c3726813accffb7c51cd30ff93b79a4391f382.1244019829.git.matthltc@us.ibm.com>
	<20090603161840.GD7848@us.ibm.com>
	<Pine.LNX.4.64.0906031957110.19096@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0906031957110.19096-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From 6cdb7d9504a19ad88e6da8ad85374267c7acb1b2 Mon Sep 17 00:00:00 2001
From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Wed, 3 Jun 2009 02:31:21 -0700
Subject: [PATCH] cgroup freezer: Add CHECKPOINTING state to safeguard container checkpoint

The CHECKPOINTING state prevents userspace from unfreezing tasks until
sys_checkpoint() is finished. When doing container checkpoint userspace
will do:

	echo FROZEN > /cgroups/my_container/freezer.state
	...
	rc = sys_checkpoint( <pid of container root> );

To ensure a consistent checkpoint image userspace should not be allowed
to thaw the cgroup (echo THAWED > /cgroups/my_container/freezer.state)
during checkpoint.

"CHECKPOINTING" can only be set on a "FROZEN" cgroup using the checkpoint
system call. Once in the "CHECKPOINTING" state, the cgroup may not leave until
the checkpoint system call is finished and ready to return. Then the
freezer state returns to "FROZEN". Writing any new state to freezer.state while
checkpointing will return EBUSY. These semantics ensure that userspace cannot
unfreeze the cgroup midway through the checkpoint system call.

The cgroup_freezer_begin_checkpoint() and cgroup_freezer_end_checkpoint()
make relatively few assumptions about the task that is passed in. However the
way they are called in do_checkpoint() assumes that the root of the container
is in the same freezer cgroup as all the other tasks that will be
checkpointed.

Matt Helsley's wrote the original patch.

Changlog:
  [2009-Jun-03] change cgroup_freezer_{begin,end}_checkpoint() to take a
  		struct cgroup_subsys_state pointer
		add struct cgroup_subsys_state *get_task_cgroup_freezer()

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

Notes:
        As a side-effect this prevents the multiple tasks from entering the
                CHECKPOINTING state simultaneously. All but one will get -EBUSY.
---
 Documentation/cgroups/freezer-subsystem.txt |   10 ++
 include/linux/freezer.h                     |   10 ++
 kernel/cgroup_freezer.c                     |  149 +++++++++++++++++++--------
 3 files changed, 127 insertions(+), 42 deletions(-)

diff --git a/Documentation/cgroups/freezer-subsystem.txt b/Documentation/cgroups/freezer-subsystem.txt
index 41f37fe..92b68e6 100644
--- a/Documentation/cgroups/freezer-subsystem.txt
+++ b/Documentation/cgroups/freezer-subsystem.txt
@@ -100,3 +100,13 @@ things happens:
 		and returns EINVAL)
 	3) The tasks that blocked the cgroup from entering the "FROZEN"
 		state disappear from the cgroup's set of tasks.
+
+When the cgroup freezer is used to guard container checkpoint operations the
+freezer.state may be "CHECKPOINTING". "CHECKPOINTING" can only be set on a
+"FROZEN" cgroup using the checkpoint system call. Once in the "CHECKPOINTING"
+state, the cgroup may not leave until the checkpoint system call returns the
+freezer state to "FROZEN". Writing any new state to freezer.state while
+checkpointing will return EBUSY. These semantics ensure that userspace cannot
+unfreeze the cgroup midway through the checkpoint system call. Note that,
+unlike "FROZEN" and "FREEZING", there is no corresponding "CHECKPOINTED"
+state.
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index da7e52b..1402911 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -64,12 +64,22 @@ extern bool freeze_task(struct task_struct *p, bool sig_only);
 extern void cancel_freezing(struct task_struct *p);
 
 #ifdef CONFIG_CGROUP_FREEZER
+struct cgroup_subsys_state;
 extern int cgroup_freezing_or_frozen(struct task_struct *task);
+extern struct cgroup_subsys_state *get_task_cgroup_freezer(struct task_struct *task);
+extern int cgroup_freezer_begin_checkpoint(struct cgroup_subsys_state *css);
+extern void cgroup_freezer_end_checkpoint(struct cgroup_subsys_state *css);
 #else /* !CONFIG_CGROUP_FREEZER */
 static inline int cgroup_freezing_or_frozen(struct task_struct *task)
 {
 	return 0;
 }
+static inline int cgroup_freezer_begin_checkpoint(struct task_struct *task)
+{
+	return -ENOTSUPP;
+}
+static inline void cgroup_freezer_end_checkpoint(struct task_struct *task)
+{}
 #endif /* !CONFIG_CGROUP_FREEZER */
 
 /*
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 05795b7..4790fb9 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -25,6 +25,7 @@ enum freezer_state {
 	CGROUP_THAWED = 0,
 	CGROUP_FREEZING,
 	CGROUP_FROZEN,
+	CGROUP_CHECKPOINTING,
 };
 
 struct freezer {
@@ -47,6 +48,18 @@ static inline struct freezer *task_freezer(struct task_struct *task)
 			    struct freezer, css);
 }
 
+struct cgroup_subsys_state *get_task_cgroup_freezer(struct task_struct *task)
+{
+	struct cgroup_subsys_state *css;
+
+	task_lock(task);
+	css = task_subsys_state(task, freezer_subsys_id);
+	css_get(css); /* make sure freezer doesn't go away */
+	task_unlock(task);
+
+	return css;
+}
+
 int cgroup_freezing_or_frozen(struct task_struct *task)
 {
 	struct freezer *freezer;
@@ -63,6 +76,92 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
 	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
 }
 
+/* Task is frozen or will freeze immediately when next it gets woken */
+static bool is_task_frozen_enough(struct task_struct *task)
+{
+	return frozen(task) ||
+		(task_is_stopped_or_traced(task) && freezing(task));
+}
+
+/*
+ * caller must hold freezer->lock
+ */
+static void update_freezer_state(struct cgroup *cgroup,
+				 struct freezer *freezer)
+{
+	struct cgroup_iter it;
+	struct task_struct *task;
+	unsigned int nfrozen = 0, ntotal = 0;
+
+	cgroup_iter_start(cgroup, &it);
+	while ((task = cgroup_iter_next(cgroup, &it))) {
+		ntotal++;
+		if (is_task_frozen_enough(task))
+			nfrozen++;
+	}
+
+	/*
+	 * Transition to FROZEN when no new tasks can be added ensures
+	 * that we never exist in the FROZEN state while there are unfrozen
+	 * tasks.
+	 */
+	if (nfrozen == ntotal)
+		freezer->state = CGROUP_FROZEN;
+	else if (nfrozen > 0)
+		freezer->state = CGROUP_FREEZING;
+	else
+		freezer->state = CGROUP_THAWED;
+	cgroup_iter_end(cgroup, &it);
+}
+
+/*
+ * cgroup freezer state changes made without the aid of the cgroup filesystem
+ * must go through this function to ensure proper locking is observed.
+ */
+static int freezer_checkpointing(struct cgroup_subsys_state *css,
+				 enum freezer_state next_state)
+{
+	struct freezer *freezer;
+	enum freezer_state state;
+
+	freezer = container_of(css, struct freezer, css);
+
+	if (freezer->state == CGROUP_FREEZING) {
+		/* May be in middle of a lazy FREEZING -> FROZEN transition */
+		if (cgroup_lock_live_group(css->cgroup)) {
+			spin_lock_irq(&freezer->lock);
+			update_freezer_state(css->cgroup, freezer);
+			spin_unlock_irq(&freezer->lock);
+			cgroup_unlock();
+		}
+	}
+
+	spin_lock_irq(&freezer->lock);
+	state = freezer->state;
+	if ((state == CGROUP_FROZEN && next_state == CGROUP_CHECKPOINTING) ||
+	    (state == CGROUP_CHECKPOINTING && next_state == CGROUP_FROZEN))
+		freezer->state = next_state;
+	spin_unlock_irq(&freezer->lock);
+	css_put(css);
+	return state;
+}
+
+int cgroup_freezer_begin_checkpoint(struct cgroup_subsys_state *css)
+{
+	if (freezer_checkpointing(css, CGROUP_CHECKPOINTING) != CGROUP_FROZEN)
+		return -EBUSY;
+	return 0;
+}
+
+void cgroup_freezer_end_checkpoint(struct cgroup_subsys_state *css)
+{
+	/*
+	 * If we weren't in CHECKPOINTING state then userspace could have
+	 * unfrozen a task and given us an inconsistent checkpoint image
+	 */
+	WARN_ON(freezer_checkpointing(css, CGROUP_FROZEN) != CGROUP_CHECKPOINTING);
+}
+
 /*
  * cgroups_write_string() limits the size of freezer state strings to
  * CGROUP_LOCAL_BUFFER_SIZE
@@ -71,6 +170,7 @@ static const char *freezer_state_strs[] = {
 	"THAWED",
 	"FREEZING",
 	"FROZEN",
+	"CHECKPOINTING",
 };
 
 /*
@@ -78,9 +178,9 @@ static const char *freezer_state_strs[] = {
  * Transitions are caused by userspace writes to the freezer.state file.
  * The values in parenthesis are state labels. The rest are edge labels.
  *
- * (THAWED) --FROZEN--> (FREEZING) --FROZEN--> (FROZEN)
- *    ^ ^                    |                     |
- *    | \_______THAWED_______/                     |
+ * (THAWED) --FROZEN--> (FREEZING) --FROZEN--> (FROZEN) --> (CHECKPOINTING)
+ *    ^ ^                    |                     | ^             |
+ *    | \_______THAWED_______/                     | \_____________/
  *    \__________________________THAWED____________/
  */
 
@@ -153,13 +253,6 @@ static void freezer_destroy(struct cgroup_subsys *ss,
 	kfree(cgroup_freezer(cgroup));
 }
 
-/* Task is frozen or will freeze immediately when next it gets woken */
-static bool is_task_frozen_enough(struct task_struct *task)
-{
-	return frozen(task) ||
-		(task_is_stopped_or_traced(task) && freezing(task));
-}
-
 /*
  * The call to cgroup_lock() in the freezer.state write method prevents
  * a write to that file racing against an attach, and hence the
@@ -216,37 +309,6 @@ static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
 	spin_unlock_irq(&freezer->lock);
 }
 
-/*
- * caller must hold freezer->lock
- */
-static void update_freezer_state(struct cgroup *cgroup,
-				 struct freezer *freezer)
-{
-	struct cgroup_iter it;
-	struct task_struct *task;
-	unsigned int nfrozen = 0, ntotal = 0;
-
-	cgroup_iter_start(cgroup, &it);
-	while ((task = cgroup_iter_next(cgroup, &it))) {
-		ntotal++;
-		if (is_task_frozen_enough(task))
-			nfrozen++;
-	}
-
-	/*
-	 * Transition to FROZEN when no new tasks can be added ensures
-	 * that we never exist in the FROZEN state while there are unfrozen
-	 * tasks.
-	 */
-	if (nfrozen == ntotal)
-		freezer->state = CGROUP_FROZEN;
-	else if (nfrozen > 0)
-		freezer->state = CGROUP_FREEZING;
-	else
-		freezer->state = CGROUP_THAWED;
-	cgroup_iter_end(cgroup, &it);
-}
-
 static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
 			struct seq_file *m)
 {
@@ -320,7 +382,10 @@ static int freezer_change_state(struct cgroup *cgroup,
 	freezer = cgroup_freezer(cgroup);
 
 	spin_lock_irq(&freezer->lock);
-
+	if (freezer->state == CGROUP_CHECKPOINTING) {
+		retval = -EBUSY;
+		goto out;
+	}
 	update_freezer_state(cgroup, freezer);
 	if (goal_state == freezer->state)
 		goto out;
-- 
1.6.0.4
