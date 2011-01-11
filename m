From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 2/4] c/r: [ipc] allow shmat callers to specify ipc namespace
Date: Mon, 10 Jan 2011 21:11:27 -0500
Message-ID: <1294711889-30343-3-git-send-email-orenl@cs.columbia.edu>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287601006-13794-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Restore of huge page shm regions will require that the restarting
process temporarily shmat-attach to regions which are not in the
current ipc namespace.  Add an ipc_namespace argument to
do_shmat_pgoff; convert callers to pass current->nsproxy->ipc_ns.

This depends on the patch "support ipc shm regions which are partially
mapped" posted to the containers list on 6 August.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/shm.h |   15 ++++++++++-----
 ipc/shm.c           |   17 +++++++++--------
 2 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 1f6af8c..963591d 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -103,11 +103,14 @@ struct shmid_kernel /* private to the kernel */
 #define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
 #define SHM_NORESERVE   010000  /* don't check for reservations */
 
+struct ipc_namespace;
+
 #ifdef CONFIG_SYSVIPC
-long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr);
-long do_shmat_pgoff(int shmid, char __user *shmaddr,
-		    int shmflg, unsigned long *addr,
-		    unsigned long shmsize, unsigned long shmpgoff);
+extern long do_shmat(int shmid, char __user *shmaddr,
+		     int shmflg, unsigned long *addr);
+extern long do_shmat_ns_pgoff(struct ipc_namespace *ns, int shmid,
+			      char __user *shmaddr, int shmflg, unsigned long *addr,
+			      unsigned long shmsize, unsigned long shmpgoff);
 extern int is_file_shm_hugepages(struct file *file);
 #else
 static inline long do_shmat(int shmid, char __user *shmaddr,
@@ -115,13 +118,15 @@ static inline long do_shmat(int shmid, char __user *shmaddr,
 {
 	return -ENOSYS;
 }
+static inline long do_shmat_ns_pgoff(struct ipc_namespace *ns, int shmid,
+			      char __user *shmaddr, int shmflg, unsigned long *addr,
+			      unsigned long shmsize, unsigned long shmpgoff);
 static inline int is_file_shm_hugepages(struct file *file)
 {
 	return 0;
 }
 #endif
 
-struct ipc_namespace;
 extern int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 		       struct shmid_ds __user *buf, int version);
 
diff --git a/ipc/shm.c b/ipc/shm.c
index a18e7b7..a679523 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -322,6 +322,7 @@ static int ipcshm_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 		   struct ckpt_hdr_vma *h)
 {
+	struct ipc_namespace *ipcns = current->nsproxy->ipc_ns;
 	struct file *file;
 	int shmid, shmflg = 0;
 	unsigned long start;
@@ -353,9 +354,9 @@ int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	 */
 	start = (unsigned long) h->vm_start;
 	size = h->vm_end - h->vm_start;
-	ret = do_shmat_pgoff(shmid, (char __user *) start, shmflg, &addr,
-			     min(size, (unsigned long) h->ino_size),
-			     h->vm_pgoff << PAGE_SHIFT);
+	ret = do_shmat_ns_pgoff(ipcns, shmid, (char __user *) start, shmflg,
+				&addr, min(size, (unsigned long) h->ino_size),
+				h->vm_pgoff << PAGE_SHIFT);
 
 	BUG_ON(ret >= 0 && addr != h->vm_start);
 	return ret;
@@ -900,8 +901,9 @@ out:
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
@@ -913,7 +915,6 @@ long do_shmat_pgoff(int shmid, char __user *shmaddr, int shmflg,
 	unsigned long prot;
 	int acc_mode;
 	unsigned long user_addr;
-	struct ipc_namespace *ns;
 	struct shm_file_data *sfd;
 	struct path path;
 	fmode_t f_mode;
@@ -957,7 +958,6 @@ long do_shmat_pgoff(int shmid, char __user *shmaddr, int shmflg,
 	 * We cannot rely on the fs check since SYSV IPC does have an
 	 * additional creator id...
 	 */
-	ns = current->nsproxy->ipc_ns;
 	shp = shm_lock_check(ns, shmid);
 	if (IS_ERR(shp)) {
 		err = PTR_ERR(shp);
@@ -1065,7 +1065,8 @@ out_put_dentry:
  */
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 {
-	return do_shmat_pgoff(shmid, shmaddr, shmflg, raddr, 0, 0);
+	return do_shmat_ns_pgoff(current->nsproxy->ipc_ns, shmid, shmaddr,
+				 shmflg, raddr, 0, 0);
 }
 
 SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
-- 
1.7.1
