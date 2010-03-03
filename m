From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: fix regression (in "fix scheduling in atomic while
	restoring ipc shm")
Date: Tue,  2 Mar 2010 19:04:09 -0500
Message-ID: <1267574649-14269-1-git-send-email-orenl@cs.columbia.edu>
References: <20100224083534.GC18758@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100224083534.GC18758-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

So... here's a simple fix to a silly regression - this should bring
an end to my little fiasco. 

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 ipc/checkpoint_msg.c |    2 +-
 ipc/checkpoint_sem.c |    2 +-
 ipc/checkpoint_shm.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index 073a893..0155c20 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -359,7 +359,7 @@ int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	 * ipc-ns, we will need to re-examine this.
 	 */
 
-	ipc = idr_find(&msg_ids->ipcs_idr, h->perms.id);
+	ipc = idr_find(&msg_ids->ipcs_idr, ipcid_to_idx(h->perms.id));
 	BUG_ON(!ipc);
 
 	msq = container_of(ipc, struct msg_queue, q_perm);
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 78c1932..2abfb5a 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -216,7 +216,7 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	 * ipc-ns, we will need to re-examine this.
 	 */
 
-	ipc = idr_find(&sem_ids->ipcs_idr, h->perms.id);
+	ipc = idr_find(&sem_ids->ipcs_idr, ipcid_to_idx(h->perms.id));
 	BUG_ON(!ipc);
 
 	sem = container_of(ipc, struct sem_array, sem_perm);
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 6329245..a07c051 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -270,7 +270,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	 * ipc-ns, we will need to re-examine this.
 	 */
 
-	ipc = idr_find(&shm_ids->ipcs_idr, h->perms.id);
+	ipc = idr_find(&shm_ids->ipcs_idr, ipcid_to_idx(h->perms.id));
 	BUG_ON(!ipc);
 
 	shp = container_of(ipc, struct shmid_kernel, shm_perm);
-- 
1.6.3.3
