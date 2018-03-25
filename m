From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] Revert "mqueue: switch to on-demand creation of internal
	mount"
Date: Sat, 24 Mar 2018 20:25:06 -0500
Message-ID: <87r2o9eykt.fsf_-_@xmission.com>
References: <20180323060457.sxgsd3j2obi33fyw@gordon>
	<87k1u3ti9e.fsf@xmission.com> <87fu4qo4ff.fsf_-_@xmission.com>
	<20180323231511.GK30522@ZenIV.linux.org.uk>
	<87in9ljvvx.fsf@xmission.com>
	<20180324214845.GM30522@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180324214845.GM30522-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Sat, 24 Mar 2018 21:48:45 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Giuseppe Scrivano <gscrivan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org


Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: cfb2f6f6e0ba11ea7b263d6b69c170c4b32ac0ea Revert "mqueue: switch to on-demand creation of internal mount"

This fixes a regression that came in the merge window for v4.16.  The
problem is that the permissions for mounting and using the mqueuefs
filesystem are broken.  The necessary permission check is missing
letting people who should not be able to mount mqueuefs mount mqueuefs.
The field sb->s_user_ns is set incorrectly not allowing the mounter of
mqueuefs to remount and otherwise have proper control over the
filesystem.

Al Viro and I see the path to the necessary fixes differently and I am
not even certain at this point he actually sees all of the necessary
fixes.  Given a couple weeks we can probably work something out but I
don't see the review being resolved in time for the final v4.16.  I
don't want v4.16 shipping with a nasty regression.  So unfortunately I
am sending a revert.

Eric

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date: Sat, 24 Mar 2018 11:28:14 -0500
Subject: [PATCH] Revert "mqueue: switch to on-demand creation of internal mount"

