From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/7] cgroup_freezer: don't use cgroup_lock_live_group()
Date: Tue, 16 Oct 2012 15:28:46 -0700
Message-ID: <1350426526-14254-8-git-send-email-tj@kernel.org>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1350426526-14254-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rjw-KKrjLPT3xs0@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

freezer_read/write() used cgroup_lock_live_group() to synchronize
against task migration into and out of the target cgroup.
cgroup_lock_live_group() grabs the internal cgroup lock and using it
from outside cgroup core leads to complex and fragile locking
dependency issues which are difficult to resolve.

Now that freezer_can_attach() is replaced with freezer_attach() and
update_if_frozen() updated, nothing requires excluding migration
against freezer state reads and changes.

This patch removes cgroup_lock_live_group() and the matching
cgroup_unlock() usages.  The prone-to-bitrot, already outdated and
unnecessary global lock hierarchy documentation is replaced with
documentation in local scope.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup_freezer.c |   66 +++++++---------------------------------------
 1 files changed, 10 insertions(+), 56 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 3d45503..8a92b0e 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -84,50 +84,6 @@ static const char *freezer_state_strs[] = {
 
 struct cgroup_subsys freezer_subsys;
 
-/* Locks taken and their ordering
- * ------------------------------
- * cgroup_mutex (AKA cgroup_lock)
- * freezer->lock
- * css_set_lock
- * task->alloc_lock (AKA task_lock)
- * task->sighand->siglock
- *
- * cgroup code forces css_set_lock to be taken before task->alloc_lock
- *
- * freezer_create(), freezer_destroy():
- * cgroup_mutex [ by cgroup core ]
- *
- * freezer_can_attach():
- * cgroup_mutex (held by caller of can_attach)
- *
- * freezer_fork() (preserving fork() performance means can't take cgroup_mutex):
- * freezer->lock
- *  sighand->siglock (if the cgroup is freezing)
- *
- * freezer_read():
- * cgroup_mutex
- *  freezer->lock
- *   write_lock css_set_lock (cgroup iterator start)
- *    task->alloc_lock
- *   read_lock css_set_lock (cgroup iterator start)
- *
- * freezer_write() (freeze):
- * cgroup_mutex
- *  freezer->lock
- *   write_lock css_set_lock (cgroup iterator start)
- *    task->alloc_lock
- *   read_lock css_set_lock (cgroup iterator start)
- *    sighand->siglock (fake signal delivery inside freeze_task())
- *
- * freezer_write() (unfreeze):
- * cgroup_mutex
- *  freezer->lock
- *   write_lock css_set_lock (cgroup iterator start)
- *    task->alloc_lock
- *   read_lock css_set_lock (cgroup iterator start)
- *    task->alloc_lock (inside __thaw_task(), prevents race with refrigerator())
- *     sighand->siglock
- */
 static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
 {
 	struct freezer *freezer;
@@ -151,9 +107,13 @@ static void freezer_destroy(struct cgroup *cgroup)
 }
 
 /*
- * The call to cgroup_lock() in the freezer.state write method prevents
- * a write to that file racing against an attach, and hence we don't need
- * to worry about racing against migration.
+ * Tasks can be migrated into a different freezer anytime regardless of its
+ * current state.  freezer_attach() is responsible for making new tasks
+ * conform to the current state.
+ *
+ * Freezer state changes and task migration are synchronized via
+ * @freezer->lock.  freezer_attach() makes the new tasks conform to the
+ * current state and all following state changes can see the new tasks.
  */
 static void freezer_attach(struct cgroup *new_cgrp, struct cgroup_taskset *tset)
 {
@@ -217,8 +177,8 @@ out:
  * partially frozen when we exitted write.  Caller must hold freezer->lock.
  *
  * Task states and freezer state might disagree while tasks are being
- * migrated into @cgroup, so we can't verify task states against @freezer
- * state here.  See freezer_attach() for details.
+ * migrated into or out of @cgroup, so we can't verify task states against
+ * @freezer state here.  See freezer_attach() for details.
  */
 static void update_if_frozen(struct cgroup *cgroup, struct freezer *freezer)
 {
@@ -255,15 +215,11 @@ static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
 	struct freezer *freezer;
 	enum freezer_state state;
 
-	if (!cgroup_lock_live_group(cgroup))
-		return -ENODEV;
-
 	freezer = cgroup_freezer(cgroup);
 	spin_lock_irq(&freezer->lock);
 	update_if_frozen(cgroup, freezer);
 	state = freezer->state;
 	spin_unlock_irq(&freezer->lock);
-	cgroup_unlock();
 
 	seq_puts(m, freezer_state_strs[state]);
 	seq_putc(m, '\n');
@@ -297,6 +253,7 @@ static void freezer_change_state(struct cgroup *cgroup,
 {
 	struct freezer *freezer = cgroup_freezer(cgroup);
 
+	/* also synchronizes against task migration, see freezer_attach() */
 	spin_lock_irq(&freezer->lock);
 
 	switch (goal_state) {
@@ -332,10 +289,7 @@ static int freezer_write(struct cgroup *cgroup,
 	else
 		return -EINVAL;
 
-	if (!cgroup_lock_live_group(cgroup))
-		return -ENODEV;
 	freezer_change_state(cgroup, goal_state);
-	cgroup_unlock();
 	return 0;
 }
 
-- 
1.7.7.3
