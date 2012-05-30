From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 12/12] container quota: init/destroy container dqinfo on mount
	namespace.
Date: Wed, 30 May 2012 22:59:06 +0800
Message-ID: <1338389946-13711-13-git-send-email-jeff.liu@oracle.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338389946-13711-1-git-send-email-jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tytso-3s7WtUTddSA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

Initialize and destroy quota info when cloning a mount namespace or
free it up when the namespace was destroyed separately.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 fs/namespace.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 8823ba8..b12a054 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -23,6 +23,11 @@
 #include "pnode.h"
 #include "internal.h"
 
+#ifdef CONFIG_NS_QUOTA
+#include "ns_quota.h"
+#include "ns_quotaops.h"
+#endif
+
 #define HASH_SHIFT ilog2(PAGE_SIZE / sizeof(struct list_head))
 #define HASH_SIZE (1UL << HASH_SHIFT)
 
@@ -2204,6 +2209,17 @@ static struct mnt_namespace *alloc_mnt_ns(void)
 	INIT_LIST_HEAD(&new_ns->list);
 	init_waitqueue_head(&new_ns->poll);
 	new_ns->event = 0;
+#ifdef CONFIG_NS_QUOTA
+	/*
+	 * Don't trying to enable the corresponding disk quota stuff
+	 * at the this stage for now.  We need to come up with a
+	 * reasonable definition for mount namespace or container disk
+	 * quotas.
+	 */
+	new_ns->ns_qcop = NULL;
+	new_ns->ns_dqop = NULL;
+	new_ns->ns_dqinfo = NULL;
+#endif
 	return new_ns;
 }
 
@@ -2250,6 +2266,15 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 		return ERR_PTR(-ENOMEM);
 	}
 	new_ns->root = new;
+#ifdef CONFIG_NS_QUOTA
+	/*
+	 * Initialize disk quota stuff if the current mount namespace is
+	 * cloned for containers.
+	 */
+	new_ns->ns_qcop = &ns_quotactl_operations;
+	new_ns->ns_dqop = &ns_dquot_operations;
+	ns_dqinfo_init(new_ns);
+#endif
 	br_write_lock(vfsmount_lock);
 	list_add_tail(&new_ns->list, &new->mnt_list);
 	br_write_unlock(vfsmount_lock);
@@ -2598,6 +2623,9 @@ void put_mnt_ns(struct mnt_namespace *ns)
 	down_write(&namespace_sem);
 	br_write_lock(vfsmount_lock);
 	umount_tree(ns->root, 0, &umount_list);
+#ifdef CONFIG_NS_QUOTA
+	ns_dqinfo_destroy(ns);
+#endif
 	br_write_unlock(vfsmount_lock);
 	up_write(&namespace_sem);
 	release_mounts(&umount_list);
-- 
1.7.9
