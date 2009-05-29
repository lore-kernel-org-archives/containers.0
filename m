From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cr: ipc: don't unlock before calling freeary in error path
Date: Fri, 29 May 2009 15:23:06 -0500
Message-ID: <20090529202306.GA11982@us.ibm.com>
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

Else freeary will BUG out.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint_sem.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 34dea40..e6934dc 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -206,12 +206,11 @@ int restore_ipc_sem(struct ckpt_ctx *ctx)
 	memcpy(sem->sem_base, sma, sem->sem_nsems * sizeof(*sma));
 
 	ret = load_ipc_sem_hdr(ctx, h, sem);
-	ipc_unlock(perms);
-
 	if (ret < 0) {
 		ckpt_debug("sem: need to remove (%d)\n", ret);
 		freeary(current->nsproxy->ipc_ns, perms);
-	}
+	} else
+		ipc_unlock(perms);
 	up_write(&sem_ids->rw_mutex);
  out:
 	kfree(sma);
-- 
1.6.1
