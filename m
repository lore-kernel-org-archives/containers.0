From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] CFS CGroup: Report usage
Date: Tue, 23 Oct 2007 19:28:22 -0700
Message-ID: <6599ad830710231928n65a80021w582a07b5993377f8__15301.5141412199$1193193002$gmane$org@mail.gmail.com>
References: <471D4523.4040509@google.com>
	<20071023164704.GE4667@linux.vnet.ibm.com>
	<6599ad830710230941y5d175688ob3a4d9ac42ba8c8f@mail.gmail.com>
	<20071023173837.GG4667@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071023173837.GG4667-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/23/07, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > Suppose you have two cgroups that would each want to use, say, 55% of
> > a CPU - technically they should each be regarded as having 45% idle
> > time, but if they run on a the same CPU the chances are that they will
> > both always have some processes on their runqueue due to contention
> > with the other group. So how would you measure the difference between
> > this and a cgroup that really is trying to use 100%?
>
> Good point. I think we need to subtract out the time it was waiting on runqueue
> when calculating idle time.
>
>         |------- . . . . . . ---------zzzzzzzzzzzz.......-----------|
>         t0     t1            t2       t3         t4     t5          t6
>
>
>         ----    -> Running time
>         ....    -> Waiting time (to get on the cpu)
>         zzzz    -> Sleeping time (when it didnt want to run because of
>                    lack of tasks)
>
> So, in this case,
>
>         idle time = (t4 - t3) / [ (t6 - t1) - (t2-t1) - (t5-t4)
>

Do you mean (t6 - t0) where you have (t6 - t1)?

> ?
>
> This idle time will be a per-cpu stat for every cgroup and needs to be
> consolidated across cpus into a single idle-stat number, just like how
> top does it.

This would be an idle fraction, not an idle time. (seconds divided by seconds)

It doesn't seem quite right to me that a cgroup's idle time metric be
affected by the activity of other cgroups on the machine, but it's
hard to come up with a way of measuring it that doesn't have this
behaviour - which is why, in the absence of hard CPU partitioning,
it's not clear to me how much use this would be.

What would people be planning to use it for?

Paul
