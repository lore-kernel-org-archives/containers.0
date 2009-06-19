From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Fixes for the deferqueue_add() function
Date: Fri, 19 Jun 2009 12:56:00 -0500
Message-ID: <20090619175600.GB26692@us.ibm.com>
References: <1245431791-17588-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1245431791-17588-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> I'm not sure how the deferqueue would (or has ever) worked without these
> modifications, but I had to make them in order to use it :)
> 
> Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/deferqueue.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/deferqueue.c b/kernel/deferqueue.c
> index efd99d5..470b8a3 100644
> --- a/kernel/deferqueue.c
> +++ b/kernel/deferqueue.c
> @@ -66,18 +66,19 @@ int deferqueue_add(struct deferqueue_head *head, void *data, int size,
>  {
>  	struct deferqueue_entry *dq;
> 
> -	dq = kmalloc(sizeof(dq) + size, GFP_KERNEL);
> +	dq = kmalloc(sizeof(*dq) + size, GFP_KERNEL);

huh.  yeah.

>  	if (!dq)
>  		return -ENOMEM;
> 
>  	dq->function = func;
>  	dq->destructor = dtor;
> +	INIT_LIST_HEAD(&dq->list);

I'm pretty sure only head->list needed to be initialized.

>  	memcpy(dq->data, data, size);
> 
>  	pr_debug("%s: adding work %p func %p dtor %p\n",
>  		 __func__, dq, func, dtor);
>  	spin_lock(&head->lock);
> -	list_add_tail(&head->list, &dq->list);
> +	list_add_tail(&dq->list, &head->list);

at least after you've done this :)

>  	spin_unlock(&head->lock);
>  	return 0;
>  }
> -- 
> 1.6.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
