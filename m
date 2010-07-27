From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Fix net buffer logic
Date: Tue, 27 Jul 2010 08:57:17 -0700
Message-ID: <1280246238-26637-2-git-send-email-danms@us.ibm.com>
References: <1280246238-26637-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280246238-26637-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

The previous change to the buffer save/restore logic caused us to
incorrectly attempt to restore buffers on a socket in a few instances
where flags may not be restored yet or we are in a temporarily altered
state.

So, keep the same logic, but save a flag to indicate whether buffers were
checkpointed to avoid the ambiguity at restore time.

Also, move the UNIX buffer restore point to the main function to avoid
potentially ignoring the flag on a socket we assume wouldn't have saved
buffers.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    2 ++
 net/checkpoint.c               |    4 +++-
 net/ipv4/checkpoint.c          |    2 +-
 net/unix/checkpoint.c          |    9 ++++++---
 4 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 9e8d518..f4f9577 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -596,6 +596,8 @@ struct ckpt_hdr_file_eventfd {
 struct ckpt_hdr_socket {
 	struct ckpt_hdr h;
 
+	__u8 has_buffers;
+
 	struct { /* struct socket */
 		__u64 flags;
 		__u8 state;
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 0d90af2..de8e454 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -761,6 +761,8 @@ static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
 	if (!h)
 		return -ENOMEM;
 
+	h->has_buffers = ckpt_sock_need_buffers(sk);
+
 	/* part I: common to all sockets */
 	ret = sock_cptrst(ctx, sk, h, CKPT_CPT);
 	if (ret < 0)
@@ -776,7 +778,7 @@ static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
 		goto out;
 
 	/* part III: socket buffers */
-	if (ckpt_sock_need_buffers(sk))
+	if (h->has_buffers)
 		ret = sock_defer_write_buffers(ctx, sk);
  out:
 	ckpt_hdr_put(ctx, h);
diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
index eb02175..ec42e57 100644
--- a/net/ipv4/checkpoint.c
+++ b/net/ipv4/checkpoint.c
@@ -539,7 +539,7 @@ int inet_restore(struct ckpt_ctx *ctx,
 		}
 	}
 
-	if (ckpt_sock_need_buffers(sock->sk))
+	if (h->has_buffers)
 		ret = inet_defer_restore_buffers(ctx, sock->sk);
  out:
 	ckpt_hdr_put(ctx, in);
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 1fa3d7e..47d38e2 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -443,9 +443,6 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
 		ckpt_debug("unix_defer_join: %i\n", ret);
 	}
 
-	if (ckpt_sock_need_buffers(sock->sk) && !ret)
-		ret = unix_defer_restore_buffers(ctx, un->this);
-
 	return ret;
 }
 
@@ -639,6 +636,12 @@ int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
 	else
 		ckpt_err(ctx, ret, "bad af_unix state %i\n", h->sock.state);
 
+	if (ret < 0)
+		goto out;
+
+	if (h->has_buffers)
+		ret = unix_defer_restore_buffers(ctx, un->this);
+
  out:
 	ckpt_hdr_put(ctx, un);
 	kfree(cwd);
-- 
1.7.1.1
