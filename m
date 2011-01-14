From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: kernel BUG at fs/dcache.c:1363 (from cgroup)
Date: Fri, 14 Jan 2011 05:14:53 +0000
Message-ID: <20110114051453.GY19804__41705.6284532466$1294982216$gmane$org@ZenIV.linux.org.uk>
References: <4D2FD771.9040301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D2FD771.9040301-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Nick Piggin <npiggin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jan 14, 2011 at 12:56:17PM +0800, Li Zefan wrote:
> Just mount the cgroupfs:
> 
> # mount -t cgroup -o cpuset xxx /mnt
> (oops!!)
> 
> The bug is caused by:
> 
> =========
> commit 0df6a63f8735a7c8a877878bc215d4312e41ef81
> Author: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> Date:   Tue Dec 21 13:29:29 2010 -0500
> 
>     switch cgroup
>     
>     switching it to s_d_op allows to kill the cgroup_lookup() kludge.
>     
>     Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
> =========
> 
> This line:
> 
> +       sb->s_d_op = &cgroup_dops;

Oh, crap...  Right, it's using simple_lookup().  Let me check if anything
else might be stepping on that.

Umm...  There's a very strange codepath in btrfs that also might.
Interesting.  Fix for cgroup, AFAICS, should be this:

Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
---
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5c5f4cc..ffb7bba 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -764,6 +764,7 @@ EXPORT_SYMBOL_GPL(cgroup_unlock);
  */
 
 static int cgroup_mkdir(struct inode *dir, struct dentry *dentry, int mode);
+static struct dentry *cgroup_lookup(struct inode *, struct dentry *, struct nameidata *);
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry);
 static int cgroup_populate_dir(struct cgroup *cgrp);
 static const struct inode_operations cgroup_dir_inode_operations;
@@ -860,6 +861,11 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 	iput(inode);
 }
 
+static int cgroup_delete(const struct dentry *d)
+{
+	return 1;
+}
+
 static void remove_dir(struct dentry *d)
 {
 	struct dentry *parent = dget(d->d_parent);
@@ -1451,6 +1457,7 @@ static int cgroup_get_rootdir(struct super_block *sb)
 {
 	static const struct dentry_operations cgroup_dops = {
 		.d_iput = cgroup_diput,
+		.d_delete = cgroup_delete,
 	};
 
 	struct inode *inode =
@@ -2195,12 +2202,20 @@ static const struct file_operations cgroup_file_operations = {
 };
 
 static const struct inode_operations cgroup_dir_inode_operations = {
-	.lookup = simple_lookup,
+	.lookup = cgroup_lookup,
 	.mkdir = cgroup_mkdir,
 	.rmdir = cgroup_rmdir,
 	.rename = cgroup_rename,
 };
 
+static struct dentry *cgroup_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
+{
+	if (dentry->d_name.len > NAME_MAX)
+		return ERR_PTR(-ENAMETOOLONG);
+	d_add(dentry, NULL);
+	return NULL;
+}
+
 /*
  * Check if a file is a control file
  */
