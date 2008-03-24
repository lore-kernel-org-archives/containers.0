From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/11 net-2.6.26] UDP/ICMP/TCP for a namespace
Date: Mon, 24 Mar 2008 17:33:05 +0300
Message-ID: <1206369185.23705.7.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: Netdev List <netdev@vger.kernel.org>, devel@openvz.org, containers <containers@lists.osdl.org>, xemul <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Hello, Dave!

This patch set finally enables TCP/UDP and ICMP inside a namespace.
In order to do this we fix ARP processing, IP options processing and
allow packets to flow to namespace aware protocols.

Finally, this makes namespace functional and alive :)

Signed-off-by: Denis V. Lunev <den@openvz.org>

