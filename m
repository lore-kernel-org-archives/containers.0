From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 0/3 net-2.6.26] Compilation fixes.
Date: Wed, 02 Apr 2008 14:01:14 +0400
Message-ID: <1207130474.17626.2.camel@iris.sw.ru>
References: <1206978361.10660.31.camel@iris.sw.ru>
	 <20080402.001048.267915281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-2CQ8bcs6nJ0+IHn5IVvh"
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080402.001048.267915281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org


--=-2CQ8bcs6nJ0+IHn5IVvh
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2008-04-02 at 00:10 -0700, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Mon, 31 Mar 2008 19:46:01 +0400
> 
> > Hello, Dave!
> > 
> > Recently I have seen several issues post to the netdev@ blaming
> > inclusion of the net_namespace.h from seq_file. This set fixes this
> > problem after two small cleanups.
> 
> All applied, thanks Denis.
> 
> I'll push to net-2.6.26 after some build sanity checks.

Dave, could you pls conside this addition. This should fix problem
reported by the Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> recently.

--=-2CQ8bcs6nJ0+IHn5IVvh
Content-Disposition: attachment; filename=diff-netns-compile.txt
Content-Type: text/plain; name=diff-netns-compile.txt; charset=KOI8-R
Content-Transfer-Encoding: 7bit

[NETNS]: Declare init_net even without CONFIG_NET defined.

This seems bogus but there is no other way for now. There are several
placec when networking headers are included even without CONFIG_NET and
the possibility of the similar reports in the nearest future is great.

Signed-off-by: Denis V. Lunev <den@openvz.org>
----
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 6c9a48a..0ab62ed 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -60,11 +60,12 @@ struct net {
 };
 
 
-#ifdef CONFIG_NET
 #include <linux/seq_file_net.h>
 
 /* Init's network namespace */
 extern struct net init_net;
+
+#ifdef CONFIG_NET
 #define INIT_NET_NS(net_ns) .net_ns = &init_net,
 
 extern struct net *copy_net_ns(unsigned long flags, struct net *net_ns);

--=-2CQ8bcs6nJ0+IHn5IVvh--

