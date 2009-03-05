From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 07/11] file c/r: expose functions to query fs support
Date: Thu, 05 Mar 2009 08:39:07 -0800
Message-ID: <20090305163907.143E9D50@kernel>
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


This pair of functions will check to see whether a given
'struct file' can be checkpointed.  If it can't be, the
"explain" function can also give a description why.

Note that we assume the presence of an f_op->checkpoint
implies that a file is always checkpointable.  That may
have to change in the future, but it is a fixed rule
for now.
  
Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/checkpoint/ckpt_file.c     |   26 ++++++++++++++++++++++++++
 linux-2.6.git-dave/include/linux/checkpoint.h |   18 ++++++++++++++++++
 2 files changed, 44 insertions(+)

diff -puN checkpoint/ckpt_file.c~cfcc333a1e665c38185a12ba119c32cf796dbd85 checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~cfcc333a1e665c38185a12ba119c32cf796dbd85	2009-03-05 08:37:03.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2009-03-05 08:37:03.000000000 -0800
@@ -93,6 +93,32 @@ int generic_file_checkpoint(struct file 
 	return 0;
 }
 
+int cr_explain_file(struct file *file, char *explain, int left)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+
+	if (!file->f_op->checkpoint)
+		return scnprintf(explain, left, " (no checkpoint handler)");
+
+	if (special_file(inode->i_mode))
+		return scnprintf(explain, left, " (special file)");
+
+	return 0;
+}
+
+int cr_file_supported(struct file *file)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+
+	if (!file->f_op->checkpoint)
+		return 0;
+
+	if (special_file(inode->i_mode))
+		return 0;
+
+	return 1;
+}
+
 /* cr_write_fd_data - dump the state of a given file pointer */
 static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
 {
diff -puN include/linux/checkpoint.h~cfcc333a1e665c38185a12ba119c32cf796dbd85 include/linux/checkpoint.h
--- linux-2.6.git/include/linux/checkpoint.h~cfcc333a1e665c38185a12ba119c32cf796dbd85	2009-03-05 08:37:03.000000000 -0800
+++ linux-2.6.git-dave/include/linux/checkpoint.h	2009-03-05 08:37:03.000000000 -0800
@@ -13,6 +13,8 @@
 #include <linux/path.h>
 #include <linux/fs.h>
 
+#ifdef CONFIG_CHECKPOINT_RESTART
+
 #define CR_VERSION  2
 
 struct cr_ctx {
@@ -99,4 +101,20 @@ extern int cr_read_files(struct cr_ctx *
 
 #define pr_fmt(fmt) "[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__
 
+int cr_explain_file(struct file *file, char *explain, int left);
+int cr_file_supported(struct file *file);
+
+#else /* !CONFIG_CHECKPOINT_RESTART */
+
+static inline int cr_explain_file(struct file *file, char *explain, int left)
+{
+	return 0;
+}
+
+static inline int cr_file_supported(struct file *file)
+{
+	return 0;
+}
+
+#endif /* CONFIG_CHECKPOINT_RESTART */
 #endif /* _CHECKPOINT_CKPT_H_ */
_
