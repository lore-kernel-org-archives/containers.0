From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: [PATCH 2/4] netns: Export nets id to /proc/net/netns
Date: Wed, 22 Oct 2008 17:22:04 +0200
Message-ID: <20081022152144.753988954__17514.3724577085$1224689170$gmane$org@theryb.frec.bull.fr>
References: <20081022152144.351965414@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

This patches exports the new 'struct net' net->id value to /proc/net/nsid
file.

Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/core/net_namespace.c |   50 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

Index: net-next-2.6/net/core/net_namespace.c
===================================================================
--- net-next-2.6.orig/net/core/net_namespace.c
+++ net-next-2.6/net/core/net_namespace.c
@@ -6,6 +6,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <linux/idr.h>
+#include <linux/proc_fs.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -211,6 +212,53 @@ struct net *copy_net_ns(unsigned long fl
 }
 #endif
 
+#ifdef CONFIG_PROC_FS
+static int netns_seq_show(struct seq_file *seq, void *v)
+{
+	struct net *net = seq->private;
+
+	seq_printf(seq, "%x\n", net->id);
+	return 0;
+}
+
+static int netns_seq_open(struct inode *inode, struct file *file)
+{
+        return single_open_net(inode, file, netns_seq_show);
+}
+
+static const struct file_operations netns_seq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = netns_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release_net,
+};
+
+static int __net_init netns_net_init(struct net *net)
+{
+	if (!proc_net_fops_create(net, "nsid", S_IRUGO, &netns_seq_fops))
+		return -ENOMEM;
+	return 0;
+}
+
+static void __net_exit netns_net_exit(struct net *net)
+{
+	proc_net_remove(net, "nsid");
+}
+
+static struct pernet_operations netns_proc_ops = {
+	.init = netns_net_init,
+	.exit = netns_net_exit,
+};
+
+static int __init netns_proc_init()
+{
+	return register_pernet_subsys(&netns_proc_ops);
+}
+#else
+#define netns_proc_init() 0
+#endif /* CONFIG_PROC_FS */
+
 static int __init net_ns_init(void)
 {
 	int err;
@@ -226,6 +274,8 @@ static int __init net_ns_init(void)
 	if (!netns_wq)
 		panic("Could not create netns workq");
 #endif
+	if (netns_proc_init())
+		panic("Could not register netns subsys");
 
 	mutex_lock(&net_mutex);
 	err = setup_net(&init_net);

-- 
