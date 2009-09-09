From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] Make sockets proper objhash objects and use
	checkpoint_obj() on them (v2)
Date: Wed,  9 Sep 2009 08:05:54 -0700
Message-ID: <1252508756-4278-2-git-send-email-danms@us.ibm.com>
References: <1252508756-4278-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252508756-4278-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This changes the checkpoint/restart procedure for sockets a bit.  The
socket file header is now checkpointed separately from the socket itself,
which allows us to checkpoint a socket without arriving at it from a
file descriptor.  Thus, most sockets will be checkpointed as a result
of processing the file table, calling sock_file_checkpoint(fd), which
in turn calls checkpoint_obj(socket).

However, we may arrive at some sockets while checkpointing other objects,
such as the other end of an AF_UNIX socket with buffers in flight.  This
patch just opens that door, which is utilized by the next patch.

Changes in v2:
 - If we attempt to checkpoint an orphan socket, create a struct socket
   to adopt it for the purposes of the checkpoint

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c           |    2 +
 include/linux/checkpoint_hdr.h |    6 +-
 include/linux/net.h            |    4 +-
 include/net/af_unix.h          |    4 +-
 include/net/sock.h             |    2 +
 net/checkpoint.c               |  153 +++++++++++++++++++++++++++++++---------
 net/unix/checkpoint.c          |   11 ++--
 7 files changed, 136 insertions(+), 46 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index a9a10d1..a410346 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -381,6 +381,8 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.obj_type = CKPT_OBJ_SOCK,
 		.ref_drop = obj_sock_drop,
 		.ref_grab = obj_sock_grab,
