From: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
Date: Thu, 13 May 2010 17:51:25 +0800
Message-ID: <1273744285-8128-1-git-send-email-xiaosuo__15165.0491323837$1273744482$gmane$org@gmail.com>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>, Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "James E.J. Bottomley" <James.Bottomley-l3A5Bk7waGM@public.gmane.org>, Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

generic adaptive large memory allocation APIs

kv*alloc are used to allocate large contiguous memory and the users don't mind
whether the memory is physically or virtually contiguous. The allocator always
try its best to allocate physically contiguous memory first.

In this patch set, some APIs are introduced: kvmalloc(), kvzalloc(), kvcalloc(),
kvrealloc(), kvfree() and kvfree_inatomic().

Signed-off-by: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
----
 include/linux/mm.h      |   31 ++++++++++++++
 include/linux/vmalloc.h |    1 
 mm/nommu.c              |    6 ++
 mm/util.c               |  104 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmalloc.c            |   14 ++++++
 5 files changed, 156 insertions(+)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 462acaf..0ece978 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1467,5 +1467,36 @@ extern int soft_offline_page(struct page *page, int flags);
 
 extern void dump_page(struct page *page);
 
+void *__kvmalloc(size_t size, gfp_t flags);
+
+static inline void *kvmalloc(size_t size)
+{
+	return __kvmalloc(size, 0);
+}
+
+static inline void *kvzalloc(size_t size)
+{
+	return __kvmalloc(size, __GFP_ZERO);
+}
+
+static inline void *kvcalloc(size_t n, size_t size)
+{
+	return __kvmalloc(n * size, __GFP_ZERO);
+}
+
+void __kvfree(void *ptr, bool inatomic);
+
+static inline void kvfree(void *ptr)
+{
+	__kvfree(ptr, false);
+}
+
+static inline void kvfree_inatomic(void *ptr)
+{
+	__kvfree(ptr, true);
+}
+
+void *kvrealloc(void *ptr, size_t newsize);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 227c2a5..33ec828 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -60,6 +60,7 @@ extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
 extern void *__vmalloc_area(struct vm_struct *area, gfp_t gfp_mask,
 				pgprot_t prot);
 extern void vfree(const void *addr);
+extern unsigned long vsize(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
diff --git a/mm/nommu.c b/mm/nommu.c
index 63fa17d..1ddf3fe 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -223,6 +223,12 @@ void vfree(const void *addr)
 }
 EXPORT_SYMBOL(vfree);
 
+unsigned long vsize(const void *addr)
+{
+	return ksize(addr);
+}
+EXPORT_SYMBOL(vsize);
+
 void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 {
 	/*
diff --git a/mm/util.c b/mm/util.c
index f5712e8..7cc364a 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -5,6 +5,7 @@
 #include <linux/err.h>
 #include <linux/sched.h>
 #include <asm/uaccess.h>
+#include <linux/vmalloc.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/kmem.h>
@@ -289,6 +290,109 @@ int __attribute__((weak)) get_user_pages_fast(unsigned long start,
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
+void *__kvmalloc(size_t size, gfp_t flags)
+{
+	void *ptr;
+
+	if (size < PAGE_SIZE)
+		return kmalloc(size, GFP_KERNEL | flags);
+	size = PAGE_ALIGN(size);
+	if (is_power_of_2(size))
+		ptr = (void *)__get_free_pages(GFP_KERNEL | flags |
+					       __GFP_NOWARN, get_order(size));
+	else
+		ptr = alloc_pages_exact(size, GFP_KERNEL | flags |
+					      __GFP_NOWARN);
+	if (ptr != NULL) {
+		virt_to_head_page(ptr)->private = size;
+		return ptr;
+	}
+
+	ptr = vmalloc(size);
+	if (ptr != NULL && (flags & __GFP_ZERO))
+		memset(ptr, 0, size);
+
+	return ptr;
+}
+EXPORT_SYMBOL(__kvmalloc);
+
+static void kvfree_work(struct work_struct *work)
+{
+	vfree(work);
+}
+
+void __kvfree(void *ptr, bool inatomic)
+{
+	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
+		return;
+	if (is_vmalloc_addr(ptr)) {
+		if (inatomic) {
+			struct work_struct *work;
+
+			work = ptr;
+			BUILD_BUG_ON(sizeof(struct work_struct) > PAGE_SIZE);
+			INIT_WORK(work, kvfree_work);
+			schedule_work(work);
+		} else {
+			vfree(ptr);
+		}
+	} else {
+		struct page *page;
+
+		page = virt_to_head_page(ptr);
+		if (PageSlab(page) || PageCompound(page))
+			kfree(ptr);
+		else if (is_power_of_2(page->private))
+			free_pages((unsigned long)ptr,
+				   get_order(page->private));
+		else
+			free_pages_exact(ptr, page->private);
+	}
+}
+EXPORT_SYMBOL(__kvfree);
+
+void *kvrealloc(void *ptr, size_t newsize)
+{
+	void *nptr;
+	size_t oldsize;
+
+	if (unlikely(!newsize)) {
+		kvfree(ptr);
+		return ZERO_SIZE_PTR;
+	}
+
+	if (unlikely(ZERO_OR_NULL_PTR(ptr)))
+		return kvmalloc(newsize);
+
+	if (is_vmalloc_addr(ptr)) {
+		oldsize = vsize(ptr);
+		if (newsize <= oldsize)
+			return ptr;
+	} else {
+		struct page *page;
+
+		page = virt_to_head_page(ptr);
+		if (PageSlab(page) || PageCompound(page)) {
+			if (newsize < PAGE_SIZE)
+				return krealloc(ptr, newsize, GFP_KERNEL);
+			oldsize = ksize(ptr);
+		} else {
+			oldsize = page->private;
+			if (newsize <= oldsize)
+				return ptr;
+		}
+	}
+
+	nptr = kvmalloc(newsize);
+	if (nptr != NULL) {
+		memcpy(nptr, ptr, oldsize);
+		kvfree(ptr);
+	}
+
+	return nptr;
+}
+EXPORT_SYMBOL(kvrealloc);
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ae00746..93552a8 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1413,6 +1413,20 @@ void vfree(const void *addr)
 EXPORT_SYMBOL(vfree);
 
 /**
+ *	vsize  -  get the actual amount of memory allocated by vmalloc()
+ *	@addr:		memory base address
+ */
+unsigned long vsize(const void *addr)
+{
+	struct vmap_area *va;
+
+	va = find_vmap_area((unsigned long)addr);
+
+	return va->va_end - va->va_start - PAGE_SIZE;
+}
+EXPORT_SYMBOL(vsize);
+
+/**
  *	vunmap  -  release virtual mapping obtained by vmap()
  *	@addr:		memory base address
  *
