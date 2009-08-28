From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/1] signal c/r: don't play with zero timeouts
Date: Fri, 28 Aug 2009 11:21:57 -0400
Message-ID: <4A97F615.8070703@librato.com>
References: <20090827184934.GA20580@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090827184934.GA20580-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Yep. Pushed...

Serge E. Hallyn wrote:
> If it_virt_expires or it_prof_expires is zero, then don't
> subtract {virt,prof}_ticks(t) from it.  This is the same
> thing do_getitimer() does, and it fixes my issues with
> the signals c/r patchset on s390.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/signal.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
> index 960356c..15b7cdc 100644
> --- a/checkpoint/signal.c
> +++ b/checkpoint/signal.c
> @@ -382,13 +382,17 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
>  	}
>  	h->it_real_incr = ktime_to_ns(signal->it_real_incr);
>  
> -	cputime = cputime_sub(signal->it_virt_expires, virt_ticks(t));
> +	cputime = signal->it_virt_expires;
> +	if (!cputime_eq(cputime, cputime_zero))
> +		cputime = cputime_sub(signal->it_virt_expires, virt_ticks(t));
>  	cputime_to_timeval(cputime, &tval);
>  	h->it_virt_value = timeval_to_ns(&tval);
>  	cputime_to_timeval(signal->it_virt_incr, &tval);
>  	h->it_virt_incr = timeval_to_ns(&tval);
>  
> -	cputime = cputime_sub(signal->it_prof_expires, prof_ticks(t));
> +	cputime = signal->it_prof_expires;
> +	if (!cputime_eq(cputime, cputime_zero))
> +		cputime = cputime_sub(signal->it_prof_expires, prof_ticks(t));
>  	cputime_to_timeval(cputime, &tval);
>  	h->it_prof_value = timeval_to_ns(&tval);
>  	cputime_to_timeval(signal->it_prof_incr, &tval);
