From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/17] Finish IPv4 infrastructure namespacing.
Date: Thu, 28 Feb 2008 20:53:09 -0800 (PST)
Message-ID: <20080228.205309.73700976.davem@davemloft.net>
References: <1203406116.27296.1.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: den@openvz.org
Cc: containers@lists.osdl.org, netdev@vger.kernel.org, devel@openvz.org
List-Id: containers.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 19 Feb 2008 10:28:36 +0300

> This set finally allows to manipulate with network devices inside a
> namespace and allows to configure them [via netlink]. 'route' is not yet
> supported (but prepared to) as it requires a socket.
> 
> Additionally, better routing cache support is added.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

All applied to net-2.6.26, thanks Denis.
