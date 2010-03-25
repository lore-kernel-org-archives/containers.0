From: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [PATCH 1/2] C/R: Support for IPv6 addresses on network devices
Date: Thu, 25 Mar 2010 16:36:55 -0400
Message-ID: <4BABC967.5090908@hp.com>
References: <1269459625-21033-1-git-send-email-danms@us.ibm.com>
	<1269459625-21033-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269459625-21033-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Hi Dan,

Dan Smith wrote: 
>  struct ckpt_netdev_addr {
> @@ -813,6 +814,13 @@ struct ckpt_netdev_addr {
>  			__be32 inet4_mask;
>  			__be32 inet4_broadcast;
>  		};
> +		struct {
> +			__be32 inet6_addr[4];

It might be easier to just make this an in6_addr.

> +			__u32  inet6_prefix_len;
> +			__u32  inet6_valid_lft;
> +			__u32  inet6_prefered_lft;
> +			__u16  inet6_scope;
> +		};

You'll also need to save "flags", without it I think all your addresses
would show up as "permanent" because it will look like they were added
by user-space tools.  Actually, using the SIOCSIFADDR path that might
happen anyways, which wouldn't be correct.

> +#ifdef CONFIG_IPV6
> +
> +#define __BYTE_ORDER_COPY(op, dst, src)		\
> +	do {					\
> +	int i;					\
> +	for (i = 0; i < 4; i++)			\
> +		dst[i] = op(src[i]);		\
> +	} while (0);
> +
> +#define HTON_IPV6(dst, src) __BYTE_ORDER_COPY(htonl, dst, src)
> +#define NTOH_IPV6(dst, src) __BYTE_ORDER_COPY(ntohl, dst, src)

Yuck, this is ugly, use ipv6_addr_copy() please.

> +static int ckpt_netdev_inet6_addrs(struct inet6_dev *indev,
> +				   int index, int max,
> +				   struct ckpt_netdev_addr *abuf)
> +{
> +	struct inet6_ifaddr *addr = indev->addr_list;
> +
> +	while (addr) {
> +		abuf[index].type = CKPT_NETDEV_ADDR_IPV6;
> +
> +		HTON_IPV6(abuf[index].inet6_addr, addr->addr.in6_u.u6_addr32);

Use ipv6_addr_copy().

> +		ckpt_debug("Checkpointed inet6: %x:%x:%x:%x\n",
> +			   abuf[index].inet6_addr[0],
> +			   abuf[index].inet6_addr[1],
> +			   abuf[index].inet6_addr[2],
> +			   abuf[index].inet6_addr[3]);

There was a new format specifier added to the kernel print routines
called "%pI6" for printing IPv6 addresses.

> +		abuf[index].inet6_prefix_len = addr->prefix_len;
> +		abuf[index].inet6_valid_lft = addr->valid_lft;
> +		abuf[index].inet6_prefered_lft = addr->prefered_lft;
> +		abuf[index].inet6_scope = addr->scope;

abuf[index].inet6_flags = addr->flags;

> +int ckpt_netdev_inet_addrs(struct net_device *dev,
>  			   struct ckpt_netdev_addr *_abuf[])
>  {
>  	struct ckpt_netdev_addr *abuf = NULL;
> -	struct in_ifaddr *addr = indev->ifa_list;
>  	int addrs = 0;

You can drop this initialization since you're now doing it below.

> @@ -167,21 +258,21 @@ int ckpt_netdev_inet_addrs(struct in_device *indev,
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

When can this return value be < 0 other then -E2BIG?

> +static int restore_inet4_addr(struct ckpt_ctx *ctx,
> +			      struct net_device *dev,
> +			      struct net *net,
> +			      struct ckpt_netdev_addr *addr)
> +{
> +	struct ifreq req;
> +	struct sockaddr_in *inaddr;
> +	int ret;
> +
> +	ckpt_debug("restoring %s: %x/%x/%x\n",
> +		   dev->name,
> +		   addr->inet4_address,
> +		   addr->inet4_mask,
> +		   addr->inet4_broadcast);

There's a "%pI4" for IPv4 addresses now.

> +#ifdef CONFIG_IPV6
> +static int restore_inet6_addr(struct ckpt_ctx *ctx,
> +			      struct net_device *dev,
> +			      struct net *net,
> +			      struct ckpt_netdev_addr *addr)
> +{
> +	struct in6_ifreq req;
> +	int ret;
> +
> +	ckpt_debug("restoring %s: %x:%x:%x:%x/%i\n",
> +		   dev->name,
> +		   addr->inet6_addr[0],
> +		   addr->inet6_addr[1],
> +		   addr->inet6_addr[2],
> +		   addr->inet6_addr[3],
> +		   addr->inet6_prefix_len);

%pI6

> +
> +	req.ifr6_ifindex = dev->ifindex;
> +	NTOH_IPV6(req.ifr6_addr.in6_u.u6_addr32, &addr->inet6_addr);

ipv6_addr_copy()

> +	req.ifr6_prefixlen = addr->inet6_prefix_len;
> +
> +	ret = __kern_addrconf(net, SIOCSIFADDR, &req);
> +	if (ret == -EEXIST)
> +		ret = 0;
> +	else if (ret < 0)
> +		ckpt_err(ctx, ret, "Failed to set address");
> +
> +	return ret;
> +}

I am still worried about this.  When an interface is activated and
the IPv6 module is loaded, it's going to generate a link-local address
right away.  Then it will auto-configure an address based on information
in a received router advertisement.  Is this code going to conflict
with that?  Meaning, will you have two link-locals on this interface
once the system is running?

Also, moving these addresses around is going to increase the likelihood
of a duplicate address (link-locals are typically based off the MAC, then
the global uses the same lower 64-bits).  Maybe only saving/restoring
"permanent" addresses is correct?  I could be wrong since I don't know
the typical use case here, but assume migrating a VM.

There's also going to be some conflict when you get to adding the
Multicast address back, as adding a "normal" IPv6 address is usually
going to add at least one Multicast address in the process.

And what about tunnel devices?  Maybe you already cover that somewhere
else?

And I won't harp on Anycast and Privacy addresses, I know this was
only a first pass :)

-Brian
