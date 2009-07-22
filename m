From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [RFC v17][PATCH 32/60] c/r: introduce '->checkpoint()' method in
	'struct file_operations'
Date: Wed, 22 Jul 2009 05:59:54 -0400
Message-ID: <1248256822-23416-33-git-send-email-orenl__6737.95881816677$1248261665$gmane$org@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

While we assume all normal files and directories can be checkpointed,
there are, as usual in the VFS, specialized places that will always
need an ability to override these defaults. Although we could do this
completely in the checkpoint code, that would bitrot quickly.

This adds a new 'file_operations' function for checkpointing a file.
It is assumed that there should be a dirt-simple way to make something
(un)checkpointable that fits in with current code.

As you can see in the ext[234] patches down the road, all that we have
to do to make something simple be supported is add a single "generic"
f_op entry.

Also introduce vfs_fcntl() so that it can be called from restart (see
patch adding restart of files).

Changelog[v17]
  - Forward-declare 'ckpt_ctx' et-al, don't use checkpoint_types.h

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/fcntl.c         |   21 +++++++++++++--------
 include/linux/fs.h |    6 ++++++
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index ae41308..78d3116 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -339,6 +339,18 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 	return err;
 }
 
+int vfs_fcntl(int fd, unsigned int cmd, unsigned long arg, struct file *filp)
+{
+	int err;
+
+	err = security_file_fcntl(filp, cmd, arg);
+	if (err)
+		goto out;
+	err = do_fcntl(fd, cmd, arg, filp);
+ out:
+	return err;
+}
+
 SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
 {	
 	struct file *filp;
@@ -348,14 +360,7 @@ SYSCALL_DEFINE3(fcntl, unsigned int, fd, unsigned int, cmd, unsigned long, arg)
 	if (!filp)
 		goto out;
 
-	err = security_file_fcntl(filp, cmd, arg);
-	if (err) {
-		fput(filp);
-		return err;
-	}
-
-	err = do_fcntl(fd, cmd, arg, filp);
-
+	err = vfs_fcntl(fd, cmd, arg, filp);
  	fput(filp);
 out:
 	return err;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index d88d4fc..05d4745 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -388,6 +388,7 @@ struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
 struct cred;
+struct ckpt_ctx;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -1088,6 +1089,8 @@ struct file_lock {
 
 #include <linux/fcntl.h>
 
+extern int vfs_fcntl(int fd, unsigned cmd, unsigned long arg, struct file *fp);
+
 extern void send_sigio(struct fown_struct *fown, int fd, int band);
 
 /* fs/sync.c */
@@ -1510,6 +1513,7 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+	int (*checkpoint)(struct ckpt_ctx *, struct file *);
 };
 
 struct inode_operations {
@@ -2309,6 +2313,8 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
 loff_t inode_get_bytes(struct inode *inode);
 void inode_set_bytes(struct inode *inode, loff_t bytes);
 
+#define generic_file_checkpoint NULL
+
 extern int vfs_readdir(struct file *, filldir_t, void *);
 
 extern int vfs_stat(char __user *, struct kstat *);
-- 
1.6.0.4
