From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Fri, 9 Sep 2011 10:22:11 +0400
Message-ID: <20110909062210.GO28162@sun>
References: <20110907215329.GB28162@sun>
 <20110907151323.613e62e7.akpm@linux-foundation.org>
 <20110907224234.GD28162@sun>
 <20110907155332.beda7d3d.akpm@linux-foundation.org>
 <20110908054826.GF28162@sun>
 <20110908055025.GG28162@sun>
 <20110908060405.GH28162@sun>
 <20110908165201.59e82c71.akpm@linux-foundation.org>
 <20110909054819.GN28162@sun>
 <20110908230020.11f306be.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110908230020.11f306be.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Tejun Heo <tj@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Thu, Sep 08, 2011 at 11:00:20PM -0700, Andrew Morton wrote:
...
> > 
> > Hmm. I never saw this warning. (Andrew, I'm still unable to fetch
> > your current -mm tree, is there some place other than kernel.org?
> 
> Nope, sorry - we're dead in the water at present.
> 
> > So the patch is done on top of 3.1-rc3). I guess this warrning is
> > from p = flex_array_get(fa, i); ? (since I don't have any warning
> > at all).
> 
> The warning is from
> 
> 	ei->op.proc_get_link = proc_map_files_get_link;
> 
> The lhs has type
> 
> union proc_op {
> 	int (*proc_get_link)(struct inode *, struct path *);
> 
> and the rhs has type
> 
> static int proc_map_files_get_link(struct dentry *dentry, struct path *path)
> 
> So we end up passing an inode* to a function which expects a dentry*.
> 
> That's in 3.1-rc4.  proc_op.proc_get_link() hasn't changed since 3.0 (at least).

Crap. I know what happened. At first proposal time Tejun (iirc ;) said that
is might be better to separate proc_get_link change. I did so... and of
course I forgot to send it out ;) Ie it's in my queue and I dont see any
warnings for that reason. Sorry for that. Attached below.
---
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: fs, proc: Make proc_get_link to use dentry instead of inode

This patch prepares the ground for the next "map_files"
patch which needs a name of a link file to analyse.

So instead of squashing this change into one big
patch the separate one is done.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
CC: Pavel Emelyanov <xemul@parallels.com>
CC: Tejun Heo <tj@kernel.org>
CC: Vasiliy Kulikov <segoon@openwall.com>
CC: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: Alexey Dobriyan <adobriyan@gmail.com>
CC: Al Viro <viro@ZenIV.linux.org.uk>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 fs/proc/base.c          |   20 ++++++++++----------
 include/linux/proc_fs.h |    2 +-
 2 files changed, 11 insertions(+), 11 deletions(-)

Index: linux-2.6.git/fs/proc/base.c
===================================================================
--- linux-2.6.git.orig/fs/proc/base.c
+++ linux-2.6.git/fs/proc/base.c
@@ -165,9 +165,9 @@ static int get_task_root(struct task_str
 	return result;
 }
 
-static int proc_cwd_link(struct inode *inode, struct path *path)
+static int proc_cwd_link(struct dentry *dentry, struct path *path)
 {
-	struct task_struct *task = get_proc_task(inode);
+	struct task_struct *task = get_proc_task(dentry->d_inode);
 	int result = -ENOENT;
 
 	if (task) {
@@ -182,9 +182,9 @@ static int proc_cwd_link(struct inode *i
 	return result;
 }
 
-static int proc_root_link(struct inode *inode, struct path *path)
+static int proc_root_link(struct dentry *dentry, struct path *path)
 {
-	struct task_struct *task = get_proc_task(inode);
+	struct task_struct *task = get_proc_task(dentry->d_inode);
 	int result = -ENOENT;
 
 	if (task) {
@@ -1580,13 +1580,13 @@ static const struct file_operations proc
 	.release	= single_release,
 };
 
-static int proc_exe_link(struct inode *inode, struct path *exe_path)
+static int proc_exe_link(struct dentry *dentry, struct path *exe_path)
 {
 	struct task_struct *task;
 	struct mm_struct *mm;
 	struct file *exe_file;
 
-	task = get_proc_task(inode);
+	task = get_proc_task(dentry->d_inode);
 	if (!task)
 		return -ENOENT;
 	mm = get_task_mm(task);
@@ -1616,7 +1616,7 @@ static void *proc_pid_follow_link(struct
 	if (!proc_fd_access_allowed(inode))
 		goto out;
 
-	error = PROC_I(inode)->op.proc_get_link(inode, &nd->path);
+	error = PROC_I(inode)->op.proc_get_link(dentry, &nd->path);
 out:
 	return ERR_PTR(error);
 }
@@ -1655,7 +1655,7 @@ static int proc_pid_readlink(struct dent
 	if (!proc_fd_access_allowed(inode))
 		goto out;
 
-	error = PROC_I(inode)->op.proc_get_link(inode, &path);
+	error = PROC_I(inode)->op.proc_get_link(dentry, &path);
 	if (error)
 		goto out;
 
@@ -1947,9 +1947,9 @@ static int proc_fd_info(struct inode *in
 	return -ENOENT;
 }
 
-static int proc_fd_link(struct inode *inode, struct path *path)
+static int proc_fd_link(struct dentry *dentry, struct path *path)
 {
-	return proc_fd_info(inode, path, NULL);
+	return proc_fd_info(dentry->d_inode, path, NULL);
 }
 
 static int tid_fd_revalidate(struct dentry *dentry, struct nameidata *nd)
Index: linux-2.6.git/include/linux/proc_fs.h
===================================================================
--- linux-2.6.git.orig/include/linux/proc_fs.h
+++ linux-2.6.git/include/linux/proc_fs.h
@@ -253,7 +253,7 @@ extern const struct proc_ns_operations u
 extern const struct proc_ns_operations ipcns_operations;
 
 union proc_op {
-	int (*proc_get_link)(struct inode *, struct path *);
+	int (*proc_get_link)(struct dentry *, struct path *);
 	int (*proc_read)(struct task_struct *task, char *page);
 	int (*proc_show)(struct seq_file *m,
 		struct pid_namespace *ns, struct pid *pid,

	Cyrill
