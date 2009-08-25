From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] c/r: alloc_pid() should return -ENOMEM on failure
Date: Tue, 25 Aug 2009 01:53:14 -0400
Message-ID: <4A937C4A.9010109@librato.com>
References: <20090819194654.GA22851@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090819194654.GA22851-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Added, thanks.

Sukadev Bhattiprolu wrote:
> The clone_with_pids() patchset changed alloc_pid() to return an error
> code in the pointer. alloc_pid() should then return -ENOMEM rather than
> NULL when memory allocations fails.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Index: linux-cr/kernel/pid.c
> ===================================================================
> --- linux-cr.orig/kernel/pid.c	2009-08-19 12:43:45.000000000 -0700
> +++ linux-cr/kernel/pid.c	2009-08-19 12:45:33.000000000 -0700
> @@ -290,8 +290,10 @@
>  	int tpid;
>  
>  	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
> -	if (!pid)
> +	if (!pid) {
> +		pid = ERR_PTR(-ENOMEM);
>  		goto out;
> +	}
>  
>  	tmp = ns;
>  	for (i = ns->level; i >= 0; i--) {
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
