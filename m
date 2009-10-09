From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] ipc ns: fix memory leak (idr)
Date: Fri, 9 Oct 2009 17:25:31 -0500
Message-ID: <20091009222531.GA8222@us.ibm.com>
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
To: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

We have apparently had a memory leak since
7ca7e564e049d8b350ec9d958ff25eaa24226352
"ipc: store ipcs into IDRs" in 2007.  The idr of which 3
exist for each ipc namespace is never freed.

This patch simply frees them when the ipcns is freed.  I don't
believe any idr_remove() are done from rcu (and could therefore
be delayed until after this idr_destroy()), so the patch should
be safe.  Some quick testing showed no harm, and the memory
leak fixed.

Caught by kmemleak.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/msg.c |    1 +
 ipc/sem.c |    1 +
 ipc/shm.c |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index 3559d53..861cc32 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -124,6 +124,7 @@ void msg_init_ns(struct ipc_namespace *ns)
 void msg_exit_ns(struct ipc_namespace *ns)
 {
 	free_ipcs(ns, &msg_ids(ns), freeque);
+	idr_destroy(&ns->ids[IPC_MSG_IDS].ipcs_idr);
 }
 #endif
 
diff --git a/ipc/sem.c b/ipc/sem.c
index 7361041..23ce7ec 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -128,6 +128,7 @@ void sem_init_ns(struct ipc_namespace *ns)
 void sem_exit_ns(struct ipc_namespace *ns)
 {
 	free_ipcs(ns, &sem_ids(ns), freeary);
+	idr_destroy(&ns->ids[IPC_SEM_IDS].ipcs_idr);
 }
 #endif
 
diff --git a/ipc/shm.c b/ipc/shm.c
index 26f9253..82ab773 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -102,6 +102,7 @@ void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 void shm_exit_ns(struct ipc_namespace *ns)
 {
 	free_ipcs(ns, &shm_ids(ns), do_shm_rmid);
+	idr_destroy(&ns->ids[IPC_SHM_IDS].ipcs_idr);
 }
 #endif
 
-- 
1.5.4.3
