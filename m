From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc2][PATCH 19/29] Record 'struct file' object instead of the
	file name for VMAs
Date: Tue, 31 Mar 2009 01:28:59 -0400
Message-ID: <1238477349-11029-20-git-send-email-orenl@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238477349-11029-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

The vma->vm_file can be an arbitrary file pointer, including one that
is in use by a process as well and provided originally via the mmap()
syscall.

Thus, when dumping the state of a VMA, save a file object instead
of only the file name. As with other file objects, if it's seen for
the first time it is dumped entirely, otherwise only the 'objref' is
saved. The restart logic updated accordingly.

Changelog[v14]:
  - Introduce patch

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c        |    5 +++
 checkpoint/ckpt_file.c         |    2 +-
 checkpoint/ckpt_mem.c          |   49 ++++++++++++++++---------
 checkpoint/rstr_file.c         |    2 +-
 checkpoint/rstr_mem.c          |   79 +++++++++++++++++++++++++++-------------
 include/linux/checkpoint.h     |    2 +
 include/linux/checkpoint_hdr.h |    2 +-
 7 files changed, 94 insertions(+), 47 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 7f5eee6..ef35754 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -118,6 +118,11 @@ int cr_write_fname(struct cr_ctx *ctx, struct path *path, struct path *root)
 	char *buf, *fname;
 	int ret, flen;
 
+	/*
+	 * FIXME: we can optimize and save memory (and storage) if we
+	 * share strings (through objhash) and reference them instead
+	 */
+
 	flen = PATH_MAX;
 	buf = kmalloc(flen, GFP_KERNEL);
 	if (!buf)
diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index dd26b3d..5de83ab 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -112,7 +112,7 @@ int generic_file_checkpoint(struct cr_ctx *ctx, struct file *file,
 }
 
 /* cr_write_file - dump the state of a given file pointer */
