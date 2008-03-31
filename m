From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/3 net-2.6.26] Compilation fixes.
Date: Mon, 31 Mar 2008 19:46:01 +0400
Message-ID: <1206978361.10660.31.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: yoshfuji <yoshfuji@linux-ipv6.org>, Netdev List <netdev@vger.kernel.org>, containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hello, Dave!

Recently I have seen several issues post to the netdev@ blaming
inclusion of the net_namespace.h from seq_file. This set fixes this
problem after two small cleanups.

Regards,
	Den

