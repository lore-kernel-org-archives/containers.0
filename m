From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 18/30] cr: restore vDSO on i386/x86_64
Date: Fri, 10 Apr 2009 06:37:52 +0400
Message-ID: <20090410023752.GS27788__28413.458975456$1239331975$gmane$org@x200.localdomain>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

FIXME: check VMA has same parameters.
FIXME: abort if target kernel has vDSO disabled (?)
FIXME: restore pages, vDSO is writable after all.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 arch/x86/vdso/vdso32-setup.c |    6 ++
 include/linux/cr.h           |   11 +++++
 include/linux/mm.h           |    5 +-
 kernel/cr/cr-mm.c            |   87 +++++++++++++++++++++++++++++++++++++++++++
 mm/mmap.c                    |    3 +
 5 files changed, 110 insertions(+), 2 deletions(-)

--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -328,6 +328,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, unsigned long start,
 
 	map_compat_vdso(compat);
 
+	if (start) {
+		addr = start;
+		goto map;
+	}
 	if (compat)
 		addr = VDSO_HIGH_BASE;
 	else {
@@ -337,7 +341,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, unsigned long start,
 			goto up_fail;
 		}
 	}
-
+map:
 	if (compat_uses_vma || !compat) {
 		/*
 		 * MAYWRITE to allow gdb to COW and set breakpoints
--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -34,6 +34,7 @@ struct cr_object_header {
 #define CR_OBJ_FILE		3
 #define CR_OBJ_VMA		4
 #define CR_OBJ_VMA_CONTENT	5
+#define CR_OBJ_VMA_VDSO		6
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -177,6 +178,16 @@ struct cr_image_vma {
 	cr_pos_t	cr_pos_vm_file;
 } __packed;
 
+struct cr_image_vma_vdso {
+	struct cr_object_header cr_hdr;
+
+	__u64		cr_vm_start;
+	__u64		cr_vm_end;
+	__u64		cr_vm_page_prot;
+	__u64		cr_vm_flags;
+	__u64		cr_vm_pgoff;
+} __packed;
+
 struct cr_image_vma_content {
 	struct cr_object_header cr_hdr;
 
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1129,7 +1129,10 @@ extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
-
+#ifdef CONFIG_CR
+struct cr_context;
+int special_mapping_checkpoint(struct vm_area_struct *vma, struct cr_context *ctx);
+#endif
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
--- a/kernel/cr/cr-mm.c
+++ b/kernel/cr/cr-mm.c
@@ -332,6 +332,88 @@ static int cr_restore_vma(struct cr_context *ctx, loff_t pos)
 	return cr_restore_vma_content(ctx, pos + sizeof(*i));
 }
 
+#ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
+int special_mapping_checkpoint(struct vm_area_struct *vma, struct cr_context *ctx)
+{
+	struct cr_image_vma *i;
+	struct page **page;
+	unsigned long addr;
+	int rv;
+
+	i = cr_prepare_image(CR_OBJ_VMA_VDSO, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_vm_start = vma->vm_start;
+	i->cr_vm_end = vma->vm_end;
+	i->cr_vm_page_prot = vma->vm_page_prot.pgprot;
+	i->cr_vm_flags = vma->vm_flags;
+	i->cr_vm_pgoff = vma->vm_pgoff;
+
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	if (rv < 0)
+		return rv;
+
+	page = vma->vm_private_data;
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
+		struct cr_image_vma_content i;
+		void *data;
+
+		i.cr_hdr.cr_type = CR_OBJ_VMA_CONTENT;
+		i.cr_hdr.cr_len = sizeof(i) + 1 * PAGE_SIZE;
+
+		i.cr_start_addr = addr;
+		i.cr_nr_pages = 1;
+		i.cr_page_size = PAGE_SIZE;
+		rv = cr_write(ctx, &i, sizeof(i));
+		if (rv < 0)
+			return rv;
+		data = kmap(page[(addr - vma->vm_start) / PAGE_SIZE]);
+		rv = cr_write(ctx, data, 1 * PAGE_SIZE);
+		kunmap(page[(addr - vma->vm_start) / PAGE_SIZE]);
+		if (rv < 0)
+			return rv;
+	}
+	printk("dump vDSO: %08lx-%08lx, rv %d\n", vma->vm_start, vma->vm_end, rv);
+	return 0;
+}
+
+static int cr_restore_vma_vdso(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_vma_vdso *i;
+	int rv;
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	rv = cr_pread(ctx, i, sizeof(*i), pos);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+	if (i->cr_hdr.cr_type != CR_OBJ_VMA_VDSO) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	rv = arch_setup_additional_pages(NULL, i->cr_vm_start, 0);
+	printk("restore vDSO: %08lx, rv %d\n", (unsigned long)i->cr_vm_start, rv);
+	kfree(i);
+	return rv;
+}
+#else
+int special_mapping_checkpoint(struct vm_area_struct *vma, struct cr_context *ctx)
+{
+	return -EINVAL;
+}
+
+static int cr_restore_vma_vdso(struct cr_context *ctx, loff_t pos)
+{
+	return -EINVAL;
+}
+#endif
+
 static int cr_restore_all_vma(struct cr_context *ctx, loff_t pos)
 {
 	struct cr_object_header cr_hdr;
@@ -347,6 +429,11 @@ static int cr_restore_all_vma(struct cr_context *ctx, loff_t pos)
 			if (rv < 0)
 				return rv;
 			break;
+		case CR_OBJ_VMA_VDSO:
+			rv = cr_restore_vma_vdso(ctx, pos);
+			if (rv < 0)
+				return rv;
+			break;
 		case CR_OBJ_VMA_CONTENT:
 			break;
 		default:
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2257,6 +2257,9 @@ static void special_mapping_close(struct vm_area_struct *vma)
 static struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
 	.fault = special_mapping_fault,
+#ifdef CONFIG_CR
+	.checkpoint = special_mapping_checkpoint,
+#endif
 };
 
 /*
