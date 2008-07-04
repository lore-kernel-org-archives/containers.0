From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 0/9] selective (per/namespace) flush of rt_cache
Date: Fri, 04 Jul 2008 17:16:00 +0400
Message-ID: <1215177360.27873.50.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: Netdev List <netdev@vger.kernel.org>, containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hello, Dave!

This series of patches implements selective rt cache flushing to make
sure that in one namespace we'll not been able to affect the performance
of other from the user space.

Regards,
	Den

