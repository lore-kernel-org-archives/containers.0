From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] make netns cleanup to run in a separate workq
Date: Mon, 19 Nov 2007 10:32:47 +0100
Message-ID: <4741583F.3050302@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030309040800040108030505"
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
To: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------030309040800040108030505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------030309040800040108030505
Content-Type: text/x-patch;
 name="create-workq-for-the-namespace.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="create-workq-for-the-namespace.patch"

Subject: make netns cleanup to run in a separate queue
From: Benjamin Thery

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/core/net_namespace.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: linux-2.6-netns/net/core/net_namespace.c
===================================================================
--- linux-2.6-netns.orig/net/core/net_namespace.c
+++ linux-2.6-netns/net/core/net_namespace.c
@@ -14,6 +14,7 @@
 static LIST_HEAD(pernet_list);
 static struct list_head *first_device = &pernet_list;
 static DEFINE_MUTEX(net_mutex);
+static struct workqueue_struct *netns_wq;
 
 LIST_HEAD(net_namespace_list);
 
@@ -149,7 +150,7 @@ void __put_net(struct net *net)
 {
 	/* Cleanup the network namespace in process context */
 	INIT_WORK(&net->work, cleanup_net);
-	schedule_work(&net->work);
+	queue_work(netns_wq, &net->work);
 }
 EXPORT_SYMBOL_GPL(__put_net);
 
@@ -172,6 +173,12 @@ static int __init net_ns_init(void)
 					SMP_CACHE_BYTES,
 					SLAB_PANIC, NULL);
 #endif
+
+	/* Create workqueue for cleanup */
+	netns_wq = create_singlethread_workqueue("netns");
+	if (!netns_wq)
+		panic("Could not create netns cleaner");
+
 	mutex_lock(&net_mutex);
 	err = setup_net(&init_net);
 

--------------030309040800040108030505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------030309040800040108030505--
