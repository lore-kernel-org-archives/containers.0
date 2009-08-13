From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] Save and restore UNIX socket peer credentials
Date: Thu, 13 Aug 2009 12:29:09 -0700
Message-ID: <1250191750-3864-4-git-send-email-danms@us.ibm.com>
References: <1250191750-3864-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250191750-3864-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This saves the uid/gid of the sk_peercred structure in the checkpoint
stream.  On restart, it uses may_setuid() and may_setgid() to determine
if the uid/gid from the checkpoint stream may be used.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    2 ++
 net/unix/checkpoint.c          |   29 ++++++++++++++++-------------
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 829ff2d..6c6780c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -523,6 +523,8 @@ struct ckpt_hdr_socket_unix {
 	struct ckpt_hdr h;
 	__s32 this;
 	__s32 peer;
+	__u32 peercred_uid;
+	__u32 peercred_gid;
 	__u32 flags;
 	__u32 laddr_len;
 	__u32 raddr_len;
diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
index 841d25d..eb19e66 100644
--- a/net/unix/checkpoint.c
+++ b/net/unix/checkpoint.c
@@ -3,6 +3,7 @@
 #include <linux/fs_struct.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/user.h>
 #include <net/af_unix.h>
 #include <net/tcp_states.h>
 
@@ -98,6 +99,9 @@ int sock_unix_checkpoint(struct ckpt_ctx *ctx,
 		goto out;
 	}
 
+	un->peercred_uid = socket->sk->sk_peercred.uid;
+	un->peercred_gid = socket->sk->sk_peercred.gid;
+
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	if (ret < 0)
 		goto out;
@@ -225,19 +229,6 @@ static int sock_unix_join(struct ckpt_ctx *ctx,
 	unix_sk(a)->peer = b;
 	unix_sk(b)->peer = a;
 
-	/* TODO:
-	 * Checkpoint the credentials, restore them here if the values match
-	 * the restored creds or we may_setuid()
-	 */
-
-	a->sk_peercred.pid = task_tgid_vnr(current);
-	a->sk_peercred.uid = ctx->realcred->uid;
-	a->sk_peercred.gid = ctx->realcred->gid;
-
-	b->sk_peercred.pid = a->sk_peercred.pid;
-	b->sk_peercred.uid = a->sk_peercred.uid;
-	b->sk_peercred.gid = a->sk_peercred.gid;
-
 	if (!UNIX_ADDR_EMPTY(un->raddr_len))
 		addr = sock_unix_makeaddr(&un->raddr, un->raddr_len);
 	else if (!UNIX_ADDR_EMPTY(un->laddr_len))
@@ -303,6 +294,18 @@ static int sock_unix_restore_connected(struct ckpt_ctx *ctx,
 		goto out;
 	}
 
+	this->sk_peercred.pid = task_tgid_vnr(current);
+
+	if (may_setuid(ctx->realcred->user->user_ns, un->peercred_uid) &&
+	    may_setgid(ctx->realcred->group_info, un->peercred_gid)) {
+		this->sk_peercred.uid = un->peercred_uid;
+		this->sk_peercred.gid = un->peercred_gid;
+	} else {
+		ckpt_debug("peercred %i:%i would require setuid",
+			   un->peercred_uid, un->peercred_gid);
+		return -1;
+	}
+
 	/* Prime the socket's buffer limit with the maximum.  These will be
 	 * overwritten with the values in the checkpoint stream in a later
 	 * phase.
-- 
1.6.0.4
