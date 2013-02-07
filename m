From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 03/10] netfilter: ebt_log: add net namespace support for
	ebt_log
Date: Thu, 7 Feb 2013 15:49:43 +0800
Message-ID: <1360223390-15589-3-git-send-email-gaofeng__41480.9273010634$1360223411$gmane$org@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lve-ke3WRBg/xIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
List-Id: containers.vger.kernel.org

Add pernet_operations for ebt_log, in pernet_ops,
we call nf_log_set/unset to set/unset nf_loggers
of per net.

Because the syslog ns has not been implemented,
we don't want the container DOS the host's syslog.
so only enable ebt_log in init_net and wait for
syslog ns.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/bridge/netfilter/ebt_log.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 1d397ac..a654240 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -78,6 +78,10 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
    const char *prefix)
 {
 	unsigned int bitmask;
+	struct net *net = dev_net((in != NULL) ? in : out);
+
+	if (!net_eq(net, &init_net))
+		return;
 
 	spin_lock_bh(&ebt_log_lock);
 	printk(KERN_SOH "%c%s IN=%s OUT=%s MAC source = %pM MAC dest = %pM proto = 0x%04x",
@@ -207,6 +211,22 @@ static struct nf_logger ebt_log_logger __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
+static int __net_init ebt_log_net_init(struct net *net)
+{
+	nf_log_set(net, NFPROTO_BRIDGE, &ebt_log_logger);
+	return 0;
+}
+
+static void __net_exit ebt_log_net_fini(struct net *net)
+{
+	nf_log_unset(net, &ebt_log_logger);
+}
+
+static struct pernet_operations ebt_log_net_ops = {
+	.init = ebt_log_net_init,
+	.exit = ebt_log_net_fini,
+};
+
 static int __init ebt_log_init(void)
 {
 	int ret;
@@ -214,12 +234,14 @@ static int __init ebt_log_init(void)
 	ret = xt_register_target(&ebt_log_tg_reg);
 	if (ret < 0)
 		return ret;
+
 	nf_log_register(NFPROTO_BRIDGE, &ebt_log_logger);
-	return 0;
+	return register_pernet_subsys(&ebt_log_net_ops);
 }
 
 static void __exit ebt_log_fini(void)
 {
+	unregister_pernet_subsys(&ebt_log_net_ops);
 	nf_log_unregister(&ebt_log_logger);
 	xt_unregister_target(&ebt_log_tg_reg);
 }
-- 
1.7.11.7
