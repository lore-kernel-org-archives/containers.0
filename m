From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/10] Support relinking unlinked files in btrfs
Date: Mon, 28 Feb 2011 20:05:12 -0800
Message-ID: <ac2a9431a97bbb45bdecf2ccd011f70ee99f2731.1298952288.git.matthltc@us.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
	<a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc@us.ibm.com>
	<cbc5f629ca02554497bcb385039a2a300ef897f0.1298952288.git.matthltc@us.ibm.com>
	<6f547f7b0dd12d409f993dba3fbc899dc52f2a78.1298952288.git.matthltc@us.ibm.com>
	<1a7a344ddd1d68ac862ec2248be77f2dd9f138c8.1298952288.git.matthltc@us.ibm.com>
	<dbe36642be44152833a63e8173e8f0490dc1573f.1298952288.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <dbe36642be44152833a63e8173e8f0490dc1573f.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Chris Mason <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 fs/btrfs/inode.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index bb5064b..ce923eb 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -4776,14 +4776,15 @@ static int btrfs_link(struct dentry *old_dentry, struct inode *dir,
 	unsigned long nr = 0;
 	int err;
 	int drop_inode = 0;
-
-	if (inode->i_nlink == 0)
-		return -ENOENT;
+	int adopted = 0;
 
 	/* do not allow sys_link's with other subvols of the same device */
 	if (root->objectid != BTRFS_I(inode)->root->objectid)
 		return -EPERM;
 
+	if (inode->i_nlink == 0)
+		/* Not orphaned by truncate -- getting back in the game! */
+		adopted = 1;
 	btrfs_inc_nlink(inode);
 	inode->i_ctime = CURRENT_TIME;
 
@@ -4804,7 +4805,15 @@ static int btrfs_link(struct dentry *old_dentry, struct inode *dir,
 	btrfs_set_trans_block_group(trans, dir);
 	ihold(inode);
 
-	err = btrfs_add_nondir(trans, dir, dentry, inode, 1, index);
+	if (adopted) {
+		/* inode->i_nlink was 0 -- we were an orphan */
+		err = btrfs_orphan_del(trans, inode);
+		if (err)
+			drop_inode = 1;
+	}
+
+	if (!err)
+		err = btrfs_add_nondir(trans, dir, dentry, inode, 1, index);
 
 	if (err) {
 		drop_inode = 1;
-- 
1.6.3.3
