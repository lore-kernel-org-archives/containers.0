From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 01/33] nf_conntrack_sip: de-static helper pointers
Date: Mon,  8 Sep 2008 07:02:38 +0400
Message-ID: <1220842990-30500-1-git-send-email-adobriyan__23696.8749821701$1220843168$gmane$org@gmail.com>
References: <48C01046.2070704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C01046.2070704-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

->help hook can run concurrently with itself, so iterating over SIP helpers
with static pointer can't work reliably.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 2f9bbc0..1fa306b 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1193,7 +1193,6 @@ static const struct sip_handler sip_handlers[] = {
 static int process_sip_response(struct sk_buff *skb,
 				const char **dptr, unsigned int *datalen)
 {
-	static const struct sip_handler *handler;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	unsigned int matchoff, matchlen;
@@ -1214,6 +1213,8 @@ static int process_sip_response(struct sk_buff *skb,
 	dataoff = matchoff + matchlen + 1;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
+		const struct sip_handler *handler;
+
 		handler = &sip_handlers[i];
 		if (handler->response == NULL)
 			continue;
@@ -1228,13 +1229,14 @@ static int process_sip_response(struct sk_buff *skb,
 static int process_sip_request(struct sk_buff *skb,
 			       const char **dptr, unsigned int *datalen)
 {
-	static const struct sip_handler *handler;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	unsigned int matchoff, matchlen;
 	unsigned int cseq, i;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
+		const struct sip_handler *handler;
+
 		handler = &sip_handlers[i];
 		if (handler->request == NULL)
 			continue;
