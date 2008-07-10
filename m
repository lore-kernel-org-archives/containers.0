From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 3/5] fs: add get_sb_single_ns() helper routine
Date: Thu, 10 Jul 2008 15:30:50 -0700
Message-ID: <20080710223050.75DB117C@kernel>
References: <20080710223047.315FF88A@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080710223047.315FF88A@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

This patch add a helper routine get_sb_single_ns() which allocates
a single super_block per instance of namespace. The data parameter
is used to differentiate the namespaces.

This is used in subsystems with an internal fs like mqueue. 

TODO:
	- use in pidns and devpts 

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/fs/super.c         |   37 ++++++++++++++++++++++++++++++++++
 linux-2.6.git-dave/include/linux/fs.h |    4 +++
 2 files changed, 41 insertions(+)

diff -puN fs/super.c~add-get_sb_single_ns-helper fs/super.c
--- linux-2.6.git/fs/super.c~add-get_sb_single_ns-helper	2008-06-24 12:03:17.000000000 -0700
+++ linux-2.6.git-dave/fs/super.c	2008-06-24 12:03:17.000000000 -0700
@@ -882,6 +882,43 @@ int get_sb_single(struct file_system_typ
 
 EXPORT_SYMBOL(get_sb_single);
 
+static int compare_sb_single_ns(struct super_block *sb, void *data)
+{
+	return sb->s_fs_info == data;
+}
+
+static int set_sb_single_ns(struct super_block *sb, void *data)
+{
+	sb->s_fs_info = data;
+	return set_anon_super(sb, data);
+}
+
+int get_sb_single_ns(struct file_system_type *fs_type,
+	int flags, void *data,
+	int (*fill_super)(struct super_block *, void *, int),
+	struct vfsmount *mnt)
+{
+	struct super_block *s;
+	int error;
+
+	s = sget(fs_type, compare_sb_single_ns, set_sb_single_ns, data);
+	if (IS_ERR(s))
+		return PTR_ERR(s);
+	if (!s->s_root) {
+		s->s_flags = flags;
+		error = fill_super(s, data, flags & MS_SILENT ? 1 : 0);
+		if (error) {
+			up_write(&s->s_umount);
+			deactivate_super(s);
+			return error;
+		}
+		s->s_flags |= MS_ACTIVE;
+	}
+	do_remount_sb(s, flags, data, 0);
+	return simple_set_mnt(mnt, s);
+}
+EXPORT_SYMBOL(get_sb_single_ns);
+
 struct vfsmount *
 vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void *data)
 {
diff -puN include/linux/fs.h~add-get_sb_single_ns-helper include/linux/fs.h
--- linux-2.6.git/include/linux/fs.h~add-get_sb_single_ns-helper	2008-06-24 12:03:17.000000000 -0700
+++ linux-2.6.git-dave/include/linux/fs.h	2008-06-24 12:03:17.000000000 -0700
@@ -1502,6 +1502,10 @@ extern int get_sb_nodev(struct file_syst
 	int flags, void *data,
 	int (*fill_super)(struct super_block *, void *, int),
 	struct vfsmount *mnt);
+extern int get_sb_single_ns(struct file_system_type *fs_type,
+	int flags, void *data,
+	int (*fill_super)(struct super_block *, void *, int),
+	struct vfsmount *mnt);
 void generic_shutdown_super(struct super_block *sb);
 void kill_block_super(struct super_block *sb);
 void kill_anon_super(struct super_block *sb);
_
