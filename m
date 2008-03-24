From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/11 net-2.6.26] UDP/ICMP/TCP for a namespace
Date: Mon, 24 Mar 2008 15:44:19 -0700 (PDT)
Message-ID: <20080324.154419.85665963.davem@davemloft.net>
References: <1206369185.23705.7.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1206369185.23705.7.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon, 24 Mar 2008 17:33:05 +0300

> This patch set finally enables TCP/UDP and ICMP inside a namespace.
> In order to do this we fix ARP processing, IP options processing and
> allow packets to flow to namespace aware protocols.
> 
> Finally, this makes namespace functional and alive :)
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Thanks for all of your hard work, applied.

I'll push this to my net-2.6.26 tree after some build
sanity checking.
