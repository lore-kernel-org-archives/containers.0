From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] checkpoint: handle sigaltstack
Date: Wed, 14 Jul 2010 10:23:45 -0500
Message-ID: <1279121025-17795-1-git-send-email-ntl@pobox.com>
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
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

sigaltstack(2) manipulates two fields in task_struct; save and restore
these.  Without this change the alternate stack is not used after
restart.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    2 ++
 kernel/checkpoint/process.c    |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index c8383c0..bc4ef43 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -380,6 +380,8 @@ struct ckpt_hdr_task {
 
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
+	__u64 sas_ss_sp;
+	__u32 sas_ss_size;
 } __attribute__((aligned(8)));
 
 /* Posix capabilities */
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index f6f3771..936675a 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -138,6 +138,9 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	h->exit_state = t->exit_state;
 	h->exit_code = t->exit_code;
 
+	h->sas_ss_sp = t->sas_ss_sp;
+	h->sas_ss_size = t->sas_ss_size;
+
 	if (t->exit_state) {
 		/* zombie - skip remaining state */
 		BUG_ON(t->exit_state != EXIT_ZOMBIE);
@@ -542,6 +545,9 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 		t->exit_signal = h->exit_signal;
 		t->pdeath_signal = h->pdeath_signal;
 
+		t->sas_ss_sp = (unsigned long)h->sas_ss_sp;
+		t->sas_ss_size = h->sas_ss_size;
+
 		t->set_child_tid =
 			(int __user *) (unsigned long) h->set_child_tid;
 		t->clear_child_tid =
-- 
1.7.1.1
