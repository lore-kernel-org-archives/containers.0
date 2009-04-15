From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] Revert "sysvipc-shm: correctly handle deleted (active)
	ipc shared memory"
Date: Wed, 15 Apr 2009 11:02:21 -0500
Message-ID: <20090415160221.GA31929@us.ibm.com>
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

( this patchset applies on top of v14-3-dev to turn the deferqueue into
a generic mechanism )

From 274f58b8f265dc54e13728aa742c4852bde44ec1 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 14 Apr 2009 16:06:41 -0700
Subject: [PATCH 1/4] Revert "sysvipc-shm: correctly handle deleted (active) ipc shared memory"

This reverts commit 373eb88b3d338edc5039d34a30a4574f9a9fdfba.
---
 ipc/ckpt_shm.c |   44 ++++----------------------------------------
 1 files changed, 4 insertions(+), 40 deletions(-)

diff --git a/ipc/ckpt_shm.c b/ipc/ckpt_shm.c
index c5b7f60..ee9b77a 100644
--- a/ipc/ckpt_shm.c
+++ b/ipc/ckpt_shm.c
@@ -145,25 +145,6 @@ int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns)
  * ipc restart
  */
 
-struct cr_dq_ipcshm_del {
-	struct ipc_namespace *ipcns;
-	int id;
-};
-
-static int cr_ipc_shm_delete(void *data)
-{
-	struct cr_dq_ipcshm_del *dq = (struct cr_dq_ipcshm_del *) data;
-	mm_segment_t old_fs;
-	int ret;
-
-	old_fs = get_fs();
-	set_fs(get_ds());
-	ret = shmctl_down(dq->ipcns, dq->id, IPC_RMID, NULL, 0);
-	set_fs(old_fs);
-
-	return ret;
-}
-
 int cr_ipc_shm_attach(struct file *file,
 		      unsigned long vm_addr,
 		      unsigned long vm_flags)
@@ -243,25 +224,7 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 	if (hh->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
 		goto out;
 
-	/*
-	 * SHM_DEST means that the shm is to be deleted after creation.
-	 * However, deleting before it's actually attached is quite silly.
-	 * Instead, we defer this task to until restart has succeeded.
-	 */
-	if (hh->perms.mode & SHM_DEST) {
-		struct cr_dq_ipcshm_del dq;
-
-		/* to not confuse the rest of the code */
-		hh->perms.mode &= ~SHM_DEST;
-
-		dq.ipcns = current->nsproxy->ipc_ns;
-		dq.id = hh->perms.id;
-
-		ret = cr_deferqueue_add(ctx, cr_ipc_shm_delete,
-				       0, &dq, sizeof(dq));
-		if (ret < 0)
-			goto out;
-	}
+	/* FIXME: this will fail for deleted ipc shm segments */
 
 	shmflag = hh->flags | hh->perms.mode | IPC_CREAT | IPC_EXCL;
 	cr_debug("shm: do_shmget size %lld flag %#x id %d\n",
@@ -272,6 +235,7 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 		goto out;
 
 	down_write(&shm_ids->rw_mutex);
+
 	ret = -EIDRM;
 	perms = ipc_lock(shm_ids, hh->perms.id);
 	if (IS_ERR(perms)) {	/* this should not happen .. but be safe */
@@ -297,9 +261,9 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 	/* deposit in objhash and read contents in */
 	ret = cr_obj_add_ref(ctx, file, hh->objref, CR_OBJ_FILE, 0);
 	if (ret < 0)
-		goto fput;
+		goto file;
 	ret = cr_read_shmem_contents(ctx, file->f_dentry->d_inode);
- fput:
+ file:
 	fput(file);
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
-- 
1.5.4.3
