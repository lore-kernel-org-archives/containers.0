From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/8] sysvshm: check for hugetlb before assuming shmem
Date: Tue, 14 Sep 2010 15:02:03 -0500
Message-ID: <1284494530-25946-2-git-send-email-ntl@pobox.com>
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

fill_ipc_shm_hdr should ensure that the region isn't hugetlbfs-backed
before backcasting the inode to shmem_inode_info, not after.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 ipc/checkpoint_shm.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index c8247ce..a929e33 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -58,13 +58,17 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 		h->mlock_uid = (unsigned int) -1;
 
 	h->flags = 0;
-	/* check if shm was setup with SHM_NORESERVE */
-	if (SHMEM_I(shp->shm_file->f_dentry->d_inode)->flags & VM_NORESERVE)
-		h->flags |= SHM_NORESERVE;
+
 	/* check if shm was setup with SHM_HUGETLB (unsupported yet) */
 	if (is_file_hugepages(shp->shm_file)) {
 		pr_warning("c/r: unsupported SHM_HUGETLB\n");
 		ret = -ENOSYS;
+	} else {
+		struct shmem_inode_info *info;
+
+		info = SHMEM_I(shp->shm_file->f_dentry->d_inode);
+		if (info->flags & VM_NORESERVE)
+			h->flags |= SHM_NORESERVE;
 	}
 
 	ipc_unlock(&shp->shm_perm);
-- 
1.7.2.2
