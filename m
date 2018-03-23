From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/2] mqueuefs: Fix the permissions and permission checks when
	mounting mqueuefs
Date: Fri, 23 Mar 2018 16:43:42 -0500
Message-ID: <874ll6o4c1.fsf_-___30369.5823801265$1521841370$gmane$org@xmission.com>
References: <20180323060457.sxgsd3j2obi33fyw@gordon>
	<87k1u3ti9e.fsf@xmission.com> <87fu4qo4ff.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fu4qo4ff.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Fri, 23 Mar 2018 16:41:40 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Aleksa Sarai writes:
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
>
> [1]: https://github.com/docker/docker/issues/36674

After examination of the code it might be safe by chance but it is
definitely wrong.  The missing permission checks are needed in the
general case, and sb->s_user_ns needs to be set to ns->user_ns to give
root in the user namespace the appropriate permissions over the
filesystem.

Fixes: 36735a6a2b5e ("mqueue: switch to on-demand creation of internal mount")
Reported-by: Felix Abecassis <fabecassis-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Reported-by: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

Unless there are objections I will push these fixes to Linus in a day
or so.

 ipc/mqueue.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index d7f309f74dec..832c1ec21318 100644
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
@@ -349,9 +348,9 @@ static struct file_system_type mqueue_fs_type;
  * Return value is pinned only by reference in ->mq_mnt; it will
  * live until ipcns dies.  Caller does not need to drop it.
  */
-static struct vfsmount *mq_internal_mount(void)
+static struct vfsmount *mq_internal_mount(void *nsp)
 {
-	struct ipc_namespace *ns = current->nsproxy->ipc_ns;
+	struct ipc_namespace *ns = nsp;
 	struct vfsmount *m = ns->mq_mnt;
 	if (m)
 		return m;
@@ -373,15 +372,9 @@ static struct dentry *mqueue_mount(struct file_system_type *fs_type,
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
+	struct ipc_namespace *ns = current->nsproxy->ipc_ns;
+	return mount_ns(fs_type, flags, data, ns, ns->user_ns,
+			mq_internal_mount, mqueue_fill_super);
 }
 
 static void init_once(void *foo)
@@ -771,7 +764,7 @@ static int prepare_open(struct dentry *dentry, int oflag, int ro,
 static int do_mq_open(const char __user *u_name, int oflag, umode_t mode,
 		      struct mq_attr *attr)
 {
-	struct vfsmount *mnt = mq_internal_mount();
+	struct vfsmount *mnt = mq_internal_mount(current->nsproxy->ipc_ns);
 	struct dentry *root;
 	struct filename *name;
 	struct path path;
-- 
2.14.1
