From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 07/10] Update ptmx permissions during remount
Date: Fri, 12 Sep 2008 10:52:52 -0700
Message-ID: <20080912175252.GH17350@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080912174845.GA17350-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From 8c20ae3e9d5e051791a99b9060326069432d7fff Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 9 Sep 2008 18:37:55 -0700
Subject: [PATCH 07/10] Update ptmx permissions during remount

By default, /dev/pts/ptmx node starts out with 0000 permissions.  While
user's can chmod /dev/pts/ptmx, it maybe easier for legacy systems to
update /etc/fstab and change the permissions using ptmxmode option.

This patch caches the dentry for ptmx node and uses it to update permissions
of ptmx node during remount (code will be enabled in a follow-on patch).

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/devpts/inode.c |   28 +++++++++++++++++++++++++++-
 1 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 17e14f5..6b56255 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -68,6 +68,7 @@ static match_table_t tokens = {
 struct pts_fs_info {
 	struct ida allocated_ptys;
 	struct pts_mount_opts mount_opts;
+	struct dentry *ptmx_dentry;
 };
 
 static inline struct pts_fs_info *DEVPTS_SB(struct super_block *sb)
@@ -184,14 +185,39 @@ static int mknod_ptmx(struct super_block *sb)
 
 	return 0;
 }
+
+static void update_ptmx_mode(struct pts_fs_info *fsi)
+{
+	struct inode *inode;
+	if (fsi->ptmx_dentry) {
+		inode = fsi->ptmx_dentry->d_inode;
+		inode->i_mode = S_IFCHR|fsi->mount_opts.ptmxmode;
+	}
+}
+#else
+static inline void update_ptmx_mode(struct pts_fs_info *fsi)
+{
+	return;
+}
 #endif
 
 static int devpts_remount(struct super_block *sb, int *flags, char *data)
 {
+	int err;
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 	struct pts_mount_opts *opts = &fsi->mount_opts;
 
-	return parse_mount_options(data, opts);
+	err = parse_mount_options(data, opts);
+
+	/*
+	 * parse_mount_options() restores options to default values
+	 * before parsing and may have changed ptmxmode. So, update the
+	 * mode in the inode too. Bogus options don't fail the remount,
+	 * so do this even on error return.
+	 */
+	update_ptmx_mode(fsi);
+
+	return err;
 }
 
 static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
-- 
1.5.2.5
