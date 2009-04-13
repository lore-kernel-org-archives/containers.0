From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 01/10] Infrastructure for work postponed to the
	end of checkpoint/restart
Date: Mon, 13 Apr 2009 10:35:04 -0500
Message-ID: <20090413153504.GA15846@us.ibm.com>
References: <1239107503-21941-1-git-send-email-orenl@cs.columbia.edu>
	<1239107503-21941-2-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239107503-21941-2-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> --- a/checkpoint/Makefile
> +++ b/checkpoint/Makefile
> @@ -2,8 +2,8 @@
>  # Makefile for linux checkpoint/restart.
>  #
> 
> -obj-$(CONFIG_CHECKPOINT) += sys.o objhash.o \
> +obj-$(CONFIG_CHECKPOINT) += sys.o objhash.o deferqueue.o \
>  		checkpoint.o restart.o \
>  		ckpt_task.o rstr_task.o \
>  		ckpt_mem.o rstr_mem.o \
> -		ckpt_file.o rstr_file.o
> +		ckpt_file.o rstr_file.o \

?

> +int cr_deferqueue_add(struct cr_ctx *ctx, cr_deferqueue_func_t function,
> +		     unsigned int flags, void *data, int size)
> +{
> +	struct cr_deferqueue *wq;
> +
> +	wq = kmalloc(sizeof(wq) + size, GFP_KERNEL);
> +	if (!wq)
> +		return -ENOMEM;
> +
> +	wq->function = function;
> +	wq->flags = flags;
> +	memcpy(wq->data, data, size);
> +
> +	cr_debug("adding work %p function %p\n", wq, wq->function);
> +	list_add_tail(&ctx->deferqueue, &wq->list);
> +	return 0;
> +}

Shouldn't the deferqueue be protected by a spinlock here?

-serge
