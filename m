From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/12 net-2.6.26] icmp_socket namespacing
Date: Fri, 29 Feb 2008 11:23:11 -0800 (PST)
Message-ID: <20080229.112311.168388051.davem@davemloft.net>
References: <1204292360.10368.11.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1204292360.10368.11.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 29 Feb 2008 16:39:20 +0300

> This set of patches is targeted to create separate icmp_socket inside
> each namespace. Both IPv4 and IPv6 codepaths are affected.
> 
> Though, in order to do this smoothly, a bit of optimisations are
> performed. The kernel from now on will use sock rather than socket on
> the ICMP send path.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

I applied everything except the final patch #12.

I'll reply to that patch posting with my feedback.
