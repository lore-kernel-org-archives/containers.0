From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at once
Date: Thu, 6 Aug 2009 08:19:22 -0700
Message-ID: <20090806151922.GB6747@linux.vnet.ibm.com>
References: <6599ad830908050911t6f23f810i65fe8fe17f3ee698@mail.gmail.com>
	<20090805164218.GB26446@hawkmoon.kerlabs.com>
	<2f86c2480908051701s57120404q475edbedb58cdca1@mail.gmail.com>
	<20090806095854.GD26446@hawkmoon.kerlabs.com>
	<6599ad830908060328y21a008c1pc5ed5c27e0ec905d@mail.gmail.com>
	<1249554853.32113.145.camel@twins>
	<6599ad830908060342m1fc8cdd2me25af248a8e0e183@mail.gmail.com>
	<1249556540.32113.191.camel@twins>
	<6599ad830908060424r72e1aa12g2b246785e7bc039c@mail.gmail.com>
	<1249558761.32113.262.camel@twins>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1249558761.32113.262.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 06, 2009 at 01:39:21PM +0200, Peter Zijlstra wrote:
> On Thu, 2009-08-06 at 04:24 -0700, Paul Menage wrote:
> > On Thu, Aug 6, 2009 at 4:02 AM, Peter Zijlstra<a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org> wrote:
> > >
> > > Taking that many locks in general, some apps (JVM based usually) tend to
> > > be thread heavy and can easily have hundreds of them, even on relatively
> > 
> > Oh, I'm well aware that apps can be heavily multi-threaded - we have
> > much worse cases at Google.
> > 
> > >
> > > Now that's not real nice is it ;-)
> > 
> > Not particularly - but who exactly is going to be moving processes
> > with thousands of threads between cgroups on a lockdep-enabled debug
> > kernel?
> 
> All it takes are: 8 or 48 (or soon 2048) depending on your particular
> annotation. I might and then I'd have to come and kick you ;-)
> 
> Really, lockdep not being able to deal with something is a strong
> indication that you're doing something wonky.
> 
> Stronger, you can even do wonky things which lockdep thinks are
> absolutely fine.
> 
> And doing wonky things should be avoided :-)
> 
> Luckily we seem to have found a sensible solution.
> 
> > What benefits does the additional complexity of SRCU give, over the
> > simple solution of putting an rwsem in the same cache line as
> > sighand->count ?
> 
> I said:
> 
> > Then again, clone() might already serialize on the process as a whole
> > (not sure though, Oleg/Ingo?), in which case you can indeed take a
> > process wide lock.
> 
> Which looking up sighand->count seems to be the case:
> 
> static int copy_sighand(unsigned long clone_flags, struct task_struct *tsk)
> {
>         struct sighand_struct *sig;
> 
>         if (clone_flags & CLONE_SIGHAND) {
>                 atomic_inc(&current->sighand->count);
>                 return 0;
>         }
> 
> 
> So yes, putting a rwsem in there sounds fine, you're already bouncing
> it.

If the critical section is small, is an rwsem really better than a
straight mutex?

							Thanx, Paul
