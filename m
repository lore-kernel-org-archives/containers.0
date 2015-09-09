From: "Michael J. Coss" <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/3] lib/kobject_uevent.c: disable broadcast of uevents to
	other namespaces
Date: Wed,  9 Sep 2015 14:53:11 -0400
Message-ID: <51c185b6fa89f0b8e9e7dcaffb3c21c975c84302.1441762578.git.michael.coss__40512.1496915401$1441824870$gmane$org@alcatel-lucent.com>
References: <cover.1441762578.git.michael.coss@alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1441762578.git.michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
Cc: "Michael J. Coss" <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Restrict sending uevents to only those listeners operating in the same
network namespace as the system init process.  This is the first step
toward allowing policy control of the forwarding of events to other
namespaces in userspace.

Signed-off-by: Michael J. Coss <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
---
 lib/kobject_uevent.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index f6c2c1e..d791e33 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -295,6 +295,10 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 		if (!netlink_has_listeners(uevent_sock, 1))
 			continue;
 
+		/* forward event only to the host systems network namespaces */
+		if (!net_eq(sock_net(uevent_sock), &init_net))
+			continue;
+
 		/* allocate message with the maximum possible size */
 		len = strlen(action_string) + strlen(devpath) + 2;
 		skb = alloc_skb(len + env->buflen, GFP_KERNEL);
-- 
2.4.6
