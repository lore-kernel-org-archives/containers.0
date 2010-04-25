From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/4] Modularize the handling of netdev address c/r
Date: Sun, 25 Apr 2010 17:04:45 -0400
Message-ID: <4BD4AE6D.2070507@cs.columbia.edu>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>
	<1270748932-26745-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1270748932-26745-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Looks good, thanks. Please see comments below:

Dan Smith wrote:
> This moves the INET4 address checkpoint and restart routines into
> net/ipv4/devinet.c and introduces a registration method to present
> the checkpoint code with the handler functions.
> 
> This makes it easier to add additional address types, and also
> makes the cases where inet4 is absent, inet6 is a module, etc much
> easier.  It also elminates the need for a couple of helper functions.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint.h     |   18 +++++-
>  include/linux/checkpoint_hdr.h |    1 +
>  net/checkpoint_dev.c           |  152 ++++++++++++++++++++++++----------------
>  net/ipv4/devinet.c             |   75 ++++++++++++++++++++
>  4 files changed, 184 insertions(+), 62 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 96693e2..5fdbd01 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -132,7 +132,8 @@ extern void *restore_netdev(struct ckpt_ctx *ctx);
>  
>  extern int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx,
>  				     struct net_device *dev);
> -extern int ckpt_netdev_inet_addrs(struct in_device *indev,
> +extern int ckpt_netdev_inet_addrs(struct ckpt_ctx *ctx,
> +				  struct net_device *dev,
>  				  struct ckpt_netdev_addr *list[]);
>  extern int ckpt_netdev_hwaddr(struct net_device *dev,
>  			      struct ckpt_hdr_netdev *h);
> @@ -513,6 +514,21 @@ extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
>  	_do_ckpt_msg(ctx, err, "[E @ %s:%d]" fmt, __func__, __LINE__, ##args); \
>  } while (0)
>  
> +struct ckpt_netdev_addr_handler {
> +	int type;
> +	struct module *owner;
> +	int (*checkpoint_addr)(struct ckpt_ctx *ctx,
> +			       struct net_device *dev,
> +			       int index, int max,
> +			       struct ckpt_netdev_addr *addrs);
> +	int (*restore_addr)(struct ckpt_ctx *ctx,
> +			    struct net_device *dev,
> +			    struct net *net,
> +			    struct ckpt_netdev_addr *addr);
> +};
> +extern int ckpt_netdev_addr_register(struct ckpt_netdev_addr_handler *);
> +extern int ckpt_netdev_addr_unregister(struct ckpt_netdev_addr_handler *);

In another context, Matt pointed out that the naming convention
should start with "register", so something like:

   register_checkpoint_netdev_addr()
   unregister_checkpoint_netdev_addr()

> +
>  #endif /* CONFIG_CHECKPOINT */
>  #endif /* __KERNEL__ */
>  
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 36386ad..13bf62c 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -804,6 +804,7 @@ struct ckpt_hdr_netdev {
>  
>  enum ckpt_netdev_addr_types {
>  	CKPT_NETDEV_ADDR_IPV4,
> +	CKPT_NETDEV_ADDR_MAX
>  };
>  
>  struct ckpt_netdev_addr {
> diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
> index 5a4a95b..4ef06e3 100644
> --- a/net/checkpoint_dev.c
> +++ b/net/checkpoint_dev.c
> @@ -12,11 +12,11 @@
>  #include <linux/sched.h>
>  #include <linux/if.h>
>  #include <linux/if_arp.h>
> -#include <linux/inetdevice.h>
>  #include <linux/veth.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  #include <linux/deferqueue.h>
> +#include <linux/module.h>
>  
>  #include <net/net_namespace.h>
>  #include <net/sch_generic.h>
> @@ -34,17 +34,64 @@ struct mvl_newlink {
>  
>  typedef int (*new_link_fn)(struct sk_buff *, void *);
>  
> -static int __kern_devinet_ioctl(struct net *net, unsigned int cmd, void *arg)
> +static struct ckpt_netdev_addr_handler *addr_handlers[CKPT_NETDEV_ADDR_MAX];
> +
> +static char *addr_modules[] = {
> +	"ipv4",		/* CKPT_NETDEV_ADDR_IPV4 */
> +	"ipv6",		/* CKPT_NETDEV_ADDR_IPV6 */
> +};
> +
> +int ckpt_netdev_addr_register(struct ckpt_netdev_addr_handler *h)
>  {
> -	mm_segment_t fs;
> -	int ret;
> +	if (h->type >= CKPT_NETDEV_ADDR_MAX)
> +		return -EINVAL;

h->type is 'int' and can be negative :(
Either test for it, or better - change to unsigned int (above).

>  
> -	fs = get_fs();
> -	set_fs(KERNEL_DS);
> -	ret = devinet_ioctl(net, cmd, arg);
> -	set_fs(fs);
> +	if (addr_handlers[h->type] != NULL)
> +		return -EEXIST;

Does this test-and-set need locking ?

>  
> -	return ret;
> +	ckpt_debug("Registered addr type %s\n", addr_modules[h->type]);
> +	addr_handlers[h->type] = h;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(ckpt_netdev_addr_register);
> +
> +int ckpt_netdev_addr_unregister(struct ckpt_netdev_addr_handler *h)
> +{
> +	if (h->type >= CKPT_NETDEV_ADDR_MAX)
> +		return -EINVAL;
> +
> +	if (addr_handlers[h->type] == NULL)
> +		return -ESRCH;
> +
> +	ckpt_debug("Unregistered addr type %s\n", addr_modules[h->type]);
> +	addr_handlers[h->type] = NULL;

Ditto ?

> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(ckpt_netdev_addr_unregister);
> +
> +static struct ckpt_netdev_addr_handler *get_addr_handler(int type)
> +{
> +	struct ckpt_netdev_addr_handler *h;
> +
> +	if (type >= CKPT_NETDEV_ADDR_MAX)
> +		return ERR_PTR(-EINVAL);

type is 'int' - same comment as above.

> +
> +	h = addr_handlers[type];

Ditto for locking ?  (try_module_get below should be inside the
lock, of course).

> +
> +	if (h == NULL)
> +		return NULL;
> +
> +	if (try_module_get(h->owner))
> +		return h;
> +	else
> +		return ERR_PTR(-EBUSY);

Maybe some ckpt_err() here ?  I can feel the frustration of trying
to figure out where _this_ came from !

> +}
> +
> +static void put_addr_handler(struct ckpt_netdev_addr_handler *h)
> +{
> +	module_put(h->owner);
>  }

[...]

The rest looks ok :)

Oren.
