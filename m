From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 3/3] C/R: Basic support for network namespaces and devices
Date: Wed, 20 Jan 2010 16:26:50 -0500
Message-ID: <4B57751A.5080506@cs.columbia.edu>
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


Cool - looks good !

Would this compile without CONFIG_NET ?  without CONFIG_NET_NS ?

How can a user ask to not checkpoint the network-ns ?  (e.g. in
a subtree checkpoint)

And a few minor comments inline...


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
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]

> +/*
> + * Determine if an interface should be checkpointed, skipped, or
> + * if it makes us uncheckpointable.  This needs to be improved
> + * dramatically, but works for the moment.

Maybe be a bit more verbose about what's missing ?

> + *
> + * Return 1 for yes, 0 for skip, -ERRNO for error
> + */

[...]

> +static int count_inet4_addrs(struct in_device *indev)
> +{
> +	int count = 0;
> +	struct in_ifaddr *addr;
> +
> +	for (addr = indev->ifa_list; addr; addr = addr->ifa_next)
> +		count++;
> +
> +	return count;
> +}
> +
> +static int checkpoint_in_addrs(struct ckpt_ctx *ctx, struct in_device *indev)
> +{
> +	struct ckpt_hdr_netdev_addr *h;
> +	struct in_ifaddr *addr = indev->ifa_list;
> +	int ret;
> +	int count = 0;
> +

Is there a reason not to collect all addresses into one buffer (can
there be more than a page worth of them ?) and write in one go ?

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
> +
> +		ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +		ckpt_hdr_put(ctx, h);
> +		if (ret < 0)
> +			break;
> +
> +		addr = addr->ifa_next;
> +
> +		count++;
> +	}
> +
> +	return ret < 0 ? ret : count;
> +}

[...]

> +
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

While this is correct, perhaps be more verbose and change to:
	else if (strncmp(dev->name, "veth", 4) == 0)

> +		h->type = CKPT_NETDEV_VETH;
> +		peer = veth_get_peer(dev);
> +	}

and then
	} else {
		/* error */
	}

> +
> +	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
> +	ret = __kern_dev_ioctl(net, SIOCGIFFLAGS, &req);
> +	h->flags = req.ifr_flags;
> +	if (ret < 0)
> +		goto out;
> +

[...]

> +
> +int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct net *net = ptr;
> +	struct net_device *dev;
> +	struct ckpt_hdr_netns *h;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NET_NS);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->this_ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
> +	if (h->this_ref == 0) {
> +		/* This shouldn't happen because we're called from
> +		 * checkpoint_obj() which should have already put
> +		 * us in the hash
> +		 */

If this can only happen due to a bug, then BUG_ON(). Otherwise,
maybe use ckpt_err() ?

> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	for_each_netdev(net, dev) {
> +		ret = should_checkpoint_netdev(dev);
> +		if (ret > 0)
> +			ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
> +		if (ret < 0)
> +			break;
> +	}
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +

[...]

Thanks,

Oren.
