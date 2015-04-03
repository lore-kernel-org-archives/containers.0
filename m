From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 17/19] vfs: Test for and handle paths that are
	unreachable from their mnt_root
Date: Thu,  2 Apr 2015 20:56:21 -0500
Message-ID: <1428026183-14879-17-git-send-email-ebiederm__35649.5478227318$1428026522$gmane$org@xmission.com>
References: <87a8yqou41.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8yqou41.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Omar Sandoval <osandov-nWWhXC5lh1RBDgjK7y7TUQ@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

- Add a mount flag MNT_VIOLATED to mark loopback mounts that have had
  a dentry moved into a directory that does not descend from the mount
  root dentry.

- Add a function path_connected to verify a path.dentry is reachable from
  path.mnt.mnt_root.  AKA rename did not do something nasty to the bind mount.

- Disable ".." when a path is not connected during lookup.
  (Maybe we want to stop ".." at this path instead?)

  Following .. is not disabled after a transition to /
  and is never disabled when / is the directory we start
  with.   Because we already limit .. no higher than /

- In prepend_path and it's callers in the d_path family
  for a path that is not connected don't attempt to find
  parent directories.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c           |  3 +++
 fs/internal.h         |  1 +
 fs/namei.c            | 30 ++++++++++++++++++++++++++++++
 include/linux/mount.h |  1 +
 include/linux/namei.h |  2 ++
 5 files changed, 37 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index c71e3732e53b..e07eb03f6de6 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2871,6 +2871,9 @@ static int prepend_path(const struct path *path,
 	char *bptr;
 	int blen;
 
+	if (!path_connected(path))
+		root = path;
+
 	rcu_read_lock();
 restart_mnt:
 	read_seqbegin_or_lock(&mount_lock, &m_seq);
diff --git a/fs/internal.h b/fs/internal.h
index 01dce1d1476b..046767f0042e 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -51,6 +51,7 @@ extern void __init chrdev_init(void);
 extern int user_path_mountpoint_at(int, const char __user *, unsigned int, struct path *);
 extern int vfs_path_lookup(struct dentry *, struct vfsmount *,
 			   const char *, unsigned int, struct path *);
+extern bool path_connected(const struct path *);
 
 /*
  * namespace.c
diff --git a/fs/namei.c b/fs/namei.c
index c83145af4bfc..ec09c90089a9 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -493,6 +493,22 @@ void path_put(const struct path *path)
 }
 EXPORT_SYMBOL(path_put);
 
+/**
+ * path_connected - Verify that a path->dentry is below path->mnt->mnt.mnt_root
+ * @path: path to verify
+ *
+ * Rename can sometimes move a file or directory outside of bind mount
+ * don't honor paths where this has happened.
+ */
+bool path_connected(const struct path *path)
+{
+	struct vfsmount *mnt = path->mnt;
+	if (!(mnt->mnt_flags & MNT_VIOLATED))
+		return true;
+
+	return is_subdir(path->dentry, mnt->mnt_root);
+}
+
 struct nameidata {
 	struct path	path;
 	struct qstr	last;
@@ -712,6 +728,7 @@ void nd_jump_link(struct nameidata *nd, struct path *path)
 	nd->path = *path;
 	nd->inode = nd->path.dentry->d_inode;
 	nd->flags |= LOOKUP_JUMPED;
+	nd->flags &= ~LOOKUP_NODOTDOT;
 }
 
 void nd_set_link(struct nameidata *nd, char *path)
@@ -897,6 +914,7 @@ follow_link(struct path *link, struct nameidata *nd, void **p)
 			nd->path = nd->root;
 			path_get(&nd->root);
 			nd->flags |= LOOKUP_JUMPED;
+			nd->flags &= ~LOOKUP_NODOTDOT;
 		}
 		nd->inode = nd->path.dentry->d_inode;
 		error = link_path_walk(s, nd);
@@ -1161,6 +1179,7 @@ static bool __follow_mount_rcu(struct nameidata *nd, struct path *path,
 		path->mnt = &mounted->mnt;
 		path->dentry = mounted->mnt.mnt_root;
 		nd->flags |= LOOKUP_JUMPED;
+		nd->flags &= ~LOOKUP_NODOTDOT;
 		nd->seq = read_seqcount_begin(&path->dentry->d_seq);
 		/*
 		 * Update the inode too. We don't need to re-check the
@@ -1176,6 +1195,10 @@ static bool __follow_mount_rcu(struct nameidata *nd, struct path *path,
 static int follow_dotdot_rcu(struct nameidata *nd)
 {
 	struct inode *inode = nd->inode;
+
+	if (nd->flags & LOOKUP_NODOTDOT)
+		return 0;
+
 	if (!nd->root.mnt)
 		set_root_rcu(nd);
 
@@ -1293,6 +1316,9 @@ static void follow_mount(struct path *path)
 
 static void follow_dotdot(struct nameidata *nd)
 {
+	if (nd->flags & LOOKUP_NODOTDOT)
+		return;
+
 	if (!nd->root.mnt)
 		set_root(nd);
 
@@ -1909,6 +1935,8 @@ static int path_init(int dfd, const char *name, unsigned int flags,
 		} else {
 			get_fs_pwd(current->fs, &nd->path);
 		}
+		if (unlikely(!path_connected(&nd->path)))
+			nd->flags |= LOOKUP_NODOTDOT;
 	} else {
 		/* Caller must check execute permissions on the starting path component */
 		struct fd f = fdget_raw(dfd);
@@ -1936,6 +1964,8 @@ static int path_init(int dfd, const char *name, unsigned int flags,
 			path_get(&nd->path);
 			fdput(f);
 		}
+		if (unlikely(!path_connected(&nd->path)))
+			nd->flags |= LOOKUP_NODOTDOT;
 	}
 
 	nd->inode = nd->path.dentry->d_inode;
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 564beeec5d83..778d7cf65b9a 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -62,6 +62,7 @@ struct mnt_namespace;
 #define MNT_SYNC_UMOUNT		0x2000000
 #define MNT_MARKED		0x4000000
 #define MNT_UMOUNT		0x8000000
+#define MNT_VIOLATED		0x10000000
 
 struct vfsmount {
 	struct dentry *mnt_root;	/* root of the mounted tree */
diff --git a/include/linux/namei.h b/include/linux/namei.h
index c8990779f0c3..55c8aaec7b03 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -45,6 +45,8 @@ enum {LAST_NORM, LAST_ROOT, LAST_DOT, LAST_DOTDOT, LAST_BIND};
 #define LOOKUP_ROOT		0x2000
 #define LOOKUP_EMPTY		0x4000
 
+#define LOOKUP_NODOTDOT		0x10000
+
 extern int user_path_at(int, const char __user *, unsigned, struct path *);
 extern int user_path_at_empty(int, const char __user *, unsigned, struct path *, int *empty);
 
-- 
2.2.1
