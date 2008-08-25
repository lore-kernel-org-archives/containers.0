From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] devcgroup: use kmemdup()
Date: Mon, 25 Aug 2008 10:22:14 +0800
Message-ID: <48B21756.4020208__29077.2501881749$1219631240$gmane$org@cn.fujitsu.com>
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

This saves 40 bytes on my x86_32 box.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 security/device_cgroup.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 46f2397..9c625f6 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -84,13 +84,9 @@ static int dev_whitelist_copy(struct list_head *dest, struct list_head *orig)
 	struct dev_whitelist_item *wh, *tmp, *new;
 
 	list_for_each_entry(wh, orig, list) {
-		new = kmalloc(sizeof(*wh), GFP_KERNEL);
+		new = kmemdup(wh, sizeof(*wh), GFP_KERNEL);
 		if (!new)
 			goto free_and_exit;
-		new->major = wh->major;
-		new->minor = wh->minor;
-		new->type = wh->type;
-		new->access = wh->access;
 		list_add_tail(&new->list, dest);
 	}
 
@@ -114,11 +110,10 @@ static int dev_whitelist_add(struct dev_cgroup *dev_cgroup,
 {
 	struct dev_whitelist_item *whcopy, *walk;
 
-	whcopy = kmalloc(sizeof(*whcopy), GFP_KERNEL);
+	whcopy = kmemdup(wh, sizeof(*wh), GFP_KERNEL);
 	if (!whcopy)
 		return -ENOMEM;
 
-	memcpy(whcopy, wh, sizeof(*whcopy));
 	spin_lock(&dev_cgroup->lock);
 	list_for_each_entry(walk, &dev_cgroup->whitelist, list) {
 		if (walk->type != wh->type)
-- 
1.5.4.rc3
