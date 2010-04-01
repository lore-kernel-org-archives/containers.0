From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH linux-cr] export net checkpoint fns
Date: Thu, 01 Apr 2010 00:31:43 -0400
Message-ID: <4BB421AF.60906@cs.columbia.edu>
References: <20100330155112.GA3132@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100330155112.GA3132-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Got it -- for v21-rc2.

Serge E. Hallyn wrote:
> Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  net/checkpoint_dev.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
> index bc0415d..eb9673c 100644
> --- a/net/checkpoint_dev.c
> +++ b/net/checkpoint_dev.c
> @@ -128,6 +128,8 @@ int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx, struct net_device *dev)
>  	return dev->nd_net == current->nsproxy->net_ns;
>  }
>  
> +EXPORT_SYMBOL_GPL(ckpt_netdev_in_init_netns);
> +
>  int ckpt_netdev_hwaddr(struct net_device *dev, struct ckpt_hdr_netdev *h)
>  {
>  	struct net *net = dev->nd_net;
> @@ -228,6 +230,8 @@ struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
>  	return h;
>  }
>  
> +EXPORT_SYMBOL_GPL(ckpt_netdev_base);
> +
>  int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
>  {
>  	struct net_device *dev = (struct net_device *)ptr;
