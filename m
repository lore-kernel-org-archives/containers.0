From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 4/13 net-2.6.26] [INET]: Rename
	inet_csk_ctl_sock_create to inet_ctl_sock_create.
Date: Mon, 31 Mar 2008 10:43:45 -0300
Message-ID: <20080331134345.GC14945@ghostprotocols.net>
References: <1206969367.10660.16.camel@iris.sw.ru> <1206969413-12096-4-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1206969413-12096-4-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Em Mon, Mar 31, 2008 at 05:16:44PM +0400, Denis V. Lunev escreveu:
> This call is nothing common with INET connection sockets code. It simply
> creates an unhashes kernel sockets for protocol messages.
> 
> Move the new call into af_inet.c after the rename.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
