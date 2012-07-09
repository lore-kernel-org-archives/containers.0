From: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] netns: correctly use per-netns ipv4 sysctl_tcp_mem
Date: Mon, 9 Jul 2012 14:05:09 +0800
Message-ID: <4FFA7495.5070702__28138.6633789682$1341814528$gmane$org@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Now, kernel allows each net namespace to independently set up its levels
for tcp memory pressure thresholds.

But it seems there is a bug, as using the following steps:

[root@host socket]# lxc-start -n test -f config /bin/bash
[root@net-test socket]# ip route add default via 192.168.58.2
[root@net-test socket]# echo 0 0 0 > /proc/sys/net/ipv4/tcp_mem
[root@net-test socket]# scp root-Q0ErXNX1RuabR28l3DCWlg@public.gmane.org:/home/tcp_mem_test .

and it still can transport the "tcp_mem_test" file which we hope it
would not.

It's because inet_init() (net/ipv4/af_inet.c)initialize the
tcp_prot.sysctl_mem:
tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;

So when the protocal is TCP, sk->sk_prot->sysctl_mem(following code)
always use the ipv4 sysctl_tcp_mem of init_net namespace rather than
it's own net namespace.
This patch simply set "prot" equal to net->ipv4.sysctl_tcp_mem when
the protocol type is TCP.

Signed-off-by: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/net/sock.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4a45216..b62a8d9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -59,6 +59,7 @@
 #include <linux/static_key.h>
 #include <linux/aio.h>
 #include <linux/sched.h>
+#include <linux/in.h>

 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
@@ -1062,7 +1063,12 @@ static inline void sk_enter_memory_pressure(struct sock *sk)

 static inline long sk_prot_mem_limits(const struct sock *sk, int index)
 {
+	struct net *net = sock_net(sk);
 	long *prot = sk->sk_prot->sysctl_mem;
+	
+	if (sk->protocol == IPPROTO_TCP)
+		prot = net->ipv4.sysctl_tcp_mem;
+
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
 		prot = sk->sk_cgrp->sysctl_mem;
 	return prot[index];
-- 
1.7.1
