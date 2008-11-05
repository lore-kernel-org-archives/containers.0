From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 1/3] netns: Delete virtual interfaces during namespace cleanup
Date: Wed, 05 Nov 2008 15:22:26 -0800
Message-ID: <m14p2l4v2l.fsf_-_@frodo.ebiederm.org>
References: <m18wt6v7eb.fsf@frodo.ebiederm.org> <48EB36FC.4000008@fr.ibm.com>
	<48EB3F72.5090201@openvz.org> <m1d4ic4pbr.fsf@frodo.ebiederm.org>
	<48ECA8D2.4090406@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48ECA8D2.4090406-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Pavel Emelyanov's message of "Wed,
	08 Oct 2008 16:34:26 +0400")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

Acked-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Acked-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/core/dev.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8f9d3b3..9475f3e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4852,6 +4852,12 @@ static void __net_exit default_device_exit(struct net *net)
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
1.5.6.5
