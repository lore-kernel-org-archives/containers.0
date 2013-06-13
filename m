From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/11] cgroup: use kzalloc() instead of kmalloc()
Date: Wed, 12 Jun 2013 21:04:51 -0700
Message-ID: <1371096298-24402-5-git-send-email-tj@kernel.org>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371096298-24402-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

There's no point in using kmalloc() instead of the clearing variant
for trivial stuff.  We can live dangerously elsewhere.  Use kzalloc()
instead and drop 0 inits.

While at it, do trivial code reorganization in cgroup_file_open().

This patch doesn't introduce any functional changes.

v2: I was caught in the very distant past where list_del() didn't
    poison and the initial version converted list_del()s to
    list_del_init()s too.  Li and Kent took me out of the stasis
    chamber.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0b5cd0e..e308ee7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
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
-- 
1.8.2.1
