From: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 11/11] container quota: bill container disk blocks alloc/free
	on ext4.
Date: Wed, 30 May 2012 22:59:05 +0800
Message-ID: <1338389946-13711-12-git-send-email-jeff.liu@oracle.com>
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

Bill up container disk blocks allocation and free on ext4.

Signed-off-by: Jie Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 fs/ext4/balloc.c  |    4 ++++
 fs/ext4/mballoc.c |   17 ++++++++++++++---
 fs/ext4/xattr.c   |    7 +++++++
 3 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
index c45c411..417d1de 100644
--- a/fs/ext4/balloc.c
+++ b/fs/ext4/balloc.c
@@ -21,6 +21,8 @@
 #include "ext4_jbd2.h"
 #include "mballoc.h"
 
+#include "../ns_quotaops.h"
+
 #include <trace/events/ext4.h>
 
 static unsigned ext4_num_base_meta_clusters(struct super_block *sb,
@@ -547,6 +549,8 @@ ext4_fsblk_t ext4_new_meta_blocks(handle_t *handle, struct inode *inode,
 		spin_unlock(&EXT4_I(inode)->i_block_reservation_lock);
 		dquot_alloc_block_nofail(inode,
 				EXT4_C2B(EXT4_SB(inode->i_sb), ar.len));
+		ns_dquot_alloc_block_nofail(inode,
+				EXT4_C2B(EXT4_SB(inode->i_sb), ar.len));
 	}
 	return ret;
 }
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 99ab428..a373a9a 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -27,6 +27,8 @@
 #include <linux/slab.h>
 #include <trace/events/ext4.h>
 
+#include "../ns_quotaops.h"
+
 /*
  * MUSTDO:
  *   - test ext4_ext_search_left() and ext4_ext_search_right()
@@ -4271,10 +4273,14 @@ ext4_fsblk_t ext4_mb_new_blocks(handle_t *handle,
 		if (ar->flags & EXT4_MB_USE_ROOT_BLOCKS) {
 			dquot_alloc_block_nofail(ar->inode,
 						 EXT4_C2B(sbi, ar->len));
+			ns_dquot_alloc_block_nofail(ar->inode,
+						 EXT4_C2B(sbi, ar->len));
 		} else {
 			while (ar->len &&
 				dquot_alloc_block(ar->inode,
-						  EXT4_C2B(sbi, ar->len))) {
+						  EXT4_C2B(sbi, ar->len)) &&
+				ns_dquot_alloc_block(ar->inode,
+						     EXT4_C2B(sbi, ar->len))) {
 
 				ar->flags |= EXT4_MB_HINT_NOPREALLOC;
 				ar->len--;
@@ -4353,8 +4359,11 @@ repeat:
 out:
 	if (ac)
 		kmem_cache_free(ext4_ac_cachep, ac);
-	if (inquota && ar->len < inquota)
+	if (inquota && ar->len < inquota) {
 		dquot_free_block(ar->inode, EXT4_C2B(sbi, inquota - ar->len));
+		ns_dquot_free_block(ar->inode,
+				    EXT4_C2B(sbi, inquota - ar->len));
+	}
 	if (!ar->len) {
 		if (!ext4_test_inode_state(ar->inode,
 					   EXT4_STATE_DELALLOC_RESERVED))
@@ -4673,8 +4682,10 @@ do_more:
 
 	freed += count;
 
-	if (!(flags & EXT4_FREE_BLOCKS_NO_QUOT_UPDATE))
+	if (!(flags & EXT4_FREE_BLOCKS_NO_QUOT_UPDATE)) {
 		dquot_free_block(inode, EXT4_C2B(sbi, count_clusters));
+		ns_dquot_free_block(inode, EXT4_C2B(sbi, count_clusters));
+	}
 
 	/* We dirtied the bitmap block */
 	BUFFER_TRACE(bitmap_bh, "dirtied bitmap block");
diff --git a/fs/ext4/xattr.c b/fs/ext4/xattr.c
index e88748e..1d6bc49 100644
--- a/fs/ext4/xattr.c
+++ b/fs/ext4/xattr.c
@@ -61,6 +61,8 @@
 #include "xattr.h"
 #include "acl.h"
 
+#include "../ns_quotaops.h"
+
 #define BHDR(bh) ((struct ext4_xattr_header *)((bh)->b_data))
 #define ENTRY(ptr) ((struct ext4_xattr_entry *)(ptr))
 #define BFIRST(bh) ENTRY(BHDR(bh)+1)
@@ -496,6 +498,7 @@ ext4_xattr_release_block(handle_t *handle, struct inode *inode,
 		if (IS_SYNC(inode))
 			ext4_handle_sync(handle);
 		dquot_free_block(inode, 1);
+		ns_dquot_free_block(inode, 1);
 		ea_bdebug(bh, "refcount now=%d; releasing",
 			  le32_to_cpu(BHDR(bh)->h_refcount));
 	}
@@ -787,6 +790,9 @@ inserted:
 				error = dquot_alloc_block(inode, 1);
 				if (error)
 					goto cleanup;
+				error = ns_dquot_alloc_block(inode, 1);
+				if (error)
+					goto cleanup;
 				error = ext4_journal_get_write_access(handle,
 								      new_bh);
 				if (error)
@@ -881,6 +887,7 @@ cleanup:
 
 cleanup_dquot:
 	dquot_free_block(inode, 1);
+	ns_dquot_free_block(inode, 1);
 	goto cleanup;
 
 bad_block:
-- 
1.7.9
