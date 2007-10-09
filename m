From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 1/2][NETNS49][IPV4][UDPLITE] add udp_proc_register per net
Date: Tue, 09 Oct 2007 19:00:08 +0200
Message-ID: <20071009170206.404193237@mai.toulouse-stg.fr.ibm.com>
References: <20071009170007.487455316@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=net-ns-ipv4-udplite-proc-per-net.patch
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

This patch add a pernet subsystem to register /proc/net/udplite
per network namespace.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

---
 net/ipv4/udplite.c |   24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

Index: linux-2.6-netns/net/ipv4/udplite.c
===================================================================
--- linux-2.6-netns.orig/net/ipv4/udplite.c
+++ linux-2.6-netns/net/ipv4/udplite.c
@@ -96,6 +96,27 @@ static struct udp_seq_afinfo udplite4_se
 	.seq_show	= udp4_seq_show,
 	.seq_fops	= &udplite4_seq_fops,
 };
+
+static int udplite4_proc_net_init(struct net *net)
+{
+	if (net != &init_net)
+		return -EPERM;
+
+	if (udp_proc_register(net, &udplite4_seq_afinfo)) /* udplite4_proc_init() */
+		printk(KERN_ERR "%s: Cannot register /proc!\n", __FUNCTION__);
+
+	return 0;
+}
+
+static void udplite4_proc_net_exit(struct net *net)
+{
+	udp_proc_unregister(net, &udplite4_seq_afinfo);
+}
+
+static struct pernet_operations udplite4_proc_net_ops = {
+	.init = udplite4_proc_net_init,
+	.exit = udplite4_proc_net_exit,
+};
 #endif
 
 void __init udplite4_register(void)
@@ -109,8 +130,7 @@ void __init udplite4_register(void)
 	inet_register_protosw(&udplite4_protosw);
 
 #ifdef CONFIG_PROC_FS
-	if (udp_proc_register(&init_net, &udplite4_seq_afinfo)) /* udplite4_proc_init() */
-		printk(KERN_ERR "%s: Cannot register /proc!\n", __FUNCTION__);
+	register_pernet_subsys(&udplite4_proc_net_ops);
 #endif
 	return;
 

-- 
