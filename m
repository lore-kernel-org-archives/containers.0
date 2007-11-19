From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH][net-2.6.25][NETNS] make netns cleanup to run in a separate
 workqueue
Date: Mon, 19 Nov 2007 11:44:25 +0100
Message-ID: <47416909.4000602@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070406080409010300070800"
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: Linux Netdev List <netdev@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, "Denis V. Lunev" <den@openvz.org>, Benjamin Thery <benjamin.thery@bull.net>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------070406080409010300070800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070406080409010300070800
Content-Type: text/x-patch;
 name="create-workq-for-the-namespace.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="create-workq-for-the-namespace.patch"

Subject: make netns cleanup to run in a separate queue
From: Benjamin Thery <benjamin.thery@bull.net>

This patch adds a separate workqueue for cleaning up a network 
namespace. If we use the keventd workqueue to execute cleanup_net(), 
there is a problem to unregister devices in IPv6. Indeed the code 
that cleans up also schedule work in keventd: as long as cleanup_net() 
hasn't return, dst_gc_task() cannot run and as long as dst_gc_task() has
not run, there are still some references pending on the net devices and
cleanup_net() can not unregister and exit the keventd workqueue.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Acked-by: Denis V. Lunev <den@openvz.org>
---
 net/core/net_namespace.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: net-2.6.25/net/core/net_namespace.c
===================================================================
--- net-2.6.25.orig/net/core/net_namespace.c
+++ net-2.6.25/net/core/net_namespace.c
@@ -58,6 +58,7 @@ out_undo:
 
 #ifdef CONFIG_NET_NS
 static struct kmem_cache *net_cachep;
+static struct workqueue_struct *netns_wq;
 
 static struct net *net_alloc(void)
 {
@@ -149,7 +150,7 @@ void __put_net(struct net *net)
 {
 	/* Cleanup the network namespace in process context */
 	INIT_WORK(&net->work, cleanup_net);
-	schedule_work(&net->work);
+	queue_work(netns_wq, &net->work);
 }
 EXPORT_SYMBOL_GPL(__put_net);
 
@@ -171,7 +172,13 @@ static int __init net_ns_init(void)
 	net_cachep = kmem_cache_create("net_namespace", sizeof(struct net),
 					SMP_CACHE_BYTES,
 					SLAB_PANIC, NULL);
+
+	/* Create workqueue for cleanup */
+	netns_wq = create_singlethread_workqueue("netns");
+	if (!netns_wq)
+		panic("Could not create netns workq");
 #endif
+
 	mutex_lock(&net_mutex);
 	err = setup_net(&init_net);
 

--------------070406080409010300070800--
