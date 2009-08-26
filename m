From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Rename headerless struct ckpt_hdr_* to struct ckpt_*
Date: Wed, 26 Aug 2009 04:55:29 -0700
Message-ID: <20090826115529.GJ8078@count0.beaverton.ibm.com>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

    Rename headerless struct ckpt_hdr_* to struct ckpt_*
    
    These structures do not, in fact, contain a struct ckpt_hdr so they
    should not be named struct ckpt_hdr_* but struct ckpt_*.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
--
Coccinelle patch (doesn't fixup headers but..):

@@
@@
-struct ckpt_hdr_const
+struct ckpt_constants
@@
@@
-struct ckpt_hdr_pids
+struct ckpt_pids
@@
@@
-struct ckpt_hdr_socket
+struct ckpt_socket
@@
@@
-struct ckpt_hdr_sigset
+struct ckpt_sigset
@@
@@
-struct ckpt_hdr_sigaction
+struct ckpt_sigaction
@@
@@
-struct ckpt_hdr_siginfo
+struct ckpt_siginfo
@@
@@
-struct ckpt_hdr_rlimit
+struct ckpt_rlimit

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 870b16d..c19f812 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -180,7 +180,7 @@ int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
  * Checkpoint
  */
 
-static void fill_kernel_const(struct ckpt_hdr_const *h)
+static void fill_kernel_const(struct ckpt_constants *h)
 {
 	struct task_struct *tsk;
 	struct mm_struct *mm;
@@ -350,7 +350,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 static int checkpoint_pids(struct ckpt_ctx *ctx)
 {
-	struct ckpt_hdr_pids *h;
+	struct ckpt_pids *h;
 	struct pid_namespace *ns;
 	struct task_struct *task;
 	struct task_struct **tasks_arr;
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 4fdae78..ed42b4b 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -343,7 +343,7 @@ int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
  * Restart
  */
 
-static int check_kernel_const(struct ckpt_hdr_const *h)
+static int check_kernel_const(struct ckpt_constants *h)
 {
 	struct task_struct *tsk;
 	struct mm_struct *mm;
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 960356c..439cff8 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -20,12 +20,12 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
-static inline void fill_sigset(struct ckpt_hdr_sigset *h, sigset_t *sigset)
+static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
 {
 	memcpy(&h->sigset, sigset, sizeof(*sigset));
 }
 
-static inline void load_sigset(sigset_t *sigset, struct ckpt_hdr_sigset *h)
+static inline void load_sigset(sigset_t *sigset, struct ckpt_sigset *h)
 {
 	memcpy(sigset, &h->sigset, sizeof(*sigset));
 }
@@ -37,7 +37,7 @@ static inline void load_sigset(sigset_t *sigset, struct ckpt_hdr_sigset *h)
 int do_checkpoint_sighand(struct ckpt_ctx *ctx, struct sighand_struct *sighand)
 {
 	struct ckpt_hdr_sighand *h;
-	struct ckpt_hdr_sigaction *hh;
+	struct ckpt_sigaction *hh;
 	struct sigaction *sa;
 	int i, ret;
 
@@ -103,7 +103,7 @@ int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
 struct sighand_struct *do_restore_sighand(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_sighand *h;
-	struct ckpt_hdr_sigaction *hh;
+	struct ckpt_sigaction *hh;
 	struct sighand_struct *sighand;
 	struct sigaction *sa;
 	int i;
@@ -168,7 +168,7 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
  * signal checkpoint/restart
  */
 
-static void fill_siginfo(struct ckpt_hdr_siginfo *si, siginfo_t *info)
+static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
 {
 	si->signo = info->si_signo;
 	si->_errno = info->si_errno;
@@ -212,7 +212,7 @@ static void fill_siginfo(struct ckpt_hdr_siginfo *si, siginfo_t *info)
 	}
 }
 
-static int load_siginfo(siginfo_t *info, struct ckpt_hdr_siginfo *si)
+static int load_siginfo(siginfo_t *info, struct ckpt_siginfo *si)
 {
 	if (!valid_signal(si->signo))
 		return -EINVAL;
@@ -278,7 +278,7 @@ static int checkpoint_sigpending(struct ckpt_ctx *ctx,
 				 struct sigpending *pending)
 {
 	struct ckpt_hdr_sigpending *h;
-	struct ckpt_hdr_siginfo *si;
+	struct ckpt_siginfo *si;
 	struct sigqueue *q;
 	int nr_pending = 0;
 	int ret;
@@ -421,7 +421,7 @@ int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 static int restore_sigpending(struct ckpt_ctx *ctx, struct sigpending *pending)
 {
 	struct ckpt_hdr_sigpending *h;
-	struct ckpt_hdr_siginfo *si;
+	struct ckpt_siginfo *si;
 	struct sigqueue *q;
 	int ret = 0;
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 3a31377..06bc6e2 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -33,7 +33,9 @@
 /*
  * header format: 'struct ckpt_hdr' must prefix all other headers. Therfore
  * when a header is passed around, the information about it (type, size)
- * is readily available.
+ * is readily available. Structs that include a struct ckpt_hdr are named
+ * struct ckpt_hdr_* by convention (usualy the struct ckpt_hdr is the first
+ * member).
  */
 struct ckpt_hdr {
 	__u32 type;
@@ -138,7 +140,7 @@ enum obj_type {
 };
 
 /* kernel constants */
-struct ckpt_hdr_const {
+struct ckpt_constants {
 	/* task */
 	__u16 task_comm_len;
 	/* mm */
@@ -168,7 +170,7 @@ struct ckpt_hdr_header {
 	__u16 patch;
 	__u16 rev;
 
-	struct ckpt_hdr_const constants;
+	struct ckpt_constants constants;
 
 	__u64 time;	/* when checkpoint taken */
 	__u64 uflags;	/* uflags from checkpoint */
@@ -194,7 +196,7 @@ struct ckpt_hdr_tree {
 	__s32 nr_tasks;
 } __attribute__((aligned(8)));
 
-struct ckpt_hdr_pids {
+struct ckpt_pids {
 	__s32 vpid;
 	__s32 vppid;
 	__s32 vtgid;
@@ -366,7 +368,7 @@ struct ckpt_hdr_file_pipe {
 } __attribute__((aligned(8)));
 
 /* socket */
-struct ckpt_hdr_socket {
+struct ckpt_socket {
 	struct { /* struct socket */
 		__u64 flags;
 		__u8 state;
@@ -426,7 +428,7 @@ struct ckpt_hdr_socket_unix {
 
 struct ckpt_hdr_file_socket {
 	struct ckpt_hdr_file common;
-	struct ckpt_hdr_socket socket;
+	struct ckpt_socket socket;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_utsns {
@@ -490,24 +492,24 @@ struct ckpt_hdr_pgarr {
 } __attribute__((aligned(8)));
 
 /* signals */
-struct ckpt_hdr_sigset {
+struct ckpt_sigset {
 	__u8 sigset[CKPT_ARCH_NSIG / 8];
 } __attribute__((aligned(8)));
 
-struct ckpt_hdr_sigaction {
+struct ckpt_sigaction {
 	__u64 _sa_handler;
 	__u64 sa_flags;
 	__u64 sa_restorer;
-	struct ckpt_hdr_sigset sa_mask;
+	struct ckpt_sigset sa_mask;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_sighand {
 	struct ckpt_hdr h;
-	struct ckpt_hdr_sigaction action[0];
+	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
 #ifndef HAVE_ARCH_SIGINFO_T
-struct ckpt_hdr_siginfo {
+struct ckpt_siginfo {
 	__u32 signo;
 	__u32 _errno;
 	__u32 code;
@@ -524,11 +526,11 @@ struct ckpt_hdr_siginfo {
 struct ckpt_hdr_sigpending {
 	struct ckpt_hdr h;
 	__u32 nr_pending;
-	struct ckpt_hdr_sigset signal;
-	struct ckpt_hdr_siginfo siginfo[0];
+	struct ckpt_sigset signal;
+	struct ckpt_siginfo siginfo[0];
 } __attribute__((aligned(8)));
 
-struct ckpt_hdr_rlimit {
+struct ckpt_rlimit {
 	__u64 rlim_cur;
 	__u64 rlim_max;
 } __attribute__((aligned(8)));
@@ -544,7 +546,7 @@ struct ckpt_hdr_rlimit {
 
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
-	struct ckpt_hdr_rlimit rlim[CKPT_RLIM_NLIMITS];
+	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
 	__u64 it_real_value;
 	__u64 it_real_incr;
 	__u64 it_virt_value;
@@ -555,7 +557,7 @@ struct ckpt_hdr_signal {
 
 struct ckpt_hdr_signal_task {
 	struct ckpt_hdr h;
-	struct ckpt_hdr_sigset blocked;
+	struct ckpt_sigset blocked;
 } __attribute__((aligned(8)));
 
 /* ipc commons */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index e98251b..a18846f 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -61,7 +61,7 @@ struct ckpt_ctx {
 	int nr_tasks;                   /* size of tasks array */
 
 	/* [multi-process restart] */
-	struct ckpt_hdr_pids *pids_arr;	/* array of all pids [restart] */
+	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
 	int nr_pids;			/* size of pids array */
 	int active_pid;			/* (next) position in pids array */
 	struct completion complete;	/* container root and other tasks on */
diff --git a/include/linux/net.h b/include/linux/net.h
index 96c7e22..27187a4 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -148,7 +148,7 @@ struct msghdr;
 struct module;
 
 struct ckpt_ctx;
-struct ckpt_hdr_socket;
+struct ckpt_socket;
 
 struct proto_ops {
 	int		family;
@@ -197,7 +197,7 @@ struct proto_ops {
 	int		(*checkpoint)(struct ckpt_ctx *ctx,
 				      struct socket *sock);
 	int		(*restore)(struct ckpt_ctx *ctx, struct socket *sock,
-				   struct ckpt_hdr_socket *h);
+				   struct ckpt_socket *h);
 };
 
 struct net_proto_family {
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index eba9142..86dc320 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -71,10 +71,10 @@ static inline void unix_sysctl_unregister(struct net *net) {}
 
 #ifdef CONFIG_CHECKPOINT
 struct ckpt_ctx;
-struct ckpt_hdr_socket;
+struct ckpt_socket;
 extern int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
 extern int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
-			struct ckpt_hdr_socket *h);
+			struct ckpt_socket *h);
 #endif /* CONFIG_CHECKPOINT */
 
 #endif
diff --git a/net/checkpoint.c b/net/checkpoint.c
index f3e2a62..2541e81 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -166,7 +166,7 @@ int ckpt_sock_getnames(struct ckpt_ctx *ctx, struct socket *sock,
 	return 0;
 }
 
-static int sock_cptrst_verify(struct ckpt_hdr_socket *h)
+static int sock_cptrst_verify(struct ckpt_socket *h)
 {
 	uint8_t userlocks_mask = SOCK_SNDBUF_LOCK | SOCK_RCVBUF_LOCK |
 		                 SOCK_BINDADDR_LOCK | SOCK_BINDPORT_LOCK;
@@ -204,7 +204,7 @@ static int sock_cptrst_opt(int op, struct socket *sock,
 	sock_cptrst_opt(op, sk->sk_socket, name, (char *)opt, sizeof(*opt))
 
 static int sock_cptrst_bufopts(int op, struct sock *sk,
-			       struct ckpt_hdr_socket *h)
+			       struct ckpt_socket *h)
 
 {
 	if (CKPT_COPY_SOPT(op, sk, SO_RCVBUF, &h->sock.rcvbuf))
@@ -270,7 +270,7 @@ static int sock_restore_flag(struct socket *sock,
 
 
 static int sock_restore_flags(struct socket *sock,
-                             struct ckpt_hdr_socket *h)
+                             struct ckpt_socket *h)
 {
        int ret;
        int i;
@@ -339,7 +339,7 @@ static int sock_copy_timeval(int op, struct sock *sk,
 }
 
 static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
-		       struct ckpt_hdr_socket *h, int op)
+		       struct ckpt_socket *h, int op)
 {
 	if (sk->sk_socket) {
 		CKPT_COPY(op, h->socket.state, sk->sk_socket->state);
@@ -531,7 +531,7 @@ static struct file *sock_alloc_attach_fd(struct socket *sock)
 struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 {
 	struct ckpt_hdr_file_socket *hh = (struct ckpt_hdr_file_socket *) ptr;
-	struct ckpt_hdr_socket *h = &hh->socket;
+	struct ckpt_socket *h = &hh->socket;
 	struct socket *sock;
 	struct file *file;
 	int ret;
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 4aff931..08e664b 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -237,7 +237,7 @@ static int unix_join(struct ckpt_ctx *ctx,
 }
 
 static int unix_restore_connected(struct ckpt_ctx *ctx,
-				  struct ckpt_hdr_socket *h,
+				  struct ckpt_socket *h,
 				  struct ckpt_hdr_socket_unix *un,
 				  struct socket *sock)
 {
@@ -423,7 +423,7 @@ static int unix_fakebind(struct socket *sock,
 	return 0;
 }
 
-static int unix_restore_bind(struct ckpt_hdr_socket *h,
+static int unix_restore_bind(struct ckpt_socket *h,
 			     struct ckpt_hdr_socket_unix *un,
 			     struct socket *sock,
 			     const char *path)
@@ -440,7 +440,7 @@ static int unix_restore_bind(struct ckpt_hdr_socket *h,
 }
 
 /* Some easy pre-flight checks before we get underway */
-static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
+static int unix_precheck(struct socket *sock, struct ckpt_socket *h)
 {
 	struct net *net = sock_net(sock->sk);
 
@@ -471,7 +471,7 @@ static int unix_precheck(struct socket *sock, struct ckpt_hdr_socket *h)
 }
 
 int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
-		      struct ckpt_hdr_socket *h)
+		      struct ckpt_socket *h)
 
 {
 	struct ckpt_hdr_socket_unix *un;
