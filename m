From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: fix false negative of test for unlinked files at
	checkpoint
Date: Wed, 10 Feb 2010 20:39:43 -0500
Message-ID: <1265852383-17486-1-git-send-email-orenl@cs.columbia.edu>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Checkpoint will abort when it detects non-checkpoint-able state. This
patch fixes a false positive of testing for unlinked files.

The test for an unlinked file (or directory) is not file system
agnostic. Commit a3a065e3f13da8a3470ed09c7f38aad256083726 made it
visible when it changed the behavior of dentry for pipe, sockets and
anon_inodes (eventfd, timerfd, epoll, signalfd and perf...) to set
their DCACHE_UNHASHED.

This is fixed by moving the actual test whether the file is unlinked
or not to the per filesystem .checkpoint() method, (including the
default generic_file_checkpoint).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/files.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index d1242f2..267d361 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -197,14 +197,20 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	struct ckpt_hdr_file_generic *h;
 	int ret;
 
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
-	if (!h)
-		return -ENOMEM;
-
 	/*
 	 * FIXME: when we'll add support for unlinked files/dirs, we'll
 	 * need to distinguish between unlinked filed and unlinked dirs.
 	 */
+	if (d_unlinked(file->f_dentry)) {
+		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
+			 file);
+		return -EBADF;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
 	h->common.f_type = CKPT_FILE_GENERIC;
 
 	ret = checkpoint_file_common(ctx, file, &h->common);
@@ -231,11 +237,6 @@ int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 			       file, file->f_op);
 		return -EBADF;
 	}
-	if (d_unlinked(file->f_dentry)) {
-		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
-			 file);
-		return -EBADF;
-	}
 
 	ret = file->f_op->checkpoint(ctx, file);
 	if (ret < 0)
-- 
1.6.3.3
