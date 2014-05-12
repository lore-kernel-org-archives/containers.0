From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH driver-core-linus] kernfs, sysfs, cgroup: restrict extra perm
	check on open to sysfs
Date: Mon, 12 May 2014 13:56:27 -0400
Message-ID: <20140512175627.GE1421@htj.dyndns.org>
References: <CANaxB-xUm3rJ-Cbp72q-rQJO5mZe1qK6qXsQM=vh0U8upJ44+A@mail.gmail.com>
	<20140512151908.GC1421@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140512151908.GC1421-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

The kernfs open method - kernfs_fop_open() - inherited extra
permission checks from sysfs.  While the vfs layer allows ignoring the
read/write permissions checks if the issuer has CAP_DAC_OVERRIDE,
sysfs explicitly denied open regardless of the cap if the file doesn't
have any of the UGO perms of the requested access or doesn't implement
the requested operation.  It can be debated whether this was a good
idea or not but the behavior is too subtle and dangerous to change at
this point.

After cgroup got converted to kernfs, this extra perm check also got
applied to cgroup breaking libcgroup which opens write-only files with
O_RDWR as root.  This patch gates the extra open permission check with
a new flag KERNFS_ROOT_EXTRA_OPEN_PERM_CHECK and enables it for sysfs.
For sysfs, nothing changes.  For cgroup, root now can perform any
operation regardless of the permissions as it was before kernfs
conversion.  Note that kernfs still fails unimplemented operations
with -EINVAL.

While at it, add comments explaining KERNFS_ROOT flags.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Andrey Wagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
References: http://lkml.kernel.org/g/CANaxB-xUm3rJ-Cbp72q-rQJO5mZe1qK6qXsQM=vh0U8upJ44+A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org
Fixes: 2bd59d48ebfb ("cgroup: convert to kernfs")
---
 fs/kernfs/file.c       |   19 +++++++++++--------
 fs/sysfs/mount.c       |    3 ++-
 include/linux/kernfs.h |   19 ++++++++++++++++++-
 3 files changed, 31 insertions(+), 10 deletions(-)

--- a/fs/kernfs/file.c
+++ b/fs/kernfs/file.c
@@ -610,6 +610,7 @@ static void kernfs_put_open_node(struct
 static int kernfs_fop_open(struct inode *inode, struct file *file)
 {
 	struct kernfs_node *kn = file->f_path.dentry->d_fsdata;
+	struct kernfs_root *root = kernfs_root(kn);
 	const struct kernfs_ops *ops;
 	struct kernfs_open_file *of;
 	bool has_read, has_write, has_mmap;
@@ -624,14 +625,16 @@ static int kernfs_fop_open(struct inode
 	has_write = ops->write || ops->mmap;
 	has_mmap = ops->mmap;
 
-	/* check perms and supported operations */
-	if ((file->f_mode & FMODE_WRITE) &&
-	    (!(inode->i_mode & S_IWUGO) || !has_write))
-		goto err_out;
-
-	if ((file->f_mode & FMODE_READ) &&
-	    (!(inode->i_mode & S_IRUGO) || !has_read))
-		goto err_out;
+	/* see the flag definition for details */
+	if (root->flags & KERNFS_ROOT_EXTRA_OPEN_PERM_CHECK) {
+		if ((file->f_mode & FMODE_WRITE) &&
+		    (!(inode->i_mode & S_IWUGO) || !has_write))
+			goto err_out;
+
+		if ((file->f_mode & FMODE_READ) &&
+		    (!(inode->i_mode & S_IRUGO) || !has_read))
+			goto err_out;
+	}
 
 	/* allocate a kernfs_open_file for the file */
 	error = -ENOMEM;
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -63,7 +63,8 @@ int __init sysfs_init(void)
 {
 	int err;
 
-	sysfs_root = kernfs_create_root(NULL, 0, NULL);
+	sysfs_root = kernfs_create_root(NULL, KERNFS_ROOT_EXTRA_OPEN_PERM_CHECK,
+					NULL);
 	if (IS_ERR(sysfs_root))
 		return PTR_ERR(sysfs_root);
 
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -50,7 +50,24 @@ enum kernfs_node_flag {
 
 /* @flags for kernfs_create_root() */
 enum kernfs_root_flag {
-	KERNFS_ROOT_CREATE_DEACTIVATED = 0x0001,
+	/*
+	 * kernfs_nodes are created in the deactivated state and invisible.
+	 * They require explicit kernfs_activate() to become visible.  This
+	 * can be used to make related nodes become visible atomically
+	 * after all nodes are created successfully.
+	 */
+	KERNFS_ROOT_CREATE_DEACTIVATED		= 0x0001,
+
+	/*
+	 * For regular flies, if the opener has CAP_DAC_OVERRIDE, open(2)
+	 * succeeds regardless of the RW permissions.  sysfs had an extra
+	 * layer of enforcement where open(2) fails with -EACCES regardless
+	 * of CAP_DAC_OVERRIDE if the permission doesn't have the
+	 * respective read or write access at all (none of S_IRUGO or
+	 * S_IWUGO) or the respective operation isn't implemented.  The
+	 * following flag enables that behavior.
+	 */
+	KERNFS_ROOT_EXTRA_OPEN_PERM_CHECK	= 0x0002,
 };
 
 /* type-specific structures for kernfs_node union members */
