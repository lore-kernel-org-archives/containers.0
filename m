From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/17] Finish IPv4 infrastructure namespacing.
Date: Tue, 19 Feb 2008 10:28:36 +0300
Message-ID: <1203406116.27296.1.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: Linux Containers <containers@lists.osdl.org>, netdev <netdev@vger.kernel.org>, devel@openvz.org
List-Id: containers.vger.kernel.org

This set finally allows to manipulate with network devices inside a
namespace and allows to configure them [via netlink]. 'route' is not yet
supported (but prepared to) as it requires a socket.

Additionally, better routing cache support is added.

Signed-off-by: Denis V. Lunev <den@openvz.org>

