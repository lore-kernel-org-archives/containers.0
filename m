From: "Denis V. Lunev" <den@sw.ru>
Subject: [PATCH 0/17] Finish IPv4 infrastructure namespacing
Date: Wed, 06 Feb 2008 13:53:10 +0300
Message-ID: <47A99196.2030105@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: Linux Containers <containers@lists.osdl.org>, netdev <netdev@vger.kernel.org>, devel@openvz.org
List-Id: containers.vger.kernel.org

This set finally allows to manipulate with network devices inside a
namespace and allows to configure them [via netlink]. 'route' is not yet
supported (but prepared to).

Additionally, better routing cache support is added.

By the way, working ICMP is behind a couple of patches after this set :)

Signed-off-by: Denis V. Lunev <den@openvz.org>

