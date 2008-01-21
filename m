From: "Denis V. Lunev" <den@sw.ru>
Subject: [PATCH 0/6 net-2.6.25] Provide correct namespace on IPv4 packet input
 path.
Date: Mon, 21 Jan 2008 17:49:50 +0300
Message-ID: <4794B10E.7010703@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

This patchset sequentially adds namespace parameter to fib_lookup and
inetdev_by_index. After that it is possible to pass network namespace
from input packet to routing engine.

Output path is much more intrusive and will be sent separately.

Signed-off-by: Denis V. Lunev <den@openvz.org>
