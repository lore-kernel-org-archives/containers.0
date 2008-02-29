From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/12 net-2.6.26] [ICMP6]: Consolidate fail path
 icmpv6_sk_init with icmpv6_sk_exit.
Date: Fri, 29 Feb 2008 11:23:42 -0800 (PST)
Message-ID: <20080229.112342.76764059.davem@davemloft.net>
References: <1204292360.10368.11.camel@iris.sw.ru>
	<1204292458-11636-12-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1204292458-11636-12-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 29 Feb 2008 16:40:58 +0300

> +static void __net_exit icmpv6_sk_exit(struct net *net)
> +{

Since you call this from __new_init code, won't this
create a section conflict when ipv6 is built statically
into the kernel?
