From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/3] c/r: cleanup sock_file_restore()/sock_file_checkpoint()
Date: Mon, 17 Aug 2009 16:12:09 -0400
Message-ID: <1250539931-12951-2-git-send-email-orenl@librato.com>
References: <1250539931-12951-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250539931-12951-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

This patch was intended to fix a compilation warning regarding the
sock_file_restore():

checkpoint/files.c: At top level:
checkpoint/files.c:573: warning: initialization from incompatible pointer type

and evolved to some cleanup of that code, making the following changes:

* Make ckpt_hdr_socket be part of ckpt_hdr_file_socket; There is no
  good reason to use a separate header for it. This saves write/read
  of an extra structure.

* Fold do_sock_file_checkpoint() into sock_file_checkpoint(), and also
  do_sock_file_restore() into sock_file_restore(). This makes the code
  a bit simpler and more streamlined.

* Move sock_file_{checkpoint,restore} to net/checkpoint.c, which is a
  more proper place than net/socket.c.

* Properly define sock_file_{checkpoint,restore} in header file

* Have sock_file_restore() call restore_file_common(), which was
  omitted previously.


Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |  116 +++++++++++++++++++--------------------
 include/linux/net.h            |    2 +
 include/net/af_unix.h          |    6 +-
 include/net/sock.h             |   10 ++--
 net/checkpoint.c               |   94 ++++++++++++++++++++++++--------
 net/socket.c                   |   84 +----------------------------
 net/unix/checkpoint.c          |    8 +---
 7 files changed, 138 insertions(+), 182 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 53d3f37..4d5c22a 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -94,7 +94,6 @@ enum {
 	CKPT_HDR_SIGPENDING,
 
 	CKPT_HDR_FD_SOCKET = 701,
-	CKPT_HDR_SOCKET,
 	CKPT_HDR_SOCKET_QUEUE,
 	CKPT_HDR_SOCKET_BUFFER,
 	CKPT_HDR_SOCKET_UNIX,
@@ -366,8 +365,65 @@ struct ckpt_hdr_file_pipe {
 	__s32 pipe_objref;
 } __attribute__((aligned(8)));
 
+/* socket */
+struct ckpt_hdr_socket {
+	struct { /* struct socket */
+		__u64 flags;
+		__u8 state;
+	} socket __attribute__ ((aligned(8)));
+
+	struct { /* struct sock_common */
+		__u32 bound_dev_if;
+		__u32 reuse;
+		__u16 family;
+		__u8 state;
+	} sock_common __attribute__ ((aligned(8)));
+
+	struct { /* struct sock */
+		__s64 rcvlowat;
+		__u64 flags;
+
+		__u32 err;
+		__u32 err_soft;
+		__u32 priority;
+		__s32 rcvbuf;
+		__s32 sndbuf;
+		__u16 type;
+		__s16 backlog;
+
+		__u8 protocol;
+		__u8 state;
+		__u8 shutdown;
+		__u8 userlocks;
+		__u8 no_check;
+
+		struct linger linger;
+		struct timeval rcvtimeo;
+		struct timeval sndtimeo;
+	} sock __attribute__ ((aligned(8)));
+} __attribute__ ((aligned(8)));
+
+struct ckpt_hdr_socket_queue {
+	struct ckpt_hdr h;
+	__u32 skb_count;
+	__u32 total_bytes;
+} __attribute__ ((aligned(8)));
+
+#define CKPT_UNIX_LINKED 1
+struct ckpt_hdr_socket_unix {
+	struct ckpt_hdr h;
+	__s32 this;
+	__s32 peer;
+	__u32 flags;
+	__u32 laddr_len;
+	__u32 raddr_len;
+	struct sockaddr_un laddr;
+	struct sockaddr_un raddr;
+} __attribute__ ((aligned(8)));
+
 struct ckpt_hdr_file_socket {
 	struct ckpt_hdr_file common;
+	struct ckpt_hdr_socket socket;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_utsns {
@@ -576,64 +632,6 @@ struct ckpt_hdr_ipc_sem {
 	__u32 sem_nsems;
 } __attribute__((aligned(8)));
 
-#define CKPT_UNIX_LINKED 1
-struct ckpt_hdr_socket_unix {
-	struct ckpt_hdr h;
-	__s32 this;
-	__s32 peer;
-	__u32 flags;
-	__u32 laddr_len;
-	__u32 raddr_len;
-	struct sockaddr_un laddr;
-	struct sockaddr_un raddr;
-} __attribute__ ((aligned(8)));
-
-struct ckpt_hdr_socket {
-	struct ckpt_hdr h;
-
-	struct { /* struct socket */
-		__u64 flags;
-		__u8 state;
-	} socket __attribute__ ((aligned(8)));
-
-	struct { /* struct sock_common */
-		__u32 bound_dev_if;
-		__u32 reuse;
-		__u16 family;
-		__u8 state;
-	} sock_common __attribute__ ((aligned(8)));
-
-	struct { /* struct sock */
-		__s64 rcvlowat;
-		__u64 flags;
-
-		__u32 err;
-		__u32 err_soft;
-		__u32 priority;
-		__s32 rcvbuf;
-		__s32 sndbuf;
-		__u16 type;
-		__s16 backlog;
-
-		__u8 protocol;
-		__u8 state;
-		__u8 shutdown;
-		__u8 userlocks;
-		__u8 no_check;
-
-		struct linger linger;
-		struct timeval rcvtimeo;
-		struct timeval sndtimeo;
-
-	} sock __attribute__ ((aligned(8)));
-
-} __attribute__ ((aligned(8)));
-
-struct ckpt_hdr_socket_queue {
-	struct ckpt_hdr h;
-	__u32 skb_count;
-	__u32 total_bytes;
-} __attribute__ ((aligned(8)));
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
diff --git a/include/linux/net.h b/include/linux/net.h
index 4fc2ffd..2c4a75d 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -223,6 +223,8 @@ extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
 				  size_t len);
 extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
 				  size_t size, int flags);
+extern int	     sock_attach_fd(struct socket *sock, struct file *file,
+				    int flags);
 extern int 	     sock_map_fd(struct socket *sock, int flags);
 extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 7aef51b..35b5b9c 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -70,6 +70,8 @@ static inline void unix_sysctl_unregister(struct net *net) {}
 #endif
 
 #ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+struct ckpt_hdr_socket;
 
 #ifdef CONFIG_UNIX_MODULE
 /* FIXME: Our current scheme won't work with CONFIG_UNIX=m */
@@ -77,9 +79,7 @@ static inline void unix_sysctl_unregister(struct net *net) {}
 #endif
 
 #ifdef CONFIG_UNIX
-extern int sock_unix_checkpoint(struct ckpt_ctx *ctx,
-				struct socket *socket,
-				struct ckpt_hdr_socket *h);
+extern int sock_unix_checkpoint(struct ckpt_ctx *ctx, struct socket *socket);
 extern int sock_unix_restore(struct ckpt_ctx *ctx,
 			     struct ckpt_hdr_socket *h,
 			     struct socket *socket);
diff --git a/include/net/sock.h b/include/net/sock.h
index da75f2f..8e3b050 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1643,12 +1643,10 @@ extern __u32 sysctl_rmem_default;
 #ifdef CONFIG_CHECKPOINT
 /* Checkpoint/Restart Functions */
 struct ckpt_ctx;
-struct ckpt_hdr_socket;
-extern int sock_file_checkpoint(struct ckpt_ctx *, void *);
-extern void *sock_file_restore(struct ckpt_ctx *);
-extern struct socket *do_sock_file_restore(struct ckpt_ctx *,
-					   struct ckpt_hdr_socket *);
-extern int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+struct ckpt_hdr_file;
+extern int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+extern struct file *sock_file_restore(struct ckpt_ctx *ctx,
+				      struct ckpt_hdr_file *h);
 #endif
 
 #endif	/* _SOCK_H */
diff --git a/net/checkpoint.c b/net/checkpoint.c
index ebbd68a..b97cb89 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -323,44 +323,50 @@ static int sock_cptrst(struct ckpt_ctx *ctx,
 		return 0;
 }
 
-int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 {
+	struct ckpt_hdr_file_socket *h;
 	struct socket *socket = file->private_data;
 	struct sock *sock = socket->sk;
-	struct ckpt_hdr_socket *h;
-	int ret = 0;
+	int ret;
 
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
 	if (!h)
 		return -ENOMEM;
 
-	ret = sock_cptrst(ctx, sock, h, CKPT_CPT);
-	if (ret)
+	h->common.f_type = CKPT_FILE_SOCKET;
+
+	/* part I: common to all sockets */
+	ret = sock_cptrst(ctx, sock, &h->socket, CKPT_CPT);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
 		goto out;
 
+	/* part II: per socket type state */
 	if (sock->sk_family == AF_UNIX) {
-		ret = sock_unix_checkpoint(ctx, socket, h);
-		if (ret)
-			goto out;
+		ret = sock_unix_checkpoint(ctx, socket);
 	} else {
 		ckpt_write_err(ctx, "unsupported socket family %i",
 			       sock->sk_family);
 		ret = -ENOSYS;
-		goto out;
 	}
+	if (ret < 0)
+		goto out;
 
+	/* part III: socket buffers */
 	if (sock->sk_state != TCP_LISTEN) {
 		ret = sock_write_buffers(ctx, &sock->sk_receive_queue);
 		if (ret)
 			goto out;
-
 		ret = sock_write_buffers(ctx, &sock->sk_write_queue);
-		if (ret)
-			goto out;
 	}
  out:
 	ckpt_hdr_put(ctx, h);
-
 	return ret;
 }
 
@@ -400,12 +406,36 @@ struct ckpt_hdr_socket_queue *ckpt_sock_read_buffer_hdr(struct ckpt_ctx *ctx,
 		return h;
 }
 
-struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
-				    struct ckpt_hdr_socket *h)
+static struct file *sock_alloc_attach_fd(struct socket *socket)
 {
+	struct file *file;
+	int err;
+
+	file = get_empty_filp();
+	if (!file)
+		return ERR_PTR(ENOMEM);
+
+	err = sock_attach_fd(socket, file, 0);
+	if (err < 0) {
+		put_filp(file);
+		file = ERR_PTR(err);
+	}
+
+	return file;
+}
+
+struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_socket *hh = (struct ckpt_hdr_file_socket *) ptr;
+	struct ckpt_hdr_socket *h = &hh->socket;
 	struct socket *socket;
