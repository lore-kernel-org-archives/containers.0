From: "Dmitry Adamushko" <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Sun, 16 Dec 2007 11:06:22 +0100
Message-ID: <b647ffbd0712160206h5ce3ec6eh947f4a249bde3cbf@mail.gmail.com>
References: <b647ffbd0712140447kfba5945ybde40f18653dd164@mail.gmail.com>
	<20071214153607.GB23670@linux.vnet.ibm.com>
	<20071214153823.GC23670@linux.vnet.ibm.com>
	<b647ffbd0712140825h4f541be0xa7a7866e70b3af7a@mail.gmail.com>
	<b647ffbd0712141151k697d9bbemda9a7e90515e4400@mail.gmail.com>
	<Pine.LNX.4.58.0712141614340.22005@gandalf.stny.rr.com>
	<b647ffbd0712150222p30cac9f9i772c2a2c4e05a4a@mail.gmail.com>
	<b647ffbd0712151544n2dfad101r2d306d393e8550ff@mail.gmail.com>
	<b647ffbd0712151600s14e3f355we5ee6348b4d484cc@mail.gmail.com>
	<20071216085559.GB20790@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071216085559.GB20790-X9Un+BFzKDI@public.gmane.org>
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
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On 16/12/2007, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> wrote:
>
> * Dmitry Adamushko <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> > --- a/kernel/sched.c
> > +++ b/kernel/sched.c
> > @@ -7360,7 +7360,7 @@ void sched_move_task(struct task_struct *tsk)
> >
> >         update_rq_clock(rq);
> >
> > -       running = task_running(rq, tsk);
> > +       running = (rq->curr == tsk);
> >         on_rq = tsk->se.on_rq;
>
> thanks, i've queued this up (pending more testing).

btw., sched_setscheduler() and rt_mutex_setprio() are also affected
(in general, anything that may call put_prev_task/set_curr_task()
relying task_running()).

Will see, maybe we may come up with smth better than just replacing
task_running() with (rq->curr == tsk) there.


> Btw., you should be able to force the ia64 scheduling by adding this to
> the very top of include/linux/sched.h:
>
> #define __ARCH_WANT_UNLOCKED_CTXSW
> #define __ARCH_WANT_INTERRUPTS_ON_CTXSW

Yeah, with both we even get ARM behavior. Can be a good test indeed.


>
>         Ingo
>


-- 
Best regards,
Dmitry Adamushko
