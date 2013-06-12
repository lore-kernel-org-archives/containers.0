From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/11] cgroup: use kzalloc() and list_del_init()
Date: Wed, 12 Jun 2013 14:03:09 -0700
Message-ID: <1371070996-20613-5-git-send-email-tj__4352.06642509929$1371071056$gmane$org@kernel.org>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371070996-20613-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

There's no point in using kmalloc() and list_del() instead of the
clearing variants for trivial stuff.  We can live dangerously
elsewhere.  Use kzalloc() and list_del_init() instead and drop 0
inits.

While at it, do trivial code reorganization in cgroup_file_open().

This patch doesn't introduce any functional changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0b5cd0e..585f0a5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -404,8 +404,8 @@ static void __put_css_set(struct css_set *cset, int taskexit)
 	list_for_each_entry_safe(link, tmp_link, &cset->cgrp_links, cgrp_link) {
 		struct cgroup *cgrp = link->cgrp;
 
-		list_del(&link->cset_link);
-		list_del(&link->cgrp_link);
+		list_del_init(&link->cset_link);
+		list_del_init(&link->cgrp_link);
 
 		/*
 		 * We may not be holding cgroup_mutex, and if cgrp->count is
@@ -576,7 +576,7 @@ static void free_cgrp_cset_links(struct list_head *links_to_free)
 	struct cgrp_cset_link *link, *tmp_link;
 
 	list_for_each_entry_safe(link, tmp_link, links_to_free, cset_link) {
-		list_del(&link->cset_link);
+		list_del_init(&link->cset_link);
 		kfree(link);
 	}
 }
@@ -597,7 +597,7 @@ static int allocate_cgrp_cset_links(int count, struct list_head *tmp_links)
 	INIT_LIST_HEAD(tmp_links);
 
 	for (i = 0; i < count; i++) {
-		link = kmalloc(sizeof(*link), GFP_KERNEL);
+		link = kzalloc(sizeof(*link), GFP_KERNEL);
 		if (!link) {
 			free_cgrp_cset_links(tmp_links);
 			return -ENOMEM;
@@ -658,7 +658,7 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	if (cset)
 		return cset;
 
-	cset = kmalloc(sizeof(*cset), GFP_KERNEL);
+	cset = kzalloc(sizeof(*cset), GFP_KERNEL);
 	if (!cset)
 		return NULL;
 
@@ -1754,14 +1754,14 @@ static void cgroup_kill_sb(struct super_block *sb) {
 	write_lock(&css_set_lock);
 
 	list_for_each_entry_safe(link, tmp_link, &cgrp->cset_links, cset_link) {
-		list_del(&link->cset_link);
-		list_del(&link->cgrp_link);
+		list_del_init(&link->cset_link);
+		list_del_init(&link->cgrp_link);
 		kfree(link);
 	}
 	write_unlock(&css_set_lock);
 
 	if (!list_empty(&root->root_list)) {
-		list_del(&root->root_list);
+		list_del_init(&root->root_list);
 		root_count--;
 	}
 
@@ -2478,10 +2478,12 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	cft = __d_cft(file->f_dentry);
 
 	if (cft->read_map || cft->read_seq_string) {
-		struct cgroup_seqfile_state *state =
-			kzalloc(sizeof(*state), GFP_USER);
+		struct cgroup_seqfile_state *state;
+
+		state = kzalloc(sizeof(*state), GFP_USER);
 		if (!state)
 			return -ENOMEM;
+
 		state->cft = cft;
 		state->cgroup = __d_cgrp(file->f_dentry->d_parent);
 		file->f_op = &cgroup_seqfile_operations;
@@ -3514,7 +3516,7 @@ static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
 		}
 	}
 	/* entry not found; create a new one */
-	l = kmalloc(sizeof(struct cgroup_pidlist), GFP_KERNEL);
+	l = kzalloc(sizeof(struct cgroup_pidlist), GFP_KERNEL);
 	if (!l) {
 		mutex_unlock(&cgrp->pidlist_mutex);
 		return l;
@@ -3523,8 +3525,6 @@ static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
 	down_write(&l->mutex);
 	l->key.type = type;
 	l->key.ns = get_pid_ns(ns);
-	l->use_count = 0; /* don't increment here */
-	l->list = NULL;
 	l->owner = cgrp;
 	list_add(&l->links, &cgrp->pidlists);
 	mutex_unlock(&cgrp->pidlist_mutex);
@@ -3738,7 +3738,7 @@ static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 	BUG_ON(!l->use_count);
 	if (!--l->use_count) {
 		/* we're the last user if refcount is 0; remove and free */
-		list_del(&l->links);
+		list_del_init(&l->links);
 		mutex_unlock(&l->owner->pidlist_mutex);
 		pidlist_free(l->list);
 		put_pid_ns(l->key.ns);
-- 
1.8.2.1
