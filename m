From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH] Use KMEM_CACHE macro to create the nsproxy cache
Date: Wed, 26 Sep 2007 15:37:35 +0200
Message-ID: <46FA609F.60702@fr.ibm.com>
References: <46FA5D0F.2090604@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759447AbXIZNhv@vger.kernel.org>
In-Reply-To: <46FA5D0F.2090604@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> The blessed way for standard caches is to use it.
> Besides, this may give this cache a better alignment.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

yes of course. thanks. 

Acked-by: Cedric Le Goater <clg@fr.ibm.com>

> ---
> 
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index ee68964..31351cc 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -222,8 +222,7 @@ void exit_task_namespaces(struct task_st
> 
>  static int __init nsproxy_cache_init(void)
>  {
> -	nsproxy_cachep = kmem_cache_create("nsproxy", sizeof(struct nsproxy),
> -					   0, SLAB_PANIC, NULL);
> +	nsproxy_cachep = KMEM_CACHE(nsproxy, SLAB_PANIC);
>  	return 0;
>  }
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
