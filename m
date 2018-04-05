From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH net-next 1/2 MERGED] net: add uevent socket member
Date: Thu, 5 Apr 2018 16:56:40 +0200
Message-ID: <20180405145639.GA13789@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

----- Forwarded message from Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> -----

Date: Mon, 19 Mar 2018 13:17:30 +0100
From: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org, avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 1/2 v4] net: add uevent socket member
X-Mailer: git-send-email 2.15.1

This commit adds struct uevent_sock to struct net. Since struct uevent_sock
records the position of the uevent socket in the uevent socket list we can
trivially remove it from the uevent socket list during cleanup. This speeds
up the old removal codepath.
Note, list_del() will hit __list_del_entry_valid() in its call chain which
will validate that the element is a member of the list. If it isn't it will
take care that the list is not modified.

Signed-off-by: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
Changelog v3->v4:
* non-functional change: remove return from function returning void

Changelog v2->v3:
* patch added
  This patch was split out of the follow up patch
  Subject: [PATCH 2/2 v3] netns: send uevent messages

Changelog v1->v2:
* patch not present

Changelog v0->v1:
* patch not present
---
 include/net/net_namespace.h |  4 +++-
 lib/kobject_uevent.c        | 17 +++++++----------
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index f306b2aa15a4..abd7d91bffac 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -40,7 +40,7 @@ struct net_device;
 struct sock;
 struct ctl_table_header;
 struct net_generic;
-struct sock;
+struct uevent_sock;
 struct netns_ipvs;
 
 
@@ -79,6 +79,8 @@ struct net {
 	struct sock 		*rtnl;			/* rtnetlink socket */
 	struct sock		*genl_sock;
 
+	struct uevent_sock	*uevent_sock;		/* uevent socket */
+
 	struct list_head 	dev_base_head;
 	struct hlist_head 	*dev_name_head;
 	struct hlist_head	*dev_index_head;
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 9fe6ec8fda28..8dd992e8638d 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -32,11 +32,13 @@ u64 uevent_seqnum;
 #ifdef CONFIG_UEVENT_HELPER
 char uevent_helper[UEVENT_HELPER_PATH_LEN] = CONFIG_UEVENT_HELPER_PATH;
 #endif
-#ifdef CONFIG_NET
+
 struct uevent_sock {
 	struct list_head list;
 	struct sock *sk;
 };
+
+#ifdef CONFIG_NET
 static LIST_HEAD(uevent_sock_list);
 #endif
 
@@ -621,6 +623,9 @@ static int uevent_net_init(struct net *net)
 		kfree(ue_sk);
 		return -ENODEV;
 	}
+
+	net->uevent_sock = ue_sk;
+
 	mutex_lock(&uevent_sock_mutex);
 	list_add_tail(&ue_sk->list, &uevent_sock_list);
 	mutex_unlock(&uevent_sock_mutex);
@@ -629,17 +634,9 @@ static int uevent_net_init(struct net *net)
 
 static void uevent_net_exit(struct net *net)
 {
-	struct uevent_sock *ue_sk;
+	struct uevent_sock *ue_sk = net->uevent_sock;
 
 	mutex_lock(&uevent_sock_mutex);
-	list_for_each_entry(ue_sk, &uevent_sock_list, list) {
-		if (sock_net(ue_sk->sk) == net)
-			goto found;
-	}
-	mutex_unlock(&uevent_sock_mutex);
-	return;
-
-found:
 	list_del(&ue_sk->list);
 	mutex_unlock(&uevent_sock_mutex);
 
-- 
2.15.1


----- End forwarded message -----
