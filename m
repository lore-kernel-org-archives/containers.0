From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] UNIX: remove unused declaration of
	sysctl_unix_max_dgram_qlen (resend, wrong patch was sent)
Date: Tue, 11 Dec 2007 14:53:23 +0300
Message-ID: <20071211115323.GA9922@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

UNIX: remove unused declaration of sysctl_unix_max_dgram_qlen

Signed-off-by: Denis V. Lunev <den@openvz.org>
--
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -59,7 +59,6 @@ struct unix_sock {
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
 #ifdef CONFIG_SYSCTL
-extern int sysctl_unix_max_dgram_qlen;
 extern int unix_sysctl_register(struct net *net);
 extern void unix_sysctl_unregister(struct net *net);
 #else
