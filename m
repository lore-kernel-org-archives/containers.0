From: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Subject: [PATCH] RFC containerized syslog and iptable log dispatching
	(working stage)
Date: Tue, 23 Feb 2010 16:01:19 -0500
Message-ID: <201002232058.o1NKwoJx020242@kernel.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Resent-Message-Id: <201002232101.o1NL1TqC026174-4srrYzrIIfvCUzpuK5MMl/d9D2ou9A/h@public.gmane.org>
Resent-To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

	Capability to redirect iptable log, in the right containerized
	syslog_ns, is now fully working.

	Tried my best to have a very minimal foot-print.

	BEWARE: patch not done for IPV6 (I can't test it),
	you are welcome to do it.

Signed-off-by:  Jean-Marc Pigeon        <jmp-4qkeo2rQ0gg@public.gmane.org>
---
 include/linux/netdevice.h    |    2 +
 include/linux/syslog.h       |    8 +++
 kernel/syslog.c              |  140 +++++++++++++++++++++++++++++++++++++++---
 net/core/rtnetlink.c         |    3 +
 net/ipv4/netfilter/ipt_LOG.c |   11 +++
 5 files changed, 154 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..c323463 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -918,6 +918,8 @@ struct net_device {
 	/* Network namespace this network device is inside */
 	struct net		*nd_net;
 #endif
+	/* to assign a syslog chanel according device ownership	*/
+	pid_t			syslog_ns_pid;
 
 	/* mid-layer private */
 	void			*ml_priv;
diff --git a/include/linux/syslog.h b/include/linux/syslog.h
index 9fbe190..2188f09 100644
--- a/include/linux/syslog.h
+++ b/include/linux/syslog.h
@@ -44,15 +44,23 @@ static inline void put_syslog_ns(struct syslog_ns *ns)
 #ifdef	CONFIG_PRINTK
 extern struct syslog_ns *current_syslog_ns(void);
 extern struct syslog_ns *switch_syslog_ns(struct syslog_ns *syslog_ns);
+extern struct syslog_ns *find_syslog_ns_bypid(pid_t pid);
 #else
 static inline syslog_ns *current_syslog_ns(void)
 {
 	return 0;
 }
+
 static inline struct syslog_ns *switch_syslog_ns(struct syslog_ns *syslog_ns)
 {
 	return syslog_ns;
 }
+
+static inline syslog_ns *find_syslog_ns_bypid(pid_t pid)
+
+{
+	return 0;
+}
 #endif
 
 #endif /* _LINUX_SYSLOG_H */
diff --git a/kernel/syslog.c b/kernel/syslog.c
index 9873c06..1ab9bdc 100644
--- a/kernel/syslog.c
+++ b/kernel/syslog.c
@@ -18,7 +18,8 @@
  *  where container kernel data are redirected, kept and
  *  managed.
  *
- *  Containerized syslog is activated by CLONE_SYSLOG
+ *  Containerized syslog is activated if CLONE_SYSLOG
+ *  condition is true.
  *
  */
 
@@ -47,23 +48,99 @@ struct syslog_ns init_kernel_syslog_ns = {
 	.buf_len = __LOG_BUF_LEN,
 	.buf = __log_buf
 };
-
 struct syslog_ns init_kernel_syslog_ns;
 EXPORT_SYMBOL_GPL(init_kernel_syslog_ns);
 
 /*
+ * List of all syslog ns currently allocated
+ * first member of this list (kernel syslog)
+ * can't be removed.
+ */
+struct	log_list	{
+	spinlock_t list_lock;		/*make sure about list access	*/
+	struct log_list *next;		/*next syslog_ns in the list	*/
+	struct syslog_ns *syslog_ns;
+	}  log_list = {
+		.list_lock = __SPIN_LOCK_INITIALIZER(list_lock),
+		.next = (struct log_list *)0,
+		.syslog_ns = &init_kernel_syslog_ns
+		};
+/*
+ * removing a syslog reference from the list
+ *
+ */
+static void removing_syslog_ns(struct syslog_ns *syslog_ns)
+
+{
+	int done;
+	struct log_list	*start;
+
+	done = false;
+	start = &log_list;
+	while (start->next != (struct log_list *)0) {
+		struct log_list	*check;
+		unsigned long flags;
+
+		spin_lock_irqsave(&(start->next->list_lock), flags);
+		check = start->next;
+		if (check->syslog_ns == syslog_ns) {
+			start->next = check->next;
+			done = true;
+			}
+		spin_unlock_irqrestore(&(check->list_lock), flags);
+		if (done == true) {
+			kfree(check);
+			break;
+			}
+		start = start->next;
+		}
+}
+
+/*
+ * adding a syslog_ns to the list of known syslog
+ *
+ */
+static void adding_syslog_ns(struct syslog_ns *syslog_ns)
+
+{
+	int done;
+	struct log_list	*start;
+
+	done = false;
+	start = &log_list;
+	while ((done == false) && (start != (struct log_list *)0)) {
+		unsigned long flags;
+
+		spin_lock_irqsave(&(start->list_lock), flags);
+		if (start->next == (struct log_list *)0) {
+			struct log_list *next;
+
+			next = kzalloc(sizeof(struct log_list), GFP_KERNEL);
+			BUG_ON(!next);
+			spin_lock_init(&(next->list_lock));
+			next->syslog_ns = syslog_ns;
+			start->next = next;
+			done = true;
+			}
+		spin_unlock_irqrestore(&(start->list_lock), flags);
+		start = start->next;
+		}
+}
+
+/*
  * Procedure to free all ressources tied to syslog
  *
  */
-static struct syslog_ns *free_all_syslog_ns(struct syslog_ns *syslog)
+static struct syslog_ns *free_all_syslog_ns(struct syslog_ns *syslog_ns)
 
 {
-	if (syslog != (struct syslog_ns *)0) {
-		(void) kfree(syslog->buf);
-		(void) kfree(syslog);
-		syslog = (struct syslog_ns *)0;
+	if (syslog_ns != (struct syslog_ns *)0) {
+		(void) removing_syslog_ns(syslog_ns);
+		(void) kfree(syslog_ns->buf);
+		(void) kfree(syslog_ns);
+		syslog_ns = (struct syslog_ns *)0;
 		}
-	return syslog;
+	return syslog_ns;
 }
 
 /*
@@ -93,9 +170,28 @@ static struct syslog_ns *malloc_syslog_ns(unsigned container_buf_len)
 	ns->handle = current->pid;
 	ns->buf_len = container_buf_len;
 	ns->buf = buf;
+	(void) adding_syslog_ns(ns);
 	return ns;
 }
 /*
+ * Procedure to locate and return a syslog_ns with same handle as pid submitted.
+ * return a NULL pointer if not found;
+ *
+ */
+static struct syslog_ns *find_its_syslog_ns(pid_t pid)
+
+{
+	struct log_list	*start;
+
+	start = &log_list;
+	while (start != (struct log_list *)0) {
+		if (start->syslog_ns->handle == pid)
+			return start->syslog_ns;
+		start = start->next;
+		}
+	return 0;
+}
+/*
  * Procedure to ONLY increase syslog buffer size
  * If syslog_ns is NULL, assign a brand new syslog_ns
  *
@@ -193,7 +289,7 @@ void free_syslog_ns(struct kref *kref)
 /*
  * Procedure to get the current syslog area linked to a
  * container (by CLONE_SYSLOG).
- * if trouble, pin down the problem before it propagate.
+ * if trouble, report host kernel own syslog_ns.
  *
  */
 struct syslog_ns *current_syslog_ns(void)
@@ -222,7 +318,31 @@ struct syslog_ns *switch_syslog_ns(struct syslog_ns *syslog_ns)
 
 	spin_lock_irqsave(&(current_syslog_ns()->logbuf_lock), flags);
 	old = current_syslog_ns();
-	current->nsproxy->syslog_ns = syslog_ns;
+	if (syslog_ns)
+		current->nsproxy->syslog_ns = syslog_ns;
 	spin_unlock_irqrestore(&(old->logbuf_lock), flags);
 	return old;
 }
+/*
+ * Procedure to locate the syslog handle own by a given
+ * pid or one of its parents lineage.
+ *
+ */
+struct syslog_ns *find_syslog_ns_bypid(pid_t pid)
+
+{
+	while (pid > 1) {
+		struct syslog_ns *its_ns;
+		struct task_struct *ns_task;
+
+		its_ns = find_its_syslog_ns(pid);
+		if (its_ns)
+			return its_ns;
+		ns_task = find_task_by_vpid(pid);
+		if ((ns_task) && (ns_task->real_parent))
+			pid = ns_task->real_parent->pid;
+		else
+			break;
+		}
+	return log_list.syslog_ns;
+}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 794bcb8..e41bc93 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -775,6 +775,9 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			err = PTR_ERR(net);
 			goto errout;
 		}
+		if (dev)
+			dev->syslog_ns_pid = nla_get_u32(tb[IFLA_NET_NS_PID]);
+
 		err = dev_change_net_namespace(dev, net, ifname);
 		put_net(net);
 		if (err)
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index ee128ef..7e1467d 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -14,6 +14,7 @@
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
+#include <linux/syslog.h>
 #include <net/icmp.h>
 #include <net/udp.h>
 #include <net/tcp.h>
@@ -382,6 +383,15 @@ ipt_log_packet(u_int8_t pf,
 	       const struct nf_loginfo *loginfo,
 	       const char *prefix)
 {
+
+	struct syslog_ns	*syslog_ns;
+
+
+	syslog_ns = (struct syslog_ns *)0;
+	if (skb->dev) 	/*another syslog_ns possible?	*/
+		syslog_ns = find_syslog_ns_bypid(skb->dev->syslog_ns_pid);
+	syslog_ns = switch_syslog_ns(syslog_ns);
+
 	if (!loginfo)
 		loginfo = &default_loginfo;
 
@@ -422,6 +432,7 @@ ipt_log_packet(u_int8_t pf,
 	dump_packet(loginfo, skb, 0);
 	printk("\n");
 	spin_unlock_bh(&log_lock);
+	(void) switch_syslog_ns(syslog_ns);
 }
 
 static unsigned int
-- 
1.6.6
