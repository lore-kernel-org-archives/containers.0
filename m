From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/6] procfs: kill the global proc_mnt variable
Date: Sun, 20 Jun 2010 01:45:48 -0700
Message-ID: <m1bpb6qegz.fsf_-_@fess.ebiederm.org>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
	<20100617212003.GA4182@redhat.com>
	<20100618082033.GD16877@hawkmoon.kerlabs.com>
	<20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com>
	<20100618173320.GG16877@hawkmoon.kerlabs.com>
	<20100618175541.GA13680@redhat.com>
	<20100618212355.GA29478@redhat.com> <20100619190840.GA3424@redhat.com>
	<m1pqzmqema.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqzmqema.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 20 Jun 2010 01\:42\:37 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Louis Rilling <louis.rilling@kerlabs.com>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

From: Oleg Nesterov <oleg@redhat.com>

After the previous cleanup in proc_get_sb() the global proc_mnt has
no reasons to exists, kill it.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/inode.c    |    2 --
 fs/proc/internal.h |    1 -
 fs/proc/root.c     |    5 +++--
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index aea8502..e538886 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -43,8 +43,6 @@ static void proc_delete_inode(struct inode *inode)
 	clear_inode(inode);
 }
 
-struct vfsmount *proc_mnt;
-
 static struct kmem_cache * proc_inode_cachep;
 
 static struct inode *proc_alloc_inode(struct super_block *sb)
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 1f24a3e..ae01ca6 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -106,7 +106,6 @@ static inline struct proc_dir_entry *pde_get(struct proc_dir_entry *pde)
 }
 void pde_put(struct proc_dir_entry *pde);
 
-extern struct vfsmount *proc_mnt;
 int proc_fill_super(struct super_block *);
 struct inode *proc_get_inode(struct super_block *, unsigned int, struct proc_dir_entry *);
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 5f15353..310ac20 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -93,14 +93,15 @@ static struct file_system_type proc_fs_type = {
 
 void __init proc_root_init(void)
 {
+	struct vfsmount *mnt;
 	int err;
 
 	proc_init_inodecache();
 	err = register_filesystem(&proc_fs_type);
 	if (err)
 		return;
-	proc_mnt = kern_mount_data(&proc_fs_type, &init_pid_ns);
-	if (IS_ERR(proc_mnt)) {
+	mnt = kern_mount_data(&proc_fs_type, &init_pid_ns);
+	if (IS_ERR(mnt)) {
 		unregister_filesystem(&proc_fs_type);
 		return;
 	}
-- 
1.6.5.2.143.g8cc62
