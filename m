From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Remove some unnecessary checks on socket restart
Date: Thu,  1 Oct 2009 14:40:28 -0700
Message-ID: <1254433228-20882-1-git-send-email-danms@us.ibm.com>
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

These two checks are removed because they cannot be true because of the
unsigned nature of the values being examined

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
---
 net/checkpoint.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index a11ec7a..017c7f8 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -480,12 +480,10 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
 		ckpt_debug("socket/sock in inconsistent state: %i/%i",
 			   h->socket.state, h->sock.state);
 		return -EINVAL;
-	} else if ((h->sock.state < TCP_ESTABLISHED) ||
-		   (h->sock.state >= TCP_MAX_STATES)) {
+	} else if (h->sock.state >= TCP_MAX_STATES) {
 		ckpt_debug("sock in invalid state: %i", h->sock.state);
 		return -EINVAL;
-	} else if ((h->socket.state < SS_FREE) ||
-		   (h->socket.state > SS_DISCONNECTING)) {
+	} else if (h->socket.state > SS_DISCONNECTING) {
 		ckpt_debug("socket in invalid state: %i",
 			   h->socket.state);
 		return -EINVAL;
-- 
1.6.0.4
