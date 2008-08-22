From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/10] userns: store child userns uids as xattrs in ext3
	using lib/fsuserns
Date: Fri, 22 Aug 2008 14:47:05 -0500
Message-ID: <20080822194705.GH10360@us.ibm.com>
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

userns: store child userns uids as xattrs in ext3 using lib/fsuserns

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/ext3/namei.c                |    7 +++-
 fs/ext3/xattr.c                |   29 +++++++++++++++
 fs/ext3/xattr.h                |    2 +
 include/linux/user_namespace.h |    1 +
 kernel/user_namespace.c        |    1 +
 lib/fsuserns.c                 |   74 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 113 insertions(+), 1 deletions(-)

diff --git a/fs/ext3/namei.c b/fs/ext3/namei.c
index de13e91..e5be4bc 100644
--- a/fs/ext3/namei.c
+++ b/fs/ext3/namei.c
@@ -1676,6 +1676,9 @@ static int ext3_add_nondir(handle_t *handle,
 	return err;
 }
 
+int fsuserns_store_creds(struct inode *inode, struct user_struct *user,
+	int (*)(struct inode *inode, const void *value, size_t value_len));
+
 /*
  * By the time this is called, we already have created
  * the directory cache entry for the new file, but it
@@ -1707,7 +1710,9 @@ retry:
 		inode->i_op = &ext3_file_inode_operations;
 		inode->i_fop = &ext3_file_operations;
 		ext3_set_aops(inode);
-		err = ext3_add_nondir(handle, dentry, inode);
+		err = fsuserns_store_creds(inode, current->user, ext3_xattr_set_userns);
+		if (!err)
+			err = ext3_add_nondir(handle, dentry, inode);
 	}
 	ext3_journal_stop(handle);
 	if (err == -ENOSPC && ext3_should_retry_alloc(dir->i_sb, &retries))
diff --git a/fs/ext3/xattr.c b/fs/ext3/xattr.c
index 175414a..da47c35 100644
--- a/fs/ext3/xattr.c
+++ b/fs/ext3/xattr.c
@@ -1070,6 +1070,35 @@ retry:
 	return error;
 }
 
+int
+ext3_xattr_set_userns(struct inode *inode,
+	       const void *value, size_t value_len)
+{
+	int name_index = EXT3_XATTR_INDEX_SECURITY;
+	handle_t *handle;
+	int error, retries = 0;
+	char *name = "userns";
+
+retry:
+	handle = ext3_journal_start(inode, EXT3_DATA_TRANS_BLOCKS(inode->i_sb));
+	if (IS_ERR(handle)) {
+		error = PTR_ERR(handle);
+	} else {
+		int error2;
+
+		error = ext3_xattr_set_handle(handle, inode, name_index, name,
+					      value, value_len, flags);
+		error2 = ext3_journal_stop(handle);
+		if (error == -ENOSPC &&
+		    ext3_should_retry_alloc(inode->i_sb, &retries))
+			goto retry;
+		if (error == 0)
+			error = error2;
+	}
+
+	return error;
+}
+
 /*
  * ext3_xattr_delete_inode()
  *
diff --git a/fs/ext3/xattr.h b/fs/ext3/xattr.h
index 148a4df..8a523de 100644
--- a/fs/ext3/xattr.h
+++ b/fs/ext3/xattr.h
@@ -70,6 +70,8 @@ extern int ext3_xattr_get(struct inode *, int, const char *, void *, size_t);
 extern int ext3_xattr_set(struct inode *, int, const char *, const void *, size_t, int);
 extern int ext3_xattr_set_handle(handle_t *, struct inode *, int, const char *, const void *, size_t, int);
 
+extern int ext3_xattr_set_userns(struct inode *inode, const void *value, size_t value_len, int flags);
+
 extern void ext3_xattr_delete_inode(handle_t *, struct inode *);
 extern void ext3_xattr_put_super(struct super_block *);
 
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 1b4959d..a793263 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -14,6 +14,7 @@ struct user_namespace {
 	struct hlist_head	uidhash_table[UIDHASH_SZ];
 	struct user_struct	*root_user;
 	struct user_struct	*creator;
+	gid_t			creator_grp;
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 39aea7b..879693a 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -51,6 +51,7 @@ int create_new_userns(int flags, struct task_struct *tsk)
 	put_user_ns(ns);
 
 	task_switch_uid(tsk, ns->root_user);
+	ns->creator_grp = tsk->gid;
 	tsk->uid = tsk->euid = tsk->suid = tsk->fsuid = 0;
 	tsk->gid = tsk->egid = tsk->sgid = tsk->fsgid = 0;
 
diff --git a/lib/fsuserns.c b/lib/fsuserns.c
index c237d1d..db70970 100644
--- a/lib/fsuserns.c
+++ b/lib/fsuserns.c
@@ -5,6 +5,7 @@
 #include <linux/fs.h>
 #include <linux/user.h>
 #include <linux/user_namespace.h>
+#include <linux/xattr.h>
 
 /*
  * Ok, eventually I'll want some policy loaded which looks as follows:
@@ -233,3 +234,76 @@ convert:
 	printk(KERN_NOTICE "%s: oh, but I wasn't capable(%d)\n", __func__, cap);
 	return 0;
 }
+
+/*
+ * when a user_namespace is registered with an fs, we store the
+ * nsid.  This next fn will need to retreive an nsid for a
+ * given fs (inode->i_sb, that is) and user_namespace
+ *
+ * I don't want to do that bookkeeping yet, so i just return 1 :)
+ */
+int find_ns_id(struct inode *inode, struct user_namespace *ns)
+{
+	struct fsuserns_conversion_table *t;
+	struct fsuserns_table_entries *ep;
+
+	t = find_table(inode->i_sb);
+	mutex_lock(&fsuserns_table_mutex);
+	list_for_each_entry(ep, &t->entries, entries) {
+		if (ep->ns == ns)
+			goto found;
+	}
+	ep = NULL;
+found:
+	mutex_unlock(&fsuserns_table_mutex);
+
+	if (!ep)
+		return -1;
+	return ep->userns_id;
+
+
+}
+
+struct unsstore {
+	int ns;
+	uid_t uid;
+};
+
+int fsuserns_store_creds(struct inode *inode, struct user_struct *user,
+	int (*xattrset)(struct inode *inode, const void *value, size_t value_len))
+{
+	struct user_namespace *ns = user->user_ns, *lastns;
+	size_t size;
+	int i, depth, ret;
+	struct unsstore *unsstore;
+	struct user_struct *creator = user;
+	
+	if (ns == &init_user_ns)
+		return 0;
+
+	depth = 0;
+	while (ns != &init_user_ns) {
+		depth++;
+		creator = ns->creator;
+		ns = creator->user_ns;
+	}
+	size = depth * sizeof(struct unsstore);
+	unsstore = kmalloc(size, GFP_KERNEL);
+	ns = user->user_ns;
+	for (i=0; ns != &init_user_ns; i++) {
+		unsstore[i].ns = find_ns_id(inode, ns);
+		unsstore[i].uid = user->uid;
+		printk(KERN_NOTICE "%s: setting xattr with ns=%d,uid=%d\n", __func__,
+				unsstore[i].ns, unsstore[i].uid);
+		user = ns->creator;
+		lastns = ns;
+		ns = user->user_ns;
+	}
+
+	inode->i_uid = creator->uid;
+	inode->i_gid = lastns->creator_grp;
+
+	ret = xattrset(inode, unsstore, size);
+	kfree(unsstore);
+	return ret;
+}
-- 
1.5.4.3
