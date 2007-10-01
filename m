From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/5] Generic notifiers for SLUB events
Date: Mon, 01 Oct 2007 18:35:07 +0530
Message-ID: <4700F083.1070706@linux.vnet.ibm.com>
References: <46F91841.9070708@openvz.org> <46F918D9.3020406@openvz.org>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46F918D9.3020406-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> If the user wants more than one listener for SLUB event,
> it can register them all as notifier_block-s so all of
> them will be notified.
> 
> This costs us about 10% of performance loss, in comparison
> with static linking.
> 
> The selected method of notification is srcu notifier blocks.
> This is selected because the "call" path, i.e. when the 
> notification is done, is lockless and at the same time the
> handlers can sleep. Neither regular nor atomic notifiers
> provide such facilities.
> 
> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> ---
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 684ccfb..e9acc29 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -593,6 +599,16 @@ config SLUB_DEBUG
>  	  SLUB sysfs support. /sys/slab will not exist and there will be
>  	  no support for cache validation etc.
> 
> +config SLUB_NOTIFY
> +	default y

Should the default be on? Shouldn't it depend on KMEM?

> +	bool "Enable SLUB events generic notification"
> +	depends on SLUB
> +	help
> +	  When Y, this option enables generic notifications of some major
> +	  slub events. However, if you do know that there will be the
> +	  only listener for them, you may say N here, so that callbacks
> +	  will be called directly.
> +
> -
> -
> +#ifdef CONFIG_SLUB_NOTIFY
> +	srcu_init_notifier_head(&slub_nb);

Can we get rid of the #ifdef CONFIG_SLUB_NOTIFY?

> +#endif
>  	printk(KERN_INFO "SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
>  		" CPUs=%d, Nodes=%d\n",
>  		caches, cache_line_size(),
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
