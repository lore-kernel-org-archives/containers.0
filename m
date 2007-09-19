From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [patch 1/1] fix bad netif_carrier_off place
Date: Wed, 19 Sep 2007 12:35:43 +0400
Message-ID: <46F0DF5F.9080905@openvz.org>
References: <20070918165645.365056264@mai.toulouse-stg.fr.ibm.com>
	<20070918170430.254614330@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070918170430.254614330-WECHFHqYCmGD/CxQmPlnQ0FT0OZdM7KVQQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

> From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> 
> If the netif_carrier_off is called before register_netdev
> that will use and generate an event for a non initialized network
> device and that leads to a Oops.
> 
> I moved the netif_carrier_off from the setup function after each 
> register_netdev call.
> 
> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

Acked-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Eric, if you managed to reproduce your oopses, does this patch help?

BTW, this problem exists for some other drivers, no? E.g.
xpnet_init() does the same thing and probably oopses as well.

> ---
>  drivers/net/veth.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> Index: net-2.6.24/drivers/net/veth.c
> ===================================================================
> --- net-2.6.24.orig/drivers/net/veth.c
> +++ net-2.6.24/drivers/net/veth.c
> @@ -286,7 +286,6 @@ static void veth_setup(struct net_device
>  	dev->features |= NETIF_F_LLTX;
>  	dev->init = veth_dev_init;
>  	dev->destructor = veth_dev_free;
> -	netif_carrier_off(dev);
>  }
>  
>  /*
> @@ -357,6 +356,8 @@ static int veth_newlink(struct net_devic
>  	if (err < 0)
>  		goto err_register_peer;
>  
> +	netif_carrier_off(peer);
> +
>  	/*
>  	 * register dev last
>  	 *
> @@ -382,6 +383,8 @@ static int veth_newlink(struct net_devic
>  	if (err < 0)
>  		goto err_register_dev;
>  
> +	netif_carrier_off(dev);
> +
>  	/*
>  	 * tie the deviced together
>  	 */
> 
> -- 
