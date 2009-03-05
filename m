From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 04/11] actually use f_op in checkpoint code
Date: Thu, 05 Mar 2009 08:39:02 -0800
Message-ID: <20090305163902.C0DC6044@kernel>
References: <20090305163857.0C18F3FD@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090305163857.0C18F3FD@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Right now, we assume all normal files and directories
can be checkpointed.  However, as usual in the VFS, there
are specialized places that will always need an ability
to override these defaults.  We could do this completely
in the checkpoint code, but that would bitrot quickly.

This adds a new 'file_operations' function for
checkpointing a file.  I did this under the assumption
that we should have a dirt-simple way to make something
(un)checkpointable that fits in with current code.

As you can see in the ext[234] and /proc patches, all
that we have to do to make something simple be
supported is add a single "generic" f_op entry.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/checkpoint/ckpt_file.c |    4 ++--
 linux-2.6.git-dave/include/linux/fs.h     |    9 +++++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff -puN checkpoint/ckpt_file.c~f_op-for-checkpointability checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~f_op-for-checkpointability	2009-03-05 08:37:01.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2009-03-05 08:37:01.000000000 -0800
@@ -106,8 +106,8 @@ static int cr_write_fd_data(struct cr_ct
 
 	hh->fd_type = CR_FD_UNSET;
 	ret = -EBADF;
-	if ((file->f_dentry->d_inode->i_mode & S_IFMT) == S_IFREG)
-		ret = generic_file_checkpoint(file, ctx, hh);
+	if (file->f_op->checkpoint)
+		ret = file->f_op->checkpoint(file, ctx, hh);
 
 	if (ret)
 		goto out;
diff -puN include/linux/fs.h~f_op-for-checkpointability include/linux/fs.h
--- linux-2.6.git/include/linux/fs.h~f_op-for-checkpointability	2009-03-05 08:37:01.000000000 -0800
+++ linux-2.6.git-dave/include/linux/fs.h	2009-03-05 08:37:01.000000000 -0800
@@ -1296,6 +1296,14 @@ int generic_osync_inode(struct inode *, 
 typedef int (*filldir_t)(void *, const char *, int, loff_t, u64, unsigned);
 struct block_device_operations;
 
+struct cr_ctx;
+struct cr_hdr_fd;
+#ifdef CONFIG_CHECKPOINT_RESTART
+int generic_file_checkpoint(struct file *, struct cr_ctx *, struct cr_hdr_fd *);
+#else
+#define generic_file_checkpoint NULL
+#endif
+
 /* These macros are for out of kernel modules to test that
  * the kernel supports the unlocked_ioctl and compat_ioctl
  * fields in struct file_operations. */
@@ -1334,6 +1342,7 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+	int (*checkpoint)(struct file *, struct cr_ctx *, struct cr_hdr_fd *);
 };
 
 struct inode_operations {
_
