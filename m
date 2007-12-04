From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2.6.25] net: netns compilation speedup
Date: Tue, 4 Dec 2007 12:03:20 +0300
Message-ID: <20071204090320.GA5550@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

This patch speedups compilation when net_namespace.h is changed.

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
--
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index f285de6..2eaf204 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -2,7 +2,6 @@
 #define __NET_PKT_CLS_H
 
 #include <linux/pkt_cls.h>
-#include <net/net_namespace.h>
 #include <net/sch_generic.h>
 #include <net/act_api.h>
 
@@ -336,6 +335,8 @@ static inline int tcf_valid_offset(const struct sk_buff *skb,
 }
 
 #ifdef CONFIG_NET_CLS_IND
+#include <net/net_namespace.h>
+
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
 {
diff --git a/include/net/sock.h b/include/net/sock.h
index 43e3cd9..a04e361 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -57,7 +57,6 @@
 #include <asm/atomic.h>
 #include <net/dst.h>
 #include <net/checksum.h>
-#include <net/net_namespace.h>
 
 /*
  * This structure really needs to be cleaned up.
@@ -95,6 +94,7 @@ typedef struct {
 
 struct sock;
 struct proto;
+struct net;
 
 /**
  *	struct sock_common - minimal network layer representation of sockets
