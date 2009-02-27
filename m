From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 1/8] kill '_data' in cr_hdr_fd_data name
Date: Fri, 27 Feb 2009 12:34:25 -0800
Message-ID: <20090227203425.F3B51176__17712.9871714444$1235767007$gmane$org@kernel>
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
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


The 'cr_hdr_fd_data' name is too long for me.  Adding data
at the end doesn't clarify anything in its use which makes
it a waste of space.  Kill it.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/checkpoint/ckpt_file.c         |    2 +-
 linux-2.6.git-dave/checkpoint/rstr_file.c         |    2 +-
 linux-2.6.git-dave/include/linux/checkpoint_hdr.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff -puN checkpoint/ckpt_file.c~no_data0 checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~no_data0	2009-02-27 12:07:37.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2009-02-27 12:07:37.000000000 -0800
@@ -76,7 +76,7 @@ int cr_scan_fds(struct files_struct *fil
 static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
 {
 	struct cr_hdr h;
-	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct cr_hdr_fd *hh = cr_hbuf_get(ctx, sizeof(*hh));
 	struct dentry *dent = file->f_dentry;
 	struct inode *inode = dent->d_inode;
 	enum fd_type fd_type;
diff -puN checkpoint/rstr_file.c~no_data0 checkpoint/rstr_file.c
--- linux-2.6.git/checkpoint/rstr_file.c~no_data0	2009-02-27 12:07:37.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/rstr_file.c	2009-02-27 12:07:37.000000000 -0800
@@ -71,7 +71,7 @@ static int cr_attach_get_file(struct fil
 static int
 cr_read_fd_data(struct cr_ctx *ctx, struct files_struct *files, int rparent)
 {
-	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct cr_hdr_fd *hh = cr_hbuf_get(ctx, sizeof(*hh));
 	struct file *file;
 	int parent, ret;
 	int fd = 0;	/* pacify gcc warning */
diff -puN include/linux/checkpoint_hdr.h~no_data0 include/linux/checkpoint_hdr.h
--- linux-2.6.git/include/linux/checkpoint_hdr.h~no_data0	2009-02-27 12:07:37.000000000 -0800
+++ linux-2.6.git-dave/include/linux/checkpoint_hdr.h	2009-02-27 12:07:37.000000000 -0800
@@ -137,7 +137,7 @@ enum  fd_type {
 	CR_FD_DIR,
 };
 
-struct cr_hdr_fd_data {
+struct cr_hdr_fd {
 	__u16 fd_type;
 	__u16 f_mode;
 	__u32 f_flags;
_
