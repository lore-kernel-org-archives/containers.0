From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 7/8] Do not recompute msgmni anymore if explicitely set
 by user
Date: Mon, 11 Feb 2008 12:24:08 -0800
Message-ID: <20080211122408.5008902f.akpm__19165.4127128006$1202772529$gmane$org@linux-foundation.org>
References: <20080211141646.948191000@bull.net>
	<20080211141816.094061000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080211141816.094061000-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 11 Feb 2008 15:16:53 +0100
Nadia.Derbey-6ktuUTfB/bM@public.gmane.org wrote:

> [PATCH 07/08]
> 
> This patch makes msgmni not recomputed anymore upon ipc namespace creation /
> removal or memory add/remove, as soon as it has been set from userland.
> 
> As soon as msgmni is explicitely set via procfs or sysctl(), the associated
> callback routine is unregistered from the ipc namespace notifier chain.
> 

The patch series looks pretty good.

> ===================================================================
> --- linux-2.6.24-mm1.orig/ipc/ipc_sysctl.c	2008-02-08 16:07:15.000000000 +0100
> +++ linux-2.6.24-mm1/ipc/ipc_sysctl.c	2008-02-08 16:08:32.000000000 +0100
> @@ -35,6 +35,24 @@ static int proc_ipc_dointvec(ctl_table *
>  	return proc_dointvec(&ipc_table, write, filp, buffer, lenp, ppos);
>  }
>  
> +static int proc_ipc_callback_dointvec(ctl_table *table, int write,
> +	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	size_t lenp_bef = *lenp;
> +	int rc;
> +
> +	rc = proc_ipc_dointvec(table, write, filp, buffer, lenp, ppos);
> +
> +	if (write && !rc && lenp_bef == *lenp)
> +		/*
> +		 * Tunable has successfully been changed from userland:
> +		 * disable its automatic recomputing.
> +		 */
> +		unregister_ipcns_notifier(current->nsproxy->ipc_ns);
> +
> +	return rc;
> +}

If you haven't done so, could you please check that it all builds cleanly
with CONFIG_PROCFS=n, and that all code which isn't needed if procfs is
disabled is not present in the final binary?
