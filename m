From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 2/2] first callers of process_deny_checkpoint()
Date: Thu, 09 Oct 2008 12:04:06 -0700
Message-ID: <20081009190406.1B257119__23567.2851712026$1223579408$gmane$org@kernel>
References: <20081009190405.13A253CB@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081009190405.13A253CB@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


These are just a few simple examples of things we know we can't
checkpoint now.  There are plenty more, but this should give
everyone an idea how this will look in practice.


Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/fs/aio.c     |    7 +++++++
 linux-2.6.git-dave/ipc/mqueue.c |    3 +++
 linux-2.6.git-dave/net/socket.c |    5 +++++
 3 files changed, 15 insertions(+)

diff -puN fs/aio.c~no-checkpointing-for-sockets fs/aio.c
--- linux-2.6.git/fs/aio.c~no-checkpointing-for-sockets	2008-10-09 11:56:58.000000000 -0700
+++ linux-2.6.git-dave/fs/aio.c	2008-10-09 11:56:58.000000000 -0700
@@ -19,6 +19,7 @@
 
 #define DEBUG 0
 
+#include <linux/checkpoint.h>
 #include <linux/sched.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -1663,6 +1664,8 @@ asmlinkage long sys_io_submit(aio_contex
 	if (unlikely(!access_ok(VERIFY_READ, iocbpp, (nr*sizeof(*iocbpp)))))
 		return -EFAULT;
 
+	process_deny_checkpointing(current);
+
 	ctx = lookup_ioctx(ctx_id);
 	if (unlikely(!ctx)) {
 		pr_debug("EINVAL: io_submit: invalid context id\n");
@@ -1742,6 +1745,8 @@ asmlinkage long sys_io_cancel(aio_contex
 	if (unlikely(!ctx))
 		return -EINVAL;
 
+	process_deny_checkpointing(current);
+
 	spin_lock_irq(&ctx->ctx_lock);
 	ret = -EAGAIN;
 	kiocb = lookup_kiocb(ctx, iocb, key);
@@ -1796,6 +1801,8 @@ asmlinkage long sys_io_getevents(aio_con
 	struct kioctx *ioctx = lookup_ioctx(ctx_id);
 	long ret = -EINVAL;
 
+	process_deny_checkpointing(current);
+
 	if (likely(ioctx)) {
 		if (likely(min_nr <= nr && min_nr >= 0 && nr >= 0))
 			ret = read_events(ioctx, min_nr, nr, events, timeout);
diff -puN ipc/mqueue.c~no-checkpointing-for-sockets ipc/mqueue.c
--- linux-2.6.git/ipc/mqueue.c~no-checkpointing-for-sockets	2008-10-09 11:56:58.000000000 -0700
+++ linux-2.6.git-dave/ipc/mqueue.c	2008-10-09 11:56:58.000000000 -0700
@@ -14,6 +14,7 @@
  */
 
 #include <linux/capability.h>
+#include <linux/checkpoint.h>
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/file.h>
@@ -655,6 +656,8 @@ asmlinkage long sys_mq_open(const char _
 	char *name;
 	int fd, error;
 
+	process_deny_checkpointing(current);
+
 	error = audit_mq_open(oflag, mode, u_attr);
 	if (error != 0)
 		return error;
diff -puN net/socket.c~no-checkpointing-for-sockets net/socket.c
--- linux-2.6.git/net/socket.c~no-checkpointing-for-sockets	2008-10-09 11:56:58.000000000 -0700
+++ linux-2.6.git-dave/net/socket.c	2008-10-09 11:56:58.000000000 -0700
@@ -87,6 +87,7 @@
 #include <linux/audit.h>
 #include <linux/wireless.h>
 #include <linux/nsproxy.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -1236,6 +1237,8 @@ asmlinkage long sys_socket(int family, i
 	if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK))
 		flags = (flags & ~SOCK_NONBLOCK) | O_NONBLOCK;
 
+	process_deny_checkpointing(current);
+
 	retval = sock_create(family, type, protocol, &sock);
 	if (retval < 0)
 		goto out;
@@ -2130,6 +2133,8 @@ asmlinkage long sys_socketcall(int call,
 	a0 = a[0];
 	a1 = a[1];
 
+	process_deny_checkpointing(current);
+
 	switch (call) {
 	case SYS_SOCKET:
 		err = sys_socket(a0, a1, a[2]);
_
