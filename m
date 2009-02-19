From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 2/5] file c/r: expose functions to query fs support
Date: Thu, 19 Feb 2009 10:20:08 -0800
Message-ID: <20090219182008.8F45CD7E@kernel>
References: <20090219182007.B4B47C1F@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090219182007.B4B47C1F@kernel>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


This pair of functions will check to see whether a given
'struct file' can be checkpointed.  If it can't be, the
"explain" function can also give a description why.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/checkpoint/ckpt_file.c     |   30 ++++++++++++++++++++++++++
 linux-2.6.git-dave/include/linux/checkpoint.h |   18 +++++++++++++++
 2 files changed, 48 insertions(+)

diff -puN checkpoint/ckpt_file.c~cr-explain-unckpt-file checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~cr-explain-unckpt-file	2009-02-19 10:17:24.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2009-02-19 10:17:24.000000000 -0800
@@ -72,6 +72,36 @@ int cr_scan_fds(struct files_struct *fil
 	return n;
 }
 
+int cr_explain_file(struct file *file, char *explain, int left)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct file_system_type *fs_type = inode->i_sb->s_type;
+
+	if (!(fs_type->fs_flags & FS_CHECKPOINTABLE))
+		return snprintf(explain, left,
+				" (%s does not support checkpoint)",
+				fs_type->name);
+
+	if (special_file(inode->i_mode))
+		return snprintf(explain, left, " (special file)");
+
+	return 0;
+}
+
+int cr_file_supported(struct file *file)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct file_system_type *fs_type = inode->i_sb->s_type;
+
+	if (!(fs_type->fs_flags & FS_CHECKPOINTABLE))
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
diff -puN include/linux/checkpoint.h~cr-explain-unckpt-file include/linux/checkpoint.h
--- linux-2.6.git/include/linux/checkpoint.h~cr-explain-unckpt-file	2009-02-19 10:17:24.000000000 -0800
+++ linux-2.6.git-dave/include/linux/checkpoint.h	2009-02-19 10:17:24.000000000 -0800
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
+#else
+
+static inline int cr_explain_file(struct file *file, char *explain, int left)
+{
+	return 0;
+}
+
+int cr_file_supported(struct file *file)
+{
+	return 0;
+}
+
+#endif
 #endif /* _CHECKPOINT_CKPT_H_ */
_
