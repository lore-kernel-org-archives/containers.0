From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] checkpoint/restart timerfd
Date: Mon, 16 Nov 2009 11:57:16 -0800
Message-ID: <20091116195716.GM891@count0.beaverton.ibm.com>
References: <96703bfb68e1626100dd5fa6ce033ec204bcb58b.1258159772.git.matthltc@us.ibm.com>
	<4B01A043.3010001@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B01A043.3010001-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Nov 16, 2009 at 01:56:03PM -0500, Oren Laadan wrote:

<snip>

> > diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> > index dfcb59b..f429386 100644
> > --- a/include/linux/checkpoint.h
> > +++ b/include/linux/checkpoint.h
> > @@ -321,6 +321,17 @@ static inline int ckpt_validate_errno(int errno)
> >  			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
> >  	} while (0)
> >  
> > +struct ckpt_itimerspec;
> > +struct itimerspec;
> > +static inline void ckpt_copy_itimerspec(int op, struct ckpt_itimerspec *h,
> > +					struct itimerspec *tmr)
> > +{
> > +	CKPT_COPY(op, h->interval.tv_sec,  tmr->it_interval.tv_sec);
> > +	CKPT_COPY(op, h->interval.tv_nsec, tmr->it_interval.tv_nsec);
> > +	CKPT_COPY(op, h->value.tv_sec,     tmr->it_value.tv_sec);
> > +	CKPT_COPY(op, h->value.tv_nsec,    tmr->it_value.tv_nsec);
> > +}
> > +
> 
> Is there a reason to place this here and not in timerfd source file ?

I hadn't checked the code in checkpoint/signal.c -- I was hoping to share the
itimerspec struct but clearly it's not needed there. I'll move it to timerfd.c.

Thanks for the review!

Cheers,
	-Matt