+		.checkpoint = checkpoint_sock,
+		.restore = restore_sock,
 	},
 };
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 06bc6e2..b75562c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -70,6 +70,7 @@ enum {
 	CKPT_HDR_USER,
 	CKPT_HDR_GROUPINFO,
 	CKPT_HDR_TASK_CREDS,
+	CKPT_HDR_SOCKET,
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -368,7 +369,8 @@ struct ckpt_hdr_file_pipe {
 } __attribute__((aligned(8)));
 
 /* socket */
-struct ckpt_socket {
+struct ckpt_hdr_socket {
+	struct ckpt_hdr h;
 	struct { /* struct socket */
 		__u64 flags;
 		__u8 state;
@@ -428,7 +430,7 @@ struct ckpt_hdr_socket_unix {
 
 struct ckpt_hdr_file_socket {
 	struct ckpt_hdr_file common;
-	struct ckpt_socket socket;
+	__s32 sock_objref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_utsns {
diff --git a/include/linux/net.h b/include/linux/net.h
index 27187a4..96c7e22 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -148,7 +148,7 @@ struct msghdr;
 struct module;
 
 struct ckpt_ctx;
-struct ckpt_socket;
+struct ckpt_hdr_socket;
 
 struct proto_ops {
 	int		family;
@@ -197,7 +197,7 @@ struct proto_ops {
 	int		(*checkpoint)(struct ckpt_ctx *ctx,
 				      struct socket *sock);
 	int		(*restore)(struct ckpt_ctx *ctx, struct socket *sock,
-				   struct ckpt_socket *h);
+				   struct ckpt_hdr_socket *h);
 };
 
 struct net_proto_family {
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 1a1fd20..61f666b 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -71,10 +71,10 @@ static inline void unix_sysctl_unregister(struct net *net) {}
 
 #ifdef CONFIG_CHECKPOINT
 struct ckpt_ctx;
-struct ckpt_socket;
+struct ckpt_hdr_socket;
 extern int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
 extern int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
-			struct ckpt_socket *h);
+			struct ckpt_hdr_socket *h);
 #else
 #define unix_checkpoint NULL
 #define unix_restore NULL
diff --git a/include/net/sock.h b/include/net/sock.h
index 8e3b050..0db1ca3 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1644,6 +1644,8 @@ extern __u32 sysctl_rmem_default;
 /* Checkpoint/Restart Functions */
 struct ckpt_ctx;
 struct ckpt_hdr_file;
+extern int checkpoint_sock(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_sock(struct ckpt_ctx *ctx);
 extern int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
 extern struct file *sock_file_restore(struct ckpt_ctx *ctx,
 				      struct ckpt_hdr_file *h);
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 2541e81..d52389a 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -166,7 +166,7 @@ int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
 	return 0;
 }
 
-static int sock_cptrst_verify(struct ckpt_socket *h)
+static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
 {
 	uint8_t userlocks_mask = SOCK_SNDBUF_LOCK | SOCK_RCVBUF_LOCK |
 		                 SOCK_BINDADDR_LOCK | SOCK_BINDPORT_LOCK;
@@ -204,7 +204,7 @@ static int sock_cptrst_opt(int op, struct socket *sock,
 	sock_cptrst_opt(op, sk->sk_socket, name, (char *)opt, sizeof(*opt))
 
 static int sock_cptrst_bufopts(int op, struct sock *sk,
-			       struct ckpt_socket *h)
+			       struct ckpt_hdr_socket *h)
 
 {
 	if (CKPT_COPY_SOPT(op, sk, SO_RCVBUF, &h->sock.rcvbuf))
@@ -270,7 +270,7 @@ static int sock_restore_flag(struct socket *sock,
 
 
 static int sock_restore_flags(struct socket *sock,
-                             struct ckpt_socket *h)
+                             struct ckpt_hdr_socket *h)
 {
        int ret;
        int i;
@@ -309,6 +309,9 @@ static int sock_restore_flags(struct socket *sock,
                return -ENOSYS;
        }
 
+       if (test_and_clear_bit(SOCK_DEAD, &sk_flags))
+	       sock_flag(sock->sk, SOCK_DEAD);
+
        /* Anything that is still set in the flags that isn't part of
         * our protocol's default set, indicates an error
         */
@@ -339,7 +342,7 @@ static int sock_copy_timeval(int op, struct sock *sk,
 }
 
 static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
-		       struct ckpt_socket *h, int op)
+		       struct ckpt_hdr_socket *h, int op)
 {
 	if (sk->sk_socket) {
 		CKPT_COPY(op, h->socket.state, sk->sk_socket->state);
@@ -428,31 +431,26 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 		return 0;
 }
 
-int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
 {
-	struct ckpt_hdr_file_socket *h;
-	struct socket *sock = file->private_data;
-	struct sock *sk = sock->sk;
 	int ret;
+	struct socket *sock = sk->sk_socket;
+	struct ckpt_hdr_socket *h;
 
 	if (!sock->ops->checkpoint) {
 		ckpt_write_err(ctx, "socket (proto_ops: %pS)", sock->ops);
 		return -ENOSYS;
 	}
 
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
 	if (!h)
 		return -ENOMEM;
 
-	h->common.f_type = CKPT_FILE_SOCKET;
-
 	/* part I: common to all sockets */
-	ret = sock_cptrst(ctx, sk, &h->socket, CKPT_CPT);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_file_common(ctx, file, &h->common);
+	ret = sock_cptrst(ctx, sk, h, CKPT_CPT);
 	if (ret < 0)
 		goto out;
+
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	if (ret < 0)
 		goto out;
@@ -463,12 +461,71 @@ int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 		goto out;
 
 	/* part III: socket buffers */
-	if (sk->sk_state != TCP_LISTEN) {
+	if ((sk->sk_state != TCP_LISTEN) && (!sock_flag(sk, SOCK_DEAD))) {
 		ret = sock_write_buffers(ctx, &sk->sk_receive_queue);
 		if (ret)
 			goto out;
 		ret = sock_write_buffers(ctx, &sk->sk_write_queue);
 	}
+
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
+{
+	struct socket *sock;
+	int ret;
+
+	if (sk->sk_socket)
+		return __do_sock_checkpoint(ctx, sk);
+
+	/* Temporarily adopt this orphan socket */
+	ret = sock_create(sk->sk_family, sk->sk_type, 0, &sock);
+	if (ret < 0)
+		return ret;
+	sock_graft(sk, sock);
+
+	ret = __do_sock_checkpoint(ctx, sk);
+
+	sock_orphan(sk);
+	sock->sk = NULL;
+	sock_release(sock);
+
+	return ret;
+}
+
+int checkpoint_sock(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_sock_checkpoint(ctx, (struct sock *)ptr);
+}
+
+int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_socket *h;
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_SOCKET;
+
+	h->sock_objref = checkpoint_obj(ctx, sk, CKPT_OBJ_SOCK);
+	if (h->sock_objref < 0) {
+		ret = h->sock_objref;
+		goto out;
+	}
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -525,27 +582,31 @@ static struct file *sock_alloc_attach_fd(struct socket *sock)
 		file = ERR_PTR(err);
 	}
 
+	/* Since objhash assumes the initial reference for a socket,
+	 * we bump it here for this descriptor, unlike other places in the
+	 * socket code which assume the descriptor is the owner.
+	 */
+	sock_hold(sock->sk);
+
 	return file;
 }
 
-struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+struct sock *do_sock_restore(struct ckpt_ctx *ctx)
 {
-	struct ckpt_hdr_file_socket *hh = (struct ckpt_hdr_file_socket *) ptr;
-	struct ckpt_socket *h = &hh->socket;
+	struct ckpt_hdr_socket *h;
 	struct socket *sock;
-	struct file *file;
 	int ret;
 
-	if (ptr->h.type != CKPT_HDR_FILE  ||
-	    ptr->h.len != sizeof(*hh) || ptr->f_type != CKPT_FILE_SOCKET)
-		return ERR_PTR(-EINVAL);
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
 
 	/* silently clear flags, e.g. SOCK_NONBLOCK or SOCK_CLOEXEC */
 	h->sock.type &= SOCK_TYPE_MASK;
 
 	ret = sock_create(h->sock_common.family, h->sock.type, 0, &sock);
 	if (ret < 0)
-		return ERR_PTR(ret);
+		goto err;
 
 	if (!sock->ops->restore) {
 		ckpt_debug("proto_ops lacks checkpoint: %pS\n", sock->ops);
@@ -566,21 +627,45 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	if (ret < 0)
 		goto err;
 
-	file = sock_alloc_attach_fd(sock);
-	if (IS_ERR(file)) {
-		ret = PTR_ERR(file);
-		goto err;
-	}
+	ckpt_hdr_put(ctx, h);
+
+	return sock->sk;
+ err:
+	ckpt_hdr_put(ctx, h);
+	sock_release(sock);
+
+	return ERR_PTR(ret);
+}
+
+void *restore_sock(struct ckpt_ctx *ctx)
+{
+	return do_sock_restore(ctx);
+}
+
+struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_socket *h = (struct ckpt_hdr_file_socket *)ptr;
+	struct sock *sk;
+	struct file *file;
+	int ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE || ptr->f_type != CKPT_FILE_SOCKET)
+		return ERR_PTR(-EINVAL);
+
+	sk = ckpt_obj_fetch(ctx, h->sock_objref, CKPT_OBJ_SOCK);
+	if (IS_ERR(sk))
+		return ERR_PTR(PTR_ERR(sk));
+
+	file = sock_alloc_attach_fd(sk->sk_socket);
+	if (IS_ERR(file))
+		return file;
 
 	ret = restore_file_common(ctx, file, ptr);
 	if (ret < 0) {
 		fput(file);
-		file = ERR_PTR(ret);
+		return ERR_PTR(ret);
 	}
-	return file;
 
- err:
-	sock_release(sock);
-	return ERR_PTR(ret);
+	return file;
 }
 
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 08e664b..395f6fd 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -57,7 +57,6 @@ static int unix_write_cwd(struct ckpt_ctx *ctx,
 int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 {
 	struct unix_sock *sk = unix_sk(sock->sk);
-	struct unix_sock *pr = unix_sk(sk->peer);
 	struct ckpt_hdr_socket_unix *un;
 	int new;
 	int ret = -ENOMEM;
@@ -86,7 +85,7 @@ int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 		goto out;
 
 	if (sk->peer)
-		un->peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
+		un->peer = checkpoint_obj(ctx, sk->peer, CKPT_OBJ_SOCK);
 	else
 		un->peer = 0;
 
@@ -237,7 +236,7 @@ static int unix_join(struct ckpt_ctx *ctx,
 }
 
 static int unix_restore_connected(struct ckpt_ctx *ctx,
-				  struct ckpt_socket *h,
+				  struct ckpt_hdr_socket *h,
 				  struct ckpt_hdr_socket_unix *un,
 				  struct socket *sock)
 {
@@ -423,7 +422,7 @@ static int unix_fakebind(struct socket *sock,
 	return 0;
 }
 
-static int unix_restore_bind(struct ckpt_socket *h,
+static int unix_restore_bind(struct ckpt_hdr_socket *h,
 			     struct ckpt_hdr_socket_unix *un,
 			     struct socket *sock,
 			     const char *path)
@@ -440,7 +439,7 @@ static int unix_restore_bind(struct ckpt_socket *h,
 }
 
 /* Some easy pre-flight checks before we get underway */
-static int unix_precheck(struct socket *sock, struct ckpt_socket *h)
+static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
 {
 	struct net *net = sock_net(sock->sk);
 
@@ -471,7 +470,7 @@ static int unix_precheck(struct socket *sock, struct ckpt_socket *h)
 }
 
 int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
-		      struct ckpt_socket *h)
+		      struct ckpt_hdr_socket *h)
 
 {
 	struct ckpt_hdr_socket_unix *un;
-- 
1.6.2.5
