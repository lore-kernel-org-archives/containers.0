From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/3]sysctl: make sysctl_somaxconn
 per-namespace
Date: Sat, 08 Dec 2007 00:12:48 -0800 (PST)
Message-ID: <20071208.001248.208605097.davem@davemloft.net>
References: <475946D0.7020104@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <475946D0.7020104@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: xemul@openvz.org
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 16:12:48 +0300

> Just move the variable on the struct net and adjust
> its usage.
> 
> Others sysctls from sys.net.core table are more
> difficult to virtualize (i.e. make them per-namespace),
> but I'll look at them as well a bit later.
> 
> Signed-off-by: Pavel Emelyanov <xemul@oenvz.org>

Applied, thanks.
