From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 7/7] netns ebtables: br_nf_pre_routing_finish() fixup
Date: Wed, 29 Oct 2008 00:02:28 +0300
Message-ID: <20081028210228.GI15660@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-owner@vger.kernel.org
To: kaber@trash.net
Cc: netfilter@vger.kernel.org, containers@osdl.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/bridge/br_netfilter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -357,7 +357,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 			if (err != -EHOSTUNREACH || !in_dev || IN_DEV_FORWARD(in_dev))
 				goto free_skb;
 
-			if (!ip_route_output_key(&init_net, &rt, &fl)) {
+			if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 				/* - Bridged-and-DNAT'ed traffic doesn't
 				 *   require ip_forwarding. */
 				if (((struct dst_entry *)rt)->dev == dev) {
