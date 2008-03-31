From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 8/13 net-2.6.26] [NETNS]: Inet control socket should
	not hold a namespace.
Date: Mon, 31 Mar 2008 10:51:10 -0300
Message-ID: <20080331135109.GJ14945@ghostprotocols.net>
References: <1206969367.10660.16.camel@iris.sw.ru> <1206969413-12096-8-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1206969413-12096-8-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Em Mon, Mar 31, 2008 at 05:16:48PM +0400, Denis V. Lunev escreveu:
> This is a generic requirement, so make inet_ctl_sock_create namespace
> aware and create a inet_ctl_sock_destroy wrapper around sk_release_kernel.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

OOps, drop my previous comment about this, but then again you
could have avoided one more patch if you used this function in
"[PATCH 3/13 net-2.6.26] [DCCP]: dccp_v(4|6)_ctl_socket is leaked."

:-)

- Arnaldo
