From: "Dmitry Adamushko" <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Sat, 15 Dec 2007 12:15:16 +0100
Message-ID: <b647ffbd0712150315l28f125a9x6fc52eb7a5cba7f8@mail.gmail.com>
References: <20071214094909.GG11266@elte.hu>
	<b647ffbd0712140447kfba5945ybde40f18653dd164@mail.gmail.com>
	<20442799.1197642268756.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214153607.GB23670@linux.vnet.ibm.com>
	<20071214153823.GC23670@linux.vnet.ibm.com>
	<b647ffbd0712140825h4f541be0xa7a7866e70b3af7a@mail.gmail.com>
	<b647ffbd0712141151k697d9bbemda9a7e90515e4400@mail.gmail.com>
	<Pine.LNX.4.58.0712141614340.22005@gandalf.stny.rr.com>
	<b647ffbd0712150222p30cac9f9i772c2a2c4e05a4a@mail.gmail.com>
	<20071215105036.GB26325@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071215105036.GB26325-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 15/12/2007, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> On Sat, Dec 15, 2007 at 11:22:08AM +0100, Dmitry Adamushko wrote:
> > On 14/12/2007, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> > >
> > > On Fri, 14 Dec 2007, Dmitry Adamushko wrote:
> > >
> > > >
> > > > argh... it's a consequence of the 'current is not kept within the tree" indeed.
> > > >
> > >
> > > Thanks Dmitry for tracking this down.
> >
> > My analysis was flawed (hmm... me was under control of Belgium beer :-)
> >
> > The task in not on the runqueue (p->on_rq == 0) at the moment when
> > put_prev_task_fair() and set_curr_task_fair() get its turn in
> > sched_move_task()... so dequeue/enqueue_entity() are not triggered,
> > that's good.
> >
>
> Again, I am probably missing something, but if on_rq == 0, then how is
> set_curr_task_fair() getting called?
>

...
        running = task_running(rq, tsk);
        on_rq = tsk->se.on_rq;

// let's say on_rq == 1 , i.e. the task is on the runqueue

        if (on_rq) {
                dequeue_task(rq, tsk, 0);

// now tsk->se.on_rq becomes 0

                if (unlikely(running))
                        tsk->sched_class->put_prev_task(rq, tsk);

// put_prev_task() --> put_prev_entity() checks for 'tsk->se.on_rq' to
determine whether __enqueue_entity() must be done ---> and it's 0 in
our case.

[ it can be non-zero for the following path : schedule() -->
put_prev_task(..., prev) when deactivate_task(..., prev) was not
previously called in schedule(), i.e. 'prev' was preempted ]

tsk->se.on_rq will become 1 only after enqueue_task(). As a result,
tsk->se.on_rq is still 0 when set_curr_task() is executed.

does it make sense now?


> --
> regards,
> Dhaval
>


-- 
Best regards,
Dmitry Adamushko