-static int cr_write_file(struct cr_ctx *ctx, struct file *file)
+int cr_write_file(struct cr_ctx *ctx, struct file *file)
 {
 	struct cr_hdr_file *hh;
 	int ret;
diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index 3d3c5f5..7a10e03 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -447,7 +447,10 @@ static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 {
 	struct cr_hdr h;
 	struct cr_hdr_vma *hh;
-	int vma_type, ret;
+	int vma_type;
+	int objref = 0;
+	int new = 0;
+	int ret;
 
 	h.type = CR_HDR_VMA;
 	h.len = sizeof(*hh);
@@ -467,36 +470,46 @@ static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 
 	if (vma->vm_flags & CR_BAD_VM_FLAGS) {
 		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
-		cr_hbuf_put(ctx, sizeof(*hh));
-		return -ENOSYS;
+		ret = -ENOSYS;
+		goto out;
 	}
 
-	/* by default assume anon memory */
-	vma_type = CR_VMA_ANON;
+	vma_type = CR_VMA_ANON;  /* by default assume anon memory */
 
-	/*
-	 * if there is a backing file, assume private-mapped
-	 * (FIXME: check if the file is unlinked)
-	 */
 	if (vma->vm_file)
-		vma_type = CR_VMA_FILE;
+		vma_type = CR_VMA_FILE;		/* assume private-mapped */
+
+	/* if file-backed, add 'file' to the hash (will keep a reference) */
+	if (vma->vm_file) {
+		new = cr_obj_add_ptr(ctx, vma->vm_file,
+				     &objref, CR_OBJ_FILE, 0);
+		cr_debug("vma %p objref %d file %p)\n",
+			 vma, objref, vma->vm_file);
+		if (new < 0) {
+			ret  = new;
+			goto out;
+		}
+	}
 
 	hh->vma_type = vma_type;
+	hh->vma_objref = objref;
 
 	ret = cr_write_obj(ctx, &h, hh);
-	cr_hbuf_put(ctx, sizeof(*hh));
 	if (ret < 0)
-		return ret;
+		goto out;
 
-	/* save the file name */
-	/* FIXME: files should be deposited and sought in the objhash */
-	if (vma->vm_file) {
-		ret = cr_write_fname(ctx, &vma->vm_file->f_path, &ctx->fs_mnt);
+	/* new==1 if-and-only-if file was newly added to hash */
+	if (new) {
+		ret = cr_write_file(ctx, vma->vm_file);
 		if (ret < 0)
-			return ret;
+			goto out;
 	}
 
-	return cr_write_private_vma_contents(ctx, vma);
+	ret = cr_write_private_vma_contents(ctx, vma);
+
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
 }
 
 int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
index db2fcf2..de260dc 100644
--- a/checkpoint/rstr_file.c
+++ b/checkpoint/rstr_file.c
@@ -232,7 +232,7 @@ static int cr_read_fd_generic(struct cr_ctx *ctx, struct cr_hdr_file *hh)
 #define CR_SETFL_MASK (O_APPEND|O_NONBLOCK|O_NDELAY|FASYNC|O_DIRECT|O_NOATIME)
 
 /* cr_read_file - restore the state of a given file pointer */
-static int cr_read_file(struct cr_ctx *ctx, int objref)
+int cr_read_file(struct cr_ctx *ctx, int objref)
 {
 	struct cr_hdr_file *hh;
 	struct file *file;
diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
index 003b391..a72189b 100644
--- a/checkpoint/rstr_mem.c
+++ b/checkpoint/rstr_mem.c
@@ -18,6 +18,7 @@
 #include <linux/mman.h>
 #include <linux/mm.h>
 #include <linux/err.h>
+#include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -204,6 +205,40 @@ static unsigned long cr_calc_map_flags_bits(unsigned long orig_vm_flags)
 	return vm_flags;
 }
 
+/*
+ * cr_vma_read_file - prepare a file object required for a vma
+ * @ctx - restart context
+ * @objref - objref of file object
+ *
+ * If the file object is found, will grab a reference to the pointer
+ * that the caller will need release.
+ */
+static struct file *cr_vma_read_file(struct cr_ctx *ctx, int objref)
+{
+	struct file *file;
+	int fd;
+
+	file = cr_obj_get_by_ref(ctx, objref, CR_OBJ_FILE);
+	if (IS_ERR(file))
+		return file;
+
+	/* if object found in objhash - use it */
+	if (file) {
+		get_file(file);
+		return file;
+	}
+
+	/* get (or construct) the respective file object */
+	fd = cr_read_file(ctx, objref);
+	if (fd < 0)
+		return ERR_PTR(fd);
+
+	file = fget(fd);
+	sys_close(fd);
+
+	return file;
+}
+
 /**
  * cr_read_vma - read vma data, recreate it and read contents
  * @ctx: checkpoint context
@@ -225,14 +260,16 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 		return -ENOMEM;
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
 	if (ret < 0)
-		goto err;
+		goto out;
 
 	cr_debug("vma %#lx-%#lx type %d\n", (unsigned long) hh->vm_start,
 		 (unsigned long) hh->vm_end, (int) hh->vma_type);
 
 	ret = -EINVAL;
 	if (hh->vm_end < hh->vm_start)
-		goto err;
+		goto out;
+	if (hh->vma_objref <= 0)
+		goto out;
 
 	vm_start = hh->vm_start;
 	vm_pgoff = hh->vm_pgoff;
@@ -241,13 +278,11 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 	vm_flags = cr_calc_map_flags_bits(hh->vm_flags);
 	vma_type = hh->vma_type;
 
-	cr_hbuf_put(ctx, sizeof(*hh));
-
 	switch (vma_type) {
 
 	case CR_VMA_ANON:		/* anonymous private mapping */
 		if (vm_flags & VM_SHARED)
-			goto err;
+			goto out;
 		/*
 		 * vm_pgoff for anonymous mapping is the "global" page
 		 * offset (namely from addr 0x0), so we force a zero
@@ -257,23 +292,20 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 
 	case CR_VMA_FILE:		/* private mapping from a file */
 		if (vm_flags & VM_SHARED)
-			goto err;
-		/*
-		 * for private mapping using 'read-only' is sufficient
-		 */
-		file = cr_read_open_fname(ctx, O_RDONLY, 0);
+			goto out;
+		file = cr_vma_read_file(ctx, hh->vma_objref);
 		if (IS_ERR(file)) {
 			ret = PTR_ERR(file);
-			goto err;
+			file = NULL;
+			goto out;
 		}
 		break;
 
 	default:
-		goto err;
+		goto out;
 
 	}
 
-
 	down_write(&mm->mmap_sem);
 	addr = do_mmap_pgoff(file, vm_start, vm_size,
 			     vm_prot, vm_flags, vm_pgoff);
@@ -281,12 +313,10 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 	cr_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
 		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
 
-	/* the file (if opened) is now referenced by the vma */
-	if (file)
-		filp_close(file, NULL);
-
-	if (IS_ERR((void *) addr))
-		return PTR_ERR((void *) addr);
+	if (IS_ERR((void *) addr)) {
+		ret = PTR_ERR((void *) addr);
+		goto out;
+	}
 
 	/*
 	 * CR_VMA_ANON: read in memory as is
@@ -302,14 +332,11 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 		break;
 	}
 
-	if (ret < 0)
-		return ret;
-
-	cr_debug("vma retval %d\n", ret);
-	return 0;
-
- err:
+ out:
+	if (file)
+		fput(file);
 	cr_hbuf_put(ctx, sizeof(*hh));
+	cr_debug("vma retval %d\n", ret);
 	return ret;
 }
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 3be3902..69d14c4 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -110,10 +110,12 @@ extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
 extern int do_checkpoint(struct cr_ctx *ctx, pid_t pid);
 extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t);
+extern int cr_write_file(struct cr_ctx *ctx, struct file *file);
 
 extern int do_restart(struct cr_ctx *ctx, pid_t pid);
 extern int cr_read_mm(struct cr_ctx *ctx);
 extern int cr_read_fd_table(struct cr_ctx *ctx);
+extern int cr_read_file(struct cr_ctx *ctx, int objref);
 
 #define cr_debug(fmt, args...)  \
 	pr_debug("[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__, ## args)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index ce5d880..8623d3b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -126,7 +126,7 @@ enum cr_vma_type {
 
 struct cr_hdr_vma {
 	__u32 vma_type;
-	__u32 _padding;
+	__u32 vma_objref;	/* for vma->vm_file */
 
 	__u64 vm_start;
 	__u64 vm_end;
-- 
1.5.4.3
