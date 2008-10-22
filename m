From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: [PATCH 1/4] netns: add in ida ID to identify the network namespace
Date: Wed, 22 Oct 2008 17:21:54 +0200
Message-ID: <20081022152144.562569159__12908.9553178803$1224689165$gmane$org@theryb.frec.bull.fr>
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

This patch adds in 'id' member to struct net. This member contains an
IDA ID. The id is allocated at netns creation. 

This id will be used to 'tag' net devices belonging to network namespace
in sysfs (in order to allow registration of net devices with the same name 
in different network namespace: see last patch for the details).

The advantage of IDA IDs over using the netns pointer is the id values
are small starting at 0, thus they requires less bytes to be displayed
(we are limited to 3 characters: again see last patch for the details). 
And they stay small as they are recycled when IDs are freed (unless you
have thousands of netns running on your host).

Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |   24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

Index: net-next-2.6/include/net/net_namespace.h
===================================================================
--- net-next-2.6.orig/include/net/net_namespace.h
+++ net-next-2.6/include/net/net_namespace.h
@@ -75,6 +75,8 @@ struct net {
 #endif
 #endif
 	struct net_generic	*gen;
+
+	int			id;
 };
 
 
Index: net-next-2.6/net/core/net_namespace.c
===================================================================
--- net-next-2.6.orig/net/core/net_namespace.c
+++ net-next-2.6/net/core/net_namespace.c
@@ -26,6 +26,16 @@ EXPORT_SYMBOL(init_net);
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
 
 /*
+ * IDs allocated from this ida are used as a suffix in sysfs to tag
+ * devices belonging to each netns (other than init_net).
+ * Only 4 characters are left to store a separator plus this tag in sysfs
+ * (BUS_ID_SIZE-IFNAMSIZ)
+ * Thus, this limits us to 4095 ("FFF") simultaneous network namespaces.
+ */
+static DEFINE_IDA(net_id_ida);
+#define NET_ID_MAX 0xFFF
+
+/*
  * setup_net runs the initializers for the network namespace object.
  */
 static __net_init int setup_net(struct net *net)
@@ -40,7 +50,20 @@ static __net_init int setup_net(struct n
 	atomic_set(&net->use_count, 0);
 #endif
 
+	/* Get an ID */
+again:
+	error = ida_get_new(&net_id_ida, &net->id);
+	if (error) {
+		if (error == -EAGAIN) {
+			ida_pre_get(&net_id_ida, GFP_KERNEL);
+			goto again;
+		}
+		goto out;
+	}
 	error = -ENOMEM;
+	if (net->id > NET_ID_MAX)
+		goto out;
+
 	ng = kzalloc(sizeof(struct net_generic) +
 			INITIAL_NET_GEN_PTRS * sizeof(void *), GFP_KERNEL);
 	if (ng == NULL)
@@ -97,6 +120,7 @@ static void net_free(struct net *net)
 	}
 #endif
 
+	ida_remove(&net_id_ida, net->id);
 	kmem_cache_free(net_cachep, net);
 }
 

-- 
