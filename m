From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/3] kernfs: make kernfs_notify() trigger inotify events too
Date: Wed,  9 Apr 2014 11:07:31 -0400
Message-ID: <1397056052-2829-3-git-send-email-tj@kernel.org>
References: <1397056052-2829-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1397056052-2829-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

kernfs_notify() is used to indicate either new data is available or
the content of a file has changed.  It currently only triggers poll
which may not be the most convenient to monitor especially when there
are a lot to monitor.  Let's hook it up to fsnotify too so that the
events can be monitored via inotify too.

fsnotify_modify() requires file * but kernfs_notify() doesn't have any
specific file associated; however, we can walk all super_blocks
associated with a kernfs_root and as kernfs always associate one ino
with inode and one dentry with an inode, it's trivial to look up the
dentry associated with a given kernfs_node.  As any active monitor
would pin dentry, just looking up existing dentry is enough.  This
patch looks up the dentry associated with the specified kernfs_node
and generates events equivalent to fsnotify_modify().

Note that as fsnotify doesn't provide fsnotify_modify() equivalent
which can be called with dentry, kernfs_notify() directly calls
fsnotify_parent() and fsnotify().  It might be better to add a wrapper
in fsnotify.h instead.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: John McCutchan <john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org>
Cc: Robert Love <rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org>
Cc: Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>
---
 fs/kernfs/file.c | 41 +++++++++++++++++++++++++++++++++++------
 1 file changed, 35 insertions(+), 6 deletions(-)

diff --git a/fs/kernfs/file.c b/fs/kernfs/file.c
index ddcb471..774af54 100644
--- a/fs/kernfs/file.c
+++ b/fs/kernfs/file.c
@@ -14,6 +14,7 @@
 #include <linux/poll.h>
 #include <linux/pagemap.h>
 #include <linux/sched.h>
+#include <linux/fsnotify.h>
 
 #include "kernfs-internal.h"
 
@@ -784,20 +785,48 @@ static unsigned int kernfs_fop_poll(struct file *filp, poll_table *wait)
  */
 void kernfs_notify(struct kernfs_node *kn)
 {
+	struct kernfs_root *root = kernfs_root(kn);
 	struct kernfs_open_node *on;
+	struct kernfs_super_info *info;
 	unsigned long flags;
 
+	if (WARN_ON(kernfs_type(kn) != KERNFS_FILE))
+		return;
+
+	/* kick poll */
 	spin_lock_irqsave(&kernfs_open_node_lock, flags);
 
-	if (!WARN_ON(kernfs_type(kn) != KERNFS_FILE)) {
-		on = kn->attr.open;
-		if (on) {
-			atomic_inc(&on->event);
-			wake_up_interruptible(&on->poll);
-		}
+	on = kn->attr.open;
+	if (on) {
+		atomic_inc(&on->event);
+		wake_up_interruptible(&on->poll);
 	}
 
 	spin_unlock_irqrestore(&kernfs_open_node_lock, flags);
+
+	/* kick fsnotify */
+	mutex_lock(&kernfs_mutex);
+
+	list_for_each_entry(info, &root->supers, node) {
+		struct inode *inode;
+		struct dentry *dentry;
+
+		inode = ilookup(info->sb, kn->ino);
+		if (!inode)
+			continue;
+
+		dentry = d_find_any_alias(inode);
+		if (dentry) {
+			fsnotify_parent(NULL, dentry, FS_MODIFY);
+			fsnotify(inode, FS_MODIFY, inode, FSNOTIFY_EVENT_INODE,
+				 NULL, 0);
+			dput(dentry);
+		}
+
+		iput(inode);
+	}
+
+	mutex_unlock(&kernfs_mutex);
 }
 EXPORT_SYMBOL_GPL(kernfs_notify);
 
-- 
1.9.0
