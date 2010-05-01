From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 095/100] c/r: Add rtnl_dellink() helper
Date: Sat,  1 May 2010 10:16:17 -0400
Message-ID: <1272723382-19470-96-git-send-email-orenl__18745.3496423133$1272729023$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

This is the kernel equivalent of "ip link del $name" and matches the
existing rtnl_newlink() equivalent of "ip link add $name".  It factors
out the message creation and dispatch code a little further into
rtnl_do() before adding the new function.

Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint_dev.c |   86 +++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 72 insertions(+), 14 deletions(-)

diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 34a6bdb..5097011 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -475,22 +475,49 @@ static struct sk_buff *new_link_msg(new_link_fn fn, void *data, char *name)
 	return skb;
 }
 
-static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
+static struct sk_buff *del_link_msg(char *name)
+{
+	int ret = -ENOMEM;
+	int flags = NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	struct ifinfomsg *ifm;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	nlh = nlmsg_put(skb, 0, 0, RTM_DELLINK, sizeof(*ifm), flags);
+	if (!nlh)
+		goto out;
+
+	ifm = nlmsg_data(nlh);
+	memset(ifm, 0, sizeof(*ifm));
+
+	ret = nla_put_string(skb, IFLA_IFNAME, name);
+	if (ret)
+		goto out;
+
+	nlmsg_end(skb, nlh);
+
+ out:
+	if (ret < 0) {
+		kfree_skb(skb);
+		skb = ERR_PTR(ret);
+	}
+
+	return skb;
+}
+
+static int rtnl_do(struct sk_buff *skb)
 {
 	int ret = -ENOMEM;
 	struct socket *rtnl = NULL;
-	struct sk_buff *skb = NULL;
+	struct sk_buff *rskb = NULL;
 	struct nlmsghdr *nlh;
 	struct msghdr msg;
 	struct kvec kvec;
 
-	skb = new_link_msg(fn, data, name);
-	if (IS_ERR(skb)) {
-		ckpt_debug("failed to create new link message: %li\n",
-			   PTR_ERR(skb));
-		return ERR_PTR(PTR_ERR(skb));
-	}
-
 	memset(&msg, 0, sizeof(msg));
 	kvec.iov_len = skb->len;
 	kvec.iov_base = skb->head;
@@ -510,25 +537,56 @@ static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
 		goto out;
 	}
 
-	/* Free the send skb to make room for the receive skb */
-	kfree_skb(skb);
-
-	nlh = rtnl_get_response(rtnl, &skb);
+	nlh = rtnl_get_response(rtnl, &rskb);
 	if (IS_ERR(nlh)) {
 		ret = PTR_ERR(nlh);
 		ckpt_debug("RTNETLINK said: %i\n", ret);
 	}
  out:
 	rtnl_close(rtnl);
+	kfree_skb(rskb);
  out_noclose:
-	kfree_skb(skb);
+	return ret;
+}
 
+static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
+{
+	struct sk_buff *skb;
+	int ret;
+
+	skb = new_link_msg(fn, data, name);
+	if (IS_ERR(skb)) {
+		ckpt_debug("failed to create new link message: %li\n",
+			   PTR_ERR(skb));
+		return ERR_PTR(PTR_ERR(skb));
+	}
+
+	ret = rtnl_do(skb);
+	kfree_skb(skb);
 	if (ret < 0)
 		return ERR_PTR(ret);
 	else
 		return dev_get_by_name(current->nsproxy->net_ns, name);
 }
 
+static int rtnl_dellink(char *name)
+{
+	struct sk_buff *skb;
+	int ret;
+
+	skb = del_link_msg(name);
+	if (IS_ERR(skb)) {
+		ckpt_debug("failed to create del link message: %li\n",
+			   PTR_ERR(skb));
+		return PTR_ERR(skb);
+	}
+
+	ret = rtnl_do(skb);
+	kfree_skb(skb);
+
+	return ret;
+}
+
 static int netdev_noop(void *data)
 {
 	return 0;
-- 
1.6.3.3
