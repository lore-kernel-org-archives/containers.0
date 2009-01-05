From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/6] proc: support multiple filesystems using the proc
	generic infrastructure
Date: Tue, 6 Jan 2009 02:33:11 +0300
Message-ID: <20090105233311.GB3924@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753326AbZAEX2X@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: ebiederm@xmission.com, viro@zeniv.linux.org.uk
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, sds@tycho.nsa.gov, jmorris@namei.org
List-Id: containers.vger.kernel.org

From 5332645372abbb43cd75844263c6abac8b23e9da Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Wed, 19 Nov 2008 04:07:58 +0300
Subject: [PATCH 2/6] proc: support multiple filesystems using the proc generic infrastructure

- Implement proc_create_root to create a generic root directory.
- Factor out release_proc_entry() so that we can free a generic root directory.
- Remove static from proc_sops so that we can access it in other files
  implementing a proc generic filesystem.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 fs/proc/generic.c  |   30 +++++++++++++++++++++++++++---
 fs/proc/inode.c    |    2 +-
 fs/proc/internal.h |    3 +++
 3 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index db7fa5c..61d4152 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -528,7 +528,6 @@ static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp
 			dp->proc_fops = &proc_dir_operations;
 			dp->proc_iops = &proc_dir_inode_operations;
 		}
-		dir->nlink++;
 	} else if (S_ISLNK(dp->mode)) {
 		if (dp->proc_iops == NULL)
 			dp->proc_iops = &proc_link_inode_operations;
@@ -551,6 +550,8 @@ static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp
 	dp->next = dir->subdir;
 	dp->parent = dir;
 	dir->subdir = dp;
+	if (S_ISDIR(dp->mode))
+		dir->nlink++;
 	spin_unlock(&proc_subdir_lock);
 
 	return 0;
@@ -595,6 +596,24 @@ static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
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
@@ -754,6 +773,8 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 			de = *p;
 			*p = de->next;
 			de->next = NULL;
+			if (S_ISDIR(de->mode))
+				parent->nlink--;
 			break;
 		}
 	}
@@ -761,6 +782,11 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
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
@@ -796,8 +822,6 @@ continue_removing:
 	}
 	spin_unlock(&de->pde_unload_lock);
 
-	if (S_ISDIR(de->mode))
-		parent->nlink--;
 	de->nlink = 0;
 	WARN(de->subdir, KERN_WARNING "%s: removing non-empty directory "
 			"'%s/%s', leaking at least '%s'\n", __func__,
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 3e76bb9..0bbb937 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -112,7 +112,7 @@ void __init proc_init_inodecache(void)
 					     init_once);
 }
 
-static const struct super_operations proc_sops = {
+const struct super_operations proc_sops = {
 	.alloc_inode	= proc_alloc_inode,
 	.destroy_inode	= proc_destroy_inode,
 	.drop_inode	= generic_delete_inode,
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 314c0d3..cde08ef 100644
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
1.5.6.5
