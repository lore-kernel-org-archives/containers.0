From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 5/6] IPC/sem: .show operation for /proc/pid/semundo
Date: Wed, 25 Jun 2008 15:58:59 -0500
Message-ID: <20080625205859.GE16374@us.ibm.com>
References: <20080625134910.487216000@bull.net>
	<20080625135539.893049000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080625135539.893049000-6ktuUTfB/bM@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nadia.Derbey-6ktuUTfB/bM@public.gmane.org (Nadia.Derbey-6ktuUTfB/bM@public.gmane.org):
> PATCH [05/06]
> 
> This patch introduces the .show seq operation for /proc/pid/semundo.
> 
> 
> Signed-off-by: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
> Signed-off-by: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  ipc/sem.c |   28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
> 
> Index: linux-2.6.26-rc5-mm3/ipc/sem.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/ipc/sem.c	2008-06-24 12:54:40.000000000 +0200
> +++ linux-2.6.26-rc5-mm3/ipc/sem.c	2008-06-24 12:59:15.000000000 +0200
> @@ -1475,6 +1475,34 @@ static void semundo_stop(struct seq_file
> 
>  static int semundo_show(struct seq_file *m, void *v)
>  {
> +	struct undo_list_data *data = m->private;
> +	struct ipc_namespace *ns = data->ipc_ns;
> +	struct sem_undo	*u = v;
> +	int nsems, i;
> +	struct sem_array *sma;
> +
> +	/*
> +	 * This semid has been deleted, ignore it.
> +	 * Even if we skipped all sem_undo belonging to deleted semid
> +	 * in semundo_next(), some more deletions may have happened.
> +	 */
> +	if (u->semid == -1)
> +		return 0;
> +
> +	seq_printf(m, "%10d", u->semid);
> +
> +	sma = sem_lock(ns, u->semid);
> +	if (IS_ERR(sma))
> +		goto out;
> +
> +	nsems = sma->sem_nsems;
> +	sem_unlock(sma);
> +
> +	for (i = 0; i < nsems; i++)
> +		seq_printf(m, " %6d", u->semadj[i]);
> +
> +out:
> +	seq_putc(m, '\n');
>  	return 0;
>  }
> 
> 
> --