+	struct file *file;
 	int ret;
 
+	if (ptr->h.type != CKPT_HDR_FILE  ||
+	    ptr->h.len != sizeof(*hh) || ptr->f_type != CKPT_FILE_SOCKET)
+		return ERR_PTR(-EINVAL);
+
 	if ((h->sock.type != SOCK_DGRAM) && (h->sock.type != SOCK_STREAM)) {
 		ckpt_debug("Socket type %i not supported", h->sock.type);
 		return ERR_PTR(-EINVAL);
@@ -415,6 +445,10 @@ struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
 	if (ret < 0)
 		return ERR_PTR(ret);
 
+	/*
+	 * part II: per socket type state
+	 * (also takes care of part III: socket buffer)
+	 */
 	if (h->sock_common.family == AF_UNIX) {
 		ret = sock_unix_restore(ctx, h, socket);
 		ckpt_debug("sock_unix_restore: %i\n", ret);
@@ -422,17 +456,29 @@ struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
 		ckpt_debug("unsupported family %i\n", h->sock_common.family);
 		ret = -ENOSYS;
 	}
+	if (ret < 0)
+		goto err;
 
-	if (ret)
-		goto out;
-
+	/* part I: common to all sockets */
 	ret = sock_cptrst(ctx, socket->sk, h, CKPT_RST);
- out:
-	if (ret) {
-		sock_release(socket);
-		socket = ERR_PTR(ret);
+	if (ret < 0)
+		goto err;
+
+	file = sock_alloc_attach_fd(socket);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto err;
 	}
 
-	return socket;
+	ret = restore_file_common(ctx, file, ptr);
+	if (ret < 0) {
+		fput(file);
+		file = ERR_PTR(ret);
+	}
+	return file;
+
+ err:
+	sock_release(socket);
+	return ERR_PTR(ret);
 }
 
