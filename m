From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Change net c/r to use exported page I/O functions
Date: Wed, 18 Nov 2009 07:33:19 -0800
Message-ID: <871vjvvoe8.fsf@caffeine.danplanet.com>
References: <1258489484-28227-1-git-send-email-danms@us.ibm.com>
	<1258489484-28227-3-git-send-email-danms@us.ibm.com>
	<20091118041707.GA19841@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091118041707.GA19841-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue\, 17 Nov 2009 22\:17\:07 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

SH> I assume you meant to get rid of this second ckpt_hdr_put()?

Yep, that was the reason I broke it out into a separate function and
then I forgot to remove it :)

Trivially updated version below.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org

Change net c/r to use exported page I/O functions (v2)

This changes the net c/r functions that save out the socket buffers to
use the exported page I/O functions, just like the memory dump routines.

Changes in v2:
 - Remove duplicate ckpt_hdr_put() in __sock_write_skb_frag()

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index d1a93e3..95ea3dd 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -170,6 +170,8 @@ enum {
 #define CKPT_HDR_SOCKET_QUEUE CKPT_HDR_SOCKET_QUEUE
 	CKPT_HDR_SOCKET_BUFFER,
 #define CKPT_HDR_SOCKET_BUFFER CKPT_HDR_SOCKET_BUFFER
+	CKPT_HDR_SOCKET_FRAG,
+#define CKPT_HDR_SOCKET_FRAG CKPT_HDR_SOCKET_FRAG
 	CKPT_HDR_SOCKET_UNIX,
 #define CKPT_HDR_SOCKET_UNIX CKPT_HDR_SOCKET_UNIX
 	CKPT_HDR_SOCKET_INET,
@@ -610,6 +612,12 @@ struct ckpt_hdr_socket_buffer {
 	__u8 cb[48];
 };
 
+struct ckpt_hdr_socket_buffer_frag {
+	struct ckpt_hdr h;
+	__u32 size;
+	__u32 offset;
+};
+
 #define CKPT_UNIX_LINKED 1
 struct ckpt_hdr_socket_unix {
 	struct ckpt_hdr h;
diff --git a/net/checkpoint.c b/net/checkpoint.c
index 7f7d914..83d9bc0 100644
--- a/net/checkpoint.c
+++ b/net/checkpoint.c
@@ -174,39 +174,42 @@ static int sock_restore_skb_frag(struct ckpt_ctx *ctx,
 				 int frag_idx)
 {
 	int ret = 0;
-	int fraglen;
 	struct page *page;
-	void *buf;
+	struct ckpt_hdr_socket_buffer_frag *h;
 
-	fraglen = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
-	if (fraglen < 0)
-		return fraglen;
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_FRAG);
+	if (IS_ERR(h)) {
+		ckpt_err(ctx, PTR_ERR(h), "failed to read buffer object\n");
+		return PTR_ERR(h);
+	}
 
-	if (fraglen > PAGE_SIZE) {
-		ckpt_err(ctx, -EINVAL,
-			 "skb frag size %i > PAGE_SIZE\n", fraglen);
-		return -EINVAL;
+	if ((h->size > PAGE_SIZE) || (h->offset >= PAGE_SIZE)) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret,
+			 "skb frag size=%i,offset=%i > PAGE_SIZE\n",
+			 h->size, h->offset);
+		goto out;
 	}
 
 	page = alloc_page(GFP_KERNEL);
-	if (!page)
-		return -ENOMEM;
-
-	buf = kmap(page);
-	ret = ckpt_kread(ctx, buf, fraglen);
-	kunmap(page);
+	if (!page) {
+		ret = -ENOMEM;
+		goto out;
+	}
 
+	ret = restore_read_page(ctx, page);
 	if (ret) {
-		ret = -EINVAL;
-		ckpt_err(ctx, ret,
-			 "failed to read fragment: %i\n", ret);
+		ckpt_err(ctx, ret, "failed to read fragment: %i\n", ret);
 		__free_page(page);
 	} else {
-		ckpt_debug("read %i for fragment %i\n", fraglen, frag_idx);
-		skb_add_rx_frag(skb, frag_idx, page, 0, fraglen);
+		ckpt_debug("read %i+%i for fragment %i\n",
+			   h->offset, h->size, frag_idx);
+		skb_add_rx_frag(skb, frag_idx, page, h->offset, h->size);
+		ret = h->size;
 	}
-
-	return ret < 0 ? ret : fraglen;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
 }
 
 struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx,
@@ -282,6 +285,34 @@ struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx,
 	return skb;
 }
 
+static int __sock_write_skb_frag(struct ckpt_ctx *ctx,
+				 skb_frag_t *frag)
+{
+	struct ckpt_hdr_socket_buffer_frag *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_FRAG);
+	if (!h)
+		return -ENOMEM;
+
+	h->size = frag->size;
+	h->offset = frag->page_offset;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
+	if (ret < 0)
+		goto out;
+
+	ret = checkpoint_dump_page(ctx, frag->page);
+	ckpt_debug("writing frag page: %i\n", ret);
+	if (ret < 0)
+		goto out;
+
+ out:
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
 static int __sock_write_skb(struct ckpt_ctx *ctx,
 			    struct sk_buff *skb,
 			    int dst_objref)
@@ -316,16 +347,12 @@ static int __sock_write_skb(struct ckpt_ctx *ctx,
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		u8 *vaddr = kmap(frag->page);
-
+		ret = __sock_write_skb_frag(ctx, frag);
 		ckpt_debug("writing buffer fragment %i/%i (%i)\n",
-			   i + 1, h->nr_frags, frag->size);
-		ret = ckpt_write_obj_type(ctx, vaddr + frag->page_offset,
-					  frag->size, CKPT_HDR_BUFFER);
-		kunmap(frag->page);
-		h->frg_len -= frag->size;
+			   i + 1, h->nr_frags, ret);
 		if (ret < 0)
 			goto out;
+		h->frg_len -= frag->size;
 	}
 
 	WARN_ON(h->frg_len != 0);
