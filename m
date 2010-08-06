From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: support ipc shm regions which are partially mapped
Date: Fri,  6 Aug 2010 17:18:52 -0400
Message-ID: <1281129532-4041-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

UNTESTED....

Because do_shmat() has limited interface of all-or-nothing mapping,
previous we did not support VMAs that reflect partiaul mapping to a
shared memory from IPC. For example, if a task calls shmat() and
then munmap() part of that mapping.

Now that Dan Smith hit an application that actually does that, it's
time to fix the situation:

Introduce do_shmat_pgoff() that accepts also @shmsize and @shmpgoff.
If these two are 0, then it behaves like do_shmat(). Otherwise, it
attempts to map only the relevant region within the shared memory
segment.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/shm.h |    3 +++
 ipc/shm.c           |   50 ++++++++++++++++++++++++++++++++------------------
 2 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 94ac1a7..1f6af8c 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -105,6 +105,9 @@ struct shmid_kernel /* private to the kernel */
 
 #ifdef CONFIG_SYSVIPC
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr);
+long do_shmat_pgoff(int shmid, char __user *shmaddr,
+		    int shmflg, unsigned long *addr,
+		    unsigned long shmsize, unsigned long shmpgoff);
 extern int is_file_shm_hugepages(struct file *file);
 #else
 static inline long do_shmat(int shmid, char __user *shmaddr,
diff --git a/ipc/shm.c b/ipc/shm.c
index 5a5dfb5..5336dc9 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -323,7 +323,6 @@ int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 {
 	struct file *file;
 	int shmid, shmflg = 0;
-	mm_segment_t old_fs;
 	unsigned long start;
 	unsigned long addr;
 	int ret;
@@ -341,22 +340,14 @@ int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	if (!(h->vm_flags & VM_WRITE))
 		shmflg |= SHM_RDONLY;
 
-	/*
-	 * FIX: do_shmat() has limited interface: all-or-nothing
-	 * mapping. If the vma, however, reflects a partial mapping
-	 * then we need to modify that function to accomplish the
-	 * desired outcome.  Partial mapping can exist due to the user
-	 * call shmat() and then unmapping part of the region.
-	 * Currently, we at least detect this and call it a foul play.
-	 */
-	if (((h->vm_end - h->vm_start) != h->ino_size) || h->vm_pgoff)
-		return -ENOSYS;
+	/* just another sanity check; rest is done by do_shmat */
+	if (h->ino_size != i_size_read(file->f_dentry->d_inode))
+		return -EINVAL;
 
-	old_fs = get_fs();
-	set_fs(get_ds());
-	start = h->vm_start;
-	ret = do_shmat(shmid, (char __user *) start, shmflg, &addr);
-	set_fs(old_fs);
+	/* do_shmat() below handles partial and offset mapping */
+	start = (unsigned long) h->vm_start;
+	ret = do_shmat_pgoff(shmid, (char __user *) start, shmflg,
+			     &addr, h->vm_end - h->vm_start, h->vm_pgoff);
 
 	BUG_ON(ret >= 0 && addr != h->vm_start);
 	return ret;
@@ -887,11 +878,13 @@ out:
  * "raddr" thing points to kernel space, and there has to be a wrapper around
  * this.
  */
-long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
+long do_shmat_pgoff(int shmid, char __user *shmaddr, int shmflg,
+		    ulong *raddr, ulong shmsize, ulong shmpgoff)
 {
 	struct shmid_kernel *shp;
 	unsigned long addr;
 	unsigned long size;
+	unsigned long pgoff;
 	struct file * file;
 	int    err;
 	unsigned long flags;
@@ -963,6 +956,17 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 	size = i_size_read(path.dentry->d_inode);
 	shm_unlock(shp);
 
+	pgoff = 0;
+
+	err = -EINVAL;
+	if (shmsize) {
+		if (shmpgoff + shmsize > size ||
+		    shmpgoff + shmsize < shmpgoff)
+			goto out_put_dentry;
+		size = shmsize;
+		pgoff = shmpgoff;
+	}
+
 	err = -ENOMEM;
 	sfd = kzalloc(sizeof(*sfd), GFP_KERNEL);
 	if (!sfd)
@@ -996,7 +1000,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
 			goto invalid;
 	}
 		
-	user_addr = do_mmap (file, addr, size, prot, flags, 0);
+	user_addr = do_mmap (file, addr, size, prot, flags, pgoff);
 	*raddr = user_addr;
 	err = 0;
 	if (IS_ERR_VALUE(user_addr))
@@ -1032,6 +1036,16 @@ out_put_dentry:
 	goto out_nattch;
 }
 
+/*
+ * NOTE! Despite the name, this is NOT a direct system call entrypoint. The
+ * "raddr" thing points to kernel space, and there has to be a wrapper around
+ * this.
+ */
+long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
+{
+	return do_shmat_pgoff(shmid, shmaddr, shmflg, raddr, 0, 0);
+}
+
 SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
 {
 	unsigned long ret;
-- 
1.7.0.4
