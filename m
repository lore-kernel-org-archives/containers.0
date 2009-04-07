From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 07/10] sysvipc-shm: correctly handle deleted (active)
	ipc shared memory
Date: Tue,  7 Apr 2009 08:31:40 -0400
Message-ID: <1239107503-21941-8-git-send-email-orenl@cs.columbia.edu>
References: <1239107503-21941-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107503-21941-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

During restart, an ipc shared region may have SHM_DEST, indicating
that it has been originally deleted (while still active). In this
case the task of deleting the region after restoring it is postponed
until the end of the restart; otherwise, it would be quite silly to
delete it at that time, because it will be ... gone :o

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 ipc/ckpt_shm.c |   44 ++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/ipc/ckpt_shm.c b/ipc/ckpt_shm.c
index ee9b77a..c5b7f60 100644
--- a/ipc/ckpt_shm.c
+++ b/ipc/ckpt_shm.c
@@ -145,6 +145,25 @@ int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns)
  * ipc restart
  */
 
+struct cr_dq_ipcshm_del {
+	struct ipc_namespace *ipcns;
+	int id;
+};
+
+static int cr_ipc_shm_delete(void *data)
+{
+	struct cr_dq_ipcshm_del *dq = (struct cr_dq_ipcshm_del *) data;
+	mm_segment_t old_fs;
+	int ret;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	ret = shmctl_down(dq->ipcns, dq->id, IPC_RMID, NULL, 0);
+	set_fs(old_fs);
+
+	return ret;
+}
+
 int cr_ipc_shm_attach(struct file *file,
 		      unsigned long vm_addr,
 		      unsigned long vm_flags)
@@ -224,7 +243,25 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 	if (hh->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
 		goto out;
 
-	/* FIXME: this will fail for deleted ipc shm segments */
+	/*
+	 * SHM_DEST means that the shm is to be deleted after creation.
+	 * However, deleting before it's actually attached is quite silly.
+	 * Instead, we defer this task to until restart has succeeded.
+	 */
+	if (hh->perms.mode & SHM_DEST) {
+		struct cr_dq_ipcshm_del dq;
+
+		/* to not confuse the rest of the code */
+		hh->perms.mode &= ~SHM_DEST;
+
+		dq.ipcns = current->nsproxy->ipc_ns;
+		dq.id = hh->perms.id;
+
+		ret = cr_deferqueue_add(ctx, cr_ipc_shm_delete,
+				       0, &dq, sizeof(dq));
+		if (ret < 0)
+			goto out;
+	}
 
 	shmflag = hh->flags | hh->perms.mode | IPC_CREAT | IPC_EXCL;
 	cr_debug("shm: do_shmget size %lld flag %#x id %d\n",
@@ -235,7 +272,6 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 		goto out;
 
 	down_write(&shm_ids->rw_mutex);
-
 	ret = -EIDRM;
 	perms = ipc_lock(shm_ids, hh->perms.id);
 	if (IS_ERR(perms)) {	/* this should not happen .. but be safe */
@@ -261,9 +297,9 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 	/* deposit in objhash and read contents in */
 	ret = cr_obj_add_ref(ctx, file, hh->objref, CR_OBJ_FILE, 0);
 	if (ret < 0)
-		goto file;
+		goto fput;
 	ret = cr_read_shmem_contents(ctx, file->f_dentry->d_inode);
- file:
+ fput:
 	fput(file);
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
-- 
1.5.4.3
