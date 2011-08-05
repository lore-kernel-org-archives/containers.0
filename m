From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 2/4] Keep nr_dentry per super block
Date: Fri,  5 Aug 2011 04:35:42 +0400
Message-ID: <1312504544-1108-3-git-send-email-glommer@parallels.com>
References: <1312504544-1108-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1312504544-1108-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Now that we have per-sb shrinkers, it makes sense to have nr_dentries
stored per sb as well. We turn them into per-cpu counters so we can
keep acessing them without locking.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
---
 fs/dcache.c        |   12 +++++++++++-
 fs/super.c         |   15 ++++++++++++++-
 include/linux/fs.h |    2 ++
 3 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index b05aac3..ac19d24 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -151,7 +151,13 @@ static void __d_free(struct rcu_head *head)
 static void d_free(struct dentry *dentry)
 {
 	BUG_ON(dentry->d_count);
+	/*
+	 * It is cheaper to keep a global counter separate
+	 * then to scan through all superblocks when needed
+	 */
 	this_cpu_dec(nr_dentry);
+	this_cpu_dec(*dentry->d_sb->s_nr_dentry);
+
 	if (dentry->d_op && dentry->d_op->d_release)
 		dentry->d_op->d_release(dentry);
 
@@ -1224,7 +1230,11 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	INIT_LIST_HEAD(&dentry->d_alias);
 	INIT_LIST_HEAD(&dentry->d_u.d_child);
 	d_set_d_op(dentry, dentry->d_sb->s_d_op);
-
+	/*
+	 * It is cheaper to keep a global counter separate
+	 * then to scan through all superblocks when needed
+	 */
+	this_cpu_inc(*dentry->d_sb->s_nr_dentry);
 	this_cpu_inc(nr_dentry);
 
 	return dentry;
diff --git a/fs/super.c b/fs/super.c
index 3f56a26..9345385 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -112,6 +112,7 @@ static struct super_block *alloc_super(struct file_system_type *type)
 {
 	struct super_block *s = kzalloc(sizeof(struct super_block),  GFP_USER);
 	static const struct super_operations default_op;
+	int i;
 
 	if (s) {
 		if (security_sb_alloc(s)) {
@@ -119,15 +120,26 @@ static struct super_block *alloc_super(struct file_system_type *type)
 			s = NULL;
 			goto out;
 		}
+
+		s->s_nr_dentry = alloc_percpu(int);
+		if (!s->s_nr_dentry) {
+			security_sb_free(s);
+			kfree(s);
+			s = NULL;
+			goto out;
+		}
+		for_each_possible_cpu(i)
+			*per_cpu_ptr(s->s_nr_dentry, i) = 0;
+
 #ifdef CONFIG_SMP
 		s->s_files = alloc_percpu(struct list_head);
 		if (!s->s_files) {
+			free_percpu(s->s_nr_dentry);
 			security_sb_free(s);
 			kfree(s);
 			s = NULL;
 			goto out;
 		} else {
-			int i;
 
 			for_each_possible_cpu(i)
 				INIT_LIST_HEAD(per_cpu_ptr(s->s_files, i));
@@ -198,6 +210,7 @@ static inline void destroy_super(struct super_block *s)
 {
 #ifdef CONFIG_SMP
 	free_percpu(s->s_files);
+	free_percpu(s->s_nr_dentry);
 #endif
 	security_sb_free(s);
 	kfree(s->s_subtype);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f23bcb7..35113fd 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1399,6 +1399,8 @@ struct super_block {
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	int			s_nr_dentry_unused;	/* # of dentry on lru */
 
+	int __percpu 		*s_nr_dentry;		/* # of dentry on this sb */
+
 	/* s_inode_lru_lock protects s_inode_lru and s_nr_inodes_unused */
 	spinlock_t		s_inode_lru_lock ____cacheline_aligned_in_smp;
 	struct list_head	s_inode_lru;		/* unused inode lru */
-- 
1.7.6
