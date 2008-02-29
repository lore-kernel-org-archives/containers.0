From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/12 net-2.6.26] icmp_socket namespacing
Date: Fri, 29 Feb 2008 16:39:20 +0300
Message-ID: <1204292360.10368.11.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

This set of patches is targeted to create separate icmp_socket inside
each namespace. Both IPv4 and IPv6 codepaths are affected.

Though, in order to do this smoothly, a bit of optimisations are
performed. The kernel from now on will use sock rather than socket on
the ICMP send path.

Signed-off-by: Denis V. Lunev <den@openvz.org>