diff --git a/net/socket.c b/net/socket.c
index 8732fe2..f3b501d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -96,8 +96,6 @@
 #include <net/sock.h>
 #include <linux/netfilter.h>
 
-#include <linux/checkpoint.h>
-
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
@@ -373,7 +371,7 @@ static int sock_alloc_fd(struct file **filep, int flags)
 	return fd;
 }
 
-static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
+int sock_attach_fd(struct socket *sock, struct file *file, int flags)
 {
 	struct dentry *dentry;
 	struct qstr name = { .name = "" };
@@ -420,86 +418,6 @@ int sock_map_fd(struct socket *sock, int flags)
 	return fd;
 }
 
-#ifdef CONFIG_CHECKPOINT
-int sock_file_checkpoint(struct ckpt_ctx *ctx, void *ptr)
-{
-	struct ckpt_hdr_file_socket *h;
-	int ret;
-	struct file *file = ptr;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
-	if (!h)
-		return -ENOMEM;
-
-	h->common.f_type = CKPT_FILE_SOCKET;
-
-	ret = checkpoint_file_common(ctx, file, &h->common);
-	if (ret < 0)
-		goto out;
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
-	if (ret < 0)
-		goto out;
-
-	ret = do_sock_file_checkpoint(ctx, file);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static struct file *sock_alloc_attach_fd(struct socket *socket)
-{
-	struct file *file;
-	int err;
-
-	file = get_empty_filp();
-	if (!file)
-		return ERR_PTR(ENOMEM);
-
-	err = sock_attach_fd(socket, file, 0);
-	if (err < 0) {
-		put_filp(file);
-		file = ERR_PTR(err);
-	}
-
-	return file;
-}
-
-void *sock_file_restore(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_socket *h = NULL;
-	struct socket *socket = NULL;
-	struct file *file = NULL;
-	int err;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
-	if (IS_ERR(h))
-		return h;
-
-	socket = do_sock_file_restore(ctx, h);
-	if (IS_ERR(socket)) {
-		err = PTR_ERR(socket);
-		goto err_put;
-	}
-
-	file = sock_alloc_attach_fd(socket);
-	if (IS_ERR(file)) {
-		err = PTR_ERR(file);
-		goto err_release;
-	}
-
-	ckpt_hdr_put(ctx, h);
-
-	return file;
-
- err_release:
-	sock_release(socket);
- err_put:
-	ckpt_hdr_put(ctx, h);
-
-	return ERR_PTR(err);
-}
-#endif /* CONFIG_CHECKPOINT */
-
 static struct socket *sock_from_file(struct file *file, int *err)
 {
 	if (file->f_op == &socket_file_ops)
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 209e556..69fdcf1 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -55,9 +55,7 @@ static int sock_unix_write_cwd(struct ckpt_ctx *ctx,
 	return ret;
 }
 
-int sock_unix_checkpoint(struct ckpt_ctx *ctx,
-			 struct socket *socket,
-			 struct ckpt_hdr_socket *h)
+int sock_unix_checkpoint(struct ckpt_ctx *ctx, struct socket *socket)
 {
 	struct unix_sock *sk = unix_sk(socket->sk);
 	struct unix_sock *pr = unix_sk(sk->peer);
@@ -98,10 +96,6 @@ int sock_unix_checkpoint(struct ckpt_ctx *ctx,
 		goto out;
 	}
 
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
-	if (ret < 0)
-		goto out;
-
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
 	if (ret < 0)
 		goto out;
-- 
1.6.0.4
