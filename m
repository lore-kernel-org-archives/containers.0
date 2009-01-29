From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 4/5] Remove get_init_pts_sb()
Date: Wed, 28 Jan 2009 22:47:20 -0800
Message-ID: <20090129064720.GE23160@us.ibm.com>
References: <20090129064259.GA23160@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090129064259.GA23160-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Cc: "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Wed, 28 Jan 2009 18:59:28 -0800
Subject: [RFC][PATCH 4/5] Remove get_init_pts_sb()

With mknod_ptmx() moved to devpts_get_sb(), init_pts_mount() becomes
a wrapper around get_init_pts_sb(). Remove get_init_pts_sb() and
fold code into init_pts_mount().

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/devpts/inode.c |   25 ++++++-------------------
 1 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 97b8e9f..733e8e0 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -347,7 +347,11 @@ static int new_pts_mount(struct file_system_type *fs_type, int flags,
 }
 
 /*
- * get_init_pts_sb()
+ * init_pts_mount()
+ *
+ *     Mount or remount the initial kernel mount of devpts. This type of
+ *     mount maintains the legacy, single-instance semantics, while the
+ *     kernel still allows multiple-instances.
  *
  *     This interface is needed to support multiple namespace semantics in
  *     devpts while preserving backward compatibility of the current 'single-
@@ -367,7 +371,7 @@ static int new_pts_mount(struct file_system_type *fs_type, int flags,
  *     consistently selects the 'single-namespace' superblock even in the
  *     presence of the private namespace (i.e 'newinstance') super-blocks.
  */
-static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
+static int init_pts_mount(struct file_system_type *fs_type, int flags,
 		void *data, struct pts_mount_opts *opts, struct vfsmount *mnt)
 {
 	struct super_block *s;
@@ -397,23 +401,6 @@ static int get_init_pts_sb(struct file_system_type *fs_type, int flags,
 	return 0;
 }
 
-/*
- * Mount or remount the initial kernel mount of devpts. This type of
- * mount maintains the legacy, single-instance semantics, while the
- * kernel still allows multiple-instances.
- */
-static int init_pts_mount(struct file_system_type *fs_type, int flags,
-		void *data, struct pts_mount_opts *opts, struct vfsmount *mnt)
-{
-	int err;
-
-	err = get_init_pts_sb(fs_type, flags, data, opts, mnt);
-	if (err)
-		return err;
-
-	return err;
-}
-
 static int devpts_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
-- 
1.5.2.5
