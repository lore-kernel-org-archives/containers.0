From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/8] checkpoint/sysvshm: release rwsem earlier during restore
Date: Tue, 14 Sep 2010 15:02:05 -0500
Message-ID: <1284494530-25946-4-git-send-email-ntl@pobox.com>
References: <1284494530-25946-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1284494530-25946-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

shm_ids->rw_mutex protects namespace-wide shm info, but not the
attributes or contents of individual shm regions, so release it as
soon as possible in the restart path.

The SHM_HUGETLB-specific restore code (unfortunately) needs to take
mmap_sem, which cannot be taken while holding shm_ids->rw_mutex (see
sys_shmdt -> do_munmap -> shm_close), so this is a prerequisite for
restoring hugetlb shm regions.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 ipc/checkpoint_shm.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index a929e33..69ba35a 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -284,19 +284,19 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 
 	/* this is safe because no unauthorized access is possible */
 	ipc_unlock(ipc);
+	up_write(&shm_ids->rw_mutex);
 
 	ret = load_ipc_shm_hdr(ctx, h, shp);
 	if (ret < 0)
-		goto mutex;
+		goto fput;
 
 	/* deposit in objhash and read contents in */
 	ret = ckpt_obj_insert(ctx, file, h->objref, CKPT_OBJ_FILE);
 	if (ret < 0)
-		goto mutex;
+		goto fput;
 	ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
- mutex:
+fput:
 	fput(file);
-	up_write(&shm_ids->rw_mutex);
 
 	/* discard this shmid if error and deferqueue wasn't set */
 	if (ret < 0 && !(h->perms.mode & SHM_DEST)) {
-- 
1.7.2.2
