From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 9/11][v3]: Extract option parsing to new function
Date: Wed, 3 Sep 2008 22:34:50 -0700
Message-ID: <20080904053450.GJ3680@us.ibm.com>
References: <20080904052718.GA3680@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080904052718.GA3680-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 9/11]: Extract option parsing to new function

Move code to parse mount options into a separate function so it can
(later) be shared between mount and remount operations.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
 fs/devpts/inode.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

Index: linux-2.6.27-rc3-tty/fs/devpts/inode.c
===================================================================
--- linux-2.6.27-rc3-tty.orig/fs/devpts/inode.c	2008-09-03 21:33:36.000000000 -0700
+++ linux-2.6.27-rc3-tty/fs/devpts/inode.c	2008-09-03 21:33:46.000000000 -0700
@@ -72,11 +72,9 @@ static inline struct super_block *pts_sb
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
@@ -120,6 +118,14 @@ static int devpts_remount(struct super_b
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
