From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 30/30] cr: ipc_ns
Date: Fri, 10 Apr 2009 06:41:06 +0400
Message-ID: <20090410024106.GE27788__30802.346909377$1239332036$gmane$org@x200.localdomain>
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

Create/restore ipc_ns as an object, restore sysctl values.

FIXME: restoration of sysctls is buggy as-is, values should be written
	at the very last moment
FIXME: actual restoration of IPC objects.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h     |   14 +++++
 kernel/cr/Kconfig      |    1 
 kernel/cr/Makefile     |    1 
 kernel/cr/cpt-sys.c    |    6 ++
 kernel/cr/cr-ipc.c     |  132 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr-nsproxy.c |    6 ++
 kernel/cr/cr.h         |   27 ++++++++++
 7 files changed, 187 insertions(+)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -52,6 +52,7 @@ struct cr_object_header {
 #define CR_OBJ_NET_NS		21
 #define CR_OBJ_SOCK		22
 #define CR_OBJ_TTY		23
+#define CR_OBJ_IPC_NS		24
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -180,6 +181,7 @@ struct cr_image_nsproxy {
 	struct cr_object_header cr_hdr;
 
 	cr_pos_t	cr_pos_uts_ns;
+	cr_pos_t	cr_pos_ipc_ns;	/* CR_POS_UNDEF if CONFIG_SYSVIPC=n */
 	cr_pos_t	cr_pos_mnt_ns;
 	cr_pos_t	cr_pos_pid_ns;
 	cr_pos_t	cr_pos_net_ns;	/* CR_POS_UNDEF if CONFIG_NET=n */
@@ -418,4 +420,16 @@ struct cr_image_tty {
 	__u8		cr_low_latency;
 	__u8		cr_ctrl_status;
 } __packed;
+
+struct cr_image_ipc_ns {
+	struct cr_object_header cr_hdr;
+
+	__u32		cr_sem_ctls[4];
+	__u32		cr_msg_ctlmax;
+	__u32		cr_msg_ctlmnb;
+	__u32		cr_msg_ctlmni;
+	__u64		cr_shm_ctlmax;
+	__u64		cr_shm_ctlall;
+	__u32		cr_shm_ctlmni;
+} __packed;
 #endif
--- a/kernel/cr/Kconfig
+++ b/kernel/cr/Kconfig
@@ -1,6 +1,7 @@
 config CR
 	bool "Container checkpoint/restart"
 	depends on DEVPTS_MULTIPLE_INSTANCES
+	depends on IPC_NS || (SYSVIPC = n)
 	depends on NET_NS || (NET = n)
 	depends on PID_NS
 	depends on USER_NS
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -4,6 +4,7 @@ cr-y += cr-context.o
 cr-y += cr-cred.o
 cr-y += cr-file.o
 cr-y += cr-fs.o
+cr-y += cr-ipc.o
 cr-y += cr-mm.o
 cr-y += cr-mnt.o
 cr-$(CONFIG_NET) += cr-net.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -71,6 +71,9 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_uts_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_ipc_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_mnt_ns(ctx);
 	if (rv < 0)
 		return rv;
@@ -194,6 +197,9 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_sock(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_ipc_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_sighand_struct(ctx);
 	if (rv < 0)
 		return rv;
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-ipc.c
@@ -0,0 +1,132 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fs.h>
+#include <linux/ipc_namespace.h>
+#include <linux/nsproxy.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_collect_ipc_ns(struct cr_context *ctx, struct ipc_namespace *ipc_ns)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, ipc_ns, CR_CTX_IPC_NS);
+	printk("collect ipc_ns %p: rv %d\n", ipc_ns, rv);
+	return rv;
+}
+
+int cr_collect_all_ipc_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = cr_collect_ipc_ns(ctx, nsproxy->ipc_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_IPC_NS) {
+		struct ipc_namespace *ipc_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&ipc_ns->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: ipc_ns %p has external references %lu:%u\n", __func__, ipc_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_ipc_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct ipc_namespace *ipc_ns = obj->o_obj;
+	struct cr_image_ipc_ns *i;
+	int rv;
+
+	printk("dump ipc_ns %p\n", ipc_ns);
+
+	i = cr_prepare_image(CR_OBJ_IPC_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	BUILD_BUG_ON(ARRAY_SIZE(ipc_ns->sem_ctls) != 4);
+	i->cr_sem_ctls[0] = ipc_ns->sem_ctls[0];
+	i->cr_sem_ctls[1] = ipc_ns->sem_ctls[1];
+	i->cr_sem_ctls[2] = ipc_ns->sem_ctls[2];
+	i->cr_sem_ctls[3] = ipc_ns->sem_ctls[3];
+	i->cr_msg_ctlmax = ipc_ns->msg_ctlmax;
+	i->cr_msg_ctlmnb = ipc_ns->msg_ctlmnb;
+	i->cr_msg_ctlmni = ipc_ns->msg_ctlmni;
+	i->cr_shm_ctlmax = ipc_ns->shm_ctlmax;
+	i->cr_shm_ctlall = ipc_ns->shm_ctlall;
+	i->cr_shm_ctlmni = ipc_ns->shm_ctlmni;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_ipc_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_IPC_NS) {
+		rv = cr_dump_ipc_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int cr_restore_ipc_ns(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_ipc_ns *i;
+	struct ipc_namespace *ipc_ns;
+	struct cr_object *obj;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_IPC_NS) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	ipc_ns = create_ipc_ns();
+	if (!ipc_ns) {
+		kfree(i);
+		return -ENOMEM;
+	}
+
+	ipc_ns->sem_ctls[0] = i->cr_sem_ctls[0];
+	ipc_ns->sem_ctls[1] = i->cr_sem_ctls[1];
+	ipc_ns->sem_ctls[2] = i->cr_sem_ctls[2];
+	ipc_ns->sem_ctls[3] = i->cr_sem_ctls[3];
+	ipc_ns->msg_ctlmax = i->cr_msg_ctlmax;
+	ipc_ns->msg_ctlmnb = i->cr_msg_ctlmnb;
+	ipc_ns->msg_ctlmni = i->cr_msg_ctlmni;
+	ipc_ns->shm_ctlmax = i->cr_shm_ctlmax;
+	ipc_ns->shm_ctlall = i->cr_shm_ctlall;
+	ipc_ns->shm_ctlmni = i->cr_shm_ctlmni;
+	kfree(i);
+
+	obj = cr_object_create(ipc_ns);
+	if (!obj) {
+		put_ipc_ns(ipc_ns);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_IPC_NS]);
+	printk("restore ipc_ns %p, pos %lld\n", ipc_ns, (long long)pos);
+	return 0;
+}
--- a/kernel/cr/cr-nsproxy.c
+++ b/kernel/cr/cr-nsproxy.c
@@ -59,6 +59,12 @@ static int cr_dump_nsproxy(struct cr_context *ctx, struct cr_object *obj)
 
 	tmp = cr_find_obj_by_ptr(ctx, nsproxy->uts_ns, CR_CTX_UTS_NS);
 	i->cr_pos_uts_ns = tmp->o_pos;
+#ifdef CONFIG_SYSVIPC
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->ipc_ns, CR_CTX_IPC_NS);
+	i->cr_pos_ipc_ns = tmp->o_pos;
+#else
+	i->cr_pos = CR_POS_UNDEF;
+#endif
 	tmp = cr_find_obj_by_ptr(ctx, nsproxy->mnt_ns, CR_CTX_MNT_NS);
 	i->cr_pos_mnt_ns = tmp->o_pos;
 	tmp = cr_find_obj_by_ptr(ctx, nsproxy->pid_ns, CR_CTX_PID_NS);
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -28,6 +28,9 @@ enum cr_context_obj_type {
 	CR_CTX_FILES_STRUCT,
 	CR_CTX_FS_STRUCT,
 	CR_CTX_GROUP_INFO,
+#ifdef CONFIG_SYSVIPC
+	CR_CTX_IPC_NS,
+#endif
 	CR_CTX_MM_STRUCT,
 	CR_CTX_MNT_NS,
 #ifdef CONFIG_NET
@@ -103,6 +106,14 @@ int cr_collect_all_files_struct(struct cr_context *ctx);
 int cr_collect_all_file(struct cr_context *ctx);
 int cr_collect_all_fs_struct(struct cr_context *ctx);
 int cr_collect_all_group_info(struct cr_context *ctx);
+#ifdef CONFIG_SYSVIPC
+int cr_collect_all_ipc_ns(struct cr_context *ctx);
+#else
+static inline int cr_collect_all_ipc_ns(struct cr_context *ctx)
+{
+	return 0;
+}
+#endif
 int cr_collect_all_mm_struct(struct cr_context *ctx);
 int cr_collect_all_mnt_ns(struct cr_context *ctx);
 #ifdef CONFIG_NET
@@ -137,6 +148,14 @@ int cr_dump_all_files_struct(struct cr_context *ctx);
 int cr_dump_all_file(struct cr_context *ctx);
 int cr_dump_all_fs_struct(struct cr_context *ctx);
 int cr_dump_all_group_info(struct cr_context *ctx);
+#ifdef CONFIG_SYSVIPC
+int cr_dump_all_ipc_ns(struct cr_context *ctx);
+#else
+static inline int cr_dump_all_ipc_ns(struct cr_context *ctx)
+{
+	return 0;
+}
+#endif
 int cr_dump_all_mm_struct(struct cr_context *ctx);
 int cr_dump_all_mnt_ns(struct cr_context *ctx);
 #ifdef CONFIG_NET
@@ -171,6 +190,14 @@ int cr_restore_files_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_file(struct cr_context *ctx, loff_t pos);
 int cr_restore_fs_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_group_info(struct cr_context *ctx, loff_t pos);
+#ifdef CONFIG_SYSVIPC
+int cr_restore_ipc_ns(struct cr_context *ctx, loff_t pos);
+#else
+static inline int cr_restore_ipc_ns(struct cr_context *ctx, loff_t pos)
+{
+	return 0;
+}
+#endif
 int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_mnt_ns(struct cr_context *ctx, loff_t pos);
 #ifdef CONFIG_NET
