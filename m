From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] cgroup freezer: Update stale locking comments
Date: Wed,  3 Jun 2009 02:31:20 -0700
Message-ID: <4abbb542b220448d2e8d17e5074899568c584f23.1244019829.git.matthltc@us.ibm.com>
References: <cover.1244019829.git.matthltc@us.ibm.com>
	<91260d5797bcf233ca54c7b41da8278e99b4ca66.1244019829.git.matthltc@us.ibm.com>
	<03412f8681d89c99ac575330381ab49f6e5e61ba.1244019829.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <03412f8681d89c99ac575330381ab49f6e5e61ba.1244019829.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Update stale comments regarding locking order and add a little more detail
so it's easier to follow the locking between the cgroup freezer and the
power management freezer code.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup_freezer.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 19702ac..05795b7 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -88,10 +88,10 @@ struct cgroup_subsys freezer_subsys;
 
 /* Locks taken and their ordering
  * ------------------------------
- * css_set_lock
  * cgroup_mutex (AKA cgroup_lock)
- * task->alloc_lock (AKA task_lock)
  * freezer->lock
+ * css_set_lock
+ * task->alloc_lock (AKA task_lock)
  * task->sighand->siglock
  *
  * cgroup code forces css_set_lock to be taken before task->alloc_lock
@@ -99,33 +99,38 @@ struct cgroup_subsys freezer_subsys;
  * freezer_create(), freezer_destroy():
  * cgroup_mutex [ by cgroup core ]
  *
- * can_attach():
- * cgroup_mutex
+ * freezer_can_attach():
+ * cgroup_mutex (held by caller of can_attach)
  *
- * cgroup_frozen():
+ * cgroup_freezing_or_frozen():
  * task->alloc_lock (to get task's cgroup)
  *
  * freezer_fork() (preserving fork() performance means can't take cgroup_mutex):
- * task->alloc_lock (to get task's cgroup)
  * freezer->lock
  *  sighand->siglock (if the cgroup is freezing)
  *
  * freezer_read():
  * cgroup_mutex
  *  freezer->lock
+ *   write_lock css_set_lock (cgroup iterator start)
+ *    task->alloc_lock
  *   read_lock css_set_lock (cgroup iterator start)
  *
  * freezer_write() (freeze):
  * cgroup_mutex
  *  freezer->lock
+ *   write_lock css_set_lock (cgroup iterator start)
+ *    task->alloc_lock
  *   read_lock css_set_lock (cgroup iterator start)
- *    sighand->siglock
+ *    sighand->siglock (fake signal delivery inside freeze_task())
  *
  * freezer_write() (unfreeze):
  * cgroup_mutex
  *  freezer->lock
+ *   write_lock css_set_lock (cgroup iterator start)
+ *    task->alloc_lock
  *   read_lock css_set_lock (cgroup iterator start)
- *    task->alloc_lock (to prevent races with freeze_task())
+ *    task->alloc_lock (inside thaw_process(), prevents race with refrigerator())
  *     sighand->siglock
  */
 static struct cgroup_subsys_state *freezer_create(struct cgroup_subsys *ss,
-- 
1.5.6.3
