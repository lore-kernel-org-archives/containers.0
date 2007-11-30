From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/4 net-2.6.15][UNIX] Make unix sysctls per-namespace
Date: Fri, 30 Nov 2007 19:23:53 +0300
Message-ID: <47503919.8060103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Linux Netdev List <netdev@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

Hi, Herbert, guys.

Since you have accepted some net-namespaces-related work
from Eric (sysctl namespaces), I hope, that you can pay 
some attention to further work in this direction.

This set makes the unix-sockets sysctls (currently this
includes the sys/net/unix/max_dgram_qlen only) per net
namespace.

I splitted it into four patches, to make the review simpler.
Hope that this split will help.

This set resembles the one Eric has in his netns tree, but
differs in some (maybe minor) ways.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
