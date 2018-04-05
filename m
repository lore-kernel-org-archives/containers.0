From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH net-next 2/2 MERGED] netns: send uevent messages
Date: Thu, 5 Apr 2018 16:57:27 +0200
Message-ID: <20180405145726.GB13789@gmail.com>
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

Date: Mon, 19 Mar 2018 13:17:31 +0100
From: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org, avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 2/2 v4] netns: send uevent messages
X-Mailer: git-send-email 2.15.1

This patch adds a receive method to NETLINK_KOBJECT_UEVENT netlink sockets
to allow sending uevent messages into the network namespace the socket
belongs to.

Currently non-initial network namespaces are already isolated and don't
receive uevents. There are a number of cases where it is beneficial for a
sufficiently privileged userspace process to send a uevent into a network
namespace.

One such use case would be debugging and fuzzing of a piece of software
which listens and reacts to uevents. By running a copy of that software
inside a network namespace, specific uevents could then be presented to it.
More concretely, this would allow for easy testing of udevd/ueventd.

This will also allow some piece of software to run components inside a
separate network namespace and then effectively filter what that software
can receive. Some examples of software that do directly listen to uevents
and that we have in the past attempted to run inside a network namespace
are rbd (CEPH client) or the X server.

Implementation:
The implementation has been kept as simple as possible from the kernel's
perspective. Specifically, a simple input method uevent_net_rcv() is added
to NETLINK_KOBJECT_UEVENT sockets which completely reuses existing
af_netlink infrastructure and does neither add an additional netlink family
nor requires any user-visible changes.

For example, by using netlink_rcv_skb() we can make use of existing netlink
infrastructure to report back informative error messages to userspace.

Furthermore, this implementation does not introduce any overhead for
existing uevent generating codepaths. The struct netns got a new uevent
socket member that records the uevent socket associated with that network
namespace including its position in the uevent socket list. Since we record
the uevent socket for each network namespace in struct net we don't have to
walk the whole uevent socket list. Instead we can directly retrieve the
relevant uevent socket and send the message. At exit time we can now also
trivially remove the uevent socket from the uevent socket list. This keeps
the codepath very performant without introducing needless overhead and even
makes older codepaths faster.

Uevent sequence numbers are kept global. When a uevent message is sent to
another network namespace the implementation will simply increment the
global uevent sequence number and append it to the received uevent. This
has the advantage that the kernel will never need to parse the received
uevent message to replace any existing uevent sequence numbers. Instead it
is up to the userspace process to remove any existing uevent sequence
numbers in case the uevent message to be sent contains any.

Security:
In order for a caller to send uevent messages to a target network namespace
the caller must have CAP_SYS_ADMIN in the owning user namespace of the
target network namespace. Additionally, any received uevent message is
verified to not exceed size UEVENT_BUFFER_SIZE. This includes the space
needed to append the uevent sequence number.

Testing:
This patch has been tested and verified to work with the following udev
implementations:
1. CentOS 6 with udevd version 147
2. Debian Sid with systemd-udevd version 237
3. Android 7.1.1 with ueventd

Signed-off-by: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
Changelog v3->v4:
* patch unchanged

Changelog v2->v3:
* Use reverse christmas tree ordering for local variables.

Changelog v1->v2:
* Add the whole struct uevent_sock to struct net not just the socket
  member. Since struct uevent_sock records the position of the uevent
  socket in the uevent socket list we can trivially remove it from the
  uevent socket list during cleanup. This speeds up the old removal
  codepath. list_del() will hit __list_del_entry_valid() in its call chain
  which will validate that the element is a member of the list. If it isn't
  it will take care that the list is not modified.

Changelog v0->v1:
* Hold mutex_lock() until uevent is sent to preserve uevent message
  ordering. See udev and commit for reference:

  commit 7b60a18da393ed70db043a777fd9e6d5363077c4
  Author: Andrew Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
  Date:   Wed Mar 7 14:49:56 2012 +0400

      uevent: send events in correct order according to seqnum (v3)

      The queue handling in the udev daemon assumes that the events are
      ordered.
