From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 4/4] devpts: fix usage in user namespaces
Date: Fri, 15 Mar 2013 13:13:43 +0400
Message-ID: <1363338823-25292-5-git-send-email-glommer__44307.7479060323$1363338858$gmane$org@parallels.com>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1363338823-25292-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

The current usage of devpts in user namespaces is quite problematic
for a couple of reasons:

* It requires the newinstance option, which is a sensible thing.
  However, if we are running full distributions inside containers
  or any other form of unmodified apps, that option wouldn't be passed
  for what they believe to be the initial mount. We could of course do
  the mount in the container initialization itself, but many
  distributions will somehow remount /dev in temporary storage for udev,
  and then mount devpts ontop of that. That gets rid of our setup, and
  overcoming that would require a complex synchronization between the
  control tool and the distribution booting. A much better behavior
  is to imply that option for the first mount in the user namespace.

* Again, unless we are talking about a custom application, standard
  procedures like ssh, openpty, and friends, will try to open /dev/ptmx
  instead of /dev/pts/ptmx. We can link that in userspace but that is
  quite cumbersome, for the same reasons listed above. A better behavior
  is to respect newinstance mounts regardless of whether they come from,
  but keep track of who is the first mount inside the usernamespace.
  That becomes the "root" of that namespace, and inodes without ties
  to a specific superblock will point to that instead of devpts_mount.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 fs/devpts/inode.c | 157 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 151 insertions(+), 6 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 073d30b..58fbff4 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -123,12 +123,129 @@ static const match_table_t tokens = {
 	{Opt_err, NULL}
 };
 
+struct userns_ptmx {
+	struct list_head list;
+	struct user_namespace *owner;
+	struct super_block *sb;
+};
+
 struct pts_fs_info {
 	struct ida allocated_ptys;
 	struct pts_mount_opts mount_opts;
 	struct dentry *ptmx_dentry;
+#if defined(CONFIG_DEVPTS_MULTIPLE_INSTANCES) && defined(CONFIG_USER_NS)
+	struct userns_ptmx *ns_ptmx;
+#endif
 };
 
