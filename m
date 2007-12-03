From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 00/38][IPV6] ipv6 per network namespace
Date: Mon, 03 Dec 2007 17:16:36 +0100
Message-ID: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
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
To: den-3ImXcnM4P+0@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset provides the changes to make the ipv6 protocol to handle
multiple network namespaces.

There is a pre-requesite which is already merged in net-2.6.25, it is
the separate workq for the network namespace cleanup. It will
disappear when Denis will rebase the patchset to the latest
net-2.6.25.

The sysctl per net is not yet implemented (coming soon), the patchset
adds a check to activate the network namespace only if sysctl is
disabled. It will be reverted as soon as we handle sysctl.

This subset makes per namespace:

 * inet6_addr
 * ip6_fib
 * fib6_rules
 * rt6_stats
 * rt6_info
 * route6
 * addrconf
 * ndisc

The patchset is a little big, but it is difficult to check and test without
a minimal subset of features of the protocol. So at this point we are able to
create routes and addresses per namespaces, we can check the procfs files,
setup interfaces, check the address autoconfiguration is done and the
different routes are created, etc ...

-- 
