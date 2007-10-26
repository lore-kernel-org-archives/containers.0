From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns: Fix get_net_ns_by_pid
Date: Fri, 26 Oct 2007 17:29:41 -0600
Message-ID: <m1ve8twj2y.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, "Denis V. Lunev" <dlunev@gmail.com>, Benjamin Thery <benjamin.thery@bull.net>, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org


The pid namespace patches changed the semantics of
find_task_by_pid without breaking the compile resulting
in get_net_ns_by_pid doing the wrong thing.

So switch to using the intended find_task_by_vpid.

Combined with Denis' earlier patch to make netlink traffic
fully synchronous the inadvertent race I introduced with
accessing current is actually removed.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/rtnetlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4a2640d..e1ba26f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -742,7 +742,7 @@ static struct net *get_net_ns_by_pid(pid_t pid)
 	/* Lookup the network namespace */
 	net = ERR_PTR(-ESRCH);
 	rcu_read_lock();
-	tsk = find_task_by_pid(pid);
+	tsk = find_task_by_vpid(pid);
 	if (tsk) {
 		struct nsproxy *nsproxy;
 		nsproxy = task_nsproxy(tsk);
-- 
1.5.3.rc6.17.g1911

