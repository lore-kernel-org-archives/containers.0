From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [IPV6] cleanup : remove proc_net_remove called twice
Date: Tue, 30 Oct 2007 13:55:57 +0100
Message-ID: <472729DD.4070504@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Netdev List <netdev@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
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
-       proc_net_remove(&init_net, "if_inet6");
-#endif
  }
