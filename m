From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 3/4] limit nr_dentries per superblock
Date: Fri,  5 Aug 2011 04:35:43 +0400
Message-ID: <1312504544-1108-4-git-send-email-glommer__39046.5417098769$1312504654$gmane$org@parallels.com>
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

This patch lays the foundation for us to limit the dcache size.
Each super block can have only a maximum amount of dentries under its
sub-tree. Allocation fails if we we're over limit and the cache
can't be pruned to free up space for the newcomers.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
---
 fs/dcache.c        |   25 +++++++++++++++++++++++++
 fs/super.c         |    1 +
 include/linux/fs.h |    1 +
 3 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index ac19d24..52a0faf 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1180,6 +1180,28 @@ void shrink_dcache_parent(struct dentry * parent)
 }
 EXPORT_SYMBOL(shrink_dcache_parent);
 
+static int dcache_mem_check(struct super_block *sb)
+{
+	int i;
+	int nr_dentry;
+	struct shrink_control sc = {
+		.gfp_mask = GFP_KERNEL,
+	};
+
+	do {
+		nr_dentry = 0;
+		for_each_possible_cpu(i)
+			nr_dentry += per_cpu(*sb->s_nr_dentry, i);
+
+		if (nr_dentry < sb->s_nr_dentry_max)
+			return 0;
+
+	/* nr_pages = 1, lru_pages = 0 should get delta ~ 2 */
+	} while (shrink_one_shrinker(&sb->s_shrink, &sc, 1, 0));
+
+	return -ENOMEM;
+}
+
 /**
  * __d_alloc	-	allocate a dcache entry
  * @sb: filesystem it will belong to
@@ -1195,6 +1217,9 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	struct dentry *dentry;
 	char *dname;
 
+	if (dcache_mem_check(sb))
+		return NULL;
+
 	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL);
 	if (!dentry)
 		return NULL;
diff --git a/fs/super.c b/fs/super.c
index 9345385..d9bcae8 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -130,6 +130,7 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		}
 		for_each_possible_cpu(i)
 			*per_cpu_ptr(s->s_nr_dentry, i) = 0;
+		s->s_nr_dentry_max = INT_MAX;
 
 #ifdef CONFIG_SMP
 		s->s_files = alloc_percpu(struct list_head);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 35113fd..e90dcb4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1399,6 +1399,7 @@ struct super_block {
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	int			s_nr_dentry_unused;	/* # of dentry on lru */
 
+	int 			s_nr_dentry_max;	/* max # of dentry on this sb*/
 	int __percpu 		*s_nr_dentry;		/* # of dentry on this sb */
 
 	/* s_inode_lru_lock protects s_inode_lru and s_nr_inodes_unused */
-- 
1.7.6
