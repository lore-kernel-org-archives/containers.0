From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 02/11] breakout fdinfo sprintf() into its own function
Date: Thu, 05 Mar 2009 08:38:59 -0800
Message-ID: <20090305163859.584741AF__18927.6279103526$1236271293$gmane$org@kernel>
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


I'll be adding to this in a moment and it is in a bad place
to do that cleanly now.

Also, increase the buffer size.  Most /proc files can
output up to a page, so use the same here.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/fs/proc/base.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff -puN fs/proc/base.c~breakout-fdinfo-sprintf fs/proc/base.c
--- linux-2.6.git/fs/proc/base.c~breakout-fdinfo-sprintf	2009-03-05 08:37:00.000000000 -0800
+++ linux-2.6.git-dave/fs/proc/base.c	2009-03-05 08:37:00.000000000 -0800
@@ -1632,7 +1632,18 @@ out:
 	return ~0U;
 }
 
-#define PROC_FDINFO_MAX 64
+#define PROC_FDINFO_MAX PAGE_SIZE
+
+static void proc_fd_write_info(struct file *file, char *info)
+{
+	int max = PROC_FDINFO_MAX;
+	int p = 0;
+	if (!info)
+		return;
+
+	p += scnprintf(info+p, max-p, "pos:\t%lli\n", (long long) file->f_pos);
+	p += scnprintf(info+p, max-p, "flags:\t0%o\n", file->f_flags);
+}
 
 static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 {
@@ -1657,12 +1668,7 @@ static int proc_fd_info(struct inode *in
 				*path = file->f_path;
 				path_get(&file->f_path);
 			}
-			if (info)
-				snprintf(info, PROC_FDINFO_MAX,
-					 "pos:\t%lli\n"
-					 "flags:\t0%o\n",
-					 (long long) file->f_pos,
-					 file->f_flags);
+			proc_fd_write_info(file, info);
 			spin_unlock(&files->file_lock);
 			put_files_struct(files);
 			return 0;
@@ -1870,10 +1876,11 @@ static int proc_readfd(struct file *filp
 static ssize_t proc_fdinfo_read(struct file *file, char __user *buf,
 				      size_t len, loff_t *ppos)
 {
-	char tmp[PROC_FDINFO_MAX];
+	char *tmp = kmalloc(PROC_FDINFO_MAX, GFP_KERNEL);
 	int err = proc_fd_info(file->f_path.dentry->d_inode, NULL, tmp);
 	if (!err)
 		err = simple_read_from_buffer(buf, len, ppos, tmp, strlen(tmp));
+	kfree(tmp);
 	return err;
 }
 
_
