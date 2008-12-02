From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 1/4] checkpoint/restart: fix code to handle open symlinks
Date: Tue, 02 Dec 2008 10:57:34 -0800
Message-ID: <20081202185734.F740150C@kernel>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


There's no such thing as an opened symlink.


---

 linux-2.6.git-dave/checkpoint/ckpt_file.c         |    3 ---
 linux-2.6.git-dave/checkpoint/rstr_file.c         |    1 -
 linux-2.6.git-dave/include/linux/checkpoint_hdr.h |    1 -
 3 files changed, 5 deletions(-)

diff -puN checkpoint/ckpt_file.c~fix-no-opened-symlinks checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~fix-no-opened-symlinks	2008-12-02 10:13:34.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2008-12-02 10:14:08.000000000 -0800
@@ -104,9 +104,6 @@ static int cr_write_fd_data(struct cr_ct
 	case S_IFDIR:
 		fd_type = CR_FD_DIR;
 		break;
-	case S_IFLNK:
-		fd_type = CR_FD_LINK;
-		break;
 	default:
 		cr_hbuf_put(ctx, sizeof(*hh));
 		return -EBADF;
diff -puN checkpoint/rstr_file.c~fix-no-opened-symlinks checkpoint/rstr_file.c
--- linux-2.6.git/checkpoint/rstr_file.c~fix-no-opened-symlinks	2008-12-02 10:13:34.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/rstr_file.c	2008-12-02 10:14:07.000000000 -0800
@@ -94,7 +94,6 @@ cr_read_fd_data(struct cr_ctx *ctx, stru
 	switch (hh->fd_type) {
 	case CR_FD_FILE:
 	case CR_FD_DIR:
-	case CR_FD_LINK:
 		file = cr_read_open_fname(ctx, hh->f_flags, hh->f_mode);
 		break;
 	default:
diff -puN include/linux/checkpoint_hdr.h~fix-no-opened-symlinks include/linux/checkpoint_hdr.h
--- linux-2.6.git/include/linux/checkpoint_hdr.h~fix-no-opened-symlinks	2008-12-02 10:13:34.000000000 -0800
+++ linux-2.6.git-dave/include/linux/checkpoint_hdr.h	2008-12-02 10:13:34.000000000 -0800
@@ -137,7 +137,6 @@ struct cr_hdr_fd_ent {
 enum  fd_type {
 	CR_FD_FILE = 1,
 	CR_FD_DIR,
-	CR_FD_LINK
 };
 
 struct cr_hdr_fd_data {
_
