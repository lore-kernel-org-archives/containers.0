From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] checkpoint: fix net/checkpoint.c for 64-bit
Date: Thu,  3 Dec 2009 13:50:07 -0600
Message-ID: <1259869807-12835-2-git-send-email-ntl@pobox.com>
References: <Pine.LNX.4.64.0912012352420.5665@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0912012352420.5665-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

When NET_SKBUFF_DATA_USES_OFFSET is defined:

net/checkpoint.c:100: error: invalid operands to binary - (have
'sk_buff_data_t' and 'unsigned char *')

net/checkpoint.c:106: error: 'struct sk_buff' has no member named
'transport_hdr'

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 net/checkpoint.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/checkpoint.c b/net/checkpoint.c
index 56bb026..c1c3e29 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -97,13 +97,13 @@ static void sock_record_header_info(struct sk_buff *skb,
 	h->mac_len = skb->mac_len;
 	h->skb_len = skb->len;
 	h->hdr_len = skb->data - skb->head;
-	h->lin_len = (skb->tail - skb->head);
+	h->lin_len = ((unsigned long)skb->tail - (unsigned long)skb->head);
 	h->frg_len = skb->data_len;
 
 	h->data_offset = (skb->data - skb->head);
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	h->transport_header = skb->transport_hdr;
+	h->transport_header = skb->transport_header;
 	h->network_header = skb->network_header;
 	h->mac_header = skb->mac_header;
 #else
-- 
1.6.0.6
