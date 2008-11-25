From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 49/53] netns PF_KEY: per-netns /proc/pfkey
Date: Tue, 25 Nov 2008 20:27:21 +0300
Message-ID: <1227634045-27534-49-git-send-email-adobriyan__43379.3458658785$1227637615$gmane$org@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-2-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-3-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-4-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-5-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-6-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-7-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-8-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-9-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-10-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-11-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-12-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-13-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-14-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-15-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-16-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-17-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-18-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-19-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-20-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-21-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-22-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-23-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-24-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-25-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-26-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-27-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-28-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-29-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-30-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-31-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-32-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-33-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-34-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-35-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-36-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-37-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-38-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-39-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-40-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-41-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-42-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-43-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-44-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-45-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-46-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-47-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-48-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-48-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/key/af_key.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index bb78ef9..f8bd8df 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3673,7 +3673,7 @@ static int pfkey_seq_show(struct seq_file *f, void *v)
 
 static void *pfkey_seq_start(struct seq_file *f, loff_t *ppos)
 {
-	struct net *net = &init_net;
+	struct net *net = seq_file_net(f);
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 	struct sock *s;
 	struct hlist_node *node;
@@ -3692,7 +3692,7 @@ static void *pfkey_seq_start(struct seq_file *f, loff_t *ppos)
 
 static void *pfkey_seq_next(struct seq_file *f, void *v, loff_t *ppos)
 {
-	struct net *net = &init_net;
+	struct net *net = seq_file_net(f);
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 
 	++*ppos;
@@ -3715,38 +3715,39 @@ static struct seq_operations pfkey_seq_ops = {
 
 static int pfkey_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &pfkey_seq_ops);
+	return seq_open_net(inode, file, &pfkey_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 static struct file_operations pfkey_proc_ops = {
 	.open	 = pfkey_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
-static int pfkey_init_proc(void)
+static int __net_init pfkey_init_proc(struct net *net)
 {
 	struct proc_dir_entry *e;
 
-	e = proc_net_fops_create(&init_net, "pfkey", 0, &pfkey_proc_ops);
+	e = proc_net_fops_create(net, "pfkey", 0, &pfkey_proc_ops);
 	if (e == NULL)
 		return -ENOMEM;
 
 	return 0;
 }
 
-static void pfkey_exit_proc(void)
+static void pfkey_exit_proc(struct net *net)
 {
-	proc_net_remove(&init_net, "pfkey");
+	proc_net_remove(net, "pfkey");
 }
 #else
-static inline int pfkey_init_proc(void)
+static int __net_init pfkey_init_proc(struct net *net)
 {
 	return 0;
 }
 
-static inline void pfkey_exit_proc(void)
+static void pfkey_exit_proc(struct net *net)
 {
 }
 #endif
@@ -3777,8 +3778,12 @@ static int __net_init pfkey_net_init(struct net *net)
 	rv = net_assign_generic(net, pfkey_net_id, net_pfkey);
 	if (rv < 0)
 		goto out_assign;
+	rv = pfkey_init_proc(net);
+	if (rv < 0)
+		goto out_proc;
 	return 0;
 
+out_proc:
 out_assign:
 	kfree(net_pfkey);
 out_kmalloc:
@@ -3789,6 +3794,7 @@ static void __net_exit pfkey_net_exit(struct net *net)
 {
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 
+	pfkey_exit_proc(net);
 	BUG_ON(!hlist_empty(&net_pfkey->table));
 	kfree(net_pfkey);
 }
@@ -3802,7 +3808,6 @@ static void __exit ipsec_pfkey_exit(void)
 {
 	unregister_pernet_gen_subsys(pfkey_net_id, &pfkey_net_ops);
 	xfrm_unregister_km(&pfkeyv2_mgr);
-	pfkey_exit_proc();
 	sock_unregister(PF_KEY);
 	proto_unregister(&key_proto);
 }
@@ -3817,12 +3822,9 @@ static int __init ipsec_pfkey_init(void)
 	err = sock_register(&pfkey_family_ops);
 	if (err != 0)
 		goto out_unregister_key_proto;
-	err = pfkey_init_proc();
-	if (err != 0)
-		goto out_sock_unregister;
 	err = xfrm_register_km(&pfkeyv2_mgr);
 	if (err != 0)
-		goto out_remove_proc_entry;
+		goto out_sock_unregister;
 	err = register_pernet_gen_subsys(&pfkey_net_id, &pfkey_net_ops);
 	if (err != 0)
 		goto out_xfrm_unregister_km;
@@ -3830,8 +3832,6 @@ out:
 	return err;
 out_xfrm_unregister_km:
 	xfrm_unregister_km(&pfkeyv2_mgr);
-out_remove_proc_entry:
-	pfkey_exit_proc();
 out_sock_unregister:
 	sock_unregister(PF_KEY);
 out_unregister_key_proto:
-- 
1.5.6.5
