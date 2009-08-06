From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Thu, 6 Aug 2009 04:24:25 -0700
Message-ID: <6599ad830908060424r72e1aa12g2b246785e7bc039c@mail.gmail.com>
References: <2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<20090805102057.GT29252@hawkmoon.kerlabs.com>
	<6599ad830908050911t6f23f810i65fe8fe17f3ee698@mail.gmail.com>
	<20090805164218.GB26446@hawkmoon.kerlabs.com>
	<2f86c2480908051701s57120404q475edbedb58cdca1@mail.gmail.com>
	<20090806095854.GD26446@hawkmoon.kerlabs.com>
	<6599ad830908060328y21a008c1pc5ed5c27e0ec905d@mail.gmail.com>
	<1249554853.32113.145.camel@twins>
	<6599ad830908060342m1fc8cdd2me25af248a8e0e183@mail.gmail.com>
	<1249556540.32113.191.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1249556540.32113.191.camel@twins>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, paulmck <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Aug 6, 2009 at 4:02 AM, Peter Zijlstra<a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org> wrote:
>
> Taking that many locks in general, some apps (JVM based usually) tend to
> be thread heavy and can easily have hundreds of them, even on relatively

Oh, I'm well aware that apps can be heavily multi-threaded - we have
much worse cases at Google.

>
> Now that's not real nice is it ;-)

Not particularly - but who exactly is going to be moving processes
with thousands of threads between cgroups on a lockdep-enabled debug
kernel?

>
>> But given that AFAICS we can eliminate the overhead associated with a
>> single lock by piggy-backing on the cache line containing
>> sighand->count, hopefully this won't be an issue any more.
>
> Right, so this is a write rarely, read frequently thing, which suggests
> an RCU like approach where the readers pay a minimum synchronization
> penalty.

The documentation for SRCU mentions:

        Therefore, SRCU should be used in preference to rw_semaphore
        only in extremely read-intensive situations, or in situations
        requiring SRCU's read-side deadlock immunity or low read-side
        realtime latency.

What benefits does the additional complexity of SRCU give, over the
simple solution of putting an rwsem in the same cache line as
sighand->count ?

Paul
