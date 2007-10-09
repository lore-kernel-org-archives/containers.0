From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 2/2][NETNS49][IPV4][UDPLITE] activate udplite per network
	namespace
Date: Tue, 09 Oct 2007 19:00:09 +0200
Message-ID: <20071009170207.876855063@mai.toulouse-stg.fr.ibm.com>
References: <20071009170007.487455316@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=net-ns-ipv4-udplite-per-namespace.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This patch activates the udplite protocol for multiple
network namespaces.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

---
 net/ipv4/udplite.c |   12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

Index: linux-2.6-netns/net/ipv4/udplite.c
===================================================================
--- linux-2.6-netns.orig/net/ipv4/udplite.c
+++ linux-2.6-netns/net/ipv4/udplite.c
@@ -30,18 +30,11 @@ static int udplite_v4_get_port(struct so
 
 static int udplite_rcv(struct sk_buff *skb)
 {
-	if (skb->dev->nd_net != &init_net) {
-		kfree_skb(skb);
-		return 0;
-	}
 	return __udp4_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
 }
 
 static void udplite_err(struct sk_buff *skb, u32 info)
 {
-	if (skb->dev->nd_net != &init_net)
-		return;
-
 	return __udp4_lib_err(skb, info, udplite_hash);
 }
 
@@ -83,7 +76,7 @@ static struct inet_protosw udplite4_prot
 	.ops		=  &inet_dgram_ops,
 	.capability	= -1,
 	.no_check	=  0,		/* must checksum (RFC 3828) */
-	.flags		=  INET_PROTOSW_PERMANENT,
+	.flags		=  INET_PROTOSW_PERMANENT | INET_PROTOSW_NETNS,
 };
 
 #ifdef CONFIG_PROC_FS
@@ -99,9 +92,6 @@ static struct udp_seq_afinfo udplite4_se
 
 static int udplite4_proc_net_init(struct net *net)
 {
-	if (net != &init_net)
-		return -EPERM;
-
 	if (udp_proc_register(net, &udplite4_seq_afinfo)) /* udplite4_proc_init() */
 		printk(KERN_ERR "%s: Cannot register /proc!\n", __FUNCTION__);
 

-- 
