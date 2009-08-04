From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4/4] c/r: support for real/virt/prof itimers (v2)
Date: Tue, 04 Aug 2009 14:43:54 -0400
Message-ID: <4A78816A.6080001@librato.com>
References: <1249376956-27555-1-git-send-email-orenl@librato.com>
	<1249376956-27555-5-git-send-email-orenl@librato.com>
	<20090804141746.GQ29252@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090804141746.GQ29252-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> Hi Oren,
> 
> On 04/08/09  5:09 -0400, Oren Laadan wrote:
>> This patch adds support for real/virt/prof itimers.
>> Expiry and the interval values are both saved in nanoseconds.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> ---
>>  checkpoint/signal.c            |   72 ++++++++++++++++++++++++++++++++++++++++
>>  include/linux/checkpoint_hdr.h |    6 +++
>>  2 files changed, 78 insertions(+), 0 deletions(-)
>>
>> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
>> index c9da06b..18b3e2d 100644
>> --- a/checkpoint/signal.c
>> +++ b/checkpoint/signal.c
>> @@ -15,6 +15,7 @@
>>  #include <linux/signal.h>
>>  #include <linux/errno.h>
>>  #include <linux/resource.h>
>> +#include <linux/timer.h>
>>  #include <linux/checkpoint.h>
>>  #include <linux/checkpoint_hdr.h>
>>  
>> @@ -264,6 +265,7 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
>>  	struct signal_struct *signal;
>>  	struct sigpending shared_pending;
>>  	struct rlimit *rlim;
>> +	struct timeval tval;
>>  	unsigned long flags;
>>  	int i, ret;
>>  
>> @@ -299,6 +301,49 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
>>  		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
>>  		h->rlim[i].rlim_max = rlim[i].rlim_max;
>>  	}
>> +
>> +	/* real/virt/prof itimers */
>> +	h->it_real_incr = ktime_to_ns(signal->it_real_incr);
>> +	/*
>> +	 * (a) If the timer is now active (did not expire), compute
>> +	 * the time delta.
>> +	 * (b) If the timer expired, and delivered the signal already,
>> +	 * then set the expire (value) to the interval
>> +	 * (c) If the timer expired but did not yet deliver the
>> +	 * signal, then set the expire to the minimum possible, so it
>> +	 * will expire immediately after restart succeeds.
>> +	 */
>> +	if (hrtimer_active(&signal->real_timer)) {
>> +		ktime_t delta = hrtimer_get_remaining(&signal->real_timer);
>> +		/*
>> +		 * If the timer expired after the the test above, then
>> +		 * set the expire to the minimum possible (because by
>> +		 * now the pending signals have been saved already, but
>> +		 * without the signal from this very expiry).
>> +		 */
>> +		ckpt_debug("active ! %lld\n", delta.tv64);
>> +		if (delta.tv64 <= 0)
>> +			delta.tv64 = NSEC_PER_USEC;
>> +		h->it_real_value = ktime_to_ns(delta);
>> +	} else if (sigismember(&signal->shared_pending.signal, SIGALRM)) {
>> +		/* case (b) */
>> +		h->it_real_value = h->it_real_incr;
>> +	} else {
>> +		/* case (c) */
>> +		h->it_real_value =
>> +			ktime_to_ns((ktime_t) { .tv64 = NSEC_PER_USEC });
>> +	}
> 
> AFAICS the third case catches expired timers having not delivered the signal yet
> as well as inactive timers. If the latter, at restart the timer will be
> rearmed while it should not.
> 
> However, reading hrtimer code I understand that case (c) cannot happen. IOW if
> the timer has expired but has not sent SIGALRM yet, then hrtimer_active()
> returns true, and the first block already handles that case correctly.

Yes, I re-read the code and (c) should not happen, because the timer
cannot become inactive without having sent SIGALRM as long as we hold
the siglock.

> Moreover case (b) only happens if the timer was not automatically rearmed,
> that is it_real_incr == 0. So in this case the signal was already sent (and
> picked for checkpointing if not handled), and h->it_real_value should be set to
> 0.

Here is the scenario I had in mind:

1) kernel/hrtimer.c:__run_hrtimer() is called with the timer fires,
sets the timer state to HRTIMER_STATE_CALLBACK and then invokes
the callback.

2) for itimers, the callback is kernel/itimer.c:it_real_fn(): it
sends the signal and returns HRTIMER_NORESTART.

3) back to __run_hrtimer() which does _not_ call enqueue_hrtimer(),
and then _clears_ the HRTIMER_STATE_CALLBACK. This results in the
state being zero -- that is, hrtimer_active() will be false.

So in #2 SIGALRM was sent, and then in #3 the timer became inactive
without holding siglock, and not re-armed. (if it_real_incr > 0, it
should and will be re-armed when the signal is dequeued).

Therefore when we restart, we need to set it_real_incr to its saved
value, and it_real_value to 0. Then, if SIGALRM was sent, it will
be dequeued after restart, and depending on it_real_incr the timer
will, or will not, be re-armed. If SIGALRM was not sent, then it
must be that it_real_incr is also 0.

IOW, in both cases (SIGALRM sent/not sent) of the inactive timer,
the value of it_real_incr should be 0, therefore the code you
suggest below is correct, except for the BUG_ON statement.

(In restart, it's not a big deal if these values are "incorrect",
because the worst harm it can do is send a superfluous SIGALRM).

> 
> So the following could be actually better:
> 
> 	h->it_real_incr = ktime_to_ns(signal->it_real_incr);
> 	/*
> 	 * (a) If the timer is now active, compute the time delta.
> 	 * (b) Otherwise, siglock ensures that 	 */
> 	if (hrtimer_active(&signal->real_timer)) {
> 		ktime_t delta = hrtimer_get_remaining(&signal->real_timer);
> 		/*
> 		 * If the timer expired after the the test above, then
> 		 * set the expire to the minimum possible (because by
> 		 * now the pending signals have been saved already, but
> 		 * the signal from this very expiry won't be sent before we
> 		 * release t->sighand->siglock.
> 		 */
> 		ckpt_debug("active ! %lld\n", delta.tv64);
> 		if (delta.tv64 <= 0)
> 			delta.tv64 = NSEC_PER_USEC;
> 		h->it_real_value = ktime_to_ns(delta);
> 	} else {
> 		BUG_ON(h->it_real_incr);
> 		h->it_real_value = 0;
> 	}
> 
> Louis

Thanks,

Oren.
