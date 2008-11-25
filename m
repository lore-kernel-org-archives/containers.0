From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 42/53] netns xfrm: pass netns with KM notifications
Date: Tue, 25 Nov 2008 20:27:14 +0300
Message-ID: <1227634045-27534-42-git-send-email-adobriyan__37624.7620130472$1227637274$gmane$org@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-2-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-3-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-4-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-5-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-6-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-7-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-8-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-9-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-10-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-11-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-12-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-13-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-14-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-15-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-16-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-17-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-18-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-19-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-20-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-21-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-22-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-23-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-24-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-25-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-26-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-27-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-28-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-29-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-30-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-31-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-32-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-33-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-34-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-35-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-36-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-37-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-38-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-39-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-40-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-41-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-41-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

SA and SPD flush are executed with NULL SA and SPD respectively, for
these cases pass netns explicitly from userspace socket.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/xfrm.h   |    1 +
 net/key/af_key.c     |    2 ++
 net/xfrm/xfrm_user.c |    6 ++++--
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e027179..52e784f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -256,6 +256,7 @@ struct km_event
 	u32	seq;
 	u32	pid;
 	u32	event;
+	struct net *net;
 };
 
 struct net_device;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index a0d8498..ea7755a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1739,6 +1739,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	c.event = XFRM_MSG_FLUSHSA;
+	c.net = &init_net;
 	km_state_notify(NULL, &c);
 
 	return 0;
@@ -2693,6 +2694,7 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
 	c.seq = hdr->sadb_msg_seq;
+	c.net = &init_net;
 	km_policy_notify(NULL, 0, &c);
 
 	return 0;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ab8b138..3e32ec2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1418,6 +1418,7 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
+	c.net = net;
 	km_state_notify(NULL, &c);
 
 	return 0;
@@ -1569,6 +1570,7 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
+	c.net = net;
 	km_policy_notify(NULL, 0, &c);
 	return 0;
 }
@@ -2084,7 +2086,7 @@ static int xfrm_aevent_state_notify(struct xfrm_state *x, struct km_event *c)
 
 static int xfrm_notify_sa_flush(struct km_event *c)
 {
-	struct net *net = &init_net;
+	struct net *net = c->net;
 	struct xfrm_usersa_flush *p;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
@@ -2446,7 +2448,7 @@ nlmsg_failure:
 
 static int xfrm_notify_policy_flush(struct km_event *c)
 {
-	struct net *net = &init_net;
+	struct net *net = c->net;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 
-- 
1.5.6.5
