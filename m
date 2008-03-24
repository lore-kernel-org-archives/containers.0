From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 10/11 net-2.6.26] [NETNS]: Allow to create sockets in non-initial namespace.
Date: Mon, 24 Mar 2008 17:36:11 +0300
Message-ID: <1206369372-27711-10-git-send-email-den@openvz.org>
References: <1206369185.23705.7.camel@iris.sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1206369185.23705.7.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org, xemul@openvz.org, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

Allow to create sockets in the namespace if the protocol ok with this.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/af_inet.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index a9e241c..39ddb84 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -243,6 +243,23 @@ void build_ehash_secret(void)
 }
 EXPORT_SYMBOL(build_ehash_secret);
 
+static inline int inet_netns_ok(struct net *net, int protocol)
+{
+	int hash;
+	struct net_protocol *ipprot;
+
+	if (net == &init_net)
+		return 1;
+
+	hash = protocol & (MAX_INET_PROTOS - 1);
+	ipprot = rcu_dereference(inet_protos[hash]);
+
+	if (ipprot == NULL)
+		/* raw IP is OK */
+		return 1;
+	return ipprot->netns_ok;
+}
+
 /*
  *	Create an inet socket.
  */
@@ -259,9 +276,6 @@ static int inet_create(struct net *net, struct socket *sock, int protocol)
 	int try_loading_module = 0;
 	int err;
 
-	if (net != &init_net)
-		return -EAFNOSUPPORT;
-
 	if (sock->type != SOCK_RAW &&
 	    sock->type != SOCK_DGRAM &&
 	    !inet_ehash_secret)
@@ -320,6 +334,10 @@ lookup_protocol:
 	if (answer->capability > 0 && !capable(answer->capability))
 		goto out_rcu_unlock;
 
+	err = -EAFNOSUPPORT;
+	if (!inet_netns_ok(net, protocol))
+		goto out_rcu_unlock;
+
 	sock->ops = answer->ops;
 	answer_prot = answer->prot;
 	answer_no_check = answer->no_check;
-- 
1.5.3.rc5

