From: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [PATCH 3/3] C/R: Basic support for network namespaces and devices
Date: Wed, 20 Jan 2010 17:21:19 -0500
Message-ID: <4B5781DF.6050106@hp.com>
References: <1263999673-11279-1-git-send-email-danms@us.ibm.com>
	<1263999673-11279-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1263999673-11279-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Dan Smith wrote:
> When checkpointing a task tree with network namespaces, we hook into
> do_checkpoint_ns() along with the others.  Any devices in a given namespace
> are checkpointed (including their peer, in the case of veth) sequentially.
> Each network device stores a list of protocol addresses, as well as other
> information, such as hardware address.
> 
> This patch supports veth pairs, as well as the loopback adapter.  The
> loopback support is there to make sure that any additional addresses and
> state (such as up/down) is copied to the loopback adapter that we are
> given in the new network namespace.
> 
> On restart, we instantiate new network namespaces and veth pairs as
> necessary.  Any device we encounter that isn't in a network namespace
> that was checkpointed as part of a task is left in the namespace of the
> restarting process.  This will be the case for a veth half that exists
> in the init netns to provide network access to a container.
> 
> Still to do are:
> 
>   1. Routes
>   2. Netfilter rules
>   3. IPv6 addresses
>   4. Other virtual device types (e.g. bridges)

What about:

    1. Multicast
    2. Device config info (ipv4_devconf)

> +static int checkpoint_in_addrs(struct ckpt_ctx *ctx, struct in_device *indev)
> +{
> +	struct ckpt_hdr_netdev_addr *h;
> +	struct in_ifaddr *addr = indev->ifa_list;
> +	int ret;
> +	int count = 0;
> +
> +	while (addr) {
> +		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NETDEV_ADDR);
> +		if (!h)
> +			return -ENOMEM;
> +
> +		h->type = CKPT_NETDEV_ADDR_IPV4; /* Only IPv4 right now */
> +
> +		h->inet4_local = addr->ifa_local;
> +		h->inet4_address = addr->ifa_address;
> +		h->inet4_mask = addr->ifa_mask;
> +		h->inet4_broadcast = addr->ifa_broadcast;

What about addr->ifa_flags and all the other elements like prefixlen, scope and label?

> +int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct ckpt_hdr_netdev *h;
> +	struct net_device *dev = ptr;
> +	struct net_device *peer = NULL;
> +	struct net *net = dev->nd_net;
> +	int ret = 0;
> +	struct ifreq req;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NETDEV);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	if (strcmp(dev->name, "lo") == 0)
> +		h->type = CKPT_NETDEV_LO;
> +	else {
> +		h->type = CKPT_NETDEV_VETH;
> +		peer = veth_get_peer(dev);
> +	}
> +
> +	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
> +	ret = __kern_dev_ioctl(net, SIOCGIFFLAGS, &req);
> +	h->flags = req.ifr_flags;
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = __kern_dev_ioctl(net, SIOCGIFHWADDR, &req);
> +	if (ret < 0)
> +		goto out;
> +	memcpy(h->hwaddr, req.ifr_hwaddr.sa_data, sizeof(h->hwaddr));
> +
> +	h->netns_ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
> +	if (!h->netns_ref) {
> +		ret = -EINVAL;
> +		ckpt_err(ctx, ret, "Found netdev with no netns");
> +		goto out;
> +	}
> +
> +	h->inet4_addrs = count_inet4_addrs(dev->ip_ptr);
> +
> +	if (h->type == CKPT_NETDEV_VETH) {
> +		ret = add_veth_refs(ctx, h, dev, peer);
> +		if (ret < 0)
> +			goto out;
> +	}
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	if (h->type == CKPT_NETDEV_VETH) {
> +		ret = ckpt_write_buffer(ctx, dev->name, IFNAMSIZ);
> +		if (ret < 0)
> +			goto out;
> +
> +		ret = ckpt_write_buffer(ctx, peer->name, IFNAMSIZ);
> +		if (ret < 0)
> +			goto out;
> +	}
> +
> +	ret = checkpoint_in_addrs(ctx, dev->ip_ptr);
> +	if ((ret >= 0) && (ret != h->inet4_addrs)) {
> +		ret = -EBUSY;
> +		ckpt_err(ctx, ret,
> +			 "Addresses on interface %s changed\n", dev->name);
> +		goto out;
> +	}

This isn't guaranteed to catch every change to the address list, just that
the number of addresses is the same, is there no way to hold a lock the whole
time?

-Brian
