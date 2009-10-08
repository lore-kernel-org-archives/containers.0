From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Pass the stored sock->protocol into sock_create() on restore
Date: Thu,  8 Oct 2009 11:14:03 -0700
Message-ID: <1255025643-30282-1-git-send-email-danms@us.ibm.com>
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

This should be fine because the protocol sanity-checks the number to
make sure it's valid given the type specified.

Cc: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index 9a72aae..dd23efd 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -687,7 +687,8 @@ struct sock *do_sock_restore(struct ckpt_ctx *ctx)
 	/* silently clear flags, e.g. SOCK_NONBLOCK or SOCK_CLOEXEC */
 	h->sock.type &= SOCK_TYPE_MASK;
 
-	ret = sock_create(h->sock_common.family, h->sock.type, 0, &sock);
+	ret = sock_create(h->sock_common.family, h->sock.type,
+			  h->sock.protocol, &sock);
 	if (ret < 0)
 		goto err;
 
-- 
1.6.2.5
