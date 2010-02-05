From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC PATCH] c/r: fixed false complaint on "unlinked" pipes, socket,
	etc
Date: Fri,  5 Feb 2010 14:57:34 -0500
Message-ID: <1265399854-26534-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Commit a3a065e3f13da8a3470ed09c7f38aad256083726 changes the behavior
of dentry for pipe, sockets and anon_inodes (eventfd, timerfd, epoll,
signalfd and perf...):

"""
    Filesystems outside the regular namespace do not have to clear
    in order to have a working /proc/$pid/fd/XXX. Nothing in proc prevents the
    fd link from being used if its dentry is not in the hash.

    Also, it does not get put into the dcache hash if DCACHE_UNHASHED is clear;
    that depends on the filesystem calling d_add or d_rehash.

    So delete the misleading comments and needless code.
"""

That made checkpoint complain on half-closed pipes which are
DCACHE_UNHASHED and trigger the d_unlinked() test.

This patch proposes one fix - which is to mark such dentry with a
special flag DCACHE_SPECIAL_INODE, which indicates that this dentry
is an exception, and the d_unlinked() doesn't matter.

An alternative approach would be to add an unlinked() method to file
operations: if it's null, then checkpoint will test with d_unlinked()
otherwise it will test with the specific method. for these filesystems
we'll make this method return "ok" always. This may also be useful if
unlinking a file becomes a per-filesystem operation.

Comments ?


Oren.


---
 checkpoint/files.c     |    2 +-
 fs/anon_inodes.c       |    1 +
 fs/pipe.c              |    1 +
 include/linux/dcache.h |   14 +++++++++++++-
 net/socket.c           |    1 +
 5 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index d1242f2..fa318f3 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -231,7 +231,7 @@ int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 			       file, file->f_op);
 		return -EBADF;
 	}
-	if (d_unlinked(file->f_dentry)) {
+	if (!d_special_inode(file->f_dentry) && d_unlinked(file->f_dentry)) {
 		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
 			 file);
 		return -EBADF;
diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 9f0bf13..a7bf417 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -118,6 +118,7 @@ struct file *anon_inode_getfile(const char *name,
 	atomic_inc(&anon_inode_inode->i_count);
 
 	path.dentry->d_op = &anon_inodefs_dentry_operations;
+	path.dentry->d_flags |= DCACHE_SPECIAL_INODE;
 	d_instantiate(path.dentry, anon_inode_inode);
 
 	error = -ENFILE;
diff --git a/fs/pipe.c b/fs/pipe.c
index 8c79493..2fd5ad6 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1213,6 +1213,7 @@ struct file *create_write_pipe(int flags)
 	path.mnt = mntget(pipe_mnt);
 
 	path.dentry->d_op = &pipefs_dentry_operations;
+	path.dentry->d_flags |= DCACHE_SPECIAL_INODE;
 	d_instantiate(path.dentry, inode);
 
 	err = -ENFILE;
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 30b93b2..af01318 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -186,6 +186,13 @@ d_iput:		no		no		no       yes
 
 #define DCACHE_FSNOTIFY_PARENT_WATCHED	0x0080 /* Parent inode is watched by some fsnotify listener */
 
+#define DCACHE_SPECIAL_INODE	0x0100
+     /* This dentry corresponds to a special inode, like anon-inode,
+      * pipe, and sockets. It is set once by the file-system. Used by
+      * checkpoint/restart to ignore a positive d_unlinked() for such
+      * dentries (a closed pipe is not a unlinked file)
+      */
+
 extern spinlock_t dcache_lock;
 extern seqlock_t rename_lock;
 
@@ -347,7 +354,12 @@ extern struct dentry * dget_locked(struct dentry *);
  *
  *	Returns true if the dentry passed is not currently hashed.
  */
- 
+
+static inline int d_special_inode(struct dentry *dentry)
+{
+	return (dentry->d_flags & DCACHE_SPECIAL_INODE);
+}
+
 static inline int d_unhashed(struct dentry *dentry)
 {
 	return (dentry->d_flags & DCACHE_UNHASHED);
diff --git a/net/socket.c b/net/socket.c
index 3253c04..dd5983a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -365,6 +365,7 @@ int sock_alloc_file(struct socket *sock, struct file **f, int flags)
 	path.mnt = mntget(sock_mnt);
 
 	path.dentry->d_op = &sockfs_dentry_operations;
+	path.dentry->d_flags |= DCACHE_SPECIAL_INODE;
 	d_instantiate(path.dentry, SOCK_INODE(sock));
 	SOCK_INODE(sock)->i_fop = &socket_file_ops;
 
-- 
1.6.3.3
