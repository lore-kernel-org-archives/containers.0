From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] skb->tail can be offset
Date: Mon, 15 Feb 2010 16:12:14 -0600
Message-ID: <20100215221214.GA21108@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Needed for socket c/r on 64-bit arches.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index c6b6341..ee13050 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -97,19 +97,19 @@ static void sock_record_header_info(struct sk_buff *skb,
 	h->mac_len = skb->mac_len;
 	h->skb_len = skb->len;
 	h->hdr_len = skb->data - skb->head;
-	h->lin_len = ((unsigned long)skb->tail - (unsigned long)skb->head);
 	h->frg_len = skb->data_len;
-
 	h->data_offset = (skb->data - skb->head);
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	h->transport_header = skb->transport_header;
 	h->network_header = skb->network_header;
 	h->mac_header = skb->mac_header;
+	h->lin_len = (unsigned long) skb->tail;
 #else
 	h->transport_header = skb->transport_header - skb->head;
 	h->network_header = skb->network_header - skb->head;
 	h->mac_header = skb->mac_header - skb->head;
+	h->lin_len = ((unsigned long) skb->tail - (unsigned long) skb->head);
 #endif
 
 	memcpy(h->cb, skb->cb, sizeof(skb->cb));
-- 
1.6.0.6
