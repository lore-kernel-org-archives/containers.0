From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Ensure nul-termination of file names read from checkpoint
	images
Date: Fri, 23 Oct 2009 10:58:27 -0700
Message-ID: <bb799d3c1e3e27d60dac114992c3e310fe14a9e6.1256320668.git.matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Don't rely on the checkpoint image to properly terminate the filename.
Passing PATH_MAX + 1 won't work since it's a maximum -- not the number
of bytes to allocate. Allocate space for the string, copy an amount
according to the header length (limited to < PATH_MAX), and ensure that
it's nul-terminated.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index f6de07e..0564666 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -443,6 +443,7 @@ struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
 	struct ckpt_hdr *h;
 	struct file *file;
 	char *fname;
+	int len;
 
 	/* prevent bad input from doing bad things */
 	if (flags & (O_CREAT | O_EXCL | O_NOCTTY | O_TRUNC))
@@ -451,10 +452,19 @@ struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
 	h = ckpt_read_buf_type(ctx, PATH_MAX, CKPT_HDR_FILE_NAME);
 	if (IS_ERR(h))
 		return (struct file *) h;
-	fname = (char *) (h + 1);
+	len = h->len - sizeof(*h);
+	fname = kmalloc(len + 1, GFP_KERNEL);
+	if (!fname) {
+		file = NULL;
+		goto out;
+	}
+	strncpy(fname, (char *) (h + 1), len);
+	fname[len] = '\0';
 	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
 
 	file = filp_open(fname, flags, 0);
+	kfree(fname);
+out:
 	ckpt_hdr_put(ctx, h);
 
 	return file;
-- 
1.5.6.3
