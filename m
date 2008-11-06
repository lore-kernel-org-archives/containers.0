From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/2] net: fib_rules ordering fixes.
Date: Thu, 06 Nov 2008 07:34:28 -0800
Message-ID: <m1y6zwzx4r.fsf_-_@frodo.ebiederm.org>
References: <48ECA8D2.4090406@openvz.org>
	<m14p2l4v2l.fsf_-_@frodo.ebiederm.org>
	<m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
	<20081105.160047.174722021.davem@davemloft.net>
	<m14p2l0zyu.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m14p2l0zyu.fsf@frodo.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 06 Nov 2008 05:02:33 -0800")
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org, xemul@openvz.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org


We need to setup the network namespace state before we register
the notifier.  Otherwise if a network device is already registered
we get a nasty NULL pointer dereference.

Signed-off-by: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>
---
 net/core/fib_rules.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 79de3b1..32b3a01 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -664,17 +664,18 @@ static int __init fib_rules_init(void)
 	rtnl_register(PF_UNSPEC, RTM_DELRULE, fib_nl_delrule, NULL);
 	rtnl_register(PF_UNSPEC, RTM_GETRULE, NULL, fib_nl_dumprule);
 
-	err = register_netdevice_notifier(&fib_rules_notifier);
+	err = register_pernet_subsys(&fib_rules_net_ops);
 	if (err < 0)
 		goto fail;
 
-	err = register_pernet_subsys(&fib_rules_net_ops);
+	err = register_netdevice_notifier(&fib_rules_notifier);
 	if (err < 0)
 		goto fail_unregister;
+
 	return 0;
 
 fail_unregister:
-	unregister_netdevice_notifier(&fib_rules_notifier);
+	unregister_pernet_subsys(&fib_rules_net_ops);
 fail:
 	rtnl_unregister(PF_UNSPEC, RTM_NEWRULE);
 	rtnl_unregister(PF_UNSPEC, RTM_DELRULE);
-- 
1.5.6.5

