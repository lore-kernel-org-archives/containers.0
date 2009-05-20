From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [C/R][PATCH] Export generic_file_checkpoint and generic_file_restore
Date: Tue, 19 May 2009 19:20:59 -0700
Message-ID: <20090520022059.GA30168@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 19 May 2009 19:18:25 -0700
Subject: [C/R][PATCH] Export generic_file_checkpoint and generic_file_restore

Needed when filesystems are compiled as modules.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 7da2cbf..cfea034 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -11,6 +11,7 @@
 /* default debug level for output */
 #define CKPT_DFLAG  CKPT_DFILE
 
+#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/file.h>
@@ -182,6 +183,7 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
+EXPORT_SYMBOL(generic_file_checkpoint);
 
 /* checkpoint_file - dump the state of a given file pointer */
 int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
@@ -401,6 +403,7 @@ struct file *generic_file_restore(struct ckpt_ctx *ctx,
 	}
 	return file;
 }
+EXPORT_SYMBOL(generic_file_restore);
 
 struct restore_file_ops {
 	char *file_name;
-- 
1.5.2.5
