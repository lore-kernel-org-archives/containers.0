From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Initialize the sem->sem_pending list after restoring
Date: Wed, 16 Jun 2010 09:54:40 -0700
Message-ID: <1276707280-28974-1-git-send-email-danms@us.ibm.com>
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
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Right now, we leave (effectively) garbage in it after restart.  Not only
must this be re-initialized (since we know it was empty on checkpoint), but
it must be initialized after being copied into the final resting place.

Without this, you get lots of fun crashes in various places :)

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint_sem.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index ab1830e..43e3cdf 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -171,7 +171,7 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	struct sem_array *sem;
 	struct sem *sma = NULL;
 	struct ipc_ids *sem_ids = &ns->ids[IPC_SEM_IDS];
-	int semflag, ret;
+	int semflag, ret, i;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_SEM);
 	if (IS_ERR(h))
@@ -222,6 +222,9 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	sem = container_of(ipc, struct sem_array, sem_perm);
 	memcpy(sem->sem_base, sma, sem->sem_nsems * sizeof(*sma));
 
+	for (i = 0; i < sem->sem_nsems; i++)
+		INIT_LIST_HEAD(&sem->sem_base[i].sem_pending);
+
 	/* this is safe because no unauthorized access is possible */
 	ipc_unlock(ipc);
 
-- 
1.7.0.4
