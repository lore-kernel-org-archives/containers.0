From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] checkpoint/restart: refuse checkpoint on detached file
Date: Thu, 4 Dec 2008 22:41:41 -0600
Message-ID: <20081205044141.GA1444@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

So Dave brought up the problem of checkpointing a task which has an open
fd to a file which is under a directory which has been lazily unmounted.

Now long-term I suspect we will want to do something like figure out
another path to the file which restart can use, or, if we've lost the
last ref to the file then treat it as a deleted private file...  but
in the meantime we should refuse to checkpoint such a task, since it
won't be restartable.

On irc we'd talked about catching umount -l and balancing it with the
final mntput, and setting the uncheckpointable flag on the whole
namespace in the meantime.

As an alternative, I thought it might be good to just check each file
for whether it's under a unmounted vfsmount.  The reason I think this
is a good approach is that if we try to actually solve the problem for
real, we'll want to do these steps anyway.

Opinions?

From 4a39c479498bdce027320a1cc91a093ed2fb8450 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 4 Dec 2008 20:16:22 -0800
Subject: [PATCH 1/1] checkpoint/restart: refuse checkpoint on detached file

If a file is on an fs which has been detached, refuse the
checkpoint (for now).

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/ckpt_file.c |   21 +++++++++++++++++++++
 fs/namespace.c         |   24 ++++++++++++++++++++++++
 include/linux/dcache.h |    1 +
 3 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index 9198650..1013faf 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -14,6 +14,9 @@
 #include <linux/fdtable.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/fs.h>
+#include <linux/mount.h>
+#include <linux/dcache.h>
 
 #include "checkpoint_file.h"
 
@@ -123,6 +126,18 @@ static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
 	return cr_write_fname(ctx, &file->f_path, ctx->vfsroot);
 }
 
+int file_in_detached_tree(struct file *file)
+{
+	struct vfsmount *mnt = file->f_path.mnt;
+
+	while (mnt->mnt_parent != mnt) {
+		if (!is_still_mounted(mnt))
+			return 1;
+		mnt = mnt->mnt_parent;
+	}
+	return 0;
+}
+
 /**
  * cr_write_fd_ent - dump the state of a given file descriptor
  * @ctx: checkpoint context
@@ -158,6 +173,12 @@ cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
 		goto out;
 	}
 
+	/* Make sure this isn't under some detached tree */
+	if (file_in_detached_tree(file)) {
+		ret = -EBADF;
+		goto out;
+	}
+
 	new = cr_obj_add_ptr(ctx, file, &objref, CR_OBJ_FILE, 0);
 	cr_debug("fd %d objref %d file %p c-o-e %d)\n", fd, objref, file, coe);
 
diff --git a/fs/namespace.c b/fs/namespace.c
index cce4670..17153f0 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -438,6 +438,30 @@ struct vfsmount *__lookup_mnt(struct vfsmount *mnt, struct dentry *dentry,
 	return found;
 }
 
+int is_still_mounted(struct vfsmount *childmnt)
+{
+	struct vfsmount *mnt = childmnt->mnt_parent;
+	struct dentry *dentry = childmnt->mnt_mountpoint;
+	struct list_head *head = mount_hashtable + hash(mnt, dentry);
+	struct list_head *tmp = head;
+	struct vfsmount *p;
+	int found = 0;
+
+	for (;;) {
+		tmp = tmp->next;
+		p = NULL;
+		if (tmp == head)
+			break;
+		p = list_entry(tmp, struct vfsmount, mnt_hash);
+		if (p == childmnt) {
+			found = 1;
+			break;
+		}
+	}
+	return found;
+
+}
+
 /*
  * lookup_mnt increments the ref count before returning
  * the vfsmount struct.
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index a37359d..deda0cc 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -363,6 +363,7 @@ static inline int d_mountpoint(struct dentry *dentry)
 
 extern struct vfsmount *lookup_mnt(struct vfsmount *, struct dentry *);
 extern struct dentry *lookup_create(struct nameidata *nd, int is_dir);
+extern int is_still_mounted(struct vfsmount *childmnt);
 
 extern int sysctl_vfs_cache_pressure;
 
-- 
1.5.4.3
