From: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Subject: [RFC][PATCH 3/4] IPC: use the target ID specified in procfs
Date: Mon, 10 Mar 2008 14:50:57 +0100
Message-ID: <20080310135209.461472000@bull.net>
References: <20080310135054.312992000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=ipc_use_next_id.patch
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
Cc: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

[PATCH 03/04]

This patch makes use of the target id specified by a previous write into
/proc/self/next_ipcid as the id to use to allocate the next IPC object.

Signed-off-by: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>

---
 ipc/util.c |   39 +++++++++++++++++++++++++++++++--------
 1 file changed, 31 insertions(+), 8 deletions(-)

Index: linux-2.6.25-rc3-mm1/ipc/util.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/ipc/util.c	2008-03-10 13:10:33.000000000 +0100
+++ linux-2.6.25-rc3-mm1/ipc/util.c	2008-03-10 13:11:24.000000000 +0100
@@ -35,6 +35,7 @@
 #include <linux/rwsem.h>
 #include <linux/memory.h>
 #include <linux/ipc_namespace.h>
+#include <linux/sysids.h>
 
 #include <asm/unistd.h>
 
@@ -267,20 +268,42 @@ int ipc_addid(struct ipc_ids* ids, struc
 	if (ids->in_use >= size)
 		return -ENOSPC;
 
-	err = idr_get_new(&ids->ipcs_idr, new, &id);
-	if (err)
-		return err;
+	/* If there is a target id specified, try to use it */
+	if (current->next_id && (current->next_id->flag & SYS_ID_IPC)) {
+		int new_id = current->next_id->ipc_id;
+		int new_lid = new_id % SEQ_MULTIPLIER;
+
+		if (new_id !=
+		    (new_lid + (new_id / SEQ_MULTIPLIER) * SEQ_MULTIPLIER))
+			return -EINVAL;
+
+		err = idr_get_new_above(&ids->ipcs_idr, new, new_lid, &id);
+		if (err)
+			return err;
+		if (id != new_lid) {
+			idr_remove(&ids->ipcs_idr, id);
+			return -EBUSY;
+		}
+
+		new->id = new_id;
+		new->seq = new_id / SEQ_MULTIPLIER;
+		current->next_id->flag &= ~SYS_ID_IPC;
+	} else {
+		err = idr_get_new(&ids->ipcs_idr, new, &id);
+		if (err)
+			return err;
+
+		new->seq = ids->seq++;
+		if (ids->seq > ids->seq_max)
+			ids->seq = 0;
+		new->id = ipc_buildid(id, new->seq);
+	}
 
 	ids->in_use++;
 
 	new->cuid = new->uid = current->euid;
 	new->gid = new->cgid = current->egid;
 
-	new->seq = ids->seq++;
-	if(ids->seq > ids->seq_max)
-		ids->seq = 0;
-
-	new->id = ipc_buildid(id, new->seq);
 	spin_lock_init(&new->lock);
 	new->deleted = 0;
 	rcu_read_lock();

--
