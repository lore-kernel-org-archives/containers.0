From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 03/11] userns: Convert btrfs to use kuid/kgid where appropriate
Date: Fri, 21 Sep 2012 18:35:04 -0700
Message-ID: <1348277712-30055-3-git-send-email-ebiederm@xmission.com>
References: <877grmj115.fsf@xmission.com>
	<1348277712-30055-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348277712-30055-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Mason <chris.mason-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Chris Mason <chris.mason-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/btrfs/delayed-inode.c |    8 ++++----
 fs/btrfs/inode.c         |    8 ++++----
 fs/btrfs/ioctl.c         |    6 +++---
 init/Kconfig             |    1 -
 4 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/fs/btrfs/delayed-inode.c b/fs/btrfs/delayed-inode.c
index 335605c..f908c51 100644
--- a/fs/btrfs/delayed-inode.c
+++ b/fs/btrfs/delayed-inode.c
@@ -1715,8 +1715,8 @@ static void fill_stack_inode_item(struct btrfs_trans_handle *trans,
 				  struct btrfs_inode_item *inode_item,
 				  struct inode *inode)
 {
-	btrfs_set_stack_inode_uid(inode_item, inode->i_uid);
-	btrfs_set_stack_inode_gid(inode_item, inode->i_gid);
+	btrfs_set_stack_inode_uid(inode_item, i_uid_read(inode));
+	btrfs_set_stack_inode_gid(inode_item, i_gid_read(inode));
 	btrfs_set_stack_inode_size(inode_item, BTRFS_I(inode)->disk_i_size);
 	btrfs_set_stack_inode_mode(inode_item, inode->i_mode);
 	btrfs_set_stack_inode_nlink(inode_item, inode->i_nlink);
@@ -1764,8 +1764,8 @@ int btrfs_fill_inode(struct inode *inode, u32 *rdev)
 
 	inode_item = &delayed_node->inode_item;
 
-	inode->i_uid = btrfs_stack_inode_uid(inode_item);
-	inode->i_gid = btrfs_stack_inode_gid(inode_item);
+	i_uid_write(inode, btrfs_stack_inode_uid(inode_item));
+	i_gid_write(inode, btrfs_stack_inode_gid(inode_item));
 	btrfs_i_size_write(inode, btrfs_stack_inode_size(inode_item));
 	inode->i_mode = btrfs_stack_inode_mode(inode_item);
 	set_nlink(inode, btrfs_stack_inode_nlink(inode_item));
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 83baec2..5368714 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -2570,8 +2570,8 @@ static void btrfs_read_locked_inode(struct inode *inode)
 				    struct btrfs_inode_item);
 	inode->i_mode = btrfs_inode_mode(leaf, inode_item);
 	set_nlink(inode, btrfs_inode_nlink(leaf, inode_item));
-	inode->i_uid = btrfs_inode_uid(leaf, inode_item);
-	inode->i_gid = btrfs_inode_gid(leaf, inode_item);
+	i_uid_write(inode, btrfs_inode_uid(leaf, inode_item));
+	i_gid_write(inode, btrfs_inode_gid(leaf, inode_item));
 	btrfs_i_size_write(inode, btrfs_inode_size(leaf, inode_item));
 
 	tspec = btrfs_inode_atime(inode_item);
@@ -2649,8 +2649,8 @@ static void fill_inode_item(struct btrfs_trans_handle *trans,
 			    struct btrfs_inode_item *item,
 			    struct inode *inode)
 {
-	btrfs_set_inode_uid(leaf, item, inode->i_uid);
-	btrfs_set_inode_gid(leaf, item, inode->i_gid);
+	btrfs_set_inode_uid(leaf, item, i_uid_read(inode));
+	btrfs_set_inode_gid(leaf, item, i_gid_read(inode));
 	btrfs_set_inode_size(leaf, item, BTRFS_I(inode)->disk_i_size);
 	btrfs_set_inode_mode(leaf, item, inode->i_mode);
 	btrfs_set_inode_nlink(leaf, item, inode->i_nlink);
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index bc2f6ff..1292682 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -575,13 +575,13 @@ fail:
 */
 static inline int btrfs_check_sticky(struct inode *dir, struct inode *inode)
 {
-	uid_t fsuid = current_fsuid();
+	kuid_t fsuid = current_fsuid();
 
 	if (!(dir->i_mode & S_ISVTX))
 		return 0;
-	if (inode->i_uid == fsuid)
+	if (uid_eq(inode->i_uid, fsuid))
 		return 0;
-	if (dir->i_uid == fsuid)
+	if (uid_eq(dir->i_uid, fsuid))
 		return 0;
 	return !capable(CAP_FOWNER);
 }
diff --git a/init/Kconfig b/init/Kconfig
index fd91d2b..44f580f 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -930,7 +930,6 @@ config UIDGID_CONVERTED
 	depends on 9P_FS = n
 	depends on AFS_FS = n
 	depends on AUTOFS4_FS = n
-	depends on BTRFS_FS = n
 	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
-- 
1.7.5.4
