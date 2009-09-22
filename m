From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] c/r: fix race of prepare_descendant() with an ongoing fork()
Date: Tue, 22 Sep 2009 16:47:43 -0400
Message-ID: <1253652463-11529-1-git-send-email-orenl@librato.com>
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
Cc: Oren Laadan <orenl-RdfvBDnrOiyVc3sceRu5cw@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Oren Laadan <orenl-RdfvBDnrOiyVc3sceRu5cw@public.gmane.org>

If prepare_descendants() is walking a tree and one of the tasks is
forking, one of two bads can happen. If the child doesn't inherit the
->ctx, it breaks the assumption that the entire subtree is prepared.
If the child inherits the ->ctx, it will have one without having taken
a reference.

This patch closed this race by explicitly getting and referencing the
->ctx for a child process should the parent have one, atomically under
the tasklist_lock.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 kernel/fork.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 9f13d7b..57118e4 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -62,6 +62,7 @@
 #include <linux/fs_struct.h>
 #include <linux/magic.h>
 #include <linux/perf_counter.h>
+#include <linux/checkpoint.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -1148,9 +1149,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	INIT_LIST_HEAD(&p->pi_state_list);
 	p->pi_state_cache = NULL;
 #endif
-#ifdef CONFIG_CHECKPOINT
-	p->checkpoint_ctx = NULL;
-#endif
 	/*
 	 * sigaltstack should be cleared when sharing the same VM
 	 */
@@ -1188,6 +1186,13 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	/* Need tasklist lock for parent etc handling! */
 	write_lock_irq(&tasklist_lock);
 
+#ifdef CONFIG_CHECKPOINT
+	/* If parent is restarting, child should be too */
+	if (unlikely(current->checkpoint_ctx)) {
+		p->checkpoint_ctx = current->checkpoint_ctx;
+		ckpt_ctx_get(p->checkpoint_ctx);
+	}
+#endif
 	/*
 	 * The task hasn't been attached yet, so its cpus_allowed mask will
 	 * not be changed, nor will its assigned CPU.
-- 
1.6.0.4
