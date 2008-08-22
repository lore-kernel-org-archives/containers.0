From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/10] user namespaces: Allow registering new
	usernamespaces using mount
Date: Fri, 22 Aug 2008 14:46:17 -0500
Message-ID: <20080822194617.GE10360@us.ibm.com>
References: <20080822194513.GA10262@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080822194513.GA10262-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Allow registering new user namespaces using mount(MS_ADD_USERNS).
Define lib/fsuserns.c which will contain functions which filesystems
can hook into to support user namespaces.

Since fsuserns.c currently supports neither reading policy nor
storing userns info using xattrs, the support is really bogus
for now.

The following program shows how to use the mount syscall to
register a new user namespace with a filesystem:

===================================================================
 #include <stdio.h>
 #include <sys/mount.h>
 #include <errno.h>

 #define MS_SET_USERNS   (1<<25) /* Add current's user_ns as valid for sb */

/*
 * path is a path to be remounted
 * userid is a string 'user=X' where X is an integer
 */

int main(int argc, char *argv[])
{
        char *path, *userid;
        int ret;

        path = argv[1];
        userid = argv[2];

        ret = mount(path, path, NULL, MS_SET_USERNS, userid);
        if (ret)
                perror("mount");
        return ret;
}
===================================================================

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/ext3/super.c    |   14 +++
 fs/namespace.c     |   11 +++
 include/linux/fs.h |    3 +
 lib/Makefile       |    2 +
 lib/fsuserns.c     |  226 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 256 insertions(+), 0 deletions(-)
 create mode 100644 lib/fsuserns.c

diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index f38a5af..3458d25 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -719,6 +719,15 @@ static struct quotactl_ops ext3_qctl_operations = {
 };
 #endif
 
