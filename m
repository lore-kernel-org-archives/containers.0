From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 1/2][NETNS49][IPV4][IGMP] make igmp proc per namespace
Date: Fri, 12 Oct 2007 19:10:14 +0200
Message-ID: <20071012171154.096501954@mai.toulouse-stg.fr.ibm.com>
References: <20071012171013.105324992@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=net-ns-ipv4-igmp-proc-per-net.patch
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

This patch makes the proc files: "igmp" and "mcfilter" per namespace.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

---
 net/ipv4/igmp.c |   68 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 60 insertions(+), 8 deletions(-)

Index: linux-2.6-netns/net/ipv4/igmp.c
===================================================================
--- linux-2.6-netns.orig/net/ipv4/igmp.c
+++ linux-2.6-netns/net/ipv4/igmp.c
@@ -2291,6 +2291,7 @@ int ip_check_mc(struct in_device *in_dev
 struct igmp_mc_iter_state {
 	struct net_device *dev;
 	struct in_device *in_dev;
+	struct net *net;
 };
 
 #define	igmp_mc_seq_private(seq)	((struct igmp_mc_iter_state *)(seq)->private)
@@ -2299,9 +2300,10 @@ static inline struct ip_mc_list *igmp_mc
 {
 	struct ip_mc_list *im = NULL;
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
+	struct net *net = state->net;
 
 	state->in_dev = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct in_device *in_dev;
 		in_dev = in_dev_get(state->dev);
 		if (!in_dev)
@@ -2426,31 +2428,47 @@ static int igmp_mc_seq_open(struct inode
 
 	if (!s)
 		goto out;
+
+	s->net = get_proc_net(inode);
+	if (!s->net)
+		goto out_kfree;
+
 	rc = seq_open(file, &igmp_mc_seq_ops);
 	if (rc)
-		goto out_kfree;
+		goto out_put_net;
 
 	seq = file->private_data;
 	seq->private = s;
 out:
 	return rc;
+out_put_net:
+	put_net(s->net);
 out_kfree:
 	kfree(s);
 	goto out;
 }
 
+static int igmp_mc_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct igmp_mc_iter_state *state = seq->private;
+	put_net(state->net);
+	return seq_release_private(inode, file);
+}
+
 static const struct file_operations igmp_mc_seq_fops = {
 	.owner		=	THIS_MODULE,
 	.open		=	igmp_mc_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_private,
+	.release	=	igmp_mc_seq_release,
 };
 
 struct igmp_mcf_iter_state {
 	struct net_device *dev;
 	struct in_device *idev;
 	struct ip_mc_list *im;
+	struct net *net;
 };
 
 #define igmp_mcf_seq_private(seq)	((struct igmp_mcf_iter_state *)(seq)->private)
@@ -2460,10 +2478,11 @@ static inline struct ip_sf_list *igmp_mc
 	struct ip_sf_list *psf = NULL;
 	struct ip_mc_list *im = NULL;
 	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
+	struct net *net = state->net;
 
 	state->idev = NULL;
 	state->im = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct in_device *idev;
 		idev = in_dev_get(state->dev);
 		if (unlikely(idev == NULL))
@@ -2600,31 +2619,64 @@ static int igmp_mcf_seq_open(struct inod
 
 	if (!s)
 		goto out;
+
+	s->net = get_proc_net(inode);
+	if (!s->net)
+		goto out_kfree;
+
 	rc = seq_open(file, &igmp_mcf_seq_ops);
 	if (rc)
-		goto out_kfree;
+		goto out_put_net;
 
 	seq = file->private_data;
 	seq->private = s;
 out:
 	return rc;
+out_put_net:
+	put_net(s->net);
 out_kfree:
 	kfree(s);
 	goto out;
 }
 
+static int igmp_mcf_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct igmp_mcf_iter_state *state = seq->private;
+	put_net(state->net);
+	return seq_release_private(inode, file);
+
+}
+
 static const struct file_operations igmp_mcf_seq_fops = {
 	.owner		=	THIS_MODULE,
 	.open		=	igmp_mcf_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_private,
+	.release	=	igmp_mcf_seq_release,
+};
+
+static int igmp_mc_net_init(struct net *net)
+{
+	proc_net_fops_create(net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
+	proc_net_fops_create(net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
+	return 0;
+}
+
+static void igmp_mc_net_exit(struct net *net)
+{
+	proc_net_remove(net, "igmp");
+	proc_net_remove(net, "mcfilter");
+}
+
+struct pernet_operations igmp_mc_net_ops = {
+	.init = igmp_mc_net_init,
+	.exit = igmp_mc_net_exit,
 };
 
 int __init igmp_mc_proc_init(void)
 {
-	proc_net_fops_create(&init_net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
-	proc_net_fops_create(&init_net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
+	register_pernet_subsys(&igmp_mc_net_ops);
 	return 0;
 }
 #endif

-- 
