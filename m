From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: =?us-ascii?Q?[PATCH][RFC]_freezer=3A_Add_CHECKPOINTING_state_to_sa?=
	=?us-ascii?Q?feguard_container_checkpoint?=
Date: Mon, 27 Apr 2009 19:17:56 -0700
Message-ID: <20090505002620.2173735E178@count0.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Date: Mon, 04 May 2009 17:26:19 -0700
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>

Notes:
        This is an untested RFC patch for container checkpoint. It's meant to
                work with Oren's patch series.
        As a side-effect this prevents the multiple tasks from entering the
                CHECKPOINTING state simultaneously. All but one will get -EBUSY.
---
 Documentation/cgroups/freezer-subsystem.txt |   10 ++++++
 checkpoint/checkpoint.c                     |    7 ++--
 include/linux/freezer.h                     |    8 +++++
 kernel/cgroup_freezer.c                     |   46 ++++++++++++++++++++++++++-
 4 files changed, 67 insertions(+), 4 deletions(-)

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
index 7f5c18c..010743f 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -489,7 +489,7 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 		return -EBUSY;
 	}
 
-	return 0;
+	return cgroup_freezer_begin_checkpoint(ctx->root_task);
 
  out:
 	if (task)
@@ -531,7 +531,7 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 
 	ret = ctx_checkpoint(ctx, pid);
 	if (ret < 0)
-		goto out;
+		return ret;
 	ret = build_tree(ctx);
 	if (ret < 0)
 		goto out;
@@ -560,6 +560,7 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	/* on success, return (unique) checkpoint identifier */
 	ctx->crid = atomic_inc_return(&ctx_count);
 	ret = ctx->crid;
- out:
+out:
+	cgroup_freezer_end_checkpoint(ctx->root_task);
 	return ret;
 }
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 5a361f8..f1d770b 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -65,8 +65,16 @@ extern void cancel_freezing(struct task_struct *p);
 
 #ifdef CONFIG_CGROUP_FREEZER
 extern int cgroup_frozen(struct task_struct *task);
+extern int cgroup_freezer_begin_checkpoint(struct task_struct *task);
+extern void cgroup_freezer_end_checkpoint(struct task_struct *task);
 #else /* !CONFIG_CGROUP_FREEZER */
 static inline int cgroup_frozen(struct task_struct *task) { return 0; }
+static inline int cgroup_freezer_begin_checkpoint(struct task_struct *task)
+{
+	return -ENOTSUP;
+}
+static inline void cgroup_freezer_end_checkpoint(struct task_struct *task)
+{}
 #endif /* !CONFIG_CGROUP_FREEZER */
 
 /*
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index fb249e2..0443226 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -25,6 +25,7 @@ enum freezer_state {
 	CGROUP_THAWED = 0,
 	CGROUP_FREEZING,
 	CGROUP_FROZEN,
+	CGROUP_CHECKPOINTING,
 };
 
 struct freezer {
@@ -61,6 +62,45 @@ int cgroup_frozen(struct task_struct *task)
 }
 
 /*
+ * cgroup freezer state changes made without the aid of the cgroup filesystem
+ * must go through this function to ensure proper locking is observed.
+ */
+static int freezer_checkpointing(struct task_struct *task,
+				 enum freezer_state next_state)
+{
+	struct freezer *freezer;
+	enum freezer_state state;
+
+	task_lock(task);
+	freezer = task_freezer(task);
+	spin_lock_irq(&freezer->lock);
+	state = freezer->state;
+	if ((state == CGROUP_FROZEN && next_state == CGROUP_CHECKPOINTING) ||
+	    (state == CGROUP_CHECKPOINTING && next_state == CGROUP_FROZEN))
+		freezer->state = next_state;
+	spin_unlock_irq(&freezer->lock);
+	task_unlock(task);
+
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
@@ -68,6 +108,7 @@ static const char *freezer_state_strs[] = {
 	"THAWED",
 	"FREEZING",
 	"FROZEN",
+	"CHECKPOINTING",
 };
 
 /*
@@ -309,7 +350,10 @@ static int freezer_change_state(struct cgroup *cgroup,
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
