From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 03/38][IPV6] inet6_addr - isolate inet6 addresses from proc
	file
Date: Mon, 03 Dec 2007 17:16:39 +0100
Message-ID: <20071203162437.590817219@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=inet6-addr-handle-procfs.patch
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

Make /proc/net/if_inet6 show only inet6 addresses belonging
to the namespace. 

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/addrconf.c |   48 +++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 39 insertions(+), 9 deletions(-)

Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -2699,6 +2699,7 @@ static void addrconf_dad_run(struct inet
 
 #ifdef CONFIG_PROC_FS
 struct if6_iter_state {
+	struct seq_net_private p;
 	int bucket;
 };
 
@@ -2706,11 +2707,16 @@ static struct inet6_ifaddr *if6_get_firs
 {
 	struct inet6_ifaddr *ifa = NULL;
 	struct if6_iter_state *state = seq->private;
+	struct net *net = state->p.net;
 
 	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
 		ifa = inet6_addr_lst[state->bucket];
-		if (ifa)
-			break;
+
+		while (ifa && ifa->idev->dev->nd_net != net)
+			ifa = ifa->lst_next;
+		if (!ifa)
+			continue;
+		break;
 	}
 	return ifa;
 }
@@ -2718,13 +2724,22 @@ static struct inet6_ifaddr *if6_get_firs
 static struct inet6_ifaddr *if6_get_next(struct seq_file *seq, struct inet6_ifaddr *ifa)
 {
 	struct if6_iter_state *state = seq->private;
+	struct net *net = state->p.net;
 
 	ifa = ifa->lst_next;
 try_again:
+	if (ifa) {
+		if (ifa->idev->dev->nd_net != net) {
+			ifa = ifa->lst_next;
+			goto try_again;
+		}
+	}
+
 	if (!ifa && ++state->bucket < IN6_ADDR_HSIZE) {
 		ifa = inet6_addr_lst[state->bucket];
 		goto try_again;
 	}
+
 	return ifa;
 }
 
@@ -2781,8 +2796,8 @@ static const struct seq_operations if6_s
 
 static int if6_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &if6_seq_ops,
-			sizeof(struct if6_iter_state));
+	return seq_open_net(inode, file, &if6_seq_ops,
+			    sizeof(struct if6_iter_state));
 }
 
 static const struct file_operations if6_fops = {
@@ -2790,19 +2805,34 @@ static const struct file_operations if6_
 	.open		= if6_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release_net,
+};
+
+static int if6_proc_net_init(struct net *net)
+{
+	if (!proc_net_fops_create(net, "if_inet6", S_IRUGO, &if6_fops))
+                return -ENOMEM;
+        return 0;
+}
+
+static void if6_proc_net_exit(struct net *net)
+{
+       proc_net_remove(net, "if_inet6");
+}
+
+static struct pernet_operations if6_proc_net_ops = {
+       .init = if6_proc_net_init,
+       .exit = if6_proc_net_exit,
 };
 
 int __init if6_proc_init(void)
 {
-	if (!proc_net_fops_create(&init_net, "if_inet6", S_IRUGO, &if6_fops))
-		return -ENOMEM;
-	return 0;
+	return register_pernet_subsys(&if6_proc_net_ops);
 }
 
 void if6_proc_exit(void)
 {
-	proc_net_remove(&init_net, "if_inet6");
+	unregister_pernet_subsys(&if6_proc_net_ops);
 }
 #endif	/* CONFIG_PROC_FS */
 

-- 
