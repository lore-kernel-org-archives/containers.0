From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] checkpoint/restart of robust futex lists
Date: Wed, 3 Jun 2009 10:58:04 -0500
Message-ID: <20090603155804.GA7848@us.ibm.com>
References: <20090603041919.GO9285@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090603041919.GO9285-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index b604a85..084a2e4 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -42,6 +42,17 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
> 
>  	h->task_comm_len = TASK_COMM_LEN;
> 
> +#ifdef CONFIG_FUTEX
> +	/* These are __user pointers and can be saved without the objhash. */
> +	h->robust_futex_list = t->robust_list;
> +	h->robust_futex_head_len = sizeof(t->robust_list);
> +#ifdef CONFIG_COMPAT
> +	h->compat_robust_futex_list = t->compat_robust_list;
> +	h->compat_robust_futex_head_len = sizeof(t->compat_robust_list);
> +#endif
> +	/* FIXME save pi futex state?? */
> +#endif
> +

So, I'm torn on this, but this does look like a prime example of code
which is destined to go stale and out of sync with the main futex code.

On the other hand, if we define futex_checkpoint() and futex_restart(),
and do that for every little thing we c/r, that could get out of hand...

But I think it's a risk worth taking.  What do you think?

Also, could you send out your testcase so I can add it to cr_tests?

thanks,
-serge
