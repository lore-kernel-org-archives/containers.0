From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH] vfs: Don't copy mount bind mounts of
	/proc/<pid>/ns/mnt between namespaces
Date: Tue, 27 Aug 2013 14:39:19 -0700
Message-ID: <87haeahkzc.fsf@xmission.com>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Don't copy bind mounts of /proc/<pid>/ns/mnt between namespaces.
These files hold references to a mount namespace and copying them
between namespaces could result in a reference counting loop.

The current mnt_ns_loop test prevents loops on the assumption that
mounts don't cross between namespaces.  Unfortunately unsharing a
mount namespace and shared substrees can both cause mounts to
propogate between mount namespaces.

Add two flags CL_COPY_UNBINDABLE and CL_COPY_MNT_NS_FILE are added to
control this behavior, and CL_COPY_ALL is redefined as both of them.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c |   46 ++++++++++++++++++++++++++++++++++------------
 fs/pnode.h     |    5 ++++-
 2 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 7e16a73..64627f8 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1355,14 +1355,11 @@ SYSCALL_DEFINE1(oldumount, char __user *, name)
 
 #endif
 
-static bool mnt_ns_loop(struct path *path)
+static bool is_mnt_ns_file(struct dentry *dentry)
 {
-	/* Could bind mounting the mount namespace inode cause a
-	 * mount namespace loop?
-	 */
-	struct inode *inode = path->dentry->d_inode;
+	/* Is this a proxy for a mount namespace? */
+	struct inode *inode = dentry->d_inode;
 	struct proc_ns *ei;
-	struct mnt_namespace *mnt_ns;
 
 	if (!proc_ns_inode(inode))
 		return false;
@@ -1371,7 +1368,19 @@ static bool mnt_ns_loop(struct path *path)
 	if (ei->ns_ops != &mntns_operations)
 		return false;
 
-	mnt_ns = ei->ns;
+	return true;
+}
+
+static bool mnt_ns_loop(struct dentry *dentry)
+{
+	/* Could bind mounting the mount namespace inode cause a
+	 * mount namespace loop?
+	 */
+	struct mnt_namespace *mnt_ns;
+	if (!is_mnt_ns_file(dentry))
+		return false;
+
+	mnt_ns = get_proc_ns(dentry->d_inode)->ns;
 	return current->nsproxy->mnt_ns->seq >= mnt_ns->seq;
 }
 
@@ -1380,7 +1389,10 @@ struct mount *copy_tree(struct mount *mnt, struct dentry *dentry,
 {
 	struct mount *res, *p, *q, *r, *parent;
 
-	if (!(flag & CL_COPY_ALL) && IS_MNT_UNBINDABLE(mnt))
+	if (!(flag & CL_COPY_UNBINDABLE) && IS_MNT_UNBINDABLE(mnt))
+		return ERR_PTR(-EINVAL);
+
+	if (!(flag & CL_COPY_MNT_NS_FILE) && is_mnt_ns_file(dentry))
 		return ERR_PTR(-EINVAL);
 
 	res = q = clone_mnt(mnt, dentry, flag);
@@ -1397,7 +1409,13 @@ struct mount *copy_tree(struct mount *mnt, struct dentry *dentry,
 			continue;
 
 		for (s = r; s; s = next_mnt(s, r)) {
-			if (!(flag & CL_COPY_ALL) && IS_MNT_UNBINDABLE(s)) {
+			if (!(flag & CL_COPY_UNBINDABLE) &&
+			    IS_MNT_UNBINDABLE(s)) {
+				s = skip_mnt_tree(s);
+				continue;
+			}
+			if (!(flag & CL_COPY_MNT_NS_FILE) &&
+			    is_mnt_ns_file(s->mnt.mnt_root)) {
 				s = skip_mnt_tree(s);
 				continue;
 			}
@@ -1733,7 +1751,7 @@ static int do_loopback(struct path *path, const char *old_name,
 		return err;
 
 	err = -EINVAL;
-	if (mnt_ns_loop(&old_path))
+	if (mnt_ns_loop(old_path.dentry))
 		goto out; 
 
 	mp = lock_mount(path);
@@ -1755,7 +1773,7 @@ static int do_loopback(struct path *path, const char *old_name,
 		goto out2;
 
 	if (recurse)
-		mnt = copy_tree(old, old_path.dentry, 0);
+		mnt = copy_tree(old, old_path.dentry, CL_COPY_MNT_NS_FILE);
 	else
 		mnt = clone_mnt(old, old_path.dentry, 0);
 
@@ -2417,7 +2435,7 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 
 	namespace_lock();
 	/* First pass: copy the tree topology */
-	copy_flags = CL_COPY_ALL | CL_EXPIRE;
+	copy_flags = CL_COPY_UNBINDABLE | CL_EXPIRE;
 	if (user_ns != mnt_ns->user_ns)
 		copy_flags |= CL_SHARED_TO_SLAVE | CL_UNPRIVILEGED;
 	new = copy_tree(old, old->mnt.mnt_root, copy_flags);
@@ -2452,6 +2470,10 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 		}
 		p = next_mnt(p, old);
 		q = next_mnt(q, new);
+		if (!q)
+			break;
+		while (p->mnt.mnt_root != q->mnt.mnt_root)
+			p = next_mnt(p, old);
 	}
 	namespace_unlock();
 
diff --git a/fs/pnode.h b/fs/pnode.h
index b091445..59e7eda 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -19,11 +19,14 @@
 
 #define CL_EXPIRE    		0x01
 #define CL_SLAVE     		0x02
-#define CL_COPY_ALL 		0x04
+#define CL_COPY_UNBINDABLE	0x04
 #define CL_MAKE_SHARED 		0x08
 #define CL_PRIVATE 		0x10
 #define CL_SHARED_TO_SLAVE	0x20
 #define CL_UNPRIVILEGED		0x40
+#define CL_COPY_MNT_NS_FILE	0x80
+
+#define CL_COPY_ALL		(CL_COPY_UNBINDABLE | CL_COPY_MNT_NS_FILE)
 
 static inline void set_mnt_shared(struct mount *mnt)
 {
-- 
1.7.5.4
