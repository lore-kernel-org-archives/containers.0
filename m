From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Fix socket fd allocation on -rc3
Date: Tue,  9 Feb 2010 07:18:09 -0800
Message-ID: <1265728689-2359-1-git-send-email-danms@us.ibm.com>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Since the core socket functions expect to allocate an fd when they allocate
the file, we need to be sure to release that file descriptor so that the
core checkpoint file code can properly allocate it for us.  The core
socket function doesn't actually map the file and the fd together, so we
just have to release it once we get it.

Also, remove the #if 0 around the sock_hold() which was preventing the
refcount from being correct (and thus causing a premature socket closure
during restart).

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index 69a0a76..c6b6341 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -975,17 +975,13 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	fd = sock_alloc_file(sk->sk_socket, &file, O_RDWR);
 	if (fd < 0)
 		return ERR_PTR(fd);
+	put_unused_fd(fd); /* We'll let the checkpoint code re-allocate this */
 
-#if 0
 	/* Since objhash assumes the initial reference for a socket,
 	 * we bump it here for this descriptor, unlike other places in
 	 * the socket code which assume the descriptor is the owner.
 	 */
-	sock_hold(sock->sk);
-#endif
-
-	get_file(file);
-	sys_close(fd);
+	sock_hold(sk);
 
 	ret = restore_file_common(ctx, file, ptr);
 	if (ret < 0) {
-- 
1.6.2.5
