From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 3/7] proc: Support multiple filesystems using the proc generic
	infrastructure
Date: Thu, 06 Nov 2008 02:49:58 -0800
Message-ID: <m163n12ko9.fsf_-_@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1abcd2kqk.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org> (Eric W. Biederman's message
	of "Thu, 06 Nov 2008 02:48:35 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


- Implement proc_create_root to create a generic root directory.
- Factor out release_proc_entry so that we can free a generic root directory.
- Remove static from proc_sops so that we can access it in other files
  implementing a proc generic filesystem.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/generic.c  |   30 +++++++++++++++++++++++++++---
 fs/proc/inode.c    |    2 +-
 fs/proc/internal.h |    3 +++
 3 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 60a359b..8669cf6 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -532,7 +532,6 @@ static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp
 			dp->proc_fops = &proc_dir_operations;
 			dp->proc_iops = &proc_dir_inode_operations;
 		}
-		dir->nlink++;
 	} else if (S_ISLNK(dp->mode)) {
 		if (dp->proc_iops == NULL)
 			dp->proc_iops = &proc_link_inode_operations;
@@ -555,6 +554,8 @@ static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp
 	dp->next = dir->subdir;
 	dp->parent = dir;
 	dir->subdir = dp;
+	if (S_ISDIR(dp->mode))
+		dir->nlink++;
 	spin_unlock(&proc_subdir_lock);
 
 	return 0;
@@ -599,6 +600,24 @@ static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
 	return ent;
 }
 
+struct proc_dir_entry *proc_create_root(void)
+{
+	struct proc_dir_entry *ent, *parent = NULL;
+
+	ent = __proc_create(&parent, "..", S_IFDIR | S_IRUGO | S_IXUGO, 2);
+	if (ent) {
+		ent->proc_fops = &proc_dir_operations;
+		ent->proc_iops = &proc_dir_inode_operations;
+		ent->low_ino = get_inode_number();
+		ent->parent = ent;
+		if (!ent->low_ino) {
+			kfree(ent);
+			ent = NULL;
+		}
+	}
+	return ent;
+}
+
 struct proc_dir_entry *proc_symlink(const char *name,
 		struct proc_dir_entry *parent, const char *dest)
 {
@@ -758,6 +777,8 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 			de = *p;
 			*p = de->next;
 			de->next = NULL;
+			if (S_ISDIR(de->mode))
+				parent->nlink--;
 			break;
 		}
 	}
@@ -765,6 +786,11 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 	if (!de)
 		return;
 
+	release_proc_entry(de);
+}
+
+void release_proc_entry(struct proc_dir_entry *de)
+{
 	spin_lock(&de->pde_unload_lock);
 	/*
 	 * Stop accepting new callers into module. If you're
@@ -800,8 +826,6 @@ continue_removing:
 	}
 	spin_unlock(&de->pde_unload_lock);
 
-	if (S_ISDIR(de->mode))
-		parent->nlink--;
 	de->nlink = 0;
 	WARN(de->subdir, KERN_WARNING "%s: removing non-empty directory "
 			"'%s/%s', leaking at least '%s'\n", __func__,
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 2543fd0..f3f81e2 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -115,7 +115,7 @@ void __init proc_init_inodecache(void)
 					     init_once);
 }
 
-static const struct super_operations proc_sops = {
+const struct super_operations proc_sops = {
 	.alloc_inode	= proc_alloc_inode,
 	.destroy_inode	= proc_destroy_inode,
 	.drop_inode	= generic_delete_inode,
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 2a8eabb..6fe00ff 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -86,6 +86,9 @@ struct dentry *proc_lookup_de(struct proc_dir_entry *de, struct inode *ino,
 		struct dentry *dentry);
 int proc_readdir_de(struct proc_dir_entry *de, struct file *filp, void *dirent,
 		filldir_t filldir);
+struct proc_dir_entry *proc_create_root(void);
+void release_proc_entry(struct proc_dir_entry *de);
+extern const struct super_operations proc_sops;
 
 struct pde_opener {
 	struct inode *inode;
-- 
1.5.3.rc6.17.g1911
