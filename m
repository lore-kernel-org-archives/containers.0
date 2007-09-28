From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 2/2][NETNS45][V3] remove timewait sockets at cleanup
Date: Fri, 28 Sep 2007 11:51:10 +0200
Message-ID: <20070928095348.625343106@mai.toulouse-stg.fr.ibm.com>
References: <20070928095108.455904100@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=net-wipe-out-timewait-at-cleanup_net.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, den-3ImXcnM4P+0@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

Denis Lunev spotted that if we take a reference to the network namespace
with the timewait sockets, we will need to wait for their expiration to
have the network namespace freed. This is a waste of time, the timewait
sockets are for avoiding to receive a duplicate packet from the network,
if the network namespace is freed, the network stack is removed, so no
chance to receive any packets from the outside world.

This patchset remove/destroy the timewait sockets when the
network namespace is freed.

The exit method registered by netns_register_subsys is put in the tcp.c
file and not in inet_timewait_sock.c. The reasons are we browse the tcp
established hash table and I don't want to add references to tcp in inet
timewait sockets and, furthermore, dccp protocol uses the inet timewait 
sock too. IMHO, if we status to cleanup dccp timewait too, we should add
a exit method in dccp file.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 net/ipv4/tcp.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

Index: linux-2.6-netns/net/ipv4/tcp.c
===================================================================
--- linux-2.6-netns.orig/net/ipv4/tcp.c
+++ linux-2.6-netns/net/ipv4/tcp.c
@@ -2432,8 +2432,49 @@ static int tcp_net_init(struct net *net)
 	return 0;
 }
 
+/*
+ * Wipeout tcp timewait sockets, they are no longer needed
+ * because we destroy the network namespace, so no risk to
+ * have duplicate packet coming from the network
+ */
+static void tcp_net_exit(struct net *net)
+{
+	struct inet_timewait_sock *tw;
+	struct sock *sk;
+	struct hlist_node *node;
+	int h;
+
+	local_bh_disable();
+
+        /* Browse the the established hash table */
+	for (h = 0; h < (tcp_hashinfo.ehash_size); h++) {
+		struct inet_ehash_bucket *head =
+			inet_ehash_bucket(&tcp_hashinfo, h);
+	restart:
+		write_lock(&head->lock);
+		sk_for_each(sk, node, &head->twchain) {
+
+			tw = inet_twsk(sk);
+			if (tw->tw_net != net)
+				continue;
+			sock_hold(sk);
+
+			write_unlock(&head->lock);
+
+			inet_twsk_deschedule(tw, &tcp_death_row);
+			inet_twsk_put(tw);
+
+			goto restart;
+		}
+		write_unlock(&head->lock);
+	}
+
+	local_bh_enable();
+}
+
 static struct pernet_operations tcp_net_ops = {
 	.init = tcp_net_init,
+	.exit = tcp_net_exit,
 };
 
 void __init tcp_init(void)

-- 
