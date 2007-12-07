From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 2/3]sysctl: prepare core tables to point to netns
 variables
Date: Fri, 07 Dec 2007 16:10:49 +0300
Message-ID: <47594659.2050505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: Linux Netdev List <netdev@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, devel@openvz.org
List-Id: containers.vger.kernel.org

Some of ctl variables are going to be on the struct 
net. Here's the way to adjust the ->data pointer on the
ctl_table-s to point on the right variable.

Since some pointers still point on the global variables,
I keep turning the write bits off on such tables.

This looks to become a common procedure for net sysctls,
so later parts of this code may migrate to some more
generic place.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 57a7ead..dc4cf7d 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -167,8 +167,13 @@ static __net_init int sysctl_core_net_init(struct net *net)
 		if (tbl == NULL)
 			goto err_dup;
 
-		for (tmp = tbl; tmp->procname; tmp++)
-			tmp->mode &= ~0222;
+		for (tmp = tbl; tmp->procname; tmp++) {
+			if (tmp->data >= (void *)&init_net &&
+					tmp->data < (void *)(&init_net + 1))
+				tmp->data += (char *)net - (char *)&init_net;
+			else
+				tmp->mode &= ~0222;
+		}
 	}
 
 	net->sysctl_core_hdr = register_net_sysctl_table(net,
-- 
1.5.3.4

