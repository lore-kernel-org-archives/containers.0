From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 6/7] proc_net: Simplify network namespace lookup.
Date: Thu, 06 Nov 2008 02:57:04 -0800
Message-ID: <m1od0t15rz.fsf_-_@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
	<m163n12ko9.fsf_-_@frodo.ebiederm.org>
	<m1y6zx15yj.fsf_-_@frodo.ebiederm.org>
	<m1skq515ti.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1skq515ti.fsf_-_-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org> (Eric W. Biederman's
	message of "Thu, 06 Nov 2008 02:56:09 -0800")
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


Since the network namespace is recorded in the
superblock we don't need to remember it on
each directory under /proc/net.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/generic.c       |   17 -----------------
 fs/proc/proc_net.c      |   13 ++++++++++---
 include/linux/proc_fs.h |    5 -----
 3 files changed, 10 insertions(+), 25 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 8669cf6..6db30a8 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -658,23 +658,6 @@ struct proc_dir_entry *proc_mkdir_mode(const char *name, mode_t mode,
 	return ent;
 }
 
-struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
-		struct proc_dir_entry *parent)
-{
-	struct proc_dir_entry *ent;
-
-	ent = __proc_create(&parent, name, S_IFDIR | S_IRUGO | S_IXUGO, 2);
-	if (ent) {
-		ent->data = net;
-		if (proc_register(parent, ent) < 0) {
-			kfree(ent);
-			ent = NULL;
-		}
-	}
-	return ent;
-}
-EXPORT_SYMBOL_GPL(proc_net_mkdir);
-
 struct proc_dir_entry *proc_mkdir(const char *name,
 		struct proc_dir_entry *parent)
 {
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 4a7551a..baabb9c 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -31,7 +31,7 @@ static struct file_system_type proc_net_fs_type;
 
 static struct net *get_proc_net(const struct inode *inode)
 {
-	return maybe_get_net(PDE_NET(PDE(inode)));
+	return maybe_get_net(inode->i_sb->s_fs_info);
 }
 
 int seq_open_net(struct inode *ino, struct file *f,
@@ -214,6 +214,15 @@ struct proc_dir_entry *proc_net_fops_create(struct net *net,
 }
 EXPORT_SYMBOL_GPL(proc_net_fops_create);
 
+struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
+		struct proc_dir_entry *parent)
+{
+	if (!parent)
+		parent = net->proc_net;
+	return proc_mkdir(name, parent);
+}
+EXPORT_SYMBOL_GPL(proc_net_mkdir);
+
 void proc_net_remove(struct net *net, const char *name)
 {
 	remove_proc_entry(name, net->proc_net);
@@ -308,8 +317,6 @@ static __net_init int proc_net_ns_init(struct net *net)
 	if (!netd)
 		goto out;
 
-	netd->data = net;
-
 	err = -EEXIST;
 	net_statd = proc_net_mkdir(net, "stat", netd);
 	if (!net_statd)
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 3505a72..52cc6bd 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -300,11 +300,6 @@ static inline struct proc_dir_entry *PDE(const struct inode *inode)
 	return PROC_I(inode)->pde;
 }
 
-static inline struct net *PDE_NET(struct proc_dir_entry *pde)
-{
-	return pde->parent->data;
-}
-
 struct proc_maps_private {
 	struct pid *pid;
 	struct task_struct *task;
-- 
1.5.3.rc6.17.g1911
