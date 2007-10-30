From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/1][IPV6] resend:  remove duplicate call to proc_net_remove
Date: Tue, 30 Oct 2007 17:23:45 +0100
Message-ID: <20071030162450.257974469@mai.toulouse-stg.fr.ibm.com>
References: <20071030162344.297260466@mai.toulouse-stg.fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=fix-proc-net-remove-called-twice.patch
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net, ebiederm@xmission.com
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

The file /proc/net/if_inet6 is removed twice.
First time in:
        inet6_exit
             ->addrconf_cleanup
And followed a few lines after by:
        inet6_exit
             -> if6_proc_exit

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/addrconf.c |    4 ----
 1 file changed, 4 deletions(-)

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c
+++ net-2.6/net/ipv6/addrconf.c
@@ -4288,8 +4288,4 @@ void __exit addrconf_cleanup(void)
 	del_timer(&addr_chk_timer);
 
 	rtnl_unlock();
-
-#ifdef CONFIG_PROC_FS
-	proc_net_remove(&init_net, "if_inet6");
-#endif
 }

-- 
