From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 27/38][IPV6] route6 - Make proc entry /proc/net/rt6_stats
	per namespace
Date: Mon, 03 Dec 2007 17:17:03 +0100
Message-ID: <20071203162517.877233957@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=route6-make-proc-entry-rt6_stats-per-namespace.patch
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

Make the proc entry /proc/net/rt6_stats work in all network namespace.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/route.c |   26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

Index: linux-2.6-netns/net/ipv6/route.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/route.c
+++ linux-2.6-netns/net/ipv6/route.c
@@ -2350,21 +2350,31 @@ static const struct file_operations ipv6
 
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = (struct net*)seq->private;
 	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
-		   init_net.rt6_stats->fib_nodes,
-		   init_net.rt6_stats->fib_route_nodes,
-		   init_net.rt6_stats->fib_rt_alloc,
-		   init_net.rt6_stats->fib_rt_entries,
-		   init_net.rt6_stats->fib_rt_cache,
+		   net->rt6_stats->fib_nodes,
+		   net->rt6_stats->fib_route_nodes,
+		   net->rt6_stats->fib_rt_alloc,
+		   net->rt6_stats->fib_rt_entries,
+		   net->rt6_stats->fib_rt_cache,
 		   atomic_read(&ip6_dst_ops.entries),
-		   init_net.rt6_stats->fib_discarded_routes);
+		   net->rt6_stats->fib_discarded_routes);
 
 	return 0;
 }
 
 static int rt6_stats_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, rt6_stats_seq_show, NULL);
+	struct net *net = get_proc_net(inode);
+	return single_open(file, rt6_stats_seq_show, net);
+}
+
+static int rt6_stats_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct net *net = (struct net *)seq->private;
+	put_net(net);
+	return single_release(inode, file);
 }
 
 static const struct file_operations rt6_stats_seq_fops = {
@@ -2372,7 +2382,7 @@ static const struct file_operations rt6_
 	.open	 = rt6_stats_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = rt6_stats_seq_release,
 };
 #endif	/* CONFIG_PROC_FS */
 

-- 
