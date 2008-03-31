From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 10/13 net-2.6.26] [INET]: uc_ttl assignment in inet_ctl_sock_create is redundant.
Date: Mon, 31 Mar 2008 17:16:50 +0400
Message-ID: <1206969413-12096-10-git-send-email-den@openvz.org>
References: <1206969367.10660.16.camel@iris.sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1206969367.10660.16.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

uc_ttl is initialized in inet(6)_create and never changed except setsockopt
ioctl. Remove this assignment.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/af_inet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cf766ad..72ae8ed 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1260,7 +1260,6 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 	if (rc == 0) {
 		*sk = sock->sk;
 		(*sk)->sk_allocation = GFP_ATOMIC;
-		inet_sk(*sk)->uc_ttl = -1;
 		/*
 		 * Unhash it so that IP input processing does not even see it,
 		 * we do not wish this socket to see incoming packets.
-- 
1.5.3.rc5

