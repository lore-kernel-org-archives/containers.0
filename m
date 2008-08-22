From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/10] userns: have ext3 use fsuserns to read userns
	xattrs, and add groups to userns
Date: Fri, 22 Aug 2008 14:47:13 -0500
Message-ID: <20080822194713.GI10360@us.ibm.com>
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

userns: have ext3 use fsuserns to read userns xattrs, and add groups to userns

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/ext3/super.c    |   11 +++++++++--
 fs/ext3/xattr.c    |   19 ++++++++++++++++++-
 fs/ext3/xattr.h    |    3 ++-
 include/linux/fs.h |    2 +-
 lib/fsuserns.c     |   48 +++++++++++++++++++++++++++++++++++++++++-------
 5 files changed, 71 insertions(+), 12 deletions(-)

diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index 3458d25..37c8404 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -723,11 +723,18 @@ static struct quotactl_ops ext3_qctl_operations = {
 extern int fsuserns_add_userns(struct super_block *sb,
                 struct user *user, void *data);
 extern int fsuserns_convert_uid_gid(struct user_namespace *ns,
-		struct inode *inode, uid_t *retuid, gid_t *retgid);
+		struct inode *inode, uid_t *retuid, gid_t *retgid,
+		int (*xattrget)(struct inode *, const void *, size_t));
 extern int fsuserns_is_capable(struct user_namespace *ns,
 		struct inode *inode, int cap);
 #endif
 
+int ext3_convert_uid_gid(struct user_namespace *ns, struct inode *inode,
+                        uid_t *retuid, gid_t *retgid)
+{
+	return fsuserns_convert_uid_gid(ns, inode, retuid, retgid, ext3_xattr_get_userns);
+}
+
 static const struct super_operations ext3_sops = {
 	.alloc_inode	= ext3_alloc_inode,
 	.destroy_inode	= ext3_destroy_inode,
@@ -750,7 +757,7 @@ static const struct super_operations ext3_sops = {
 #ifdef CONFIG_USER_NS
 	.add_userns	= fsuserns_add_userns,
 	.is_capable	= fsuserns_is_capable,
-	.convert_uid_gid = fsuserns_convert_uid_gid,
+	.convert_uid_gid = ext3_convert_uid_gid,
 #endif
 };
 
diff --git a/fs/ext3/xattr.c b/fs/ext3/xattr.c
index da47c35..500fec7 100644
--- a/fs/ext3/xattr.c
+++ b/fs/ext3/xattr.c
@@ -331,6 +331,23 @@ ext3_xattr_get(struct inode *inode, int name_index, const char *name,
 	return error;
 }
 
+int
+ext3_xattr_get_userns(struct inode *inode, void *value, size_t value_size)
+{
+	int error;
+	int name_index = EXT3_XATTR_INDEX_SECURITY;
+	char *name = "userns";
+
+	down_read(&EXT3_I(inode)->xattr_sem);
+	error = ext3_xattr_ibody_get(inode, name_index, name, value,
+				     value_size);
+	if (error == -ENODATA)
+		error = ext3_xattr_block_get(inode, name_index, name, value,
+					     value_size);
+	up_read(&EXT3_I(inode)->xattr_sem);
+	return error;
+}
+
 static int
 ext3_xattr_list_entries(struct inode *inode, struct ext3_xattr_entry *entry,
 			char *buffer, size_t buffer_size)
@@ -1087,7 +1104,7 @@ retry:
 		int error2;
 
 		error = ext3_xattr_set_handle(handle, inode, name_index, name,
-					      value, value_len, flags);
+					      value, value_len, 0);
 		error2 = ext3_journal_stop(handle);
 		if (error == -ENOSPC &&
 		    ext3_should_retry_alloc(inode->i_sb, &retries))
diff --git a/fs/ext3/xattr.h b/fs/ext3/xattr.h
index 8a523de..8c5b982 100644
--- a/fs/ext3/xattr.h
+++ b/fs/ext3/xattr.h
@@ -70,7 +70,8 @@ extern int ext3_xattr_get(struct inode *, int, const char *, void *, size_t);
 extern int ext3_xattr_set(struct inode *, int, const char *, const void *, size_t, int);
 extern int ext3_xattr_set_handle(handle_t *, struct inode *, int, const char *, const void *, size_t, int);
 
