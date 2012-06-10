From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in
	net/ipv{4,6}/route.c
Date: Sat, 09 Jun 2012 19:04:51 -0700 (PDT)
Message-ID: <20120609.190451.182034193302304295.davem__10213.3621614941$1339293913$gmane$org@davemloft.net>
References: <20120609.163202.516027044484907548.davem@davemloft.net>
	<20120610015832.GA9175@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120610015832.GA9175@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date: Sun, 10 Jun 2012 09:58:32 +0800

> It triggers some warnings:
> 
> WARNING: net/ipv6/ipv6.o(.text+0x1049c): Section mismatch in reference from the function ip6_route_cleanup() to the variable .init.data:ipv6_inetpeer_ops

This should fix it:

From 2b823f72585552ef6fb77d6c081e55e047e879f0 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Sat, 9 Jun 2012 19:00:16 -0700
Subject: [PATCH] ipv6: Do not mark ipv6_inetpeer_ops as __net_initdata.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/ipv6/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7f346d7..9586c27 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3016,7 +3016,7 @@ static void __net_exit ipv6_inetpeer_exit(struct net *net)
 	kfree(bp);
 }
 
-static __net_initdata struct pernet_operations ipv6_inetpeer_ops = {
+static struct pernet_operations ipv6_inetpeer_ops = {
 	.init	=	ipv6_inetpeer_init,
 	.exit	=	ipv6_inetpeer_exit,
 };
-- 
1.7.10
