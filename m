From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 04/10] Extract option parsing to new function
Date: Fri, 12 Sep 2008 10:51:53 -0700
Message-ID: <20080912175153.GE17350@us.ibm.com>
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


From 91a31d2286a22a2cfa03f9ddea44fd2eaf5fa576 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 9 Sep 2008 10:23:00 -0700
Subject: [PATCH 04/10] Extract option parsing to new function

Move code to parse mount options into a separate function so it can
(later) be shared between mount and remount operations.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/devpts/inode.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index e91c15c..7ae60aa 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -72,11 +72,9 @@ static inline struct super_block *pts_sb_from_inode(struct inode *inode)
 	return devpts_mnt->mnt_sb;
 }
 
-static int devpts_remount(struct super_block *sb, int *flags, char *data)
+static int parse_mount_options(char *data, struct pts_mount_opts *opts)
 {
 	char *p;
-	struct pts_fs_info *fsi = DEVPTS_SB(sb);
-	struct pts_mount_opts *opts = &fsi->mount_opts;
 
 	opts->setuid  = 0;
 	opts->setgid  = 0;
@@ -120,6 +118,14 @@ static int devpts_remount(struct super_block *sb, int *flags, char *data)
 	return 0;
 }
 
+static int devpts_remount(struct super_block *sb, int *flags, char *data)
+{
+	struct pts_fs_info *fsi = DEVPTS_SB(sb);
+	struct pts_mount_opts *opts = &fsi->mount_opts;
+
+	return parse_mount_options(data, opts);
+}
+
 static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
 {
 	struct pts_fs_info *fsi = DEVPTS_SB(vfs->mnt_sb);
-- 
1.5.2.5
