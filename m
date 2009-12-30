From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] checkpoint: don't checkpoint a task with aio requests
Date: Wed, 30 Dec 2009 14:37:22 -0600
Message-ID: <20091230203722.GA25170@us.ibm.com>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Not sure this is the best way, or entirely foolproof, but at
least make an attempt to not checkpoint a task which is using
aio.

A checkpoint-aware application using aio can have the checkpointer
signal all tasks to complete aio and wait for the checkpoint to
complete.

(Note I still have a queue of the patches at
http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/cr-next
so you should be able to

git fetch git://git.kernel.org/pub/scm/linux/kernel/git/sergeh/linux-cr.git cr-next:serge

and cherrypick patches from that branch instead
of wrangling all the patches from mbox...)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/memory.c |    6 ++++++
 fs/aio.c            |   17 +++++++++++++++++
 include/linux/aio.h |    2 ++
 3 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 0108dbe..49e16c5 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -25,6 +25,7 @@
 #include <linux/swap.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/aio.h>
 
 /*
  * page-array chains: each ckpt_pgarr describes a set of <struct page *,vaddr>
@@ -666,6 +667,11 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	struct file *exe_file = NULL;
 	int ret;
 
+	ret = check_for_outstanding_aio(mm);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "(%T)Outstanding aio\n");
+		return ret;
+	}
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM);
 	if (!h)
 		return -ENOMEM;
diff --git a/fs/aio.c b/fs/aio.c
index 02a2c93..7eb764c 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1784,3 +1784,20 @@ SYSCALL_DEFINE5(io_getevents, aio_context_t, ctx_id,
 	asmlinkage_protect(5, ret, ctx_id, min_nr, nr, events, timeout);
 	return ret;
 }
+
+int check_for_outstanding_aio(struct mm_struct *mm)
+{
+	int ret = -EBUSY;
+	struct kioctx *ctx;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(ctx, n, &mm->ioctx_list, list)
+		if (!ctx->dead)
+			goto found;
+	ret = 0;
+found:
+	rcu_read_unlock();
+
+	return ret;
+}
diff --git a/include/linux/aio.h b/include/linux/aio.h
index aea219d..462f22e 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -214,6 +214,7 @@ extern void kick_iocb(struct kiocb *iocb);
 extern int aio_complete(struct kiocb *iocb, long res, long res2);
 struct mm_struct;
 extern void exit_aio(struct mm_struct *mm);
+extern int check_for_outstanding_aio(struct mm_struct *mm);
 #else
 static inline ssize_t wait_on_sync_kiocb(struct kiocb *iocb) { return 0; }
 static inline int aio_put_req(struct kiocb *iocb) { return 0; }
@@ -221,6 +222,7 @@ static inline void kick_iocb(struct kiocb *iocb) { }
 static inline int aio_complete(struct kiocb *iocb, long res, long res2) { return 0; }
 struct mm_struct;
 static inline void exit_aio(struct mm_struct *mm) { }
+static inline int check_for_outstanding_aio(struct mm_struct *mm) { return 0; }
 #endif /* CONFIG_AIO */
 
 #define io_wait_to_kiocb(wait) container_of(wait, struct kiocb, ki_wait)
-- 
1.6.0.4
