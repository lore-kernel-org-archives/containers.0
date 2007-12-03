From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 20/38][IPV6] fib6_rules - make fib_rules per network
	namespace
Date: Mon, 03 Dec 2007 17:16:56 +0100
Message-ID: <20071203162506.886033709@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=fib6-rules-per-network-namespace.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: den-3ImXcnM4P+0@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

This patch makes the fib6_rules per network namespace.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/fib6_rules.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: linux-2.6-netns/net/ipv6/fib6_rules.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/fib6_rules.c
+++ linux-2.6-netns/net/ipv6/fib6_rules.c
@@ -53,6 +53,7 @@ static int fib6_rule_action(struct fib_r
 			    int flags, struct fib_lookup_arg *arg)
 {
 	struct rt6_info *rt = NULL;
+	struct net *net = flp->fl_net;
 	struct fib6_table *table;
 	pol_lookup_t lookup = arg->lookup_ptr;
 
@@ -71,7 +72,7 @@ static int fib6_rule_action(struct fib_r
 		goto discard_pkt;
 	}
 
-	table = fib6_get_table(&init_net, rule->table);
+	table = fib6_get_table(net, rule->table);
 	if (table)
 		rt = lookup(table, flp, flags);
 
@@ -145,13 +146,14 @@ static int fib6_rule_configure(struct fi
 			       struct nlattr **tb)
 {
 	int err = -EINVAL;
+	struct net *net = skb->sk->sk_net;
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
 
 	if (rule->action == FR_ACT_TO_TBL) {
 		if (rule->table == RT6_TABLE_UNSPEC)
 			goto errout;
 
-		if (fib6_new_table(&init_net, rule->table) == NULL) {
+		if (fib6_new_table(net, rule->table) == NULL) {
 			err = -ENOBUFS;
 			goto errout;
 		}

-- 
