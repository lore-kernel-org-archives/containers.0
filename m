From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 4/6] IPC/sem: next operations for /proc/pid/semundo
Date: Wed, 25 Jun 2008 15:57:19 -0500
Message-ID: <20080625205719.GD16374@us.ibm.com>
References: <20080625134910.487216000@bull.net>
	<20080625135539.519489000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080625135539.519489000-6ktuUTfB/bM@public.gmane.org>
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
> PATCH [04/06]
> 
> This patch introduces the .next seq operation for /proc/pid/semundo.
> 
> What should be mentioned here is that the undo_list lock is released between
> between each iteration.
> Doing this, we only guarantee to access some valid data during the .show,

Ok so you count on an item sticking around for the duration of the
rcu_read_cycle().  exit_sem() is therefore not an issue.  The other
possible racer is freeary() as called from IPC_RMID, but while that
could remove this entry from the undo_list->list_proc, it will wait
an rcu cycle before it actually frees it.

Am I reading that all right?  If so, then:

> not to have a full coherent view of the whole list. But, oth, this reduces the
> the performance impact on the access to the undo_list.
> 
> Signed-off-by: Pierre Peiffer <pierre.peiffer-6ktuUTfB/bM@public.gmane.org>
> Signed-off-by: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> 
> ---
>  ipc/sem.c |   23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.26-rc5-mm3/ipc/sem.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/ipc/sem.c	2008-06-24 12:32:36.000000000 +0200
> +++ linux-2.6.26-rc5-mm3/ipc/sem.c	2008-06-24 12:54:40.000000000 +0200
> @@ -1440,7 +1440,28 @@ static void *semundo_start(struct seq_fi
> 
>  static void *semundo_next(struct seq_file *m, void *v, loff_t *ppos)
>  {
> -	return NULL;
> +	struct sem_undo	*undo = v;
> +	struct undo_list_data *data = m->private;
> +	struct sem_undo_list *ulp = data->undo_list;
> +
> +	/*
> +	 * No need to protect against ulp being NULL, if we are here,
> +	 * it can't be NULL.
> +	 */
> +	spin_lock(&ulp->lock);
> +
> +	do {
> +		undo = list_entry(rcu_dereference(undo->list_proc.next),
> +				struct sem_undo, list_proc);
> +
> +	} while (&undo->list_proc != &ulp->list_proc && undo->semid == -1);
> +
> +	++*ppos;
> +	spin_unlock(&ulp->lock);
> +
> +	if (&undo->list_proc == &ulp->list_proc)
> +		return NULL;
> +	return undo;
>  }
> 
>  static void semundo_stop(struct seq_file *m, void *v)
> 
> --
