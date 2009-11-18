From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Correct data pointer offset calculation
Date: Wed, 18 Nov 2009 12:06:11 -0800
Message-ID: <1258574771-21310-1-git-send-email-danms@us.ibm.com>
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

The current data pointer offset calculation is not correct in all cases.
This patch records the offset and resets it on restore.  With this patch,
all of my test cases now pass and behave as they should.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    1 +
 net/checkpoint.c               |   11 ++++++++++-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 95ea3dd..4e57d37 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -605,6 +605,7 @@ struct ckpt_hdr_socket_buffer {
 	__u32 skb_len; /* Length of skb (adjusted) */
 	__u32 hdr_len; /* Length of skipped header */
 	__u32 mac_len;
+	__u32 data_offset; /* Offset of data pointer from head */
 	__s32 sk_objref;
 	__s32 pr_objref;
 	__u16 protocol;
diff --git a/net/checkpoint.c b/net/checkpoint.c
index c9d5b1e..2ac6a42 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -100,6 +100,8 @@ static void sock_record_header_info(struct sk_buff *skb,
 	h->lin_len = (skb->tail - skb->head);
 	h->frg_len = skb->data_len;
 
+	h->data_offset = (skb->data - skb->head);
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	h->transport_header = skb->transport_hdr;
 	h->network_header = skb->network_header;
@@ -140,6 +142,13 @@ int sock_restore_header_info(struct ckpt_ctx *ctx,
 		return -EINVAL;
 	}
 
+	if (h->data_offset > h->lin_len) {
+		ckpt_err(ctx, -EINVAL,
+			 "skb data offset %u > linear length %u\n",
+			 h->data_offset, h->lin_len);
+		return -EINVAL;
+	}
+
 	if (h->skb_len > SKB_MAX_ALLOC) {
 		ckpt_err(ctx, -EINVAL,
 			 "skb total length %u larger than max of %lu\n",
@@ -161,7 +170,7 @@ int sock_restore_header_info(struct ckpt_ctx *ctx,
 	 */
 	memcpy(skb->cb, h->cb, sizeof(skb->cb));
 
-	skb->data = skb->head + skb->hdr_len;
+	skb->data = skb->head + h->data_offset;
 	skb->len = h->skb_len;
 
 	skb_shinfo(skb)->gso_type = sk->sk_gso_type;
-- 
1.6.2.5
