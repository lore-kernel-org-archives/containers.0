From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/4] cgroup freezer: Add CHECKPOINTING state to safeguard
	container checkpoint
Date: Wed,  3 Jun 2009 02:31:21 -0700
Message-ID: <89c3726813accffb7c51cd30ff93b79a4391f382.1244019829.git.matthltc@us.ibm.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<91260d5797bcf233ca54c7b41da8278e99b4ca66.1244019829.git.matthltc@us.ibm.com>
	<03412f8681d89c99ac575330381ab49f6e5e61ba.1244019829.git.matthltc@us.ibm.com>
	<4abbb542b220448d2e8d17e5074899568c584f23.1244019829.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4abbb542b220448d2e8d17e5074899568c584f23.1244019829.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1244019829.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <cover.1244019829.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Notes:
	Meant to work with Oren's checkpoint/restart v16-dev git tree.
        Still needs testing.
        As a side-effect this prevents the multiple tasks from entering the
                CHECKPOINTING state simultaneously. All but one will get -EBUSY.
---
 Documentation/cgroups/freezer-subsystem.txt |   10 ++
 checkpoint/checkpoint.c                     |    8 ++-
 include/linux/freezer.h                     |    8 ++
 kernel/cgroup_freezer.c                     |  128 +++++++++++++++++++-------
 4 files changed, 117 insertions(+), 37 deletions(-)

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
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index afc7300..d586a9b 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -569,7 +569,10 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 
 	ret = init_checkpoint_ctx(ctx, pid);
 	if (ret < 0)
-		goto out;
+		return ret;
+	ret = cgroup_freezer_begin_checkpoint(ctx->root_task);
+	if (ret < 0)
+		return ret;
 	ret = build_tree(ctx);
 	if (ret < 0)
 		goto out;
@@ -597,6 +600,7 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	/* on success, return (unique) checkpoint identifier */
 	ctx->crid = atomic_inc_return(&ctx_count);
 	ret = ctx->crid;
- out:
+out:
+	cgroup_freezer_end_checkpoint(ctx->root_task);
 	return ret;
 }
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index da7e52b..cd31593 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -65,11 +65,19 @@ extern void cancel_freezing(struct task_struct *p);
 
 #ifdef CONFIG_CGROUP_FREEZER
 extern int cgroup_freezing_or_frozen(struct task_struct *task);
+extern int cgroup_freezer_begin_checkpoint(struct task_struct *task);
+extern void cgroup_freezer_end_checkpoint(struct task_struct *task);
 #else /* !CONFIG_CGROUP_FREEZER */
 static inline int cgroup_freezing_or_frozen(struct task_struct *task)
 {
 	return 0;
 }
+static inline int cgroup_freezer_begin_checkpoint(struct task_struct *task)
+{
+	return -ENOTSUP;
+}
+static inline void cgroup_freezer_end_checkpoint(struct task_struct *task)
+{}
 #endif /* !CONFIG_CGROUP_FREEZER */
 
 /*
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 05795b7..6519692 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -25,6 +25,7 @@ enum freezer_state {
 	CGROUP_THAWED = 0,
 	CGROUP_FREEZING,
 	CGROUP_FROZEN,
+	CGROUP_CHECKPOINTING,
 };
 
 struct freezer {
@@ -64,6 +65,90 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
 }
 
 /*
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
+static int freezer_checkpointing(struct task_struct *task,
+				 enum freezer_state next_state)
+{
+	struct freezer *freezer;
+	struct cgroup_subsys_state *css;
+	enum freezer_state state;
+
+	task_lock(task);
+	css = task_subsys_state(task, freezer_subsys_id);
+	css_get(css); /* make sure freezer doesn't go away */
+	freezer = containerof(css, struct freezer, css);
+	task_unlock(task);
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
+int cgroup_freezer_begin_checkpoint(struct task_struct *task)
+{
+	if (freezer_checkpointing(task, CGROUP_CHECKPOINTING) != CGROUP_FROZEN)
+		return -EBUSY;
+	return 0;
+}
+
+void cgroup_freezer_end_checkpoint(struct task_struct *task)
+{
+	/*
+	 * If we weren't in CHECKPOINTING state then userspace could have
+	 * unfrozen a task and given us an inconsistent checkpoint image
+	 */
+	WARN_ON(freezer_checkpointing(task, CGROUP_FROZEN) != CGROUP_CHECKPOINTING);
+}
+
+/*
  * cgroups_write_string() limits the size of freezer state strings to
  * CGROUP_LOCAL_BUFFER_SIZE
  */
@@ -71,6 +156,7 @@ static const char *freezer_state_strs[] = {
 	"THAWED",
 	"FREEZING",
 	"FROZEN",
+	"CHECKPOINTING",
 };
 
 /*
@@ -78,9 +164,9 @@ static const char *freezer_state_strs[] = {
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
 
@@ -216,37 +302,6 @@ static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
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
@@ -320,7 +375,10 @@ static int freezer_change_state(struct cgroup *cgroup,
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
1.5.6.3
