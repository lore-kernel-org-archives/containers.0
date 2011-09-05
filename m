From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Mon, 5 Sep 2011 22:53:58 +0400
Message-ID: <20110905185358.GA2103@albatros>
References: <20110831075814.003575573@openvz.org>
 <20110831080229.100652529@openvz.org>
 <20110831090612.GA3253@albatros>
 <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <20110901080508.GF30615@sun>
 <20110902163711.GA3124@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110902163711.GA3124@albatros>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Fri, Sep 02, 2011 at 20:37 +0400, Vasiliy Kulikov wrote:
> On Thu, Sep 01, 2011 at 12:05 +0400, Cyrill Gorcunov wrote:
> > ...
> > > > +/*
> > > > + * NOTE: The getattr/setattr for both /proc/$pid/map_files and
> > > > + * /proc/$pid/fd seems to have share the code, so need to be
> > > > + * unified and code duplication eliminated!
> > > 
> > > Why not do this now?
> > 
> > There are a couple of reasons. Yesterday I was talking to
> > Vasiliy Kulikov about this snippet, so he seems about to send
> > you patches related to /proc/$pid/fd update, and after those
> > patches will be merged we are to drop code duplication.
> > Vasiliy, what the status of the update?
> 
> It looks like protecting directories with sensible contents is a nasty
> thing.  The problem here is that if the dentry is present in the cache,
> ->lookup() is not called at all and the permissions can be checked in
> fop/dop/iop specific handler (getattr(), readlink(), etc.).  However, it
> would be much simplier to hook ->lookup() only.  Otherwise, we have to
> define procfs handlers for all operations, which don't call
> ->d_revalidate().
> 
> Is it possible to disable caching dentry for specific files?  It is not
> performace critical thing in fd and map_files and it would much simplify
> the task.  Creating handlers for all these op handler bloats procfs.

Looks like the following patch solves the problem.  Tested on stat() and
link().

diff --git a/fs/proc/base.c b/fs/proc/base.c
index d44c701..219588b 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1665,46 +1665,12 @@ out:
 	return error;
 }
 
-static int proc_pid_fd_link_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		struct kstat *stat)
-{
-	struct inode *inode = dentry->d_inode;
-	struct task_struct *task = get_proc_task(inode);
-	int rc;
-
-	if (task == NULL)
-		return -ESRCH;
-
-	rc = -EACCES;
-	if (lock_trace(task))
-		goto out_task;
-
-	generic_fillattr(inode, stat);
-	unlock_trace(task);
-	rc = 0;
-out_task:
-	put_task_struct(task);
-	return rc;
-}
-
 static const struct inode_operations proc_pid_link_inode_operations = {
 	.readlink	= proc_pid_readlink,
 	.follow_link	= proc_pid_follow_link,
 	.setattr	= proc_setattr,
 };
 
-static const struct inode_operations proc_fdinfo_link_inode_operations = {
-	.setattr	= proc_setattr,
-	.getattr	= proc_pid_fd_link_getattr,
-};
-
-static const struct inode_operations proc_fd_link_inode_operations = {
-	.readlink	= proc_pid_readlink,
-	.follow_link	= proc_pid_follow_link,
-	.setattr	= proc_setattr,
-	.getattr	= proc_pid_fd_link_getattr,
-};
-
 
 /* building an inode */
 
@@ -2044,9 +2010,18 @@ static int tid_fd_revalidate(struct dentry *dentry, struct nameidata *nd)
 	return 0;
 }
 
+static int pid_no_revalidate(struct dentry *dentry, struct nameidata *nd)
+{
+	if (nd && nd->flags & LOOKUP_RCU)
+		return -ECHILD;
+
+	d_drop(dentry);
+	return 0;
+}
+
 static const struct dentry_operations tid_fd_dentry_operations =
 {
-	.d_revalidate	= tid_fd_revalidate,
+	.d_revalidate	= pid_no_revalidate,
 	.d_delete	= pid_delete_dentry,
 };
 
@@ -2085,7 +2060,7 @@ static struct dentry *proc_fd_instantiate(struct inode *dir,
 	spin_unlock(&files->file_lock);
 	put_files_struct(files);
 
-	inode->i_op = &proc_fd_link_inode_operations;
+	inode->i_op = &proc_pid_link_inode_operations;
 	inode->i_size = 64;
 	ei->op.proc_get_link = proc_fd_link;
 	d_set_d_op(dentry, &tid_fd_dentry_operations);
@@ -2267,7 +2242,6 @@ static struct dentry *proc_fdinfo_instantiate(struct inode *dir,
 	ei->fd = fd;
 	inode->i_mode = S_IFREG | S_IRUSR;
 	inode->i_fop = &proc_fdinfo_file_operations;
-	inode->i_op = &proc_fdinfo_link_inode_operations;
 	d_set_d_op(dentry, &tid_fd_dentry_operations);
 	d_add(dentry, inode);
 	/* Close the race of the process dying before we return the dentry */
-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
