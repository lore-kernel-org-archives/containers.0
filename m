From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC][PATCH] devcg: cache the last matched whitelist item
Date: Tue, 14 Apr 2009 09:01:41 +0800
Message-ID: <49E3E075.6050103@cn.fujitsu.com>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

While I was doing testing by open/close files like this:
	for (i = 0; i < LOOP; i++) {
		fd = open("/dev/null");
		close(fd);
	}
It got a bit slower when devcg is used, so I made this patch
to speed it up.

But walking through whitelist in devcgroup_inode_permission()
doesn't seem to be a hot-path, if so this patch probably doesn't
worth it, and it may not work well under real workload.

Just post it to see if someone thinks it's useful.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---

based on mainline.

---
 device_cgroup.c |   53 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 36 insertions(+), 17 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 5fda7df..39ddf2b 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -41,6 +41,7 @@ struct dev_whitelist_item {
 struct dev_cgroup {
 	struct cgroup_subsys_state css;
 	struct list_head whitelist;
+	dev_whitelist_item *cache;
 };
 
 static inline struct dev_cgroup *css_to_devcgroup(struct cgroup_subsys_state *s)
@@ -153,6 +154,8 @@ static void dev_whitelist_rm(struct dev_cgroup *dev_cgroup,
 remove:
 		walk->access &= ~wh->access;
 		if (!walk->access) {
+			if (walk == dev_cgroup->cache)
+				dev_cgroup->cache = NULL;
 			list_del_rcu(&walk->list);
 			call_rcu(&walk->rcu, whitelist_item_free);
 		}
@@ -473,6 +476,26 @@ struct cgroup_subsys devices_subsys = {
 	.subsys_id = devices_subsys_id,
 };
 
+int __devcgroup_inode_permission(struct inode *inode, int mask,
+				 struct dev_whitelist_item *wh)
+{
+	if (wh->type & DEV_ALL)
+		return 1;
+	if (wh->type & DEV_BLOCK && !S_ISBLK(inode->i_mode))
+		return 0;
+	if (wh->type & DEV_CHAR && !S_ISCHR(inode->i_mode))
+		return 0;
+	if (wh->major != ~0 && wh->major != imajor(inode))
+		return 0;
+	if (wh->minor != ~0 && wh->minor != iminor(inode))
+		return 0;
+	if ((mask & MAY_WRITE) && !(wh->access & ACC_WRITE))
+		return 0;
+	if ((mask & MAY_READ) && !(wh->access & ACC_READ))
+		return 0;
+	return 1;
+}
+
 int devcgroup_inode_permission(struct inode *inode, int mask)
 {
 	struct dev_cgroup *dev_cgroup;
@@ -488,24 +511,20 @@ int devcgroup_inode_permission(struct inode *inode, int mask)
 
 	dev_cgroup = task_devcgroup(current);
 
+	if (dev_cgroup->cache) {
+		wh = dev_cgroup->cache;
+		if (__devcgroup_inode_permission(inode, mask, wh)) {
+			rcu_read_unlock();
+			return 0;
+		}
+	}
+
 	list_for_each_entry_rcu(wh, &dev_cgroup->whitelist, list) {
-		if (wh->type & DEV_ALL)
-			goto acc_check;
-		if ((wh->type & DEV_BLOCK) && !S_ISBLK(inode->i_mode))
-			continue;
-		if ((wh->type & DEV_CHAR) && !S_ISCHR(inode->i_mode))
-			continue;
-		if (wh->major != ~0 && wh->major != imajor(inode))
-			continue;
-		if (wh->minor != ~0 && wh->minor != iminor(inode))
-			continue;
-acc_check:
-		if ((mask & MAY_WRITE) && !(wh->access & ACC_WRITE))
-			continue;
-		if ((mask & MAY_READ) && !(wh->access & ACC_READ))
-			continue;
-		rcu_read_unlock();
-		return 0;
+		if (__devcgroup_inode_permission(inode, mask, wh)) {
+			dev_cgroup->cache = wh;
+			rcu_read_unlock();
+			return 0;
+		}
 	}
 
 	rcu_read_unlock();
