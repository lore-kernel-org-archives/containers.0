From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] inetpeer: add namespace support for inetpeer
Date: Tue, 05 Jun 2012 05:40:19 +0200
Message-ID: <1338867619.2760.1980.camel__36300.2291684554$1338867634$gmane$org@edumazet-glaptop>
References: <1338863012-4902-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338863012-4902-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2012-06-05 at 10:23 +0800, Gao feng wrote:
> now inetpeer doesn't support namespace,the information will
> be leaking across namespace.
> 
> this patch move the global vars v4_peers and v6_peers to
> netns_ipv4 and netns_ipv6 as a field peers.
> 
> add struct pernet_operations inetpeer_ops to initial pernet
> inetpeer data.
> 
> and change family_to_base and inet_getpeer to support namespace.
> 
> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  include/net/inetpeer.h   |   10 +++++---
>  include/net/netns/ipv4.h |    1 +
>  include/net/netns/ipv6.h |    1 +
>  net/ipv4/inetpeer.c      |   54 +++++++++++++++++++++++++++++++++++++++------
>  net/ipv4/route.c         |    2 +-
>  5 files changed, 55 insertions(+), 13 deletions(-)
> 
> diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
> index b94765e..4a50449 100644
> --- a/include/net/inetpeer.h
> +++ b/include/net/inetpeer.h
> @@ -72,7 +72,9 @@ static inline bool inet_metrics_new(const struct inet_peer *p)
>  }
>  
>  /* can be called with or without local BH being disabled */
> -struct inet_peer	*inet_getpeer(const struct inetpeer_addr *daddr, int create);
> +struct inet_peer *inet_getpeer(struct net *net,
> +			       const struct inetpeer_addr *daddr,
> +			       int create);
>  
>  static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
>  {
> @@ -80,7 +82,7 @@ static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
>  
>  	daddr.addr.a4 = v4daddr;
>  	daddr.family = AF_INET;
> -	return inet_getpeer(&daddr, create);
> +	return inet_getpeer(&init_net, &daddr, create);
>  }
>  
>  static inline struct inet_peer *inet_getpeer_v6(const struct in6_addr *v6daddr, int create)
> @@ -89,14 +91,14 @@ static inline struct inet_peer *inet_getpeer_v6(const struct in6_addr *v6daddr,
>  
>  	*(struct in6_addr *)daddr.addr.a6 = *v6daddr;
>  	daddr.family = AF_INET6;
> -	return inet_getpeer(&daddr, create);
> +	return inet_getpeer(&init_net, &daddr, create);
>  }
>  
>  /* can be called from BH context or outside */
>  extern void inet_putpeer(struct inet_peer *p);
>  extern bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
>  
> -extern void inetpeer_invalidate_tree(int family);
> +extern void inetpeer_invalidate_tree(struct net *net, int family);
>  
>  /*
>   * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index bbd023a..0855e09 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -31,6 +31,7 @@ struct netns_ipv4 {
>  	struct sock		**icmp_sk;
>  	struct sock		*tcp_sock;
>  
> +	struct inet_peer_base	*peers;
>  	struct netns_frags	frags;
>  #ifdef CONFIG_NETFILTER
>  	struct xt_table		*iptable_filter;
> diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
> index b42be53..df0a545 100644
> --- a/include/net/netns/ipv6.h
> +++ b/include/net/netns/ipv6.h
> @@ -33,6 +33,7 @@ struct netns_ipv6 {
>  	struct netns_sysctl_ipv6 sysctl;
>  	struct ipv6_devconf	*devconf_all;
>  	struct ipv6_devconf	*devconf_dflt;
> +	struct inet_peer_base	*peers;
>  	struct netns_frags	frags;
>  #ifdef CONFIG_NETFILTER
>  	struct xt_table		*ip6table_filter;
> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> index d4d61b6..dafb8b0 100644
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -90,13 +90,11 @@ struct inet_peer_base {
>  
>  static struct inet_peer_base v4_peers = {
>  	.root		= peer_avl_empty_rcu,
> -	.lock		= __SEQLOCK_UNLOCKED(v4_peers.lock),
>  	.total		= 0,
>  };
>  

Please remove v4_peers & v6_peers

>  static struct inet_peer_base v6_peers = {
>  	.root		= peer_avl_empty_rcu,
> -	.lock		= __SEQLOCK_UNLOCKED(v6_peers.lock),
>  	.total		= 0,
>  };
>  
> @@ -153,6 +151,41 @@ static void inetpeer_gc_worker(struct work_struct *work)
>  	schedule_delayed_work(&gc_work, gc_delay);
>  }
>  
> +static int __net_init inetpeer_net_init(struct net *net)
> +{
> +
> +	net->ipv4.peers = kmemdup(&v4_peers,
> +				  sizeof(v4_peers),
> +				  GFP_KERNEL);

kzalloc(), and init ->root to peer_avl_empty_rcu

> +	if (net->ipv4.peers == NULL)
> +		return -1;
> +	seqlock_init(&net->ipv4.peers->lock);
> +	net->ipv6.peers = kmemdup(&v6_peers,
> +				  sizeof(v6_peers),
> +				  GFP_KERNEL);

kzalloc(), and init ->root to peer_avl_empty_rcu

> +	if (net->ipv6.peers == NULL)
> +		goto out_ipv6;
> +	seqlock_init(&net->ipv6.peers->lock);
> +	return 0;
> +out_ipv6:
> +	kfree(net->ipv4.peers);
> +	return -1;
> +}
> +
