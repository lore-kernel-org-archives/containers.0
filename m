From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] netns: Delete virtual interfaces during namespace cleanup
Date: Thu, 02 Oct 2008 17:39:40 -0700
Message-ID: <m18wt6v7eb.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


When physical devices are inside of network namespace and that
network namespace terminates we can not make them go away.  We
have to keep them and moving them to the initial network namespace
is the best we can do.

For virtual devices left in a network namespace that is exiting
we have no need to preserve them and we now have the infrastructure
that allows us to delete them.  So delete virtual devices when we
exit a network namespace.  Keeping the necessary user space clean up
after a network namespace exits much more tractable.

This patch removes much of the need for user space clean up code to
run after a network namespace exits.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/core/dev.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7091040..f3476d4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4844,6 +4844,12 @@ static void __net_exit default_device_exit(struct net *net)
 		if (dev->features & NETIF_F_NETNS_LOCAL)
 			continue;
 
+		/* Delete virtual devices */
+		if (dev->rtnl_link_ops && dev->rtnl_link_ops->dellink) {
+			dev->rtnl_link_ops->dellink(dev);
+			continue;
+		}
+
 		/* Push remaing network devices to init_net */
 		snprintf(fb_name, IFNAMSIZ, "dev%d", dev->ifindex);
 		err = dev_change_net_namespace(dev, &init_net, fb_name);
-- 
1.5.3.rc6.17.g1911
