From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 3/4] dcache set size
Date: Fri, 29 Jul 2011 17:44:18 +0400
Message-ID: <1311947059-17209-4-git-send-email-glommer__28440.1341843934$1311947156$gmane$org@parallels.com>
References: <1311947059-17209-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1311947059-17209-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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

Simple patch that provides a function allowing its caller to set
the maximum number of dentries that can exist at the same time
at a given super block. Will be used in a later patch.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
---
 fs/dcache.c            |   12 ++++++++++++
 include/linux/dcache.h |    1 +
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 3bdb106..4369aa2 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1202,6 +1202,18 @@ static int dcache_mem_check(struct super_block *sb)
 	return -ENOMEM;
 }
 
+int vfs_set_dcache_size(struct super_block *sb, int size)
+{
+	unsigned long dr = percpu_counter_sum_positive(&sb->s_nr_dentry); 
+
+	if (size != sb->s_nr_dentry_max)
+		prune_dcache_sb(sb, dr - size);
+
+	sb->s_nr_dentry_max = size;
+
+	return 0;
+}
+
 /**
  * __d_alloc	-	allocate a dcache entry
  * @sb: filesystem it will belong to
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index d37d2a7..cd1ab71 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -251,6 +251,7 @@ extern int d_invalidate(struct dentry *);
 
 /* only used at mount-time */
 extern struct dentry * d_alloc_root(struct inode *);
+extern int vfs_set_dcache_size(struct super_block *sb, int size);
 
 /* <clickety>-<click> the ramfs-type tree */
 extern void d_genocide(struct dentry *);
-- 
1.7.6
