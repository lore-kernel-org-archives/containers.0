From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 20/30] cr: deal with UTS stuff (struct uts_namespace)
Date: Fri, 10 Apr 2009 06:38:24 +0400
Message-ID: <20090410023824.GU27788__1839.90998561985$1239331984$gmane$org@x200.localdomain>
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

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h     |   14 +++++
 kernel/cr/Kconfig      |    1 
 kernel/cr/Makefile     |    1 
 kernel/cr/cpt-sys.c    |    6 ++
 kernel/cr/cr-nsproxy.c |   21 +++++++-
 kernel/cr/cr-uts.c     |  123 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr.h         |    4 +
 7 files changed, 167 insertions(+), 3 deletions(-)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -36,6 +36,7 @@ struct cr_object_header {
 #define CR_OBJ_VMA_CONTENT	5
 #define CR_OBJ_VMA_VDSO		6
 #define CR_OBJ_NSPROXY		7
+#define CR_OBJ_UTS_NS		8
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -150,6 +151,19 @@ struct cr_image_arch_x86_64 {
 
 struct cr_image_nsproxy {
 	struct cr_object_header cr_hdr;
+
+	cr_pos_t	cr_pos_uts_ns;
+} __packed;
+
+struct cr_image_uts_ns {
+	struct cr_object_header cr_hdr;
+
+	__u8		cr_sysname[64];
+	__u8		cr_nodename[64];
+	__u8		cr_release[64];
+	__u8		cr_version[64];
+	__u8		cr_machine[64];
+	__u8		cr_domainname[64];
 } __packed;
 
 struct cr_image_mm_struct {
--- a/kernel/cr/Kconfig
+++ b/kernel/cr/Kconfig
@@ -1,5 +1,6 @@
 config CR
 	bool "Container checkpoint/restart"
+	depends on UTS_NS
 	select FREEZER
 	help
 	  Container checkpoint/restart.
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -5,5 +5,6 @@ cr-y += cr-file.o
 cr-y += cr-mm.o
 cr-y += cr-nsproxy.o
 cr-y += cr-task.o
+cr-y += cr-uts.o
 cr-$(CONFIG_X86_32) += cr-x86_32.o
 cr-$(CONFIG_X86_64) += cr-x86_64.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -68,6 +68,9 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_nsproxy(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_uts_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -110,6 +113,9 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_file(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_uts_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
--- a/kernel/cr/cr-nsproxy.c
+++ b/kernel/cr/cr-nsproxy.c
@@ -48,6 +48,7 @@ static int cr_dump_nsproxy(struct cr_context *ctx, struct cr_object *obj)
 {
 	struct nsproxy *nsproxy = obj->o_obj;
 	struct cr_image_nsproxy	*i;
+	struct cr_object *tmp;
 	int rv;
 
 	printk("dump nsproxy %p\n", nsproxy);
@@ -56,6 +57,9 @@ static int cr_dump_nsproxy(struct cr_context *ctx, struct cr_object *obj)
 	if (!i)
 		return -ENOMEM;
 
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->uts_ns, CR_CTX_UTS_NS);
+	i->cr_pos_uts_ns = tmp->o_pos;
+
 	obj->o_pos = ctx->cr_dump_file->f_pos;
 	rv = cr_write(ctx, i, sizeof(*i));
 	kfree(i);
@@ -79,7 +83,8 @@ static int __cr_restore_nsproxy(struct cr_context *ctx, loff_t pos)
 {
 	struct cr_image_nsproxy *i;
 	struct nsproxy *nsproxy;
-	struct cr_object *obj;
+	struct uts_namespace *uts_ns;
+	struct cr_object *obj, *tmp;
 	int rv;
 
 	i = kzalloc(sizeof(*i), GFP_KERNEL);
@@ -101,8 +106,18 @@ static int __cr_restore_nsproxy(struct cr_context *ctx, loff_t pos)
 		return -ENOMEM;
 	}
 
-	get_uts_ns(&init_uts_ns);
-	nsproxy->uts_ns = &init_uts_ns;
+	tmp = cr_find_obj_by_pos(ctx, i->cr_pos_uts_ns, CR_CTX_UTS_NS);
+	if (!tmp) {
+		rv = cr_restore_uts_ns(ctx, i->cr_pos_uts_ns);
+		if (rv < 0) {
+			kfree(i);
+			return rv;
+		}
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_uts_ns, CR_CTX_UTS_NS);
+	}
+	uts_ns = tmp->o_obj;
+	get_uts_ns(uts_ns);
+	nsproxy->uts_ns = uts_ns;
 
 #ifdef CONFIG_SYSVIPC
 	get_ipc_ns(&init_ipc_ns);
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-uts.c
@@ -0,0 +1,123 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fs.h>
+#include <linux/utsname.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_collect_uts_ns(struct cr_context *ctx, struct uts_namespace *uts_ns)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, uts_ns, CR_CTX_UTS_NS);
+	printk("collect uts_ns %p: rv %d\n", uts_ns, rv);
+	return rv;
+}
+
+int cr_collect_all_uts_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = cr_collect_uts_ns(ctx, nsproxy->uts_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_UTS_NS) {
+		struct uts_namespace *uts_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&uts_ns->kref.refcount);
+
+		if (obj->o_count != cnt) {
+			printk("%s: uts_ns %p has external references %lu:%u\n", __func__, uts_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_uts_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct uts_namespace *uts_ns = obj->o_obj;
+	struct cr_image_uts_ns *i;
+	int rv;
+
+	printk("dump uts_ns %p\n", uts_ns);
+
+	i = cr_prepare_image(CR_OBJ_UTS_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	strncpy((char *)i->cr_sysname, (const char *)uts_ns->name.sysname, 64);
+	strncpy((char *)i->cr_nodename, (const char *)uts_ns->name.nodename, 64);
+	strncpy((char *)i->cr_release, (const char *)uts_ns->name.release, 64);
+	strncpy((char *)i->cr_version, (const char *)uts_ns->name.version, 64);
+	strncpy((char *)i->cr_machine, (const char *)uts_ns->name.machine, 64);
+	strncpy((char *)i->cr_domainname, (const char *)uts_ns->name.domainname, 64);
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_uts_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_UTS_NS) {
+		rv = cr_dump_uts_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int cr_restore_uts_ns(struct cr_context *ctx, loff_t pos)
+{
+	struct uts_namespace *uts_ns;
+	struct cr_image_uts_ns *i;
+	struct cr_object *obj;
+	int rv;
+
+	i = kzalloc(sizeof(struct cr_image_uts_ns), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	rv = cr_pread(ctx, i, sizeof(*i), pos);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+	if (i->cr_hdr.cr_type != CR_OBJ_UTS_NS) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	uts_ns = kzalloc(sizeof(struct uts_namespace), GFP_KERNEL);
+	if (!uts_ns) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	kref_init(&uts_ns->kref);
+
+	strlcpy(uts_ns->name.sysname, (const char *)i->cr_sysname, sizeof(uts_ns->name.sysname));
+	strlcpy(uts_ns->name.nodename, (const char *)i->cr_nodename, sizeof(uts_ns->name.nodename));
+	strlcpy(uts_ns->name.release, (const char *)i->cr_release, sizeof(uts_ns->name.release));
+	strlcpy(uts_ns->name.version, (const char *)i->cr_version, sizeof(uts_ns->name.version));
+	strlcpy(uts_ns->name.machine, (const char *)i->cr_machine, sizeof(uts_ns->name.machine));
+	strlcpy(uts_ns->name.domainname, (const char *)i->cr_domainname, sizeof(uts_ns->name.domainname));
+	kfree(i);
+
+	obj = cr_object_create(uts_ns);
+	if (!obj) {
+		kfree(uts_ns);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_UTS_NS]);
+	printk("restore uts_ns %p, pos %lld\n", uts_ns, (long long)pos);
+	return 0;
+}
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -26,6 +26,7 @@ enum cr_context_obj_type {
 	CR_CTX_MM_STRUCT,
 	CR_CTX_NSPROXY,
 	CR_CTX_TASK_STRUCT,
+	CR_CTX_UTS_NS,
 	NR_CR_CTX_TYPES
 };
 
@@ -71,16 +72,19 @@ int cr_collect_all_file(struct cr_context *ctx);
 int cr_collect_all_mm_struct(struct cr_context *ctx);
 int cr_collect_all_nsproxy(struct cr_context *ctx);
 int cr_collect_all_task_struct(struct cr_context *ctx);
+int cr_collect_all_uts_ns(struct cr_context *ctx);
 
 int cr_dump_all_file(struct cr_context *ctx);
 int cr_dump_all_mm_struct(struct cr_context *ctx);
 int cr_dump_all_nsproxy(struct cr_context *ctx);
 int cr_dump_all_task_struct(struct cr_context *ctx);
+int cr_dump_all_uts_ns(struct cr_context *ctx);
 
 int cr_restore_file(struct cr_context *ctx, loff_t pos);
 int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_nsproxy(struct cr_context *ctx, loff_t pos);
 int cr_restore_task_struct(struct cr_context *ctx, loff_t pos);
+int cr_restore_uts_ns(struct cr_context *ctx, loff_t pos);
 
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 __u32 cr_image_header_arch(void);
