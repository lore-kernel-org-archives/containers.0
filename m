From: "Denis V. Lunev" <den@sw.ru>
Subject: [PATCH 0/6] preparations to enable netdevice notifiers inside a namespace
 (resend)
Date: Thu, 31 Jan 2008 14:59:49 +0300
Message-ID: <47A1B835.7050600@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Here are some preparations and cleanups to enable network device/inet
address notifiers inside a namespace.

This set of patches has been originally sent last Friday. One cleanup
patch from the original series is dropped as wrong, thanks to Daniel
Lezcano.