+#ifdef CONFIG_USER_NS
+extern int fsuserns_add_userns(struct super_block *sb,
+                struct user *user, void *data);
+extern int fsuserns_convert_uid_gid(struct user_namespace *ns,
+		struct inode *inode, uid_t *retuid, gid_t *retgid);
+extern int fsuserns_is_capable(struct user_namespace *ns,
+		struct inode *inode, int cap);
+#endif
+
 static const struct super_operations ext3_sops = {
 	.alloc_inode	= ext3_alloc_inode,
 	.destroy_inode	= ext3_destroy_inode,
@@ -738,6 +747,11 @@ static const struct super_operations ext3_sops = {
 	.quota_read	= ext3_quota_read,
 	.quota_write	= ext3_quota_write,
 #endif
+#ifdef CONFIG_USER_NS
+	.add_userns	= fsuserns_add_userns,
+	.is_capable	= fsuserns_is_capable,
+	.convert_uid_gid = fsuserns_convert_uid_gid,
+#endif
 };
 
 static const struct export_operations ext3_export_ops = {
diff --git a/fs/namespace.c b/fs/namespace.c
index 6e283c9..4bb8c61 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1885,6 +1885,15 @@ int copy_mount_options(const void __user * data, unsigned long *where)
 	return 0;
 }
 
+int do_add_userns(struct nameidata *nd, struct user_struct *user,
+		void *data_page)
+{
+	struct super_block *sb = nd->path.mnt->mnt_sb;
+	if (sb->s_op->add_userns)
+		return sb->s_op->add_userns(sb, user, data_page);
+	return -EINVAL;
+}
+
 /*
  * Flags is a 32-bit value that allows up to 31 non-fs dependent flags to
  * be given to the mount() call (ie: read-only, no-dev, no-suid etc).
@@ -1958,6 +1967,8 @@ long do_mount(char *dev_name, char *dir_name, char *type_page,
 		retval = do_change_type(&nd, flags);
 	else if (flags & MS_MOVE)
 		retval = do_move_mount(&nd, dev_name);
+	else if (flags & MS_SET_USERNS)
+		retval = do_add_userns(&nd, current->user, data_page);
 	else
 		retval = do_new_mount(&nd, type_page, flags, mnt_flags,
 				      dev_name, data_page);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bb58c2e..492abef 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -128,6 +128,7 @@ extern int dir_notify_enable;
 #define MS_RELATIME	(1<<21)	/* Update atime relative to mtime/ctime. */
 #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
 #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
+#define MS_SET_USERNS	(1<<25) /* Add current's user_ns as valid for sb */
 #define MS_ACTIVE	(1<<30)
 #define MS_NOUSER	(1<<31)
 
@@ -1308,6 +1309,7 @@ extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
 extern ssize_t vfs_writev(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *);
 
+struct user_struct;
 struct super_operations {
    	struct inode *(*alloc_inode)(struct super_block *sb);
 	void (*destroy_inode)(struct inode *);
@@ -1325,6 +1327,7 @@ struct super_operations {
 	int (*remount_fs) (struct super_block *, int *, char *);
 	void (*clear_inode) (struct inode *);
 	void (*umount_begin) (struct super_block *);
+	int (*add_userns) (struct super_block *, struct user_struct *, void *);
 	int (*is_capable) (struct user_namespace *, struct inode *, int);
 	uid_t (*convert_uid_gid)(struct user_namespace *, struct inode *,
 						uid_t *, gid_t *);
diff --git a/lib/Makefile b/lib/Makefile
index 3b1f94b..4f80936 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -80,6 +80,8 @@ obj-$(CONFIG_HAVE_LMB) += lmb.o
 
 obj-$(CONFIG_HAVE_ARCH_TRACEHOOK) += syscall.o
 
+obj-$(CONFIG_USER_NS) += fsuserns.o
+
 hostprogs-y	:= gen_crc32table
 clean-files	:= crc32table.h
 
diff --git a/lib/fsuserns.c b/lib/fsuserns.c
new file mode 100644
index 0000000..0a9f52d
--- /dev/null
+++ b/lib/fsuserns.c
@@ -0,0 +1,226 @@
+#include <linux/err.h>
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/user.h>
+#include <linux/user_namespace.h>
+
+/*
+ * Ok, eventually I'll want some policy loaded which looks as follows:
+ *
+ * [domains]
+ * INIT 1
+ * serge 2
+ * vs2 3
+ *
+ * [owners]
+ * serge serge.INIT
+ * vs2 root.INIT
+ *
+ * Meaning root on the host may own domain vs2, which is identified
+ * by id '3'.  user serge on the host may own domain serge, which is
+ * identified by id '2'.  In this case, when userid 40 in domain 'serge'
+ * saves a file, the file will be stored with serge's uid, and an
+ * xattr listing <2,40> meaning the file is owned by userid 40 in domain 2.
+ *
+ * BUT I don't wnat to deal with policy parsing yet, so for now I will
+ * just provide the interface for an fs to use these helpers.
+ */
+
+/*
+ * 1. When a user passes the MS_NEWUSER flag to mount(2), do_loopback()
+ * will call super_add_userns().  The fs can use fsuserns_add_userns()
+ * which will check whether current->fsuid is allowed to own the id
+ * passed in with 'userns=X' data.
+ * If so, we log the fact that X=get_user_ns(current->user_ns)
+ * and henceforth a task which is in that userns will be allowed to
+ * use the fs.
+ *
+ * 2. The fs will point its super_ops->convert_uid_gid() and
+ * super_ops->is_capable()  to fsuserns_convert_uid_gid() and
+ * fsuserns_is_capable().
+ */
+
+DEFINE_MUTEX(fsuserns_table_mutex);
+
+struct fsuserns_table_entries {
+	struct user_namespace *ns;
+	unsigned int userns_id;
+	struct list_head entries;
+};
+
+struct fsuserns_conversion_table {
+	struct super_block *sb;
+	struct list_head entries;
+	struct list_head tables;
+};
+
+LIST_HEAD(fsuserns_tables);
+
+struct fsuserns_conversion_table *find_table_locked(
+				struct super_block *sb)
+{
+	struct fsuserns_conversion_table *p;
+
+	if (list_empty(&fsuserns_tables))
+		return NULL;
+	list_for_each_entry(p, &fsuserns_tables, tables) {
+		if (p->sb == sb)
+			return p;
+	}
+
+	return NULL;
+}
+
+struct fsuserns_conversion_table *find_table(struct super_block *sb)
+{
+	struct fsuserns_conversion_table *p;
+
+	mutex_lock(&fsuserns_table_mutex);
+	p = find_table_locked(sb);
+	mutex_unlock(&fsuserns_table_mutex);
+
+	return p;
+}
+
+struct fsuserns_conversion_table *find_or_create_table(struct super_block *sb)
+{
+	struct fsuserns_conversion_table *p, *new;
+
+	p = find_table(sb);
+	if (p)
+		return p;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return ERR_PTR(-ENOMEM);
+
+	mutex_lock(&fsuserns_table_mutex);
+	p = find_table_locked(sb);
+	if (p)
+		goto out;
+	new->sb = sb;
+	INIT_LIST_HEAD(&new->entries);
+	list_add_tail(&new->tables, &fsuserns_tables);
+	p = new;
+
+out:
+	mutex_unlock(&fsuserns_table_mutex);
+	if (p != new)
+		kfree(new);
+	return p;
+}
+
+int fsuserns_add_userns(struct super_block *sb,
+		struct user_struct *user, void *data)
+{
+	struct user_namespace *user_ns = user->user_ns;
+	struct fsuserns_table_entries *e, *ep;
+	struct fsuserns_conversion_table *t;
+	int ret, newid;
+
+	t = find_or_create_table(sb);
+	if (!t)
+		return -ENOMEM;
+
+	/*
+	 * The creator of current's user namespace must be listed as
+	 * owning 'newid'.  But we don't have such policy yet.  So
+	 * for now, for the POC, we just check whether the creator's
+	 * userns is the sb->user_ns.
+	 * It's a bogus check!  Remove as soon as we have policy.
+	 *
+	 * Note, since unprivileged mounts are not yet allowed, we
+	 * know the owner had CAP_SYS_ADMIN to get here, so we don't
+	 * even bother checking the creator's uid.
+	 */
+	if (user_ns->creator->user_ns != sb->user_ns)
+		return -EPERM;
+	
+	ret = sscanf(data, "nsid=%d", &newid);
+	if (ret != 1)
+		return -EINVAL;
+
+	e = kmalloc(sizeof(*e), GFP_KERNEL);
+	if (!e)
+		return -ENOMEM;
+	mutex_lock(&fsuserns_table_mutex);
+	list_for_each_entry(ep, &t->entries, entries) {
+		if (ep->ns == user_ns && ep->userns_id == newid) {
+			kfree(ep);
+			goto skip;
+		}
+	}
+	e->ns = get_user_ns(user_ns);
+	e->userns_id = newid;
+	list_add_tail(&e->entries, &t->entries);
+skip:
+	mutex_unlock(&fsuserns_table_mutex);
+
+	return 0;
+}
+
+/*
+ * return 1 if we got a translation, 0 otherwise
+ */
+int fsuserns_convert_uid_gid(struct user_namespace *ns, struct inode *inode,
+                                                uid_t *retuid, gid_t *retgid)
+{
+	struct super_block *sb = inode->i_sb;
+	struct fsuserns_conversion_table *t;
+	struct fsuserns_table_entries *ep;
+
+	t = find_table(sb);
+	if (!t)
+		return 0;
+	mutex_lock(&fsuserns_table_mutex);
+	list_for_each_entry(ep, &t->entries, entries) {
+		if (ep->ns == ns)
+			goto convert;
+	}
+	mutex_unlock(&fsuserns_table_mutex);
+
+	return 0;
+convert:
+	mutex_unlock(&fsuserns_table_mutex);
+
+	/*
+	 * ok now we would look through the xattrs for the
+	 * inode to find a stored uid in this namespace.
+	 * But we don't do that yet, so we just claim failure :)
+	 * Don't worry, the is_capable() function can be more
+	 * meaningful.
+	 */
+	return 0;
+}
+
+int fsuserns_is_capable(struct user_namespace *ns, struct inode *inode,
+						int cap)
+{
+	struct super_block *sb = inode->i_sb;
+	struct fsuserns_conversion_table *t;
+	struct fsuserns_table_entries *ep;
+
+	t = find_table(sb);
+	if (!t)
+		return 0;
+	printk(KERN_NOTICE "%s: found a table\n", __func__);
+
+	mutex_lock(&fsuserns_table_mutex);
+	list_for_each_entry(ep, &t->entries, entries) {
+		if (ep->ns == ns)
+			goto convert;
+	}
+	mutex_unlock(&fsuserns_table_mutex);
+
+	return 0;
+convert:
+	mutex_unlock(&fsuserns_table_mutex);
+
+	printk(KERN_NOTICE "%s: found an entry\n", __func__);
+	if (capable(cap))
+		return 1;
+	printk(KERN_NOTICE "%s: oh, but I wasn't capable(%d)\n", __func__, cap);
+	return 0;
+}
-- 
1.5.4.3
