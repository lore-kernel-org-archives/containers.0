From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH] Enable netfilter in netns
Date: Fri, 22 Aug 2008 02:43:45 +0400
Message-ID: <20080821224345.GD31601__49698.1053184301$1219358658$gmane$org@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From kernel perspective, allow entrance in nf_hook_slow().

Stuff which uses nf_register_hook/nf_register_hooks, but otherwise not netns-ready:

	DECnet netfilter
	ipt_CLUSTERIP
	nf_nat_standalone.c together with XFRM (?)
	IPVS
	several individual match modules (like hashlimit)
	ctnetlink
	all sorts of queueing and reporting to userspace
	L3 and L4 protocol sysctls, bridge sysctls
	probably something else

Anyway critical mass has been achieved, there is no reason to hide netfilter any longer.

From userspace perspective, allow to manipulate all sorts of
iptables/ip6tables/arptables/ebtables rules.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 net/netfilter/core.c       |    8 --------
 net/netfilter/nf_sockopt.c |    3 ---
 2 files changed, 11 deletions(-)

--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -165,14 +165,6 @@ int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
 	unsigned int verdict;
 	int ret = 0;
 
-#ifdef CONFIG_NET_NS
-	struct net *net;
-
-	net = indev == NULL ? dev_net(outdev) : dev_net(indev);
-	if (net != &init_net)
-		return 1;
-#endif
-
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
 
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -65,9 +65,6 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct sock *sk, int pf,
 {
 	struct nf_sockopt_ops *ops;
 
-	if (!net_eq(sock_net(sk), &init_net))
-		return ERR_PTR(-ENOPROTOOPT);
-
 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
 		return ERR_PTR(-EINTR);
