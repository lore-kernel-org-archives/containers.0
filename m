From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 04/22] netlink: Add compare function for netlink_table
Date: Wed, 19 Jun 2013 09:53:36 +0800
Message-ID: <1371606834-5802-5-git-send-email-gaofeng@cn.fujitsu.com>
References: <1371606834-5802-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371606834-5802-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

As we know, netlink sockets are private resource of
net namespace, they can communicate with each other
only when they in the same net namespace. this works
well until we try to add namespace support for other
subsystems which use netlink.

Don't like ipv4 and route table.., it is not suited to
make these subsytems belong to net namespace, Such as
audit and crypto subsystems,they are more suitable to
user namespace.

So we must have the ability to make the netlink sockets
in same user namespace can communicate with each other.

This patch adds a new function pointer "compare" for
netlink_table, we can decide if the netlink sockets can
communicate with each other through this netlink_table
self-defined compare function.

The behavior isn't changed if we don't provide the compare
function for netlink_table.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/netlink.h  |  1 +
 net/netlink/af_netlink.c | 32 ++++++++++++++++++++++++--------
 net/netlink/af_netlink.h |  1 +
 3 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 6358da5..f78b430 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -46,6 +46,7 @@ struct netlink_kernel_cfg {
 	void		(*input)(struct sk_buff *skb);
 	struct mutex	*cb_mutex;
 	void		(*bind)(int group);
+	bool		(*compare)(struct net *net, struct sock *sk);
 };
 
 extern struct sock *__netlink_kernel_create(struct net *net, int unit,
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 57ee84d..942d429 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -854,16 +854,23 @@ netlink_unlock_table(void)
 		wake_up(&nl_table_wait);
 }
 
+static bool netlink_compare(struct net *net, struct sock *sk)
+{
+	return net_eq(sock_net(sk), net);
+}
+
 static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
 {
-	struct nl_portid_hash *hash = &nl_table[protocol].hash;
+	struct netlink_table *table = &nl_table[protocol];
+	struct nl_portid_hash *hash = &table->hash;
 	struct hlist_head *head;
 	struct sock *sk;
 
 	read_lock(&nl_table_lock);
 	head = nl_portid_hashfn(hash, portid);
 	sk_for_each(sk, head) {
-		if (net_eq(sock_net(sk), net) && (nlk_sk(sk)->portid == portid)) {
+		if (table->compare(net, sk) &&
+		    (nlk_sk(sk)->portid == portid)) {
 			sock_hold(sk);
 			goto found;
 		}
@@ -976,7 +983,8 @@ netlink_update_listeners(struct sock *sk)
 
 static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
 {
-	struct nl_portid_hash *hash = &nl_table[sk->sk_protocol].hash;
+	struct netlink_table *table = &nl_table[sk->sk_protocol];
+	struct nl_portid_hash *hash = &table->hash;
 	struct hlist_head *head;
 	int err = -EADDRINUSE;
 	struct sock *osk;
@@ -986,7 +994,8 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
 	head = nl_portid_hashfn(hash, portid);
 	len = 0;
 	sk_for_each(osk, head) {
-		if (net_eq(sock_net(osk), net) && (nlk_sk(osk)->portid == portid))
+		if (table->compare(net, osk) &&
+		    (nlk_sk(osk)->portid == portid))
 			break;
 		len++;
 	}
@@ -1183,7 +1192,8 @@ static int netlink_autobind(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
-	struct nl_portid_hash *hash = &nl_table[sk->sk_protocol].hash;
+	struct netlink_table *table = &nl_table[sk->sk_protocol];
+	struct nl_portid_hash *hash = &table->hash;
 	struct hlist_head *head;
 	struct sock *osk;
 	s32 portid = task_tgid_vnr(current);
@@ -1195,7 +1205,7 @@ retry:
 	netlink_table_grab();
 	head = nl_portid_hashfn(hash, portid);
 	sk_for_each(osk, head) {
-		if (!net_eq(sock_net(osk), net))
+		if (!table->compare(net, osk))
 			continue;
 		if (nlk_sk(osk)->portid == portid) {
 			/* Bind collision, search negative portid values. */
@@ -2285,6 +2295,8 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 		if (cfg) {
 			nl_table[unit].bind = cfg->bind;
 			nl_table[unit].flags = cfg->flags;
+			if (cfg->compare)
+				nl_table[unit].compare = cfg->compare;
 		}
 		nl_table[unit].registered = 1;
 	} else {
@@ -2707,6 +2719,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct sock *s;
 	struct nl_seq_iter *iter;
+	struct net *net;
 	int i, j;
 
 	++*pos;
@@ -2714,11 +2727,12 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (v == SEQ_START_TOKEN)
 		return netlink_seq_socket_idx(seq, 0);
 
+	net = seq_file_net(seq);
 	iter = seq->private;
 	s = v;
 	do {
 		s = sk_next(s);
-	} while (s && sock_net(s) != seq_file_net(seq));
+	} while (s && !nl_table[s->sk_protocol].compare(net, s));
 	if (s)
 		return s;
 
@@ -2730,7 +2744,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 		for (; j <= hash->mask; j++) {
 			s = sk_head(&hash->table[j]);
-			while (s && sock_net(s) != seq_file_net(seq))
+			while (s && !nl_table[s->sk_protocol].compare(net, s))
 				s = sk_next(s);
 			if (s) {
 				iter->link = i;
@@ -2923,6 +2937,8 @@ static int __init netlink_proto_init(void)
 		hash->shift = 0;
 		hash->mask = 0;
 		hash->rehash_time = jiffies;
+
+		nl_table[i].compare = netlink_compare;
 	}
 
 	netlink_add_usersock_entry();
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index ed85222..eaa88d1 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -73,6 +73,7 @@ struct netlink_table {
 	struct mutex		*cb_mutex;
 	struct module		*module;
 	void			(*bind)(int group);
+	bool			(*compare)(struct net *net, struct sock *sock);
 	int			registered;
 };
 
-- 
1.8.1.4
