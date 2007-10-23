From: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/2] CFS CGroup: Report usage
Date: Tue, 23 Oct 2007 23:08:37 +0530
Message-ID: <20071023173837.GG4667__49099.8742673129$1193160579$gmane$org@linux.vnet.ibm.com>
References: <471D4523.4040509@google.com>
	<20071023164704.GE4667@linux.vnet.ibm.com>
	<6599ad830710230941y5d175688ob3a4d9ac42ba8c8f@mail.gmail.com>
Reply-To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830710230941y5d175688ob3a4d9ac42ba8c8f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 23, 2007 at 09:41:49AM -0700, Paul Menage wrote:
> > > Adds a cpu.usage file to the CFS cgroup that reports CPU usage in
> > > milliseconds for that cgroup's tasks
> >
> > It would be nice to split this into user and sys time at some point.
> 
> Sounds reasonable - but does CFS track this?

No, not for a group. We could extend account_user_time() and
account_systime_time() in this regard.

> > We have also received request to provide idle time for a
> > container/cgroup.
> 
> The semantics of "idle time" for a cgroup on a shared system seem a
> bit fuzzy. How would you define it?

I think the percentage of time when it didn't have any runnable task in
its runqueues.

> Suppose you have two cgroups that would each want to use, say, 55% of
> a CPU - technically they should each be regarded as having 45% idle
> time, but if they run on a the same CPU the chances are that they will
> both always have some processes on their runqueue due to contention
> with the other group. So how would you measure the difference between
> this and a cgroup that really is trying to use 100%?

Good point. I think we need to subtract out the time it was waiting on runqueue
when calculating idle time.

	|------- . . . . . . ---------zzzzzzzzzzzz.......-----------|
	t0     t1	     t2	      t3 	 t4     t5          t6


	----	-> Running time
	....	-> Waiting time (to get on the cpu)
	zzzz	-> Sleeping time (when it didnt want to run because of
		   lack of tasks)

So, in this case, 

	idle time = (t4 - t3) / [ (t6 - t1) - (t2-t1) - (t5-t4) 

?

This idle time will be a per-cpu stat for every cgroup and needs to be
consolidated across cpus into a single idle-stat number, just like how
top does it.

-- 
Regards,
vatsa
