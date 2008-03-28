From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/11 net-2.6.26] [SCTP]: Use inet_csk_ctl_sock_create for control socket creation.
Date: Fri, 28 Mar 2008 12:08:51 +0300
Message-ID: <1206695338-5947-4-git-send-email-den@openvz.org>
References: <1206695071.3271.8.camel@iris.sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1206695071.3271.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

sk->sk_proc->(un)hash is noop right now, so the unification is correct.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/sctp/protocol.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5aea911..5b0323c 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -680,16 +680,13 @@ static int sctp_ctl_sock_init(void)
 	else
 		family = PF_INET;
 
-	err = sock_create_kern(family, SOCK_SEQPACKET, IPPROTO_SCTP,
-			       &sctp_ctl_socket);
+	err = inet_csk_ctl_sock_create(&sctp_ctl_socket,
+				       family, SOCK_SEQPACKET, IPPROTO_SCTP);
 	if (err < 0) {
 		printk(KERN_ERR
 		       "SCTP: Failed to create the SCTP control socket.\n");
 		return err;
 	}
-	sctp_ctl_socket->sk->sk_allocation = GFP_ATOMIC;
-	inet_sk(sctp_ctl_socket->sk)->uc_ttl = -1;
-
 	return 0;
 }
 
-- 
1.5.3.rc5

