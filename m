From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 043/100] c/r: add generic '->checkpoint()' f_op to simple
	devices
Date: Sat,  1 May 2010 10:15:25 -0400
Message-ID: <1272723382-19470-44-git-send-email-orenl__10933.8751798079$1272726688$gmane$org@cs.columbia.edu>
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

* /dev/null
* /dev/zero
* /dev/random
* /dev/urandom

Changelog [v21]:
  - Put file_ops->checkpoint under CONFIG_CHECKPOINT

Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 drivers/char/mem.c    |    6 ++++++
 drivers/char/random.c |    6 ++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index f54dab8..4e48384 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -767,6 +767,9 @@ static const struct file_operations null_fops = {
 	.read		= read_null,
 	.write		= write_null,
 	.splice_write	= splice_write_null,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 #ifdef CONFIG_DEVPORT
@@ -783,6 +786,9 @@ static const struct file_operations zero_fops = {
 	.read		= read_zero,
 	.write		= write_zero,
 	.mmap		= mmap_zero,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 /*
diff --git a/drivers/char/random.c b/drivers/char/random.c
index 2fd3d39..47a224c 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1169,6 +1169,9 @@ const struct file_operations random_fops = {
 	.poll  = random_poll,
 	.unlocked_ioctl = random_ioctl,
 	.fasync = random_fasync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 const struct file_operations urandom_fops = {
@@ -1176,6 +1179,9 @@ const struct file_operations urandom_fops = {
 	.write = random_write,
 	.unlocked_ioctl = random_ioctl,
 	.fasync = random_fasync,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = generic_file_checkpoint,
+#endif
 };
 
 /***************************************************************
-- 
1.6.3.3
