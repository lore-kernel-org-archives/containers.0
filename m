From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 52/53] netns xfrm: /proc/net/xfrm_stat in netns
Date: Tue, 25 Nov 2008 20:27:24 +0300
Message-ID: <1227634045-27534-52-git-send-email-adobriyan__38506.6694616855$1227636477$gmane$org@gmail.com>
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
	<1227634045-27534-49-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-50-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-51-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-51-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
 include/net/xfrm.h     |    3 ++-
 net/xfrm/xfrm_policy.c |   11 +++++++----
 net/xfrm/xfrm_proc.c   |   26 ++++++++++++--------------
 3 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 78ec3e8..1554ccd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1306,7 +1306,8 @@ static inline void xfrm6_fini(void)
 #endif
 
 #ifdef CONFIG_XFRM_STATISTICS
-extern int xfrm_proc_init(void);
+extern int xfrm_proc_init(struct net *net);
+extern void xfrm_proc_fini(struct net *net);
 #endif
 
 extern void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e239a25..38822b3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2377,14 +2377,20 @@ static struct notifier_block xfrm_dev_notifier = {
 #ifdef CONFIG_XFRM_STATISTICS
 static int __net_init xfrm_statistics_init(struct net *net)
 {
+	int rv;
+
 	if (snmp_mib_init((void **)net->mib.xfrm_statistics,
 			  sizeof(struct linux_xfrm_mib)) < 0)
 		return -ENOMEM;
-	return 0;
+	rv = xfrm_proc_init(net);
+	if (rv < 0)
+		snmp_mib_free((void **)net->mib.xfrm_statistics);
+	return rv;
 }
 
 static void xfrm_statistics_fini(struct net *net)
 {
+	xfrm_proc_fini(net);
 	snmp_mib_free((void **)net->mib.xfrm_statistics);
 }
 #else
@@ -2524,9 +2530,6 @@ void __init xfrm_init(void)
 {
 	register_pernet_subsys(&xfrm_net_ops);
 	xfrm_input_init();
-#ifdef CONFIG_XFRM_STATISTICS
-	xfrm_proc_init();
-#endif
 }
 
 #ifdef CONFIG_AUDITSYSCALL
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 27a2ab9..284eaef 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -59,17 +59,18 @@ fold_field(void *mib[], int offt)
 
 static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq->private;
 	int i;
 	for (i=0; xfrm_mib_list[i].name; i++)
 		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
-			   fold_field((void **)init_net.mib.xfrm_statistics,
+			   fold_field((void **)net->mib.xfrm_statistics,
 				      xfrm_mib_list[i].entry));
 	return 0;
 }
 
 static int xfrm_statistics_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, xfrm_statistics_seq_show, NULL);
+	return single_open_net(inode, file, xfrm_statistics_seq_show);
 }
 
 static struct file_operations xfrm_statistics_seq_fops = {
@@ -77,21 +78,18 @@ static struct file_operations xfrm_statistics_seq_fops = {
 	.open	 = xfrm_statistics_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = single_release_net,
 };
 
-int __init xfrm_proc_init(void)
+int __net_init xfrm_proc_init(struct net *net)
 {
-	int rc = 0;
-
-	if (!proc_net_fops_create(&init_net, "xfrm_stat", S_IRUGO,
+	if (!proc_net_fops_create(net, "xfrm_stat", S_IRUGO,
 				  &xfrm_statistics_seq_fops))
-		goto stat_fail;
-
- out:
-	return rc;
+		return -ENOMEM;
+	return 0;
+}
 
- stat_fail:
-	rc = -ENOMEM;
-	goto out;
+void xfrm_proc_fini(struct net *net)
+{
+	proc_net_remove(net, "xfrm_stat");
 }
-- 
1.5.6.5
