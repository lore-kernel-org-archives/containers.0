From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 4/6] vfs: Only support slave subtrees across different
	user namespaces
Date: Mon, 19 Nov 2012 02:50:20 -0800
Message-ID: <1353322222-27060-4-git-send-email-ebiederm@xmission.com>
References: <87k3thc1h3.fsf@xmission.com>
	<1353322222-27060-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353322222-27060-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Sharing mount subtress with mount namespaces created by unprivileged
users allows unprivileged mounts created by unprivileged users to
propagate to mount namespaces controlled by privileged users.

Prevent nasty consequences by changing shared subtrees to slave
subtress when an unprivileged users creates a new mount namespace.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c |   11 ++++++++---
 fs/pnode.h     |    1 +
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 207c7ba..4dfcaf0 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -786,7 +786,7 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 	if (!mnt)
 		return ERR_PTR(-ENOMEM);
 
-	if (flag & (CL_SLAVE | CL_PRIVATE))
+	if (flag & (CL_SLAVE | CL_PRIVATE | CL_SHARED_TO_SLAVE))
 		mnt->mnt_group_id = 0; /* not a peer of original */
 	else
 		mnt->mnt_group_id = old->mnt_group_id;
@@ -807,7 +807,8 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 	list_add_tail(&mnt->mnt_instance, &sb->s_mounts);
 	br_write_unlock(&vfsmount_lock);
 
-	if (flag & CL_SLAVE) {
+	if ((flag & CL_SLAVE) ||
+	    ((flag & CL_SHARED_TO_SLAVE) && IS_MNT_SHARED(old))) {
 		list_add(&mnt->mnt_slave, &old->mnt_slave_list);
 		mnt->mnt_master = old;
 		CLEAR_MNT_SHARED(mnt);
@@ -2331,6 +2332,7 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 	struct mount *p, *q;
 	struct mount *old = mnt_ns->root;
 	struct mount *new;
+	int copy_flags;
 
 	new_ns = alloc_mnt_ns(user_ns);
 	if (IS_ERR(new_ns))
@@ -2338,7 +2340,10 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 
 	down_write(&namespace_sem);
 	/* First pass: copy the tree topology */
-	new = copy_tree(old, old->mnt.mnt_root, CL_COPY_ALL | CL_EXPIRE);
+	copy_flags = CL_COPY_ALL | CL_EXPIRE;
+	if (user_ns != mnt_ns->user_ns)
+		copy_flags |= CL_SHARED_TO_SLAVE;
+	new = copy_tree(old, old->mnt.mnt_root, copy_flags);
 	if (IS_ERR(new)) {
 		up_write(&namespace_sem);
 		free_mnt_ns(new_ns);
diff --git a/fs/pnode.h b/fs/pnode.h
index 65c6097..19b853a3 100644
--- a/fs/pnode.h
+++ b/fs/pnode.h
@@ -22,6 +22,7 @@
 #define CL_COPY_ALL 		0x04
 #define CL_MAKE_SHARED 		0x08
 #define CL_PRIVATE 		0x10
+#define CL_SHARED_TO_SLAVE	0x20
 
 static inline void set_mnt_shared(struct mount *mnt)
 {
-- 
1.7.5.4
