From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH net-next v2 1/5] netns: allocate netns ids
Date: Tue, 23 Sep 2014 15:20:26 +0200
Message-ID: <1411478430-4989-2-git-send-email-nicolas.dichtel__26689.7182133564$1411478488$gmane$org@6wind.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1411478430-4989-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

With this patch, an id is allocated for each netns. Id database is stored in the
user namespace. It's allowed to get an id of a peer netns only if they share the
same user ns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
---
 include/linux/user_namespace.h |  4 ++++
 include/net/net_namespace.h    | 11 +++++++++++
 kernel/user_namespace.c        |  6 ++++++
 net/core/net_namespace.c       | 20 +++++++++++++++++++-
 4 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index e95372654f09..9d122b540422 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -5,6 +5,7 @@
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/err.h>
+#include <linux/idr.h>
 
 #define UID_GID_MAP_MAX_EXTENTS 5
 
@@ -33,6 +34,9 @@ struct user_namespace {
 	struct key		*persistent_keyring_register;
 	struct rw_semaphore	persistent_keyring_register_sem;
 #endif
+#ifdef CONFIG_NET_NS
+	struct idr		netns_ids;
+#endif
 };
 
 extern struct user_namespace init_user_ns;
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 361d26077196..92b5f94e2842 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -59,6 +59,7 @@ struct net {
 	struct list_head	exit_list;	/* Use only net_mutex */
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
+	int			netnsid;
 
 	unsigned int		proc_inum;
 
@@ -289,6 +290,16 @@ static inline struct net *read_pnet(struct net * const *pnet)
 #define __net_initconst	__initconst
 #endif
 
+static inline int peernet2id(struct net *net, struct net *peer)
+{
+	if (net->user_ns != peer->user_ns)
+		return -EPERM;
+
+	return peer->netnsid;
+}
+
+struct net *get_net_from_netnsid(struct net *net, int id);
+
 struct pernet_operations {
 	struct list_head list;
 	int (*init)(struct net *net);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index aa312b0dc3ec..30316a2eed49 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -104,6 +104,9 @@ int create_user_ns(struct cred *new)
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 	init_rwsem(&ns->persistent_keyring_register_sem);
 #endif
+#ifdef CONFIG_NET_NS
+	idr_init(&ns->netns_ids);
+#endif
 	return 0;
 }
 
@@ -133,6 +136,9 @@ void free_user_ns(struct user_namespace *ns)
 
 	do {
 		parent = ns->parent;
+#ifdef CONFIG_NET_NS
+		idr_destroy(&ns->netns_ids);
+#endif
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 		key_put(ns->persistent_keyring_register);
 #endif
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 7f155175bba8..f44378de7831 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -144,6 +144,19 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
+struct net *get_net_from_netnsid(struct net *net, int id)
+{
+	struct net *peer;
+
+	rcu_read_lock();
+	peer = idr_find(&net->user_ns->netns_ids, id);
+	if (peer)
+		get_net(peer);
+	rcu_read_unlock();
+
+	return peer;
+}
+
 /*
  * setup_net runs the initializers for the network namespace object.
  */
@@ -151,13 +164,16 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 {
 	/* Must be called with net_mutex held */
 	const struct pernet_operations *ops, *saved_ops;
-	int error = 0;
+	int error = 0, id;
 	LIST_HEAD(net_exit_list);
 
 	atomic_set(&net->count, 1);
 	atomic_set(&net->passive, 1);
 	net->dev_base_seq = 1;
 	net->user_ns = user_ns;
+	id = idr_alloc_cyclic(&user_ns->netns_ids, net, 1, 0, GFP_KERNEL);
+	if (id > 0)
+		net->netnsid = id;
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
@@ -288,6 +304,8 @@ static void cleanup_net(struct work_struct *work)
 	list_for_each_entry(net, &net_kill_list, cleanup_list) {
 		list_del_rcu(&net->list);
 		list_add_tail(&net->exit_list, &net_exit_list);
+		if (net->netnsid)
+			idr_remove(&net->user_ns->netns_ids, net->netnsid);
 	}
 	rtnl_unlock();
 
-- 
2.1.0
