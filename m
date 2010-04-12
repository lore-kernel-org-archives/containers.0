From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] Add IPv6 address checkpoint handler
Date: Mon, 12 Apr 2010 11:11:48 -0500
Message-ID: <20100412161148.GC23380@us.ibm.com>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>
	<1270748932-26745-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270748932-26745-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint_hdr.h |    8 +++
>  net/ipv6/addrconf.c            |   95 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 103 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 13bf62c..98aa79c 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -804,6 +804,7 @@ struct ckpt_hdr_netdev {
> 
>  enum ckpt_netdev_addr_types {
>  	CKPT_NETDEV_ADDR_IPV4,
> +	CKPT_NETDEV_ADDR_IPV6,
>  	CKPT_NETDEV_ADDR_MAX
>  };
> 
> @@ -816,6 +817,13 @@ struct ckpt_netdev_addr {
>  			__be32 inet4_mask;
>  			__be32 inet4_broadcast;
>  		};
> +		struct {
> +			struct in6_addr inet6_addr;
> +			__u32  inet6_prefix_len;
> +			__u32  inet6_valid_lft;
> +			__u32  inet6_prefered_lft;
> +			__u16  inet6_scope;
> +		};
>  	} __attribute__((aligned(8)));
>  } __attribute__((aligned(8)));
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 143791d..75cc3b8 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -87,6 +87,8 @@
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> 
> +#include <linux/checkpoint.h>
> +
>  /* Set to 3 to get tracing... */
>  #define ACONF_DEBUG 2
> 
> @@ -4514,6 +4516,91 @@ int unregister_inet6addr_notifier(struct notifier_block *nb)
> 
>  EXPORT_SYMBOL(unregister_inet6addr_notifier);
> 
> +#ifdef CONFIG_NETNS_CHECKPOING

How could that be defined?  :)

> +static int inet6_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev,
> +			    int index, int max,
> +			    struct ckpt_netdev_addr *addrs)
> +{
> +	struct inet6_dev *indev = dev->ip6_ptr;
> +	struct inet6_ifaddr *addr;
> +	struct ifmcaddr6 *mcaddr;
> +	struct ifacaddr6 *acaddr;
> +
> +	for (addr = indev->addr_list; addr; addr = addr->if_next) {
> +		if (ipv6_addr_scope(&addr->addr))
> +			continue; /* Ignore non-global scope addresses */
> +
> +		addrs[index].type = CKPT_NETDEV_ADDR_IPV6;
> +
> +		ipv6_addr_copy(&addrs[index].inet6_addr, &addr->addr);
> +
> +		ckpt_debug("Checkpointed inet6: %pI6\n", &addr->addr);
> +
> +		addrs[index].inet6_prefix_len = addr->prefix_len;
> +		addrs[index].inet6_valid_lft = addr->valid_lft;
> +		addrs[index].inet6_prefered_lft = addr->prefered_lft;
> +		addrs[index].inet6_scope = addr->scope;
> +
> +		if (++index >= max)
> +			return -E2BIG;
> +	}
> +
> +	for (mcaddr = indev->mc_list; mcaddr; mcaddr = mcaddr->next) {
> +		if (ipv6_addr_scope(&mcaddr->mca_addr))
> +			continue; /* Ignore non-global scope addresses */
> +
> +		/* TODO */
> +
> +		/* Multicast addresses are not supported, so do not
> +		 * allow checkpoint to continue if one is assigned
> +		 */
> +		ckpt_debug("ipv6 multicast addresses are not supported\n");

Again, I'd prefer ckpt_err here.

Note that in my last email that really was a q - if you're under
spinlock here, then you can't use ckpt_err().

> +		return -EINVAL;
> +	}
> +
> +	for (acaddr = indev->ac_list; acaddr; acaddr = acaddr->aca_next) {
> +		if (ipv6_addr_scope(&acaddr->aca_addr))
> +			continue; /* Ignore non-global scope addresses */
> +
> +		/* TODO */
> +
> +		/* Anycast addresses are not supported, so do not
> +		 * allow checkpoint to continue if one is assigned
> +		 */
> +		ckpt_debug("ipv6 anycast addresses are not supported\n");

and here

> +		return -EINVAL;
> +	}
> +
> +	return index;
> +}
> +
> +static int inet6_restore(struct ckpt_ctx *ctx,
> +			 struct net_device *dev,
> +			 struct net *net,
> +			 struct ckpt_netdev_addr *addr)
> +{
> +	int ret;
> +
> +	rtnl_lock();
> +	ret = inet6_addr_add(net, dev->ifindex, &addr->inet6_addr,
> +			     addr->inet6_prefix_len, IFA_F_PERMANENT,
> +			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
> +	rtnl_unlock();
> +	if (ret < 0)
> +		ckpt_err(ctx, ret, "Failed to set address %pI6\n",
> +			 &addr->inet6_addr);
> +
> +	return ret;
> +}
> +
> +struct ckpt_netdev_addr_handler inet6_addr_handler = {
> +	.type =			CKPT_NETDEV_ADDR_IPV6,
> +	.owner =		THIS_MODULE,
> +	.checkpoint_addr =	inet6_checkpoint,
> +	.restore_addr =		inet6_restore,
> +};
> +#endif /* CONFIG_NETNS_CHECKPOINT */
> +
>  /*
>   *	Init / cleanup code
>   */
> @@ -4572,6 +4659,10 @@ int __init addrconf_init(void)
> 
>  	ipv6_addr_label_rtnl_register();
> 
> +#ifdef CONFIG_NETNS_CHECKPOINT
> +	ckpt_netdev_addr_register(&inet6_addr_handler);
> +#endif
> +
>  	return 0;
>  errout:
>  	unregister_netdevice_notifier(&ipv6_dev_notf);
> @@ -4590,6 +4681,10 @@ void addrconf_cleanup(void)
>  	unregister_netdevice_notifier(&ipv6_dev_notf);
>  	unregister_pernet_subsys(&addrconf_ops);
> 
> +#ifdef CONFIG_NETNS_CHECKPOINT
> +	ckpt_netdev_addr_unregister(&inet6_addr_handler);
> +#endif
> +
>  	rtnl_lock();
> 
>  	/* clean dev list */
> -- 
> 1.6.2.5
