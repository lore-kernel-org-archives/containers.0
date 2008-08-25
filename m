From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] devcgroup: fix race against rmdir()
Date: Mon, 25 Aug 2008 10:22:06 +0800
Message-ID: <48B2174E.9060608__10839.7127165974$1219631318$gmane$org@cn.fujitsu.com>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

During the use of a dev_cgroup, we should guarantee the corresponding
cgroup won't be deleted (i.e. via rmdir). This can be done through
css_get(&dev_cgroup->css), but here we can just get and use the
dev_cgroup under rcu_read_lock.

And also remove checking NULL dev_cgroup, it won't be NULL since a task
always belongs to a cgroup.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 security/device_cgroup.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 7bd296c..46f2397 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -508,12 +508,11 @@ int devcgroup_inode_permission(struct inode *inode, int mask)
 		return 0;
 	if (!S_ISBLK(inode->i_mode) && !S_ISCHR(inode->i_mode))
 		return 0;
-	dev_cgroup = css_to_devcgroup(task_subsys_state(current,
-				devices_subsys_id));
-	if (!dev_cgroup)
-		return 0;
 
 	rcu_read_lock();
+
+	dev_cgroup = task_devcgroup(current);
+
 	list_for_each_entry_rcu(wh, &dev_cgroup->whitelist, list) {
 		if (wh->type & DEV_ALL)
 			goto acc_check;
@@ -533,6 +532,7 @@ acc_check:
 		rcu_read_unlock();
 		return 0;
 	}
+
 	rcu_read_unlock();
 
 	return -EPERM;
@@ -543,12 +543,10 @@ int devcgroup_inode_mknod(int mode, dev_t dev)
 	struct dev_cgroup *dev_cgroup;
 	struct dev_whitelist_item *wh;
 
-	dev_cgroup = css_to_devcgroup(task_subsys_state(current,
-				devices_subsys_id));
-	if (!dev_cgroup)
-		return 0;
-
 	rcu_read_lock();
+
+	dev_cgroup = task_devcgroup(current);
+
 	list_for_each_entry(wh, &dev_cgroup->whitelist, list) {
 		if (wh->type & DEV_ALL)
 			goto acc_check;
@@ -566,6 +564,8 @@ acc_check:
 		rcu_read_unlock();
 		return 0;
 	}
+
 	rcu_read_unlock();
+
 	return -EPERM;
 }
-- 
1.5.4.rc3
