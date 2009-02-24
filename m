From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] move proc_net_get_sb to a generic fs/super.c helper
Date: Mon, 23 Feb 2009 21:03:47 -0600
Message-ID: <20090224030347.GA10913@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

The mqueuefs filesystem will use this helper as well.  Proc's
main get_sb could also be made to use it, but that will require
a bit more rework.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/proc/proc_net.c |   34 ++--------------------------------
 fs/super.c         |   38 ++++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |    3 +++
 3 files changed, 43 insertions(+), 32 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 2da0002..500e70d 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -226,7 +226,7 @@ void proc_net_remove(struct net *net, const char *name)
 }
 EXPORT_SYMBOL_GPL(proc_net_remove);
 
-static int proc_net_fill_super(struct super_block *sb)
+static int proc_net_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct net *net = sb->s_fs_info;
 	struct proc_dir_entry *netd = net->proc_net;
@@ -257,43 +257,13 @@ out_no_root:
 	return -ENOMEM;
 }
 
-static int proc_net_test_super(struct super_block *sb, void *data)
-{
-	return sb->s_fs_info == data;
-}
-
-static int proc_net_set_super(struct super_block *sb, void *data)
-{
-	sb->s_fs_info = data;
-	return set_anon_super(sb, NULL);
-}
-
 static int proc_net_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
-	struct super_block *sb;
-
 	if (!(flags & MS_KERNMOUNT))
 		data = current->nsproxy->net_ns;
 
-	sb = sget(fs_type, proc_net_test_super, proc_net_set_super, data);
-	if (IS_ERR(sb))
-		return PTR_ERR(sb);
-
-	if (!sb->s_root) {
-		int err;
-		sb->s_flags = flags;
-		err = proc_net_fill_super(sb);
-		if (err) {
-			up_write(&sb->s_umount);
-			deactivate_super(sb);
-			return err;
-		}
-
-		sb->s_flags |= MS_ACTIVE;
-	}
-
-	simple_set_mnt(mnt, sb);
+	return get_sb_ns(fs_type,  flags, data, proc_net_fill_super, mnt);
 }
 
 static struct file_system_type proc_net_fs_type = {
diff --git a/fs/super.c b/fs/super.c
index 3aa9853..45846f1 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -759,6 +759,44 @@ static int test_bdev_super(struct super_block *s, void *data)
 	return (void *)s->s_bdev == data;
 }
 
+static int ns_test_super(struct super_block *sb, void *data)
+{
+	return sb->s_fs_info == data;
+}
+
+static int ns_set_super(struct super_block *sb, void *data)
+{
+	sb->s_fs_info = data;
+	return set_anon_super(sb, NULL);
+}
+
+int get_sb_ns(struct file_system_type *fs_type, int flags, void *data,
+	int (*fill_super)(struct super_block *, void *, int),
+	struct vfsmount *mnt)
+{
+	struct super_block *sb;
+
+	sb = sget(fs_type, ns_test_super, ns_set_super, data);
+	if (IS_ERR(sb))
+		return PTR_ERR(sb);
+
+	if (!sb->s_root) {
+		int err;
+		sb->s_flags = flags;
+		err = fill_super(sb, data, flags & MS_SILENT ? 1 : 0);
+		if (err) {
+			up_write(&sb->s_umount);
+			deactivate_super(sb);
+			return err;
+		}
+
+		sb->s_flags |= MS_ACTIVE;
+	}
+
+	simple_set_mnt(mnt, sb);
+	return 0;
+}
+
 int get_sb_bdev(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data,
 	int (*fill_super)(struct super_block *, void *, int),
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b0bfa3b..4bb26ca 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1597,6 +1597,9 @@ struct file_system_type {
 	struct lock_class_key i_alloc_sem_key;
 };
 
+extern int get_sb_ns(struct file_system_type *fs_type, int flags, void *data,
+	int (*fill_super)(struct super_block *, void *, int),
+	struct vfsmount *mnt);
 extern int get_sb_bdev(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data,
 	int (*fill_super)(struct super_block *, void *, int),
-- 
1.5.4.3
