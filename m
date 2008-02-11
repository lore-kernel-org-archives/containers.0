From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 8/8] Re-enable msgmni automatic recomputing msgmni if
 set to negative
Date: Mon, 11 Feb 2008 12:27:48 -0800
Message-ID: <20080211122748.64e7bc36.akpm__21915.2297977873$1202762840$gmane$org@linux-foundation.org>
References: <20080211141646.948191000@bull.net>
	<20080211141816.520049000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080211141816.520049000-6ktuUTfB/bM@public.gmane.org>
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

On Mon, 11 Feb 2008 15:16:54 +0100
Nadia.Derbey-6ktuUTfB/bM@public.gmane.org wrote:

> [PATCH 08/08]
> 
> This patch is the enhancement as asked for by Yasunori: if msgmni is set to
> a negative value, register it back into the ipcns notifier chain.
> 
> A new interface has been added to the notification mechanism:
> notifier_chain_cond_register() registers a notifier block only if not already
> registered. With that new interface we avoid taking care of the states changes
> in procfs.
> 
> ...
>
>  static int proc_ipc_callback_dointvec(ctl_table *table, int write,
>  	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> +	struct ctl_table ipc_table;
>  	size_t lenp_bef = *lenp;
>  	int rc;
>  
> -	rc = proc_ipc_dointvec(table, write, filp, buffer, lenp, ppos);
> +	memcpy(&ipc_table, table, sizeof(ipc_table));
> +	ipc_table.data = get_ipc(table);
> +
> +	rc = proc_dointvec(&ipc_table, write, filp, buffer, lenp, ppos);
>  
>  	if (write && !rc && lenp_bef == *lenp)
> -		/*
> -		 * Tunable has successfully been changed from userland:
> -		 * disable its automatic recomputing.
> -		 */
> -		unregister_ipcns_notifier(current->nsproxy->ipc_ns);
> +		tunable_set_callback(*((int *)(ipc_table.data)));
>  
>  	return rc;
>  }
> @@ -119,12 +142,14 @@ static int sysctl_ipc_registered_data(ct
>  	rc = sysctl_ipc_data(table, name, nlen, oldval, oldlenp, newval,
>  		newlen);
>  
> -	if (newval && newlen && rc > 0)
> +	if (newval && newlen && rc > 0) {
>  		/*
> -		 * Tunable has successfully been changed from userland:
> -		 * disable its automatic recomputing.
> +		 * Tunable has successfully been changed from userland
>  		 */
> -		unregister_ipcns_notifier(current->nsproxy->ipc_ns);
> +		int *data = get_ipc(table);
> +
> +		tunable_set_callback(*data);
> +	}
>  
>  	return rc;
>  }

hm, what's happening here?  We take a local copy of the caller's ctl_table
and then pass that into proc_dointvec().  Is that as hacky as it seems??
