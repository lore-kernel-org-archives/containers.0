From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 019/100] Make file_pos_read/write() public and export
	kernel_write()
Date: Sat,  1 May 2010 10:15:01 -0400
Message-ID: <1272723382-19470-20-git-send-email-orenl__24794.4928393283$1272727045$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

These three are used in a subsequent patch to allow the kernel c/r
code to call vfs_read/write() to read and write data to and from the
checkpoint image.

This patch makes the following changes:

1) Move kernel_write() from fs/splice.c to fs/exec.c to be near
kernel_read()

2) Make kernel_read/write() iterate if they face partial reads or
writes, and retry if they face -EAGAIN.

3) Adjust prototypes of kernel_read/write() to use size_t and ssize_t

4) Move file_pos_read/write() to include/linux/fs.h

Changelog [ckpt-v21]
  - Introduce kernel_write(), fix kernel_read()

Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/exec.c          |   69 ++++++++++++++++++++++++++++++++++++++++++++++++----
 fs/read_write.c    |   10 -------
 fs/splice.c        |   17 +------------
 include/linux/fs.h |   13 +++++++++-
 4 files changed, 77 insertions(+), 32 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 49cdaa1..7bacb6a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -693,23 +693,82 @@ exit:
 }
 EXPORT_SYMBOL(open_exec);
 
-int kernel_read(struct file *file, loff_t offset,
-		char *addr, unsigned long count)
+static ssize_t _kernel_read(struct file *file, loff_t offset,
+			    char __user *ubuf, size_t count)
 {
-	mm_segment_t old_fs;
+	ssize_t nread;
+	size_t nleft;
 	loff_t pos = offset;
-	int result;
+
+	for (nleft = count; nleft; nleft -= nread) {
+		nread = vfs_read(file, ubuf, nleft, &pos);
+		if (nread <= 0) {
+			if (nread == -EAGAIN) {
+				nread = 0;
+				continue;
+			} else if (nread == 0)
+				break;
+			else
+				return nread;
+		}
+		ubuf += nread;
+	}
+	return count - nleft;
+}
+
+ssize_t kernel_read(struct file *file, loff_t offset,
+		    char *addr, size_t count)
+{
+	mm_segment_t old_fs;
+	ssize_t result;
 
 	old_fs = get_fs();
 	set_fs(get_ds());
 	/* The cast to a user pointer is valid due to the set_fs() */
-	result = vfs_read(file, (void __user *)addr, count, &pos);
+	result = _kernel_read(file, offset, (void __user *)addr, count);
 	set_fs(old_fs);
 	return result;
 }
 
 EXPORT_SYMBOL(kernel_read);
 
+static ssize_t _kernel_write(struct file *file, loff_t offset,
+			     const char __user *ubuf, size_t count)
+{
+	ssize_t nwrite;
+	size_t nleft;
+	loff_t pos = offset;
+
+	for (nleft = count; nleft; nleft -= nwrite) {
+		nwrite = vfs_write(file, ubuf, nleft, &pos);
+		if (nwrite < 0) {
+			if (nwrite == -EAGAIN) {
+				nwrite = 0;
+				continue;
+			} else
+				return nwrite;
+		}
+		ubuf += nwrite;
+	}
+	return count - nleft;
+}
+
+ssize_t kernel_write(struct file *file, loff_t offset,
+		     const char *addr, size_t count)
+{
+	mm_segment_t old_fs;
+	ssize_t result;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	/* The cast to a user pointer is valid due to the set_fs() */
+	result = _kernel_write(file, offset, (void __user *)addr, count);
+	set_fs(old_fs);
+	return result;
+}
+
+EXPORT_SYMBOL(kernel_write);
+
 static int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
diff --git a/fs/read_write.c b/fs/read_write.c
index 113386d..67b7d83 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -361,16 +361,6 @@ ssize_t vfs_write(struct file *file, const char __user *buf, size_t count, loff_
 
 EXPORT_SYMBOL(vfs_write);
 
-static inline loff_t file_pos_read(struct file *file)
-{
-	return file->f_pos;
-}
-
-static inline void file_pos_write(struct file *file, loff_t pos)
-{
-	file->f_pos = pos;
-}
-
 SYSCALL_DEFINE3(read, unsigned int, fd, char __user *, buf, size_t, count)
 {
 	struct file *file;
diff --git a/fs/splice.c b/fs/splice.c
index 9313b61..188e17d 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -538,21 +538,6 @@ static ssize_t kernel_readv(struct file *file, const struct iovec *vec,
 	return res;
 }
 
-static ssize_t kernel_write(struct file *file, const char *buf, size_t count,
-			    loff_t pos)
-{
-	mm_segment_t old_fs;
-	ssize_t res;
-
-	old_fs = get_fs();
-	set_fs(get_ds());
-	/* The cast to a user pointer is valid due to the set_fs() */
-	res = vfs_write(file, (const char __user *)buf, count, &pos);
-	set_fs(old_fs);
-
-	return res;
-}
-
 ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 				 struct pipe_inode_info *pipe, size_t len,
 				 unsigned int flags)
@@ -1011,7 +996,7 @@ static int write_pipe_buf(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 		return ret;
 
 	data = buf->ops->map(pipe, buf, 0);
-	ret = kernel_write(sd->u.file, data + buf->offset, sd->len, sd->pos);
+	ret = kernel_write(sd->u.file, sd->pos, data + buf->offset, sd->len);
 	buf->ops->unmap(pipe, buf, data);
 
 	return ret;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 39d57bc..9e8b171 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1548,6 +1548,16 @@ ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,
 				struct iovec *fast_pointer,
 				struct iovec **ret_pointer);
 
+static inline loff_t file_pos_read(struct file *file)
+{
+	return file->f_pos;
+}
+
+static inline void file_pos_write(struct file *file, loff_t pos)
+{
+	file->f_pos = pos;
+}
+
 extern ssize_t vfs_read(struct file *, char __user *, size_t, loff_t *);
 extern ssize_t vfs_write(struct file *, const char __user *, size_t, loff_t *);
 extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
@@ -2127,7 +2137,8 @@ extern struct file *do_filp_open(int dfd, const char *pathname,
 		int open_flag, int mode, int acc_mode);
 extern int may_open(struct path *, int, int);
 
-extern int kernel_read(struct file *, loff_t, char *, unsigned long);
+extern ssize_t kernel_read(struct file *, loff_t, char *, size_t);
+extern ssize_t kernel_write(struct file *, loff_t, const char *, size_t);
 extern struct file * open_exec(const char *);
  
 /* fs/dcache.c -- generic fs support functions */
-- 
1.6.3.3
