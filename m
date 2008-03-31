From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 11/13 net-2.6.26] [IPV6]: Simplify IPv6 control sockets
	creation.
Date: Mon, 31 Mar 2008 10:52:52 -0300
Message-ID: <20080331135252.GL14945@ghostprotocols.net>
References: <1206969367.10660.16.camel@iris.sw.ru> <1206969413-12096-11-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1206969413-12096-11-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Em Mon, Mar 31, 2008 at 05:16:51PM +0400, Denis V. Lunev escreveu:
> Do this by replacing sock_create_kern with inet_ctl_sock_create.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
