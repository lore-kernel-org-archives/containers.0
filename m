From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH] nsfs: Add a show_path method to fix mountinfo
Date: Sat, 11 Jul 2015 11:13:12 -0500
Message-ID: <87pp3ypt9j.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Today mountinfo displays a very unhelpful "/" for nsfs files.  Add a
show_path method returning the same string as ns_dname.  This results
in a bind mount of /proc/<pid>/ns/net showing up in /proc/<pid>/mountinfo as
"net:[1234...]" instead of "/".

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/nsfs.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nsfs.c b/fs/nsfs.c
index 99521e7c492b..e4905fbf3396 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -4,6 +4,7 @@
 #include <linux/proc_ns.h>
 #include <linux/magic.h>
 #include <linux/ktime.h>
+#include <linux/seq_file.h>
 
 static struct vfsmount *nsfs_mnt;
 
@@ -136,9 +137,18 @@ out_invalid:
 	return ERR_PTR(-EINVAL);
 }
 
+static int nsfs_show_path(struct seq_file *seq, struct dentry *dentry)
+{
+	struct inode *inode = d_inode(dentry);
+	const struct proc_ns_operations *ns_ops = dentry->d_fsdata;
+
+	return seq_printf(seq, "%s:[%lu]", ns_ops->name, inode->i_ino);
+}
+
 static const struct super_operations nsfs_ops = {
 	.statfs = simple_statfs,
 	.evict_inode = nsfs_evict,
+	.show_path = nsfs_show_path,
 };
 static struct dentry *nsfs_mount(struct file_system_type *fs_type,
 			int flags, const char *dev_name, void *data)
-- 
2.2.1
