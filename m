From: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH 2/5] ima: Add ns_status for storing namespaced iint data
Date: Thu, 20 Jul 2017 18:50:30 -0400
Message-ID: <20170720225033.21298-3-mkayaalp__13889.0939103023$1500591316$gmane$org@linux.vnet.ibm.com>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170720225033.21298-1-mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds an rbtree to the IMA namespace structure that stores a
namespaced version of iint->flags in ns_status struct. Similar to the
integrity_iint_cache, both the iint ns_struct are looked up using the
inode pointer value. The lookup, allocate, and insertion code is also
similar, except ns_struct is not free'd when the inode is free'd.
Instead, the lookup verifies the i_ino and i_generation fields are also a
match. A lazy clean up of the rbtree that removes free'd inodes could be
implemented to reclaim the invalid entries.

Signed-off-by: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 include/linux/ima.h             |   3 +
 security/integrity/ima/ima.h    |  16 ++++++
 security/integrity/ima/ima_ns.c | 120 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 139 insertions(+)

diff --git a/include/linux/ima.h b/include/linux/ima.h
index 11e4841..3fdf56f 100644
--- a/include/linux/ima.h
+++ b/include/linux/ima.h
@@ -111,6 +111,9 @@ struct ima_namespace {
 	struct user_namespace *user_ns;
 	struct ns_common ns;
 	struct ima_namespace *parent;
+	struct rb_root ns_status_tree;
+	rwlock_t ns_status_lock;
+	struct kmem_cache *ns_status_cache;
 };
 
 extern struct ima_namespace init_ima_ns;
diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
index 8a8234a..5ab769a 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -128,6 +128,14 @@ static inline void ima_load_kexec_buffer(void) {}
  */
 extern bool ima_canonical_fmt;
 
+struct ns_status {
+	struct rb_node rb_node;
+	struct inode *inode;
+	ino_t i_ino;
+	u32 i_generation;
+	unsigned long flags;
+};
+
 /* Internal IMA function definitions */
 int ima_init(void);
 int ima_fs_init(void);
@@ -293,11 +301,19 @@ static inline int ima_read_xattr(struct dentry *dentry,
 
 #ifdef CONFIG_IMA_NS
 int ima_ns_init(void);
+struct ns_status *ima_get_ns_status(struct ima_namespace *ns,
+				    struct inode *inode);
 #else
 static inline int ima_ns_init(void)
 {
 	return 0;
 }
+
+static inline struct ns_status *ima_get_ns_status(struct ima_namespace *ns,
+						  struct inode *inode)
+{
+	return NULL;
+}
 #endif /* CONFIG_IMA_NS */
 
 /* LSM based policy rules require audit */
diff --git a/security/integrity/ima/ima_ns.c b/security/integrity/ima/ima_ns.c
index 383217b..5ec5a4b 100644
--- a/security/integrity/ima/ima_ns.c
+++ b/security/integrity/ima/ima_ns.c
@@ -20,6 +20,9 @@ static void get_ima_ns(struct ima_namespace *ns);
 
 int ima_init_namespace(struct ima_namespace *ns)
 {
+	ns->ns_status_tree = RB_ROOT;
+	rwlock_init(&ns->ns_status_lock);
+	ns->ns_status_cache = KMEM_CACHE(ns_status, SLAB_PANIC);
 	return 0;
 }
 
@@ -98,10 +101,24 @@ struct ima_namespace *copy_ima(unsigned long flags,
 	return new_ns;
 }
 
+static void free_ns_status_cache(struct ima_namespace *ns)
+{
+	struct ns_status *status, *next;
+
+	write_lock(&ns->ns_status_lock);
+	rbtree_postorder_for_each_entry_safe(status, next,
+					     &ns->ns_status_tree, rb_node)
+		kmem_cache_free(ns->ns_status_cache, status);
+	ns->ns_status_tree = RB_ROOT;
+	write_unlock(&ns->ns_status_lock);
+	kmem_cache_destroy(ns->ns_status_cache);
+}
+
 static void destroy_ima_ns(struct ima_namespace *ns)
 {
 	put_user_ns(ns->user_ns);
 	ns_free_inum(&ns->ns);
+	free_ns_status_cache(ns);
 	kfree(ns);
 }
 
@@ -181,3 +198,106 @@ struct ima_namespace init_ima_ns = {
 	.parent = NULL,
 };
 EXPORT_SYMBOL(init_ima_ns);
+
+/*
+ * __ima_ns_status_find - return the ns_status associated with an inode
+ */
+static struct ns_status *__ima_ns_status_find(struct ima_namespace *ns,
+					      struct inode *inode)
+{
+	struct ns_status *status;
+	struct rb_node *n = ns->ns_status_tree.rb_node;
+
+	while (n) {
+		status = rb_entry(n, struct ns_status, rb_node);
+
+		if (inode < status->inode)
+			n = n->rb_left;
+		else if (inode->i_ino > status->i_ino)
+			n = n->rb_right;
+		else
+			break;
+	}
+	if (!n)
+		return NULL;
+
+	return status;
+}
+
+/*
+ * ima_ns_status_find - return the ns_status associated with an inode
+ */
+static struct ns_status *ima_ns_status_find(struct ima_namespace *ns,
+					    struct inode *inode)
+{
+	struct ns_status *status;
+
+	read_lock(&ns->ns_status_lock);
+	status = __ima_ns_status_find(ns, inode);
+	read_unlock(&ns->ns_status_lock);
+
+	return status;
+}
+
+void insert_ns_status(struct ima_namespace *ns, struct inode *inode,
+		      struct ns_status *status)
+{
+	struct rb_node **p;
+	struct rb_node *node, *parent = NULL;
+	struct ns_status *test_status;
+
+	p = &ns->ns_status_tree.rb_node;
+	while (*p) {
+		parent = *p;
+		test_status = rb_entry(parent, struct ns_status, rb_node);
+		if (inode < test_status->inode)
+			p = &(*p)->rb_left;
+		else
+			p = &(*p)->rb_right;
+	}
+	node = &status->rb_node;
+	rb_link_node(node, parent, p);
+	rb_insert_color(node, &ns->ns_status_tree);
+}
+
+struct ns_status *ima_get_ns_status(struct ima_namespace *ns,
+				    struct inode *inode)
+{
+	struct ns_status *status;
+	int skip_insert = 0;
+
+	status = ima_ns_status_find(ns, inode);
+	if (status) {
+		/*
+		 * Unlike integrity_iint_cache we are not free'ing the
+		 * ns_status data when the inode is free'd. So, in addition to
+		 * checking the inode pointer, we need to make sure the
+		 * (i_generation, i_ino) pair matches as well. In the future
+		 * we might want to add support for lazily walking the rbtree
+		 * to clean it up.
+		 */
+		if (inode->i_ino == status->i_ino &&
+		    inode->i_generation == status->i_generation)
+			return status;
+
+		/* Same inode number is reused, overwrite the ns_status */
+		skip_insert = 1;
+	} else {
+		status = kmem_cache_alloc(ns->ns_status_cache, GFP_NOFS);
+		if (!status)
+			return ERR_PTR(-ENOMEM);
+	}
+
+	write_lock(&ns->ns_status_lock);
+
+	if (!skip_insert)
+		insert_ns_status(ns, inode, status);
+
+	status->inode = inode;
+	status->i_ino = inode->i_ino;
+	status->i_generation = inode->i_generation;
+	status->flags = 0UL;
+	write_unlock(&ns->ns_status_lock);
+
+	return status;
+}
-- 
2.9.4
