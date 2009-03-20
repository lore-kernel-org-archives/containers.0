From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc][PATCH 18/23] Prepare to support shared memory
Date: Fri, 20 Mar 2009 14:47:43 -0400
Message-ID: <1237574868-3371-19-git-send-email-orenl@cs.columbia.edu>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237574868-3371-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

Export stuff from shared memory code that will be used in the next two
patches to provide support for checkpoint/restart of shared memory.

mm/shmem.c:
- shmem_getpage() and 'enum sgp_type'
- struct vm_operations_struct shmem_vm_ops

ipc/shm.c:
- struct vm_operations_struct shm_vm_ops

Changelog[v14]:
  - Introduce patch

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint_mem.h |   18 ++++++++++++++++++
 ipc/shm.c                   |    4 ++--
 mm/shmem.c                  |   12 ++++++------
 3 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/checkpoint/checkpoint_mem.h b/checkpoint/checkpoint_mem.h
index de1d4c8..3157dde 100644
--- a/checkpoint/checkpoint_mem.h
+++ b/checkpoint/checkpoint_mem.h
@@ -43,4 +43,22 @@ static inline int cr_pgarr_nr_free(struct cr_pgarr *pgarr)
 	return CR_PGARR_TOTAL - pgarr->nr_used;
 }
 
+/*
+ * This probably belongs in include/linux/mm.h
+ */
+
+/* Flag allocation requirements to shmem_getpage and shmem_swp_alloc */
+enum sgp_type {
+	SGP_READ,	/* don't exceed i_size, don't allocate page */
+	SGP_CACHE,	/* don't exceed i_size, may allocate page */
+	SGP_DIRTY,	/* like SGP_CACHE, but set new page dirty */
+	SGP_WRITE,	/* may exceed i_size, may allocate page */
+};
+
+int shmem_getpage(struct inode *inode, unsigned long idx,
+		  struct page **pagep, enum sgp_type sgp, int *type);
+
+extern struct vm_operations_struct shmem_vm_ops;
+extern struct vm_operations_struct shm_vm_ops;
+
 #endif /* _CHECKPOINT_CKPT_MEM_H_ */
diff --git a/ipc/shm.c b/ipc/shm.c
index 05d51d2..719f329 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -54,7 +54,7 @@ struct shm_file_data {
 #define shm_file_data(file) (*((struct shm_file_data **)&(file)->private_data))
 
 static const struct file_operations shm_file_operations;
-static struct vm_operations_struct shm_vm_ops;
+struct vm_operations_struct shm_vm_ops;
 
 #define shm_ids(ns)	((ns)->ids[IPC_SHM_IDS])
 
@@ -311,7 +311,7 @@ static const struct file_operations shm_file_operations = {
 	.get_unmapped_area	= shm_get_unmapped_area,
 };
 
-static struct vm_operations_struct shm_vm_ops = {
+struct vm_operations_struct shm_vm_ops = {
 	.open	= shm_open,	/* callback for a new vm-area open */
 	.close	= shm_close,	/* callback for when the vm-area is released */
 	.fault	= shm_fault,
diff --git a/mm/shmem.c b/mm/shmem.c
index 4103a23..e5abf26 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -103,8 +103,8 @@ static unsigned long shmem_default_max_inodes(void)
 }
 #endif
 
-static int shmem_getpage(struct inode *inode, unsigned long idx,
-			 struct page **pagep, enum sgp_type sgp, int *type);
+int shmem_getpage(struct inode *inode, unsigned long idx,
+		  struct page **pagep, enum sgp_type sgp, int *type);
 
 static inline struct page *shmem_dir_alloc(gfp_t gfp_mask)
 {
@@ -203,7 +203,7 @@ static const struct file_operations shmem_file_operations;
 static const struct inode_operations shmem_inode_operations;
 static const struct inode_operations shmem_dir_inode_operations;
 static const struct inode_operations shmem_special_inode_operations;
-static struct vm_operations_struct shmem_vm_ops;
+struct vm_operations_struct shmem_vm_ops;
 
 static struct backing_dev_info shmem_backing_dev_info  __read_mostly = {
 	.ra_pages	= 0,	/* No readahead */
@@ -1187,8 +1187,8 @@ static inline struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
  * vm. If we swap it in we mark it dirty since we also free the swap
  * entry since a page cannot live in both the swap and page cache
  */
-static int shmem_getpage(struct inode *inode, unsigned long idx,
-			struct page **pagep, enum sgp_type sgp, int *type)
+int shmem_getpage(struct inode *inode, unsigned long idx,
+		  struct page **pagep, enum sgp_type sgp, int *type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -2482,7 +2482,7 @@ static const struct super_operations shmem_ops = {
 	.put_super	= shmem_put_super,
 };
 
-static struct vm_operations_struct shmem_vm_ops = {
+struct vm_operations_struct shmem_vm_ops = {
 	.fault		= shmem_fault,
 #ifdef CONFIG_NUMA
 	.set_policy     = shmem_set_policy,
-- 
1.5.4.3
