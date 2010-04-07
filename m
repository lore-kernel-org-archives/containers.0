From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] C/R: Support for IPv6 addresses on network devices
	(v2)
Date: Tue, 6 Apr 2010 23:18:58 -0500
Message-ID: <20100407041858.GA12287@us.ibm.com>
References: <1270563183-9351-1-git-send-email-danms@us.ibm.com>
	<1270563183-9351-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270563183-9351-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Two related problems here:

> +#ifdef CONFIG_IPV6

1. this will only trigger if CONFIG_IPV6=y, not if it =m.  So you
might have meant
	#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
or something.  But I'm not sure that if it's a module but not
yet loaded that that suffices?

> +
> +#define __BYTE_ORDER_COPY(op, dst, src)					\
> +	do {								\
> +		int i;							\
> +		for (i = 0; i < 16; i++) {				\
> +			(dst)->in6_u.u6_addr8[i] =			\
> +				(src)->in6_u.u6_addr8[16-i];		\
> +		}							\
> +	} while (0);
> +
> +#define HTON_IPV6(dst, src) __BYTE_ORDER_COPY(htonl, dst, src)
> +#define NTOH_IPV6(dst, src) __BYTE_ORDER_COPY(ntohl, dst, src)
> +
> +static int ckpt_netdev_inet6_addrs(struct inet6_dev *indev,
> +				   int index, int max,
> +				   struct ckpt_netdev_addr *abuf)
> +{
> +	struct inet6_ifaddr *addr;
> +	struct ifmcaddr6 *mcaddr;
> +	struct ifacaddr6 *acaddr;
> +
> +	for (addr = indev->addr_list; addr; addr = addr->if_next) {
> +		if (ipv6_addr_scope(&addr->addr))
> +			continue; /* Ignore non-global scope addresses */
> +
> +		abuf[index].type = CKPT_NETDEV_ADDR_IPV6;
> +
> +		HTON_IPV6(&abuf[index].inet6_addr, &addr->addr);
> +
> +		ckpt_debug("Checkpointed inet6: %pI6\n", &addr->addr);
> +
> +		abuf[index].inet6_prefix_len = addr->prefix_len;
> +		abuf[index].inet6_valid_lft = addr->valid_lft;
> +		abuf[index].inet6_prefered_lft = addr->prefered_lft;
> +		abuf[index].inet6_scope = addr->scope;
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
> +		return -EINVAL;
> +	}
> +
> +	return index;
> +}
> +#else
> +static int ckpt_netdev_inet6_addrs(struct inet6_dev *indev,
> +				   int index, int max,
> +				   struct ckpt_netdev_addr *abuf)
> +{
> +	return -ENOSYS;
> +}
> +#endif
> +
> +int ckpt_netdev_inet_addrs(struct net_device *dev,
>  			   struct ckpt_netdev_addr *_abuf[])
>  {
>  	struct ckpt_netdev_addr *abuf = NULL;
> -	struct in_ifaddr *addr = indev->ifa_list;
>  	int addrs = 0;
>  	int max = 32;
> 
> @@ -169,21 +288,21 @@ int ckpt_netdev_inet_addrs(struct in_device *indev,
> 
>  	read_lock(&dev_base_lock);
> 
> -	while (addr) {
> -		abuf[addrs].type = CKPT_NETDEV_ADDR_IPV4; /* Only IPv4 now */
> -		abuf[addrs].inet4_local = htonl(addr->ifa_local);
> -		abuf[addrs].inet4_address = htonl(addr->ifa_address);
> -		abuf[addrs].inet4_mask = htonl(addr->ifa_mask);
> -		abuf[addrs].inet4_broadcast = htonl(addr->ifa_broadcast);
> +	addrs = 0;
> 
> -		addr = addr->ifa_next;
> -		if (++addrs >= max) {
> -			read_unlock(&dev_base_lock);
> -			max *= 2;
> -			goto retry;
> -		}
> -	}
> +	addrs = ckpt_netdev_inet4_addrs(dev->ip_ptr, addrs, max, abuf);
> +	if (addrs == -E2BIG) {
> +		read_unlock(&dev_base_lock);
> +		goto retry;
> +	} else if (addrs < 0)
> +		goto unlock;
> 
> +	addrs = ckpt_netdev_inet6_addrs(dev->ip6_ptr, addrs, max, abuf);
> +	if (addrs == -E2BIG) {
> +		read_unlock(&dev_base_lock);
> +		goto retry;
> +	}

This is the second problem.  If CONFIG_IPV6=n or CONFIG_IPV6=m, then
ckpt_netdev_inet6_addrs() will return -ENOSYS, and you'll fail here.
So in those cases there is now no way to do a checkpoint with
CHECKPOINT_NETNS (or without CHECKPOINT_NONETNS :).

The fix of course can't be quite as simple as ignoring return
value of -ENOSYS since you'll have lost the passed-in addrs from
ckpt_netdev_inet4_addrs.

> + unlock:
>  	read_unlock(&dev_base_lock);
>   out:
>  	if (addrs < 0) {

-serge