---
 lib/kobject_uevent.c | 79 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 78 insertions(+), 1 deletion(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 8dd992e8638d..15ea216a67ce 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -25,6 +25,7 @@
 #include <linux/uuid.h>
 #include <linux/ctype.h>
 #include <net/sock.h>
+#include <net/netlink.h>
 #include <net/net_namespace.h>
 
 
@@ -604,12 +605,88 @@ int add_uevent_var(struct kobj_uevent_env *env, const char *format, ...)
 EXPORT_SYMBOL_GPL(add_uevent_var);
 
 #if defined(CONFIG_NET)
+static int uevent_net_broadcast(struct sock *usk, struct sk_buff *skb,
+				struct netlink_ext_ack *extack)
+{
+	/* u64 to chars: 2^64 - 1 = 21 chars */
+	char buf[sizeof("SEQNUM=") + 21];
+	struct sk_buff *skbc;
+	int ret;
+
+	/* bump and prepare sequence number */
+	ret = snprintf(buf, sizeof(buf), "SEQNUM=%llu", ++uevent_seqnum);
+	if (ret < 0 || (size_t)ret >= sizeof(buf))
+		return -ENOMEM;
+	ret++;
+
+	/* verify message does not overflow */
+	if ((skb->len + ret) > UEVENT_BUFFER_SIZE) {
+		NL_SET_ERR_MSG(extack, "uevent message too big");
+		return -EINVAL;
+	}
+
+	/* copy skb and extend to accommodate sequence number */
+	skbc = skb_copy_expand(skb, 0, ret, GFP_KERNEL);
+	if (!skbc)
+		return -ENOMEM;
+
+	/* append sequence number */
+	skb_put_data(skbc, buf, ret);
+
+	/* remove msg header */
+	skb_pull(skbc, NLMSG_HDRLEN);
+
+	/* set portid 0 to inform userspace message comes from kernel */
+	NETLINK_CB(skbc).portid = 0;
+	NETLINK_CB(skbc).dst_group = 1;
+
+	ret = netlink_broadcast(usk, skbc, 0, 1, GFP_KERNEL);
+	/* ENOBUFS should be handled in userspace */
+	if (ret == -ENOBUFS || ret == -ESRCH)
+		ret = 0;
+
+	return ret;
+}
+
+static int uevent_net_rcv_skb(struct sk_buff *skb, struct nlmsghdr *nlh,
+			      struct netlink_ext_ack *extack)
+{
+	struct net *net;
+	int ret;
+
+	if (!nlmsg_data(nlh))
+		return -EINVAL;
+
+	/*
+	 * Verify that we are allowed to send messages to the target
+	 * network namespace. The caller must have CAP_SYS_ADMIN in the
+	 * owning user namespace of the target network namespace.
+	 */
+	net = sock_net(NETLINK_CB(skb).sk);
+	if (!netlink_ns_capable(skb, net->user_ns, CAP_SYS_ADMIN)) {
+		NL_SET_ERR_MSG(extack, "missing CAP_SYS_ADMIN capability");
+		return -EPERM;
+	}
+
+	mutex_lock(&uevent_sock_mutex);
+	ret = uevent_net_broadcast(net->uevent_sock->sk, skb, extack);
+	mutex_unlock(&uevent_sock_mutex);
+
+	return ret;
+}
+
+static void uevent_net_rcv(struct sk_buff *skb)
+{
+	netlink_rcv_skb(skb, &uevent_net_rcv_skb);
+}
+
 static int uevent_net_init(struct net *net)
 {
 	struct uevent_sock *ue_sk;
 	struct netlink_kernel_cfg cfg = {
 		.groups	= 1,
-		.flags	= NL_CFG_F_NONROOT_RECV,
+		.input = uevent_net_rcv,
+		.flags	= NL_CFG_F_NONROOT_RECV
 	};
 
 	ue_sk = kzalloc(sizeof(*ue_sk), GFP_KERNEL);
-- 
2.15.1


----- End forwarded message -----
