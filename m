From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 07/14] user namespace: use net->user_ns for some capable
	calls under net/
Date: Tue, 12 Jul 2011 23:30:45 +0000
Message-ID: <1310513452-13397-8-git-send-email-serge__47334.2887511992$1310514437$gmane$org@hallyn.com>
References: <1310513452-13397-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1310513452-13397-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

Just a partial conversion to show how the previous patch is expected to
be used.

Changelog:
  6/28/11: fix typo in net/core/sock.c
  7/08/11: don't target capability which authorizes module loading

Signed-off-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/core/dev.c  |    4 ++--
 net/core/sock.c |   14 ++++++++------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9c58c1e..63d25b3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5004,7 +5004,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSIFNAME:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		dev_load(net, ifr.ifr_name);
 		rtnl_lock();
@@ -5043,7 +5043,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCBRADDIF:
 	case SIOCBRDELIF:
 	case SIOCSHWTSTAMP:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 		/* fall through */
 	case SIOCBONDSLAVEINFOQUERY:
diff --git a/net/core/sock.c b/net/core/sock.c
index 6e81978..965b1e7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -417,7 +417,7 @@ static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 
 	/* Sorry... */
 	ret = -EPERM;
-	if (!capable(CAP_NET_RAW))
+	if (!ns_capable(net->user_ns, CAP_NET_RAW))
 		goto out;
 
 	ret = -EINVAL;
@@ -485,6 +485,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	int valbool;
 	struct linger ling;
 	int ret = 0;
+	struct net *net = sock_net(sk);
 
 	/*
 	 *	Options without arguments
@@ -505,7 +506,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 
 	switch (optname) {
 	case SO_DEBUG:
-		if (val && !capable(CAP_NET_ADMIN))
+		if (val && !ns_capable(net->user_ns, CAP_NET_ADMIN))
 			ret = -EACCES;
 		else
 			sock_valbool_flag(sk, SOCK_DBG, valbool);
@@ -548,7 +549,7 @@ set_sndbuf:
 		break;
 
 	case SO_SNDBUFFORCE:
-		if (!capable(CAP_NET_ADMIN)) {
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
 			ret = -EPERM;
 			break;
 		}
@@ -586,7 +587,7 @@ set_rcvbuf:
 		break;
 
 	case SO_RCVBUFFORCE:
-		if (!capable(CAP_NET_ADMIN)) {
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
 			ret = -EPERM;
 			break;
 		}
@@ -609,7 +610,8 @@ set_rcvbuf:
 		break;
 
 	case SO_PRIORITY:
-		if ((val >= 0 && val <= 6) || capable(CAP_NET_ADMIN))
+		if ((val >= 0 && val <= 6) ||
+		     ns_capable(net->user_ns, CAP_NET_ADMIN))
 			sk->sk_priority = val;
 		else
 			ret = -EPERM;
@@ -726,7 +728,7 @@ set_rcvbuf:
 			clear_bit(SOCK_PASSSEC, &sock->flags);
 		break;
 	case SO_MARK:
-		if (!capable(CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			ret = -EPERM;
 		else
 			sk->sk_mark = val;
-- 
1.7.4.1
