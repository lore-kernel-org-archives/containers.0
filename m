From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 28/30] cr: sockets
Date: Fri, 10 Apr 2009 06:40:37 +0400
Message-ID: <20090410024037.GC27788__19226.2844917879$1239332027$gmane$org@x200.localdomain>
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

Nothing will be dumped because socket file_operations aren't ready.

This is one big FIXME item.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h    |    8 ++++
 kernel/cr/Makefile    |    1 
 kernel/cr/cpt-sys.c   |    6 +++
 kernel/cr/cr-net.c    |    7 +++
 kernel/cr/cr-socket.c |   90 ++++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr.h        |   19 ++++++++++
 6 files changed, 131 insertions(+)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -50,6 +50,7 @@ struct cr_object_header {
 #define CR_OBJ_USER_NS		19
 #define CR_OBJ_MNT_NS		20
 #define CR_OBJ_NET_NS		21
+#define CR_OBJ_SOCK		22
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -373,4 +374,11 @@ struct cr_image_net_ns {
 		__u32	cr_sysctl_max_dgram_qlen;
 	} cr_unx;
 } __packed;
+
+struct cr_image_sock {
+	struct cr_object_header cr_hdr;
+
+	cr_pos_t	cr_pos_sk_net;
+	__u16		cr_sk_family;
+} __packed;
 #endif
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -10,6 +10,7 @@ cr-$(CONFIG_NET) += cr-net.o
 cr-y += cr-nsproxy.o
 cr-y += cr-pid.o
 cr-y += cr-signal.o
+cr-$(CONFIG_NET) += cr-socket.o
 cr-y += cr-task.o
 cr-y += cr-uts.o
 cr-$(CONFIG_X86_32) += cr-x86_32.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -86,6 +86,9 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_file(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_sock(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_net_ns(ctx);
 	if (rv < 0)
 		return rv;
@@ -182,6 +185,9 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_net_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_sock(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_sighand_struct(ctx);
 	if (rv < 0)
 		return rv;
--- a/kernel/cr/cr-net.c
+++ b/kernel/cr/cr-net.c
@@ -27,6 +27,13 @@ int cr_collect_all_net_ns(struct cr_context *ctx)
 		if (rv < 0)
 			return rv;
 	}
+	for_each_cr_object(ctx, obj, CR_CTX_SOCK) {
+		struct sock *sk = obj->o_obj;
+
+		rv = cr_collect_net_ns(ctx, sock_net(sk));
+		if (rv < 0)
+			return rv;
+	}
 	for_each_cr_object(ctx, obj, CR_CTX_NET_NS) {
 		struct net *net_ns = obj->o_obj;
 		unsigned int cnt = atomic_read(&net_ns->count);
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-socket.c
@@ -0,0 +1,90 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <net/sock.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_check_sock(struct sock *sk)
+{
+#ifdef CONFIG_XFRM
+	if (sk->sk_policy[0] || sk->sk_policy[1]) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+#ifdef CONFIG_SECURITY
+	if (sk->sk_security) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+	return 0;
+}
+
+static int cr_collect_sock(struct cr_context *ctx, struct sock *sk)
+{
+	int rv;
+
+	rv = cr_check_sock(sk);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, sk, CR_CTX_SOCK);
+	printk("collect sock %p: rv %d, family %u\n", sk, rv, sk->sk_family);
+	return rv;
+}
+
+int cr_collect_all_sock(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		struct file *file = obj->o_obj;
+		struct inode *inode = file->f_path.dentry->d_inode;
+
+		if (!S_ISSOCK(inode->i_mode))
+			continue;
+
+		rv = cr_collect_sock(ctx, SOCKET_I(inode)->sk);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int cr_dump_sock(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct sock *sk = obj->o_obj;
+	struct cr_image_sock *i;
+	struct cr_object *tmp;
+	int rv;
+
+	printk("dump socket %p\n", sk);
+
+	i = cr_prepare_image(CR_OBJ_SOCK, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	tmp = cr_find_obj_by_ptr(ctx, sock_net(sk), CR_CTX_NET_NS);
+	i->cr_pos_sk_net = tmp->o_pos;
+
+	i->cr_sk_family = sk->sk_family;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_sock(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_SOCK) {
+		rv = cr_dump_sock(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -37,6 +37,9 @@ enum cr_context_obj_type {
 	CR_CTX_PID_NS,
 	CR_CTX_SIGHAND_STRUCT,
 	CR_CTX_SIGNAL_STRUCT,
+#ifdef CONFIG_NET
+	CR_CTX_SOCK,
+#endif
 	CR_CTX_TASK_STRUCT,
 	CR_CTX_USER_NS,
 	CR_CTX_USER_STRUCT,
@@ -113,6 +116,14 @@ int cr_collect_all_pid_ns(struct cr_context *ctx);
 int cr_collect_all_pid(struct cr_context *ctx);
 int cr_collect_all_sighand_struct(struct cr_context *ctx);
 int cr_collect_all_signal_struct(struct cr_context *ctx);
+#ifdef CONFIG_NET
+int cr_collect_all_sock(struct cr_context *ctx);
+#else
+static inline int cr_collect_all_sock(struct cr_context *ctx)
+{
+	return 0;
+}
+#endif
 int cr_collect_all_task_struct(struct cr_context *ctx);
 int cr_collect_all_user_ns(struct cr_context *ctx);
 int cr_collect_all_user_struct(struct cr_context *ctx);
@@ -138,6 +149,14 @@ int cr_dump_all_pid_ns(struct cr_context *ctx);
 int cr_dump_all_pid(struct cr_context *ctx);
 int cr_dump_all_sighand_struct(struct cr_context *ctx);
 int cr_dump_all_signal_struct(struct cr_context *ctx);
+#ifdef CONFIG_NET
+int cr_dump_all_sock(struct cr_context *ctx);
+#else
+static inline int cr_dump_all_sock(struct cr_context *ctx)
+{
+	return 0;
+}
+#endif
 int cr_dump_all_task_struct(struct cr_context *ctx);
 int cr_dump_all_user_ns(struct cr_context *ctx);
 int cr_dump_all_user_struct(struct cr_context *ctx);
