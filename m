From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/8] checkpoint/ipc: allow shmat callers to specify ipc
	namespace
Date: Tue, 14 Sep 2010 15:02:06 -0500
Message-ID: <1284494530-25946-5-git-send-email-ntl@pobox.com>
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

Restore of huge page shm regions will require that the restarting
process temporarily shmat-attach to regions which are not in the
current ipc namespace.  Add an ipc_namespace argument to
do_shmat_pgoff; convert callers to pass current->nsproxy->ipc_ns.

This depends on the patch "support ipc shm regions which are partially
mapped" posted to the containers list on 6 August.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/shm.h |    8 +++++---
 ipc/shm.c           |   15 ++++++++-------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 1f6af8c..9ca3196 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -104,10 +104,12 @@ struct shmid_kernel /* private to the kernel */
 #define SHM_NORESERVE   010000  /* don't check for reservations */
 
 #ifdef CONFIG_SYSVIPC
+struct ipc_namespace;
+
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr);
-long do_shmat_pgoff(int shmid, char __user *shmaddr,
-		    int shmflg, unsigned long *addr,
-		    unsigned long shmsize, unsigned long shmpgoff);
+long do_shmat_ns_pgoff(struct ipc_namespace *ns, int shmid,
+		       char __user *shmaddr, int shmflg, unsigned long *addr,
+		       unsigned long shmsize, unsigned long shmpgoff);
 extern int is_file_shm_hugepages(struct file *file);
 #else
 static inline long do_shmat(int shmid, char __user *shmaddr,
diff --git a/ipc/shm.c b/ipc/shm.c
index 1ba9193..6768fe4 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -321,6 +321,7 @@ static int ipcshm_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 		   struct ckpt_hdr_vma *h)
 {
+	struct ipc_namespace *ipcns = current->nsproxy->ipc_ns;
 	struct file *file;
 	int shmid, shmflg = 0;
 	unsigned long start;
@@ -348,8 +349,8 @@ int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	/* do_shmat() below handles partial and offset mapping */
 	start = (unsigned long) h->vm_start;
 	size = min(h->ino_size, h->vm_end - h->vm_start);
-	ret = do_shmat_pgoff(shmid, (char __user *) start, shmflg,
-			     &addr, size, h->vm_pgoff << PAGE_SHIFT);
+	ret = do_shmat_ns_pgoff(ipcns, shmid, (char __user *) start, shmflg,
+				&addr, size, h->vm_pgoff << PAGE_SHIFT);
 
 	BUG_ON(ret >= 0 && addr != h->vm_start);
 	return ret;
@@ -880,8 +881,9 @@ out:
  * "raddr" thing points to kernel space, and there has to be a wrapper around
  * this.
  */
-long do_shmat_pgoff(int shmid, char __user *shmaddr, int shmflg,
-		    ulong *raddr, ulong shmsize, ulong shmpgoff)
+long do_shmat_ns_pgoff(struct ipc_namespace *ns, int shmid,
+		       char __user *shmaddr, int shmflg, ulong *raddr,
+		       ulong shmsize, ulong shmpgoff)
 {
 	struct shmid_kernel *shp;
 	unsigned long addr;
@@ -893,7 +895,6 @@ long do_shmat_pgoff(int shmid, char __user *shmaddr, int shmflg,
 	unsigned long prot;
 	int acc_mode;
 	unsigned long user_addr;
-	struct ipc_namespace *ns;
 	struct shm_file_data *sfd;
 	struct path path;
 	fmode_t f_mode;
@@ -937,7 +938,6 @@ long do_shmat_pgoff(int shmid, char __user *shmaddr, int shmflg,
 	 * We cannot rely on the fs check since SYSV IPC does have an
 	 * additional creator id...
 	 */
-	ns = current->nsproxy->ipc_ns;
 	shp = shm_lock_check(ns, shmid);
 	if (IS_ERR(shp)) {
 		err = PTR_ERR(shp);
@@ -1045,7 +1045,8 @@ out_put_dentry:
  */
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 {
-	return do_shmat_pgoff(shmid, shmaddr, shmflg, raddr, 0, 0);
+	return do_shmat_ns_pgoff(current->nsproxy->ipc_ns, shmid, shmaddr,
+				 shmflg, raddr, 0, 0);
 }
 
 SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
-- 
1.7.2.2
