From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH][NETNS] fix net released by rcu callback
Date: Tue, 30 Oct 2007 11:33:59 +0100
Message-ID: <47270897.4000409@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Netdev List <netdev@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

When a network namespace reference is held by a network subsystem,
and when this reference is decremented in a rcu update callback, we
must ensure that there is no more outstanding rcu update before
trying to free the network namespace.

In the normal case, the rcu_barrier is called when the network namespace
is exiting in the cleanup_net function.

But when a network namespace creation fails, and the subsystems are
undone (like the cleanup), the rcu_barrier is missing.

This patch adds the missing rcu_barrier.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
  net/core/net_namespace.c |    2 ++
  1 file changed, 2 insertions(+)

Index: net-2.6/net/core/net_namespace.c
===================================================================
--- net-2.6.orig/net/core/net_namespace.c
+++ net-2.6/net/core/net_namespace.c
@@ -112,6 +112,8 @@ out_undo:
                 if (ops->exit)
                         ops->exit(net);
         }
+
+       rcu_barrier();
         goto out;
  }
