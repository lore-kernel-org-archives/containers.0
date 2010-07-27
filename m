From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] Fix restoring unlinked UNIX sockets
Date: Tue, 27 Jul 2010 08:57:18 -0700
Message-ID: <1280246238-26637-3-git-send-email-danms@us.ibm.com>
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

We already support the concept, but the logic controlling whether or not we
restore the CWD path didn't follow.  This patch adds a check of the
"unlinked" flag we've already set before saving or restoring the CWD string.

This fixes an issue with a real-world workload that I have which utilizes
AF_UNIX sockets.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/unix/checkpoint.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 47d38e2..9522c3a 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -165,7 +165,8 @@ int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
 	if (ret < 0)
 		goto out;
 
-	if (unix_need_cwd(&un->laddr, un->laddr_len))
+	if (unix_need_cwd(&un->laddr, un->laddr_len) &&
+	    (un->flags & CKPT_UNIX_LINKED))
 		ret = unix_write_cwd(ctx, sock->sk, un->laddr.sun_path);
  out:
 	ckpt_hdr_put(ctx, un);
@@ -614,10 +615,12 @@ int unix_restore(struct ckpt_ctx *ctx, struct socket *sock,
 	if (un->peer < 0)
 		goto out;
 
-	if (unix_need_cwd(&un->laddr, un->laddr_len)) {
+	if (unix_need_cwd(&un->laddr, un->laddr_len) &&
+	    (un->flags & CKPT_UNIX_LINKED)) {
 		cwd = ckpt_read_string(ctx, PATH_MAX);
 		if (IS_ERR(cwd)) {
 			ret = PTR_ERR(cwd);
+			cwd = NULL;
 			goto out;
 		}
 	}
-- 
1.7.1.1
