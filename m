From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] ipcns: make free_ipc_ns() static
Date: Fri, 22 May 2009 02:12:19 +0400
Message-ID: <20090521221219.GA13949@x200.localdomain>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/ipc_namespace.h |    1 
 ipc/namespace.c               |   48 +++++++++++++++++++++---------------------
 2 files changed, 24 insertions(+), 25 deletions(-)

--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -94,7 +94,6 @@ static inline int mq_init_ns(struct ipc_namespace *ns) { return 0; }
 #endif
 
 #if defined(CONFIG_IPC_NS)
-extern void free_ipc_ns(struct ipc_namespace *ns);
 extern struct ipc_namespace *copy_ipcs(unsigned long flags,
 				       struct ipc_namespace *ns);
 extern void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -83,6 +83,30 @@ void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
 	up_write(&ids->rw_mutex);
 }
 
+static void free_ipc_ns(struct ipc_namespace *ns)
+{
+	/*
+	 * Unregistering the hotplug notifier at the beginning guarantees
+	 * that the ipc namespace won't be freed while we are inside the
+	 * callback routine. Since the blocking_notifier_chain_XXX routines
+	 * hold a rw lock on the notifier list, unregister_ipcns_notifier()
+	 * won't take the rw lock before blocking_notifier_call_chain() has
+	 * released the rd lock.
+	 */
+	unregister_ipcns_notifier(ns);
+	sem_exit_ns(ns);
+	msg_exit_ns(ns);
+	shm_exit_ns(ns);
+	kfree(ns);
+	atomic_dec(&nr_ipc_ns);
+
+	/*
+	 * Do the ipcns removal notification after decrementing nr_ipc_ns in
+	 * order to have a correct value when recomputing msgmni.
+	 */
+	ipcns_notify(IPCNS_REMOVED);
+}
+
 /*
  * put_ipc_ns - drop a reference to an ipc namespace.
  * @ns: the namespace to put
@@ -108,27 +132,3 @@ void put_ipc_ns(struct ipc_namespace *ns)
 		free_ipc_ns(ns);
 	}
 }
-
-void free_ipc_ns(struct ipc_namespace *ns)
-{
-	/*
-	 * Unregistering the hotplug notifier at the beginning guarantees
-	 * that the ipc namespace won't be freed while we are inside the
-	 * callback routine. Since the blocking_notifier_chain_XXX routines
-	 * hold a rw lock on the notifier list, unregister_ipcns_notifier()
-	 * won't take the rw lock before blocking_notifier_call_chain() has
-	 * released the rd lock.
-	 */
-	unregister_ipcns_notifier(ns);
-	sem_exit_ns(ns);
-	msg_exit_ns(ns);
-	shm_exit_ns(ns);
-	kfree(ns);
-	atomic_dec(&nr_ipc_ns);
-
-	/*
-	 * Do the ipcns removal notification after decrementing nr_ipc_ns in
-	 * order to have a correct value when recomputing msgmni.
-	 */
-	ipcns_notify(IPCNS_REMOVED);
-}
