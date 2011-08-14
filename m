From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v3 2/4] Keep nr_dentry per super block
Date: Sun, 14 Aug 2011 19:13:50 +0400
Message-ID: <1313334832-1150-3-git-send-email-glommer@parallels.com>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1313334832-1150-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Now that we have per-sb shrinkers, it makes sense to have nr_dentries
stored per sb as well. We turn them into per-cpu counters so we can
keep acessing them without locking.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/dcache.c        |   12 +++++++++++-
 fs/super.c         |    4 ++++
 include/linux/fs.h |    2 ++
 3 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index b05aac3..815d9fd 100644
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
+	percpu_counter_dec(&dentry->d_sb->s_nr_dentry);
+
 	if (dentry->d_op && dentry->d_op->d_release)
 		dentry->d_op->d_release(dentry);
 
@@ -1224,8 +1230,12 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	INIT_LIST_HEAD(&dentry->d_alias);
 	INIT_LIST_HEAD(&dentry->d_u.d_child);
 	d_set_d_op(dentry, dentry->d_sb->s_d_op);
-
+	/*
+	 * It is cheaper to keep a global counter separate
+	 * then to scan through all superblocks when needed
+	 */
 	this_cpu_inc(nr_dentry);
+	percpu_counter_inc(&dentry->d_sb->s_nr_dentry);
 
 	return dentry;
 }
diff --git a/fs/super.c b/fs/super.c
index 3f56a26..e95ac4f 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -119,6 +119,9 @@ static struct super_block *alloc_super(struct file_system_type *type)
 			s = NULL;
 			goto out;
 		}
+
+		percpu_counter_init(&s->s_nr_dentry, 0);
+
 #ifdef CONFIG_SMP
 		s->s_files = alloc_percpu(struct list_head);
 		if (!s->s_files) {
@@ -199,6 +202,7 @@ static inline void destroy_super(struct super_block *s)
 #ifdef CONFIG_SMP
 	free_percpu(s->s_files);
 #endif
+	percpu_counter_destroy(&s->s_nr_dentry);
 	security_sb_free(s);
 	kfree(s->s_subtype);
 	kfree(s->s_options);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f23bcb7..8150f52 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1399,6 +1399,8 @@ struct super_block {
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	int			s_nr_dentry_unused;	/* # of dentry on lru */
 
+	struct percpu_counter 	s_nr_dentry;		/* # of dentry on this sb */
+
 	/* s_inode_lru_lock protects s_inode_lru and s_nr_inodes_unused */
 	spinlock_t		s_inode_lru_lock ____cacheline_aligned_in_smp;
 	struct list_head	s_inode_lru;		/* unused inode lru */
-- 
1.7.6
