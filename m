From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/10] ext3/4: Allow relinking to unlinked files
Date: Mon, 28 Feb 2011 20:05:08 -0800
Message-ID: <cbc5f629ca02554497bcb385039a2a300ef897f0.1298952288.git.matthltc@us.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
	<a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Orphan inodes (nlink == 0) have been forbidden from being linked back
into the ext3/4 filesystems as a means of dealing with a link/unlink
"race".

This patch effectively reverts 2988a7740dc0dd9a0cb56576e8fe1d777dff0db3

	"return ENOENT from ext3_link when racing with unlink"

which was discussed in the lkml thread:

	http://lkml.org/lkml/2007/1/12/200

The reverted commit was selected because disallowing relinking was just a
simpler solution -- not because removing tasks from the orphan list
was deemed difficult or incorrect.

Instead this patch utilizes the original patch proposed by Eric Sandeen.
Testing this patch with the orphan-repro.tar.bz2 code linked in that
thread seems to confirm that this patch does not reintroduce the OOPs.
Nonetheless, Amir Goldstein pointed out that if ext3_add_entry() fails
we'll also be left with a corrupted orphan list. So I've moved the orphan
removal code down to the spot where a successful return has been assured.

Eric's Original description (indented):

	Remove inode from the orphan list in ext3_link() if we might have
	raced with ext3_unlink(), which potentially put it on the list.
	If we're on the list with nlink > 0, we'll never get cleaned up
	properly and eventually may corrupt the list.

Unlike the reverted patch, this patch enables relinking an orphan inode
back into the filesystem. This relinking is extremely useful for
checkpoint/restart since it avoids incredibly costly and complex methods
of supporting checkpoint of tasks with open unlinked files. More on
how relink will be used can be found in the checkpoint/restart patches posted
with this patch.

Though relinking is a useful operation it may not be possible on all
filesystems. It appears to be possible in ext3/4 so this patch changes the
ext3/ext4 link functions to allow it and provide the .relink file operation
introduced earlier.

This assumes that in ext3/4 data written to unlinked files is not stored any
differently than data written to linked files. If that is not the case
I'd appreciate any pointers to the code showing where/how they are
handled differently. All I could find in ext3/4 was the orphan inode list.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
Cc: linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Amir Goldstein <amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
---
 fs/ext3/namei.c |   16 ++++++++--------
 fs/ext4/namei.c |   14 +++++++-------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/fs/ext3/namei.c b/fs/ext3/namei.c
index bce9dce..ceddffd 100644
--- a/fs/ext3/namei.c
+++ b/fs/ext3/namei.c
@@ -1984,7 +1984,7 @@ out_unlock:
 
 /*
  * ext3_orphan_del() removes an unlinked or truncated inode from the list
- * of such inodes stored on disk, because it is finally being cleaned up.
+ * of such inodes stored on disk.
  */
 int ext3_orphan_del(handle_t *handle, struct inode *inode)
 {
@@ -2242,13 +2242,6 @@ static int ext3_link (struct dentry * old_dentry,
 
 	dquot_initialize(dir);
 
-	/*
-	 * Return -ENOENT if we've raced with unlink and i_nlink is 0.  Doing
-	 * otherwise has the potential to corrupt the orphan inode list.
-	 */
-	if (inode->i_nlink == 0)
-		return -ENOENT;
-
 retry:
 	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS(dir->i_sb) +
 					EXT3_INDEX_EXTRA_TRANS_BLOCKS);
@@ -2266,6 +2259,12 @@ retry:
 	if (!err) {
 		ext3_mark_inode_dirty(handle, inode);
 		d_instantiate(dentry, inode);
+		if (inode->i_nlink == 1)
+			/*
+			 * i_nlink went from 0 to 1 thus the inode is no
+			 * longer an orphan.
+			 */
+			ext3_orphan_del(handle, inode);
 	} else {
 		drop_nlink(inode);
 		iput(inode);
@@ -2450,6 +2449,7 @@ end_rename:
 const struct inode_operations ext3_dir_inode_operations = {
 	.create		= ext3_create,
 	.lookup		= ext3_lookup,
+	.relink		= ext3_link,
 	.link		= ext3_link,
 	.unlink		= ext3_unlink,
 	.symlink	= ext3_symlink,
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index dc40e75..1bbc4c2 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -2285,13 +2285,6 @@ static int ext4_link(struct dentry *old_dentry,
 
 	dquot_initialize(dir);
 
-	/*
-	 * Return -ENOENT if we've raced with unlink and i_nlink is 0.  Doing
-	 * otherwise has the potential to corrupt the orphan inode list.
-	 */
-	if (inode->i_nlink == 0)
-		return -ENOENT;
-
 retry:
 	handle = ext4_journal_start(dir, EXT4_DATA_TRANS_BLOCKS(dir->i_sb) +
 					EXT4_INDEX_EXTRA_TRANS_BLOCKS);
@@ -2309,6 +2302,12 @@ retry:
 	if (!err) {
 		ext4_mark_inode_dirty(handle, inode);
 		d_instantiate(dentry, inode);
+		if (inode->i_nlink == 1)
+			/*
+			 * i_nlink went from 0 to 1 thus the inode is no
+			 * longer an orphan.
+			 */
+			ext4_orphan_del(handle, inode);
 	} else {
 		drop_nlink(inode);
 		iput(inode);
@@ -2497,6 +2496,7 @@ end_rename:
 const struct inode_operations ext4_dir_inode_operations = {
 	.create		= ext4_create,
 	.lookup		= ext4_lookup,
+	.relink		= ext4_link,
 	.link		= ext4_link,
 	.unlink		= ext4_unlink,
 	.symlink	= ext4_symlink,
-- 
1.6.3.3
