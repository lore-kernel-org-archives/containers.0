From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 27/30] cr: deal with netns
Date: Fri, 10 Apr 2009 06:40:19 +0400
Message-ID: <20090410024019.GB27788__3387.84898999638$1239332026$gmane$org@x200.localdomain>
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

netns is full of questions too.

Restore netns itself, and core.somaxconn, unix.max_dgram_qlen for start.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h     |   13 +++++
 kernel/cr/Kconfig      |    1 
 kernel/cr/Makefile     |    1 
 kernel/cr/cpt-sys.c    |    6 ++
 kernel/cr/cr-net.c     |  115 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr-nsproxy.c |   21 ++++++++
 kernel/cr/cr.h         |   27 +++++++++++
 7 files changed, 183 insertions(+), 1 deletion(-)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -49,6 +49,7 @@ struct cr_object_header {
 #define CR_OBJ_USER_STRUCT	18
 #define CR_OBJ_USER_NS		19
 #define CR_OBJ_MNT_NS		20
+#define CR_OBJ_NET_NS		21
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -179,6 +180,7 @@ struct cr_image_nsproxy {
 	cr_pos_t	cr_pos_uts_ns;
 	cr_pos_t	cr_pos_mnt_ns;
 	cr_pos_t	cr_pos_pid_ns;
+	cr_pos_t	cr_pos_net_ns;	/* CR_POS_UNDEF if CONFIG_NET=n */
 } __packed;
 
 struct cr_image_uts_ns {
@@ -360,4 +362,15 @@ struct cr_image_pid {
 	__u32		cr_level;
 	__u32		cr_nr[1];	/* cr_nr[cr_level + 1] */
 } __packed;
+
+struct cr_image_net_ns {
+	struct cr_object_header cr_hdr;
+
+	struct {
+		__u32	cr_sysctl_somaxconn;
+	} cr_core;
+	struct {
+		__u32	cr_sysctl_max_dgram_qlen;
+	} cr_unx;
+} __packed;
 #endif
--- a/kernel/cr/Kconfig
+++ b/kernel/cr/Kconfig
@@ -1,5 +1,6 @@
 config CR
 	bool "Container checkpoint/restart"
+	depends on NET_NS || (NET = n)
 	depends on PID_NS
 	depends on USER_NS
 	depends on UTS_NS
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -6,6 +6,7 @@ cr-y += cr-file.o
 cr-y += cr-fs.o
 cr-y += cr-mm.o
 cr-y += cr-mnt.o
+cr-$(CONFIG_NET) += cr-net.o
 cr-y += cr-nsproxy.o
 cr-y += cr-pid.o
 cr-y += cr-signal.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -86,6 +86,9 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_file(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_net_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_fs_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -176,6 +179,9 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_uts_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_net_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_sighand_struct(ctx);
 	if (rv < 0)
 		return rv;
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-net.c
@@ -0,0 +1,115 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_collect_net_ns(struct cr_context *ctx, struct net *net_ns)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, net_ns, CR_CTX_NET_NS);
+	printk("collect net_ns %p: rv %d\n", net_ns, rv);
+	return rv;
+}
+
+int cr_collect_all_net_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = cr_collect_net_ns(ctx, nsproxy->net_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_NET_NS) {
+		struct net *net_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&net_ns->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: net_ns %p has external references %lu:%u\n", __func__, net_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_net_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct net *net = obj->o_obj;
+	struct cr_image_net_ns *i;
+	int rv;
+
+	printk("dump net_ns %p\n", net);
+
+	i = cr_prepare_image(CR_OBJ_NET_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_core.cr_sysctl_somaxconn = net->core.sysctl_somaxconn;
+	i->cr_unx.cr_sysctl_max_dgram_qlen = net->unx.sysctl_max_dgram_qlen;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_net_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NET_NS) {
+		rv = cr_dump_net_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int cr_restore_net_ns(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_net_ns *i;
+	struct net *net;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_NET_NS) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	net = net_create();
+	if (IS_ERR(net)) {
+		kfree(i);
+		return PTR_ERR(net);
+	}
+
+	net->core.sysctl_somaxconn = i->cr_core.cr_sysctl_somaxconn;
+	net->unx.sysctl_max_dgram_qlen = i->cr_unx.cr_sysctl_max_dgram_qlen;
+	kfree(i);
+
+	obj = cr_object_create(net);
+	if (!obj) {
+		put_net(net);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_NET_NS]);
+	printk("restore net_ns %p, pos %lld\n", net, (long long)pos);
+	return 0;
+}
--- a/kernel/cr/cr-nsproxy.c
+++ b/kernel/cr/cr-nsproxy.c
@@ -63,6 +63,12 @@ static int cr_dump_nsproxy(struct cr_context *ctx, struct cr_object *obj)
 	i->cr_pos_mnt_ns = tmp->o_pos;
 	tmp = cr_find_obj_by_ptr(ctx, nsproxy->pid_ns, CR_CTX_PID_NS);
 	i->cr_pos_pid_ns = tmp->o_pos;
+#ifdef CONFIG_NET
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->net_ns, CR_CTX_NET_NS);
+	i->cr_pos_net_ns = tmp->o_pos;
+#else
+	i->cr_pos_net_ns = CR_POS_UNDEF;
+#endif
 
 	obj->o_pos = ctx->cr_dump_file->f_pos;
 	rv = cr_write(ctx, i, sizeof(*i));
