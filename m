From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/13 net-2.6.26] [DCCP]: Replace socket with sock for
	reset sending.
Date: Mon, 31 Mar 2008 10:44:40 -0300
Message-ID: <20080331134440.GE14945@ghostprotocols.net>
References: <1206969367.10660.16.camel@iris.sw.ru> <1206969413-12096-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1206969413-12096-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Em Mon, Mar 31, 2008 at 05:16:42PM +0400, Denis V. Lunev escreveu:
> Replace dccp_v(4|6)_ctl_socket with sock to unify a code with TCP/ICMP.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>


Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
