From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: fix lockdep subclasses overflow
Date: Wed, 04 Feb 2009 17:11:51 +0800
Message-ID: <49895BD7.8090405__4874.32524464584$1233738992$gmane$org@cn.fujitsu.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

I enabled all cgroup subsystems when compiling kernel, and then:
 # mount -t cgroup -o net_cls xxx /mnt
 # mkdir /mnt/0

This showed up immediately:
 BUG: MAX_LOCKDEP_SUBCLASSES too low!
 turning off the locking correctness validator.

It's caused by the cgroup hierarchy lock:
	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
		struct cgroup_subsys *ss = subsys[i];
		if (ss->root == root)
			mutex_lock_nested(&ss->hierarchy_mutex, i);
	}

Now we have 9 cgroup subsystems, and the above 'i' for net_cls is 9, but
MAX_LOCKDEP_SUBCLASSES is 8.

This patch uses different lockdep keys for different subsystems.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |    1 +
 kernel/cgroup.c        |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index e4e8e11..499900d 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -378,6 +378,7 @@ struct cgroup_subsys {
 	 * - initiating hotplug events
 	 */
 	struct mutex hierarchy_mutex;
+	struct lock_class_key subsys_key;
 
 	/*
 	 * Link to parent, and list entry in parent's children.
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5a54ff4..e14db9c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2351,7 +2351,7 @@ static void cgroup_lock_hierarchy(struct cgroupfs_root *root)
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
 		if (ss->root == root)
-			mutex_lock_nested(&ss->hierarchy_mutex, i);
+			mutex_lock(&ss->hierarchy_mutex);
 	}
 }
 
@@ -2637,6 +2637,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	BUG_ON(!list_empty(&init_task.tasks));
 
 	mutex_init(&ss->hierarchy_mutex);
+	lockdep_set_class(&ss->hierarchy_mutex, &ss->subsys_key);
 	ss->active = 1;
 }
 
-- 
1.5.4.rc3
