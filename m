From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 3/6] IPC/sem: start/stop operations for
	/proc/pid/semundo
Date: Wed, 25 Jun 2008 15:39:50 -0500
Message-ID: <20080625203950.GC16374@us.ibm.com>
References: <20080625134910.487216000@bull.net>
	<20080625135539.139605000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080625135539.139605000-6ktuUTfB/bM@public.gmane.org>
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
> PATCH [03/06]
> 
> This patch introduces the .start and .stop seq operations for
> /proc/pid/semundo.
> 
> Signed-off-by: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
> Signed-off-by: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  ipc/sem.c |   43 +++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 41 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.26-rc5-mm3/ipc/sem.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/ipc/sem.c	2008-06-24 10:59:46.000000000 +0200
> +++ linux-2.6.26-rc5-mm3/ipc/sem.c	2008-06-24 12:32:36.000000000 +0200
> @@ -1400,7 +1400,42 @@ struct undo_list_data {
>  /* iterator */
>  static void *semundo_start(struct seq_file *m, loff_t *ppos)
>  {
> -	return NULL;
> +	struct undo_list_data *data = m->private;
> +	struct sem_undo_list *ulp = data->undo_list;
> +	struct sem_undo	*undo;
> +	loff_t pos = *ppos;
> +
> +	if (!ulp)
> +		return NULL;
> +
> +	if (pos < 0)
> +		return NULL;
> +
> +	/* If ulp is not NULL, it means that we've successfully grabbed
> +	 * a refcnt in semundo_open. That prevents the undo_list from being
> +	 * freed.
> +	 *
> +	 * Note:
> +	 * 1) the sem_undo structure is RCU-protected. So take the rcu read
> +	 *    lock and only release it during the .stop operation.
> +	 * 2) we accept to release the undo_list lock (i.e. we allow the list
> +	 *    to change) between each iteration, instead of taking that lock
> +	 *    during the .start and releasing it during the .stop operation.
> +	 *    This is to reduce the performance impact on the access to the
> +	 *    undo_list.
> +	 */
> +	rcu_read_lock();
> +	spin_lock(&ulp->lock);
> +	list_for_each_entry_rcu(undo, &ulp->list_proc, list_proc) {
> +		if ((undo->semid != -1) && !(pos--))
> +			break;
> +	}
> +	spin_unlock(&ulp->lock);
> +
> +	if (&undo->list_proc == &ulp->list_proc)
> +		return NULL;
> +
> +	return undo;
>  }
> 
>  static void *semundo_next(struct seq_file *m, void *v, loff_t *ppos)
> @@ -1410,7 +1445,11 @@ static void *semundo_next(struct seq_fil
> 
>  static void semundo_stop(struct seq_file *m, void *v)
>  {
> -	return;
> +	struct undo_list_data *data = m->private;
> +	struct sem_undo_list *ulp = data->undo_list;
> +
> +	if (ulp)
> +		rcu_read_unlock();
>  }
> 
>  static int semundo_show(struct seq_file *m, void *v)
> 
> --