-extern int ext3_xattr_set_userns(struct inode *inode, const void *value, size_t value_len, int flags);
+extern int ext3_xattr_get_userns(struct inode *inode, void *value, size_t value_len);
+extern int ext3_xattr_set_userns(struct inode *inode, const void *value, size_t value_len);
 
 extern void ext3_xattr_delete_inode(handle_t *, struct inode *);
 extern void ext3_xattr_put_super(struct super_block *);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 492abef..9ec6dac 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1329,7 +1329,7 @@ struct super_operations {
 	void (*umount_begin) (struct super_block *);
 	int (*add_userns) (struct super_block *, struct user_struct *, void *);
 	int (*is_capable) (struct user_namespace *, struct inode *, int);
-	uid_t (*convert_uid_gid)(struct user_namespace *, struct inode *,
+	int (*convert_uid_gid)(struct user_namespace *, struct inode *,
 						uid_t *, gid_t *);
 
 	int (*show_options)(struct seq_file *, struct vfsmount *);
diff --git a/lib/fsuserns.c b/lib/fsuserns.c
index db70970..ac0ca99 100644
--- a/lib/fsuserns.c
+++ b/lib/fsuserns.c
@@ -59,6 +59,12 @@ struct fsuserns_conversion_table {
 
 LIST_HEAD(fsuserns_tables);
 
+struct unsstore {
+	int ns;
+	uid_t uid;
+	gid_t gid;
+};
+
 struct fsuserns_conversion_table *find_table_locked(
 				struct super_block *sb)
 {
@@ -166,11 +172,15 @@ skip:
  * return 1 if we got a translation, 0 otherwise
  */
 int fsuserns_convert_uid_gid(struct user_namespace *ns, struct inode *inode,
-                                                uid_t *retuid, gid_t *retgid)
+			uid_t *retuid, gid_t *retgid,
+			int (*xattrget)(struct inode *inode, void *value, size_t value_len))
 {
 	struct super_block *sb = inode->i_sb;
 	struct fsuserns_conversion_table *t;
 	struct fsuserns_table_entries *ep;
+	size_t valuelen;
+	struct unsstore *unsstore;
+	int i, ret;
 
 	t = find_table(sb);
 	if (!t)
@@ -186,6 +196,23 @@ int fsuserns_convert_uid_gid(struct user_namespace *ns, struct inode *inode,
 convert:
 	mutex_unlock(&fsuserns_table_mutex);
 
+	/* look for an xattr */
+	/* yes, 3 needs to be made adjustable */
+	valuelen = 3;
+	unsstore = kzalloc(3*sizeof(struct unsstore), GFP_KERNEL);
+	ret = xattrget(inode, unsstore, valuelen);
+	if (ret < 0)
+		return ret;
+	for (i=0; i<3; i++)
+		if (unsstore[i].ns == ep->userns_id)
+			break;
+	if (i==3)
+		goto out;
+	*retuid = unsstore[i].uid;
+	*retgid = unsstore[i].gid;
+	return 1;
+
+out:
 	/* The following is BAD CODE.  IT's for testing only */
 	if (current->uid == 0) {
 		if (inode->i_uid == ns->creator->uid) {
@@ -264,11 +291,6 @@ found:
 
 }
 
-struct unsstore {
-	int ns;
-	uid_t uid;
-};
-
 int fsuserns_store_creds(struct inode *inode, struct user_struct *user,
 	int (*xattrset)(struct inode *inode, const void *value, size_t value_len))
 {
@@ -290,11 +312,23 @@ int fsuserns_store_creds(struct inode *inode, struct user_struct *user,
 	size = depth * sizeof(struct unsstore);
 	unsstore = kmalloc(size, GFP_KERNEL);
 	ns = user->user_ns;
+	lastns = NULL;
 	for (i=0; ns != &init_user_ns; i++) {
 		unsstore[i].ns = find_ns_id(inode, ns);
 		unsstore[i].uid = user->uid;
+		/*
+		 * this is too bad.  But putting grp on user_struct wouldn't work
+		 * (think about if i do
+		* 		clone(CLONE_NEWUSER);
+		 * 		change grp,
+		 * 		clone(CLONE_NEWUSER)
+		 * */
+		if (!lastns)  
+			unsstore[i].gid = current->gid;
+		else
+			unsstore[i].gid = lastns->creator_grp;
 		printk(KERN_NOTICE "%s: setting xattr with ns=%d,uid=%d\n", __func__,
-				unsstore[i].ns, unsstore[i].uid);
+				unsstore[i].ns, unsstore[i].uid, unsstore[i].gid);
 		user = ns->creator;
 		lastns = ns;
 		ns = user->user_ns;
-- 
1.5.4.3
