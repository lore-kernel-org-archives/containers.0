From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 2/5] c/r: nit to avoid rcu lockdep complaint in
	restore_obj_sighand()
Date: Wed, 26 Jan 2011 11:10:48 -0500
Message-ID: <1296058251-21295-3-git-send-email-orenl@cs.columbia.edu>
References: <1296058251-21295-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296058251-21295-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 kernel/signal.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index dca40be..3842f5d 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2871,7 +2871,7 @@ static void *restore_sighand(struct ckpt_ctx *ctx)
 int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
 {
 	struct sighand_struct *sighand;
-	struct sighand_struct *old_sighand;
+	struct sighand_struct *old_sighand = NULL;
 
 	sighand = ckpt_obj_fetch(ctx, sighand_objref, CKPT_OBJ_SIGHAND);
 	if (IS_ERR(sighand))
@@ -2884,11 +2884,14 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
 
 	/* manipulate tsk->sighand with tasklist lock write-held */
 	write_lock_irq(&tasklist_lock);
-	old_sighand = rcu_dereference(current->sighand);
+	old_sighand = rcu_dereference_check(current->sighand,
+					    rcu_read_lock_held() ||
+					    lockdep_is_held(&tasklist_lock));
 	spin_lock(&old_sighand->siglock);
 	rcu_assign_pointer(current->sighand, sighand);
 	spin_unlock(&old_sighand->siglock);
 	write_unlock_irq(&tasklist_lock);
+
 	__cleanup_sighand(old_sighand);
 
 	return 0;
-- 
1.7.1