@@ -89,6 +95,9 @@ static int __cr_restore_nsproxy(struct cr_context *ctx, loff_t pos)
 	struct nsproxy *nsproxy;
 	struct uts_namespace *uts_ns;
 	struct pid_namespace *pid_ns;
+#ifdef CONFIG_NET
+	struct net *net;
+#endif
 	struct cr_object *obj, *tmp;
 	int rv;
 
@@ -145,7 +154,17 @@ static int __cr_restore_nsproxy(struct cr_context *ctx, loff_t pos)
 	nsproxy->pid_ns = get_pid_ns(pid_ns);
 
 #ifdef CONFIG_NET
-	nsproxy->net_ns = get_net(&init_net);
+	tmp = cr_find_obj_by_pos(ctx, i->cr_pos_net_ns, CR_CTX_NET_NS);
+	if (!tmp) {
+		rv = cr_restore_net_ns(ctx, i->cr_pos_net_ns);
+		if (rv < 0) {
+			kfree(i);
+			return rv;
+		}
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_net_ns, CR_CTX_NET_NS);
+	}
+	net = tmp->o_obj;
+	nsproxy->net_ns = get_net(net);
 #endif
 	kfree(i);
 
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -29,6 +29,9 @@ enum cr_context_obj_type {
 	CR_CTX_GROUP_INFO,
 	CR_CTX_MM_STRUCT,
 	CR_CTX_MNT_NS,
+#ifdef CONFIG_NET
+	CR_CTX_NET_NS,
+#endif
 	CR_CTX_NSPROXY,
 	CR_CTX_PID,
 	CR_CTX_PID_NS,
@@ -97,6 +100,14 @@ int cr_collect_all_fs_struct(struct cr_context *ctx);
 int cr_collect_all_group_info(struct cr_context *ctx);
 int cr_collect_all_mm_struct(struct cr_context *ctx);
 int cr_collect_all_mnt_ns(struct cr_context *ctx);
+#ifdef CONFIG_NET
+int cr_collect_all_net_ns(struct cr_context *ctx);
+#else
+static inline int cr_collect_all_net_ns(struct cr_context *ctx)
+{
+	return 0;
+}
+#endif
 int cr_collect_all_nsproxy(struct cr_context *ctx);
 int cr_collect_all_pid_ns(struct cr_context *ctx);
 int cr_collect_all_pid(struct cr_context *ctx);
@@ -114,6 +125,14 @@ int cr_dump_all_fs_struct(struct cr_context *ctx);
 int cr_dump_all_group_info(struct cr_context *ctx);
 int cr_dump_all_mm_struct(struct cr_context *ctx);
 int cr_dump_all_mnt_ns(struct cr_context *ctx);
+#ifdef CONFIG_NET
+int cr_dump_all_net_ns(struct cr_context *ctx);
+#else
+static inline int cr_dump_all_net_ns(struct cr_context *ctx)
+{
+	return 0;
+}
+#endif
 int cr_dump_all_nsproxy(struct cr_context *ctx);
 int cr_dump_all_pid_ns(struct cr_context *ctx);
 int cr_dump_all_pid(struct cr_context *ctx);
@@ -131,6 +150,14 @@ int cr_restore_fs_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_group_info(struct cr_context *ctx, loff_t pos);
 int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_mnt_ns(struct cr_context *ctx, loff_t pos);
+#ifdef CONFIG_NET
+int cr_restore_net_ns(struct cr_context *ctx, loff_t pos);
+#else
+static inline int cr_restore_net_ns(struct cr_context *ctx, loff_t pos)
+{
+	return 0;
+}
+#endif
 int cr_restore_nsproxy(struct cr_context *ctx, loff_t pos);
 int cr_restore_pid_ns(struct cr_context *ctx, loff_t pos);
 int cr_restore_pid(struct cr_context *ctx, struct cr_image_task_struct *i);
