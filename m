From: Yasunori Goto <y-goto-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH v2 7/7] Do not recompute msgmni anymore if
	explicitely set by user
Date: Tue, 05 Feb 2008 22:38:39 +0900
Message-ID: <20080205222005.67FE.Y-GOTO@jp.fujitsu.com>
References: <20080131134018.273154000@bull.net>
	<20080131135357.082657000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080131135357.082657000-6ktuUTfB/bM@public.gmane.org>
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
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Thanks Nadia-san.

I tested this patch set on my box. It works well.
I have only one comment.


> ---
>  ipc/ipc_sysctl.c |   43 +++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 41 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.24/ipc/ipc_sysctl.c
> ===================================================================
> --- linux-2.6.24.orig/ipc/ipc_sysctl.c	2008-01-29 16:55:04.000000000 +0100
> +++ linux-2.6.24/ipc/ipc_sysctl.c	2008-01-31 13:13:14.000000000 +0100
> @@ -34,6 +34,24 @@ static int proc_ipc_dointvec(ctl_table *
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
> +


Hmmm. I suppose this may be side effect which user does not wish.

I would like to recommend there should be a switch which can turn on/off
automatic recomputing.
If user would like to change this value, it should be turned off.
Otherwise, his requrest will be rejected with some messages.

Probably, user can understand easier than this side effect.

Bye.

-- 
Yasunori Goto 