+#if defined(CONFIG_DEVPTS_MULTIPLE_INSTANCES) && defined(CONFIG_USER_NS)
+/*
+ * When using user namespaces, we will require devpts to be created as a new
+ * instance and thus will span a new superblock. However, applications running
+ * inside a container may still try to open /dev/ptmx, instead of
+ * /dev/pts/ptmx. That will be the rule for all non custom applications. When
+ * that happen, they will end up opening the root namespace's /dev/ptmx. That
+ * will in turn create a new pts in the main /dev, outside the reach of our
+ * user namespace.
+ *
+ * The rule to deal with it is very simple: The first /dev/pts mount inside the
+ * namespace will become the owner of that namespace. Anyone reading /dev/ptmx
+ * will be redirected to /dev/pts/ptmx of that mount. Subsequent mounts will
+ * have to create a new instance to have a separated ptmx, just the way it it
+ * for non user namespace.
+ */
+static LIST_HEAD(userns_ptmx_list);
+static DEFINE_MUTEX(userns_ptmx_mutex);
+struct pts_fs_info;
+
+/*
+ * Having ns_ptmx stored somewhere in the superblock (and fsi is the obvious
+ * choice) is para-mount (pun intended) destroying it while umounting. We
+ * need to signal that there is something to destroy.
+ */
+static void define_ns_root_ptmx(struct super_block *sb,
+				struct userns_ptmx *ns_ptmx)
+{
+	struct pts_fs_info *fsi = sb->s_fs_info;
+	if (!ns_ptmx)
+		return;
+
+	fsi->ns_ptmx = ns_ptmx;
+	ns_ptmx->sb = sb;
+}
+
+static void remove_ns_root_ptmx(struct pts_fs_info *fsi)
+{
+	if (!fsi->ns_ptmx)
+		return;
+
+	if (WARN_ON(fsi->ns_ptmx->owner == &init_user_ns))
+		return;
+
+	mutex_lock(&userns_ptmx_mutex);
+	list_del(&fsi->ns_ptmx->list);
+	mutex_unlock(&userns_ptmx_mutex);
+	kfree(fsi->ns_ptmx);
+}
+
+static struct super_block *pts_sb_of_namespace(struct user_namespace *userns)
+{
+	struct userns_ptmx *ns_ptmx  = NULL;
+	struct super_block *sb = NULL;
+
+	mutex_lock(&userns_ptmx_mutex);
+	list_for_each_entry(ns_ptmx, &userns_ptmx_list, list) {
+		if (ns_ptmx->owner != userns)
+			continue;
+		sb = ns_ptmx->sb;
+		goto out;
+	}
+out:
+	mutex_unlock(&userns_ptmx_mutex);
+	return sb;
+}
+
+static struct userns_ptmx *pts_new_namespace_root(struct user_namespace *userns)
+{
+	struct userns_ptmx *ns_ptmx;
+	if (userns == &init_user_ns)
+		return NULL;
+
+	ns_ptmx = kzalloc(sizeof(*ns_ptmx), GFP_KERNEL);
+	if (!ns_ptmx)
+		return ns_ptmx;
+
+	ns_ptmx->owner = userns;
+	mutex_lock(&userns_ptmx_mutex);
+	list_add(&ns_ptmx->list, &userns_ptmx_list);
+	mutex_unlock(&userns_ptmx_mutex);
+
+	return ns_ptmx;
+}
+#else
+static inline void define_ns_root_ptmx(struct super_block *sb,
+				struct userns_ptmx *ns_ptmx)
+{
+}
+
+static inline struct super_block *
+pts_sb_of_namespace(struct user_namespace *userns)
+{
+	return NULL;
+}
+
+static inline struct userns_ptmx *
+pts_new_namespace_root(struct user_namespace *userns)
+{
+	return NULL;
+}
+
+static inline void remove_ns_root_ptmx(struct pts_fs_info *fsi)
+{
+}
+#endif
+
+
 static inline struct pts_fs_info *DEVPTS_SB(struct super_block *sb)
 {
 	return sb->s_fs_info;
@@ -139,6 +256,13 @@ static inline struct super_block *pts_sb_from_inode(struct inode *inode)
 #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
 	if (inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
 		return inode->i_sb;
+	else if (current_user_ns() != &init_user_ns)
+		/*
+		 * If there is valid devpts superblock associated with the
+		 * inode, then we respect it no matter what. Otherwise, which
+		 * superblock we return depends on which namespace we are at.
+		 */
+		return pts_sb_of_namespace(current_user_ns());
 #endif
 	return devpts_mnt->mnt_sb;
 }
@@ -442,16 +566,31 @@ static struct dentry *devpts_mount(struct file_system_type *fs_type,
 	int error;
 	struct pts_mount_opts opts;
 	struct super_block *s;
+	struct user_namespace *userns = current_user_ns();
+	struct userns_ptmx *ns_ptmx = NULL;
 
 	error = parse_mount_options(data, PARSE_MOUNT, &opts);
 	if (error)
 		return ERR_PTR(error);
 
-	/* Require newinstance for all user namespace mounts to ensure
-	 * the mount options are not changed.
+	/*
+	 * Require newinstance for all user namespace mounts to ensure
+	 * the mount options are not changed. If this is the first mount
+	 * of the namespace, that option is implied.
 	 */
-	if ((current_user_ns() != &init_user_ns) && !opts.newinstance)
-		return ERR_PTR(-EINVAL);
+	if ((userns != &init_user_ns) && !opts.newinstance) {
+		/*
+		 * And this is how we know we're talking about the first
+		 * mount. If we don't have an assigned ptmx of userns,
+		 * then we have to create it.
+		 */
+		if (pts_sb_of_namespace(userns))
+			return ERR_PTR(-EINVAL);
+		ns_ptmx = pts_new_namespace_root(userns);
+		if (!ns_ptmx)
+			return ERR_PTR(-ENOMEM);
+		opts.newinstance = 1;
+	}
 
 	if (opts.newinstance)
 		s = sget(fs_type, NULL, set_anon_super, flags, NULL);
@@ -459,8 +598,10 @@ static struct dentry *devpts_mount(struct file_system_type *fs_type,
 		s = sget(fs_type, compare_init_pts_sb, set_anon_super, flags,
 			 NULL);
 
-	if (IS_ERR(s))
-		return ERR_CAST(s);
+	if (IS_ERR(s)) {
+		error = PTR_ERR(s);
+		goto out_no_s;
+	}
 
 	if (!s->s_root) {
 		error = devpts_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
@@ -470,6 +611,7 @@ static struct dentry *devpts_mount(struct file_system_type *fs_type,
 	}
 
 	memcpy(&(DEVPTS_SB(s))->mount_opts, &opts, sizeof(opts));
+	define_ns_root_ptmx(s, ns_ptmx);
 
 	error = mknod_ptmx(s);
 	if (error)
@@ -479,6 +621,8 @@ static struct dentry *devpts_mount(struct file_system_type *fs_type,
 
 out_undo_sget:
 	deactivate_locked_super(s);
+out_no_s:
+	kfree(ns_ptmx);
 	return ERR_PTR(error);
 }
 
@@ -498,6 +642,7 @@ static void devpts_kill_sb(struct super_block *sb)
 {
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
 
+	remove_ns_root_ptmx(fsi);
 	kfree(fsi);
 	kill_litter_super(sb);
 }
-- 
1.8.1.2
