From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [C/R v20][PATCH 20/96] c/r: make file_pos_read/write() public
Date: Mon, 22 Mar 2010 20:12:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1003221959450.1520__48776.7319813885$1269303216$gmane$org@takamine.ncl.cs.columbia.edu>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-2-git-send-email-orenl@cs.columbia.edu>
	<20100322063113.GD17637@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100322063113.GD17637@laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 22 Mar 2010, Nick Piggin wrote:

> On Thu, Mar 18, 2010 at 08:59:45PM -0400, Oren Laadan wrote:
> > These two are used in the next patch when calling vfs_read/write()
> 
> Said next patch didn't seem to make it to fsdevel.

Thanks for reviewing, and sorry about this glitch - see below.

> 
> Should it at least go to fs/internal.h?

Sure.

So Here is the relevant hunk from said patch (the entire
patch is: https://patchwork.kernel.org/patch/86389/):

+/*
+ * Helpers to write(read) from(to) kernel space to(from) the checkpoint
+ * image file descriptor (similar to how a core-dump is performed).
+ *
+ *   ckpt_kwrite() - write a kernel-space buffer to the checkpoint image
+ *   ckpt_kread() - read from the checkpoint image to a kernel-space buffer
+ */
+
+static inline int _ckpt_kwrite(struct file *file, void *addr, int count)
+{
+	void __user *uaddr = (__force void __user *) addr;
+	ssize_t nwrite;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nwrite) {
+		loff_t pos = file_pos_read(file);
+		nwrite = vfs_write(file, uaddr, nleft, &pos);
+		file_pos_write(file, pos);
+		if (nwrite < 0) {
+			if (nwrite == -EAGAIN)
+				nwrite = 0;
+			else
+				return nwrite;
+		}
+		uaddr += nwrite;
+	}
+	return 0;
+}
+
+int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, int count)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _ckpt_kwrite(ctx->file, addr, count);
+	set_fs(fs);
+
+	ctx->total += count;
+	return ret;
+}
+
+static inline int _ckpt_kread(struct file *file, void *addr, int count)
+{
+	void __user *uaddr = (__force void __user *) addr;
+	ssize_t nread;
+	int nleft;
+
+	for (nleft = count; nleft; nleft -= nread) {
+		loff_t pos = file_pos_read(file);
+		nread = vfs_read(file, uaddr, nleft, &pos);
+		file_pos_write(file, pos);
+		if (nread <= 0) {
+			if (nread == -EAGAIN) {
+				nread = 0;
+				continue;
+			} else if (nread == 0)
+				nread = -EPIPE;		/* unexecpted EOF */
+			return nread;
+		}
+		uaddr += nread;
+	}
+	return 0;
+}
+
+int ckpt_kread(struct ckpt_ctx *ctx, void *addr, int count)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = _ckpt_kread(ctx->file , addr, count);
+	set_fs(fs);
+
+	ctx->total += count;
+	return ret;
+}

Oren.