This reverts commit 36735a6a2b5e042db1af956ce4bcc13f3ff99e21.

Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> writes:
> [REGRESSION v4.16-rc6] [PATCH] mqueue: forbid unprivileged user access to internal mount
>
> Felix reported weird behaviour on 4.16.0-rc6 with regards to mqueue[1],
> which was introduced by 36735a6a2b5e ("mqueue: switch to on-demand
> creation of internal mount").
>
> Basically, the reproducer boils down to being able to mount mqueue if
> you create a new user namespace, even if you don't unshare the IPC
> namespace.
>
> Previously this was not possible, and you would get an -EPERM. The mount
> is the *host* mqueue mount, which is being cached and just returned from
> mqueue_mount(). To be honest, I'm not sure if this is safe or not (or if
> it was intentional -- since I'm not familiar with mqueue).
>
> To me it looks like there is a missing permission check. I've included a
> patch below that I've compile-tested, and should block the above case.
> Can someone please tell me if I'm missing something? Is this actually
> safe?
>
> [1]: https://github.com/docker/docker/issues/36674

The issue is a lot deeper than a missing permission check.  sb->s_user_ns
was is improperly set as well.  So in addition to the filesystem being
mounted when it should not be mounted, so things are not allow that should
be.

We are practically to the release of 4.16 and there is no agreement between
Al Viro and myself on what the code should looks like to fix things properly.
So revert the code to what it was before so that we can take our time
and discuss this properly.

Fixes: 36735a6a2b5e ("mqueue: switch to on-demand creation of internal mount")
Reported-by: Felix Abecassis <fabecassis-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Reported-by: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 ipc/mqueue.c | 74 ++++++++++++++++--------------------------------------------
 1 file changed, 19 insertions(+), 55 deletions(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index d7f309f74dec..a808f29d4c5a 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -325,9 +325,8 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 static int mqueue_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct inode *inode;
-	struct ipc_namespace *ns = data;
+	struct ipc_namespace *ns = sb->s_fs_info;
 
-	sb->s_fs_info = ns;
 	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
@@ -344,44 +343,18 @@ static int mqueue_fill_super(struct super_block *sb, void *data, int silent)
 	return 0;
 }
 
-static struct file_system_type mqueue_fs_type;
-/*
- * Return value is pinned only by reference in ->mq_mnt; it will
- * live until ipcns dies.  Caller does not need to drop it.
- */
-static struct vfsmount *mq_internal_mount(void)
-{
-	struct ipc_namespace *ns = current->nsproxy->ipc_ns;
-	struct vfsmount *m = ns->mq_mnt;
-	if (m)
-		return m;
-	m = kern_mount_data(&mqueue_fs_type, ns);
-	spin_lock(&mq_lock);
-	if (unlikely(ns->mq_mnt)) {
-		spin_unlock(&mq_lock);
-		if (!IS_ERR(m))
-			kern_unmount(m);
-		return ns->mq_mnt;
-	}
-	if (!IS_ERR(m))
-		ns->mq_mnt = m;
-	spin_unlock(&mq_lock);
-	return m;
-}
-
 static struct dentry *mqueue_mount(struct file_system_type *fs_type,
 			 int flags, const char *dev_name,
 			 void *data)
 {
-	struct vfsmount *m;
-	if (flags & SB_KERNMOUNT)
-		return mount_nodev(fs_type, flags, data, mqueue_fill_super);
-	m = mq_internal_mount();
-	if (IS_ERR(m))
-		return ERR_CAST(m);
-	atomic_inc(&m->mnt_sb->s_active);
-	down_write(&m->mnt_sb->s_umount);
-	return dget(m->mnt_root);
+	struct ipc_namespace *ns;
+	if (flags & SB_KERNMOUNT) {
+		ns = data;
+		data = NULL;
+	} else {
+		ns = current->nsproxy->ipc_ns;
+	}
+	return mount_ns(fs_type, flags, data, ns, ns->user_ns, mqueue_fill_super);
 }
 
 static void init_once(void *foo)
@@ -771,16 +744,13 @@ static int prepare_open(struct dentry *dentry, int oflag, int ro,
 static int do_mq_open(const char __user *u_name, int oflag, umode_t mode,
 		      struct mq_attr *attr)
 {
-	struct vfsmount *mnt = mq_internal_mount();
-	struct dentry *root;
+	struct vfsmount *mnt = current->nsproxy->ipc_ns->mq_mnt;
+	struct dentry *root = mnt->mnt_root;
 	struct filename *name;
 	struct path path;
 	int fd, error;
 	int ro;
 
-	if (IS_ERR(mnt))
-		return PTR_ERR(mnt);
-
 	audit_mq_open(oflag, mode, attr);
 
 	if (IS_ERR(name = getname(u_name)))
@@ -791,7 +761,6 @@ static int do_mq_open(const char __user *u_name, int oflag, umode_t mode,
 		goto out_putname;
 
 	ro = mnt_want_write(mnt);	/* we'll drop it in any case */
-	root = mnt->mnt_root;
 	inode_lock(d_inode(root));
 	path.dentry = lookup_one_len(name->name, root, strlen(name->name));
 	if (IS_ERR(path.dentry)) {
@@ -840,9 +809,6 @@ SYSCALL_DEFINE1(mq_unlink, const char __user *, u_name)
 	struct ipc_namespace *ipc_ns = current->nsproxy->ipc_ns;
 	struct vfsmount *mnt = ipc_ns->mq_mnt;
 
-	if (!mnt)
-		return -ENOENT;
-
 	name = getname(u_name);
 	if (IS_ERR(name))
 		return PTR_ERR(name);
@@ -1569,26 +1535,28 @@ int mq_init_ns(struct ipc_namespace *ns)
 	ns->mq_msgsize_max   = DFLT_MSGSIZEMAX;
 	ns->mq_msg_default   = DFLT_MSG;
 	ns->mq_msgsize_default  = DFLT_MSGSIZE;
-	ns->mq_mnt = NULL;
 
+	ns->mq_mnt = kern_mount_data(&mqueue_fs_type, ns);
+	if (IS_ERR(ns->mq_mnt)) {
+		int err = PTR_ERR(ns->mq_mnt);
+		ns->mq_mnt = NULL;
+		return err;
+	}
 	return 0;
 }
 
 void mq_clear_sbinfo(struct ipc_namespace *ns)
 {
-	if (ns->mq_mnt)
-		ns->mq_mnt->mnt_sb->s_fs_info = NULL;
+	ns->mq_mnt->mnt_sb->s_fs_info = NULL;
 }
 
 void mq_put_mnt(struct ipc_namespace *ns)
 {
-	if (ns->mq_mnt)
-		kern_unmount(ns->mq_mnt);
+	kern_unmount(ns->mq_mnt);
 }
 
 static int __init init_mqueue_fs(void)
 {
-	struct vfsmount *m;
 	int error;
 
 	mqueue_inode_cachep = kmem_cache_create("mqueue_inode_cache",
@@ -1610,10 +1578,6 @@ static int __init init_mqueue_fs(void)
 	if (error)
 		goto out_filesystem;
 
-	m = kern_mount_data(&mqueue_fs_type, &init_ipc_ns);
-	if (IS_ERR(m))
-		goto out_filesystem;
-	init_ipc_ns.mq_mnt = m;
 	return 0;
 
 out_filesystem:
-- 
2.14.1
