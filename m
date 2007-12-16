From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 6/7] Switch users of ipv4_devconf_dflt to
 use the pernet one
Date: Sun, 16 Dec 2007 13:32:23 -0800 (PST)
Message-ID: <20071216.133223.157279452.davem@davemloft.net>
References: <475ECC69.1040809@openvz.org>
	<475ED01E.5020505@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <475ED01E.5020505@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: xemul@openvz.org
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 11 Dec 2007 20:59:58 +0300

> They are all collected in the net/ipv4/devinet.c file and
> mostly use the IPV4_DEVCONF_DFLT macro.
> 
> So I add the net parameter to it and patch users accordingly.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
