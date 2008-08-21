From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH 24/38] netns ct: per-netns statistics in proc
Date: Fri, 22 Aug 2008 02:07:04 +0400
Message-ID: <20080821220704.GX31136__34593.4146469974$1219356904$gmane$org@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |   14 +++++++++-----
 net/netfilter/nf_conntrack_standalone.c               |   15 +++++++++------
 2 files changed, 18 insertions(+), 11 deletions(-)

--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -285,6 +285,7 @@ static const struct file_operations ip_exp_file_ops = {
 
 static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	struct net *net = seq_file_net(seq);
 	int cpu;
 
 	if (*pos == 0)
@@ -294,7 +295,7 @@ static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
-		return per_cpu_ptr(init_net.ct.stat, cpu);
+		return per_cpu_ptr(net->ct.stat, cpu);
 	}
 
 	return NULL;
@@ -302,13 +303,14 @@ static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 
 static void *ct_cpu_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
+	struct net *net = seq_file_net(seq);
 	int cpu;
 
 	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu+1;
-		return per_cpu_ptr(init_net.ct.stat, cpu);
+		return per_cpu_ptr(net->ct.stat, cpu);
 	}
 
 	return NULL;
@@ -320,7 +322,8 @@ static void ct_cpu_seq_stop(struct seq_file *seq, void *v)
 
 static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 {
-	unsigned int nr_conntracks = atomic_read(&init_net.ct.count);
+	struct net *net = seq_file_net(seq);
+	unsigned int nr_conntracks = atomic_read(&net->ct.count);
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
@@ -360,7 +363,8 @@ static const struct seq_operations ct_cpu_seq_ops = {
 
 static int ct_cpu_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ct_cpu_seq_ops);
+	return seq_open_net(inode, file, &ct_cpu_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 static const struct file_operations ct_cpu_seq_fops = {
@@ -368,7 +372,7 @@ static const struct file_operations ct_cpu_seq_fops = {
 	.open    = ct_cpu_seq_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 static int __net_init ip_conntrack_net_init(struct net *net)
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -194,6 +194,7 @@ static const struct file_operations ct_file_ops = {
 
 static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	struct net *net = seq_file_net(seq);
 	int cpu;
 
 	if (*pos == 0)
@@ -203,7 +204,7 @@ static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu + 1;
-		return per_cpu_ptr(init_net.ct.stat, cpu);
+		return per_cpu_ptr(net->ct.stat, cpu);
 	}
 
 	return NULL;
@@ -211,13 +212,14 @@ static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 
 static void *ct_cpu_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
+	struct net *net = seq_file_net(seq);
 	int cpu;
 
 	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
 		*pos = cpu + 1;
-		return per_cpu_ptr(init_net.ct.stat, cpu);
+		return per_cpu_ptr(net->ct.stat, cpu);
 	}
 
 	return NULL;
@@ -229,7 +231,8 @@ static void ct_cpu_seq_stop(struct seq_file *seq, void *v)
 
 static int ct_cpu_seq_show(struct seq_file *seq, void *v)
 {
-	unsigned int nr_conntracks = atomic_read(&init_net.ct.count);
+	struct net *net = seq_file_net(seq);
+	unsigned int nr_conntracks = atomic_read(&net->ct.count);
 	const struct ip_conntrack_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
@@ -269,7 +272,8 @@ static const struct seq_operations ct_cpu_seq_ops = {
 
 static int ct_cpu_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ct_cpu_seq_ops);
+	return seq_open_net(inode, file, &ct_cpu_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 static const struct file_operations ct_cpu_seq_fops = {
@@ -277,7 +281,7 @@ static const struct file_operations ct_cpu_seq_fops = {
 	.open	 = ct_cpu_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 static int nf_conntrack_standalone_init_proc(struct net *net)
-- 
1.5.6.3
