From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 net-2.6.25] Proper netlink kernel sockets disposal.
Date: Fri, 18 Jan 2008 23:55:43 -0800 (PST)
Message-ID: <20080118.235543.220450302.davem@davemloft.net>
References: <4790A0E3.9080006@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4790A0E3.9080006@sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@sw.ru
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@sw.ru>
Date: Fri, 18 Jan 2008 15:51:47 +0300

> Alexey Dobriyan found, that virtualized netlink kernel sockets (fibl &
> rtnl) are leaked during namespace start/stop loop.
> 
> Leaking fix (simple and obvious) reveals that netlink kernel socket
> disposal leads to OOPSes:
> - nl_table[protocol]->listeners is double freed
> - sometimes during namespace stop netlink_sock_destruct
>   BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc)); is hit
> 
> This set address all these issues.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Tested-by: Alexey Dobriayn <adobriyan@openvz.org>

All 4 patches applied, thanks!
