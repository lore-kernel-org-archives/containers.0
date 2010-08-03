From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] c/r: compute hrtimer remaining time relative to
	ktime_begin
Date: Mon, 2 Aug 2010 23:40:04 -0700
Message-ID: <20100803064004.GK2927@count0.beaverton.ibm.com>
References: <1280786108-17820-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1280786108-17820-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 02, 2010 at 05:55:08PM -0400, Oren Laadan wrote:
> The rule for time values in c/r is: all time measurements in
> the checkpoint image are saved as relative values, using the
> start-of-checkpoint as the reference point in time.
> 
> This patch fixes how hrtimer delta is calculated to make it
> really follow this rule.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  kernel/signal.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/signal.c b/kernel/signal.c
> index de76729..0ec4a46 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -3151,7 +3151,8 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
>  	/* real/virt/prof itimers */
>  	if (hrtimer_active(&signal->real_timer)) {
>  		/* For an active timer compute the time delta */
> -		ktime_t delta = hrtimer_get_remaining(&signal->real_timer);
> +		ktime_t delta = ktime_sub(ctx->ktime_begin,
> +					  signal->real_timer._expires);

(Cc'ing Thomas -- perhaps he'd like to see something else..)

This doesn't look clean. Perhaps you should introduce a new hrtimer function
rather than access signal->real_timer._expires directly. I'm thinking something
like the following in include/linux/hrtimer.h:

/* after will usually be <= now */
static inline ktime_t hrtimer_get_remaining_after(const struct hrtimer *timer,
						ktime_t after)
{
    return ktime_sub(timer->_expires, after);
}

then in kernel/signal.c you'd replace the above patch hunk with:

		ktime_t delta = hrtimer_get_remaining_after(&signal->real_timer,
							ctx->ktime_begin);

which is functionally the same but looks cleaner.

Cheers,
	-Matt Helsley
