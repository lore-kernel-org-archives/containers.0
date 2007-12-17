From: "Dmitry Adamushko" <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Mon, 17 Dec 2007 23:52:37 +0100
Message-ID: <b647ffbd0712171452u1d3308aewaacfcd9129374994@mail.gmail.com>
References: <1197810077.12959.40.camel@earth>
	<Pine.LNX.4.58.0712161801590.27494@gandalf.stny.rr.com>
	<b647ffbd0712170223n13509130s7850c081f3b6c1e@mail.gmail.com>
	<Pine.LNX.4.58.0712171227230.5678@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.58.0712171227230.5678-f9ZlEuEWxVcI6MkJdU+c8EEOCMrvLtNR@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

[ trimmed the cc' list ]

On 17/12/2007, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
>
> On Mon, 17 Dec 2007, Dmitry Adamushko wrote:
>
> >
> > It may be related, maybe not. One 'abnormal' thing (at least, it
> > occurs only once in this log. Should be checked wheather it happens
> > when the system works fine) is that a few iterations before the oops
> > happens we observe the following pattern:
> >
> > CPU=2 [94359.651930] hackbench:1932(120:120:120:T) -->>
> > hackbench:1591(120:120:120)
> >
> > CPU=2 [94359.651980] hackbench:1591(49:120:120:T) -->> swapper:0(140:120:140)
>
> Thanks for noticing. The -rt patch has more priority inheritance
> situations than vanilla kernel (sleeping spinlocks or semaphors, and even
> the Preempt RCU Boost logic).

One more thing is that we don't actually see a point where that
'hackbench' gets its priority lifted.

It was scheduled in as a NORMAL task and scheduled out as a RT one.
i.e. the task got its prio elevated while it was running... a
contention with the task on another CPU?

anyway, i.e. this task must have 'p->se.on_rq == 1' and I'd expect to
see "switched_to_rt" message somewhere in between... hmm?
(check_class_changed() shoud have been called in task_setprio()).

btw., we do see one 'switched_from_rt --> switched_to_fair' case for
another 'hackbench' on CPU #0... according to traces, this one might
get a prio lifted while sleeping (it got scheduled in as a RT task).



>
> -- Steve
>

-- 
Best regards,
Dmitry Adamushko
