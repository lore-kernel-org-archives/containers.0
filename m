From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 7/9] cr: checkpoint saved_auxv as u64s
Date: Mon,  8 Feb 2010 20:00:04 -0600
Message-ID: <1265680806-13295-8-git-send-email-serue@us.ibm.com>
References: <1265680806-13295-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265680806-13295-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

unsigned longs are not a good value to checkpoint between
x86-32 and x86-64 32-bit tasks :)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c        |    5 +--
 checkpoint/memory.c            |   53 +++++++++++++++++++++++++++++++++++++--
 checkpoint/restart.c           |    6 ++--
 include/linux/checkpoint_hdr.h |    2 +-
 4 files changed, 56 insertions(+), 10 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index b4e0021..b3c1c4f 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -103,13 +103,12 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
 static void fill_kernel_const(struct ckpt_const *h)
 {
 	struct task_struct *tsk;
-	struct mm_struct *mm;
 	struct new_utsname *uts;
 
 	/* task */
 	h->task_comm_len = sizeof(tsk->comm);
-	/* mm */
-	h->mm_saved_auxv_len = sizeof(mm->saved_auxv);
+	/* mm->saved_auxv size */
+	h->at_vector_size = AT_VECTOR_SIZE;
 	/* signal */
 	h->signal_nsig = _NSIG;
 	/* uts */
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index d51f94b..5058ab3 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -661,6 +661,25 @@ static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	return ret < 0 ? ret : map_count;
 }
 
+#define CKPT_AT_SZ (AT_VECTOR_SIZE * sizeof(u64))
+/*
+ * We always write saved_auxv out as an array of u64s, though it is
+ * an array of u32s on 32-bit arch.
+ */
+static int ckpt_write_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	int i, ret;
+	u64 *buf = kzalloc(CKPT_AT_SZ, GFP_KERNEL);
+
+	if (!buf)
+		return -ENOMEM;
+	for (i=0; i<AT_VECTOR_SIZE; i++)
+		buf[i] = mm->saved_auxv[i];
+	ret = ckpt_write_buffer(ctx, buf, CKPT_AT_SZ);
+	kfree(buf);
+	return ret;
+}
+
 static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 {
 	struct ckpt_hdr_mm *h;
@@ -718,7 +737,7 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	if (ret < 0)
 		goto out;
 
-	ret = ckpt_write_buffer(ctx, mm->saved_auxv, sizeof(mm->saved_auxv));
+	ret = ckpt_write_auxv(ctx, mm);
 	if (ret < 0)
 		return ret;
 
@@ -1205,6 +1224,32 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	return ret;
 }
 
+static int ckpt_read_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	int i, ret;
+	u64 *buf = kmalloc(CKPT_AT_SZ, GFP_KERNEL);
+
+	if (!buf)
+		return -ENOMEM;
+	ret = _ckpt_read_buffer(ctx, buf, CKPT_AT_SZ);
+	if (ret < 0) {
+		kfree(buf);
+		return ret;
+	}
+
+	for (i=0; i<AT_VECTOR_SIZE; i++)
+		if (buf[i] > (u64) ULONG_MAX) {
+			kfree(buf);
+			return -E2BIG;
+		}
+
+	for (i=0; i<AT_VECTOR_SIZE; i++)
+		mm->saved_auxv[i] = buf[i];
+
+	kfree(buf);
+	return 0;
+}
+
 static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_mm *h;
@@ -1270,9 +1315,11 @@ static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
 	}
 	up_write(&mm->mmap_sem);
 
-	ret = _ckpt_read_buffer(ctx, mm->saved_auxv, sizeof(mm->saved_auxv));
-	if (ret < 0)
+	ret = ckpt_read_auxv(ctx, mm);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Error restoring auxv\n");
 		goto out;
+	}
 
 	for (nr = h->map_count; nr; nr--) {
 		ret = restore_vma(ctx, mm);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 9bb17fc..a5f30f2 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -552,15 +552,15 @@ int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
 static int check_kernel_const(struct ckpt_const *h)
 {
 	struct task_struct *tsk;
-	struct mm_struct *mm;
 	struct new_utsname *uts;
 
 	/* task */
 	if (h->task_comm_len != sizeof(tsk->comm))
 		return -EINVAL;
-	/* mm */
-	if (h->mm_saved_auxv_len != sizeof(mm->saved_auxv))
+	/* mm->saved_auxv size */
+	if (h->at_vector_size != AT_VECTOR_SIZE)
 		return -EINVAL;
+
 	/* signal */
 	if (h->signal_nsig != _NSIG)
 		return -EINVAL;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 5a68178..b5dd95c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -262,7 +262,7 @@ struct ckpt_const {
 	/* task */
 	__u16 task_comm_len;
 	/* mm */
-	__u16 mm_saved_auxv_len;
+	__u16 at_vector_size;
 	/* signal */
 	__u16 signal_nsig;
 	/* uts */
-- 
1.6.0.4
