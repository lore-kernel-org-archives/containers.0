From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] Record and restore skb header marks (v2)
Date: Tue, 27 Oct 2009 10:53:26 -0700
Message-ID: <1256666008-8231-2-git-send-email-danms@us.ibm.com>
References: <1256666008-8231-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256666008-8231-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Save this information when we checkpoint an skb and provide a mechanism
to restore that information on restart.  This will be used in the
subsequent INET patch.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Changes in v2:
 - Add range checks to ensure that the header marks we restore
   are within the data length of the skb
---
 include/linux/checkpoint.h     |    2 +
 include/linux/checkpoint_hdr.h |    7 ++++++
 net/checkpoint.c               |   45 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 4b61378..c2832ac 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -100,6 +100,8 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 			      struct socket *socket,
 			      struct sockaddr *loc, unsigned *loc_len,
 			      struct sockaddr *rem, unsigned *rem_len);
+int sock_restore_header_info(struct sk_buff *skb,
+			     struct ckpt_hdr_socket_buffer *h);
 
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index ca2500d..3e6cab1 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -542,8 +542,15 @@ struct ckpt_hdr_socket_queue {
 
 struct ckpt_hdr_socket_buffer {
 	struct ckpt_hdr h;
+	__u64 mac_len;
+	__u64 hdr_len;
+	__u64 transport_header;
+	__u64 network_header;
+	__u64 mac_header;
 	__s32 sk_objref;
 	__s32 pr_objref;
+	__u16 protocol;
+	__u8 cb[48];
 };
 
 #define CKPT_UNIX_LINKED 1
diff --git a/net/checkpoint.c b/net/checkpoint.c
index dd23efd..50baea9 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -88,6 +88,50 @@ static int sock_copy_buffers(struct sk_buff_head *from,
 	return -EAGAIN;
 }
 
+static void sock_record_header_info(struct sk_buff *skb,
+				    struct ckpt_hdr_socket_buffer *h)
+{
+
+	h->mac_len = skb->mac_len;
+	h->hdr_len = skb->hdr_len;
+
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	h->transport_header = skb->transport_hdr;
+	h->network_header = skb->network_header;
+	h->mac_header = skb->mac_header;
+#else
+	h->transport_header = skb->transport_header - skb->head;
+	h->network_header = skb->network_header - skb->head;
+	h->mac_header = skb->mac_header - skb->head;
+#endif
+
+	memcpy(h->cb, skb->cb, sizeof(skb->cb));
+}
+
+int sock_restore_header_info(struct sk_buff *skb,
+			     struct ckpt_hdr_socket_buffer *h)
+{
+	if ((h->transport_header >= skb->len) ||
+	    (h->network_header >= skb->len) ||
+	    (h->mac_header >= skb->len) ||
+	    (h->mac_len >= skb->len) ||
+	    (h->hdr_len >= skb->len)) {
+		ckpt_debug("skb header positions not within data length\n");
+		return -EINVAL;
+	}
+
+	skb->mac_len = h->mac_len;
+	skb->hdr_len = h->hdr_len;
+
+	skb_set_transport_header(skb, h->transport_header);
+	skb_set_network_header(skb, h->network_header);
+	skb_set_mac_header(skb, h->mac_header);
+
+	memcpy(skb->cb, h->cb, sizeof(skb->cb));
+
+	return 0;
+}
+
 static int __sock_write_buffers(struct ckpt_ctx *ctx,
 				struct sk_buff_head *queue,
 				int dst_objref)
@@ -123,6 +167,7 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
 			goto end;
 		h->sk_objref = ret;
 		h->pr_objref = dst_objref;
+		sock_record_header_info(skb, h);
 
 		ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 		if (ret < 0)
-- 
1.6.2.5
