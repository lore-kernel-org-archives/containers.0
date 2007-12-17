From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Mon, 17 Dec 2007 12:58:21 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0712171227230.5678@gandalf.stny.rr.com>
References: <1197810077.12959.40.camel@earth>
	<Pine.LNX.4.58.0712161801590.27494@gandalf.stny.rr.com>
	<b647ffbd0712170223n13509130s7850c081f3b6c1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b647ffbd0712170223n13509130s7850c081f3b6c1e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dmitry Adamushko <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org


On Mon, 17 Dec 2007, Dmitry Adamushko wrote:

>
> It may be related, maybe not. One 'abnormal' thing (at least, it
> occurs only once in this log. Should be checked wheather it happens
> when the system works fine) is that a few iterations before the oops
> happens we observe the following pattern:
>
> CPU=2 [94359.651930] hackbench:1932(120:120:120:T) -->>
> hackbench:1591(120:120:120)
>
> CPU=2 [94359.651980] hackbench:1591(49:120:120:T) -->> swapper:0(140:120:140)

Note: the 'T' should be a 'D' because my logdev didn't add the change that
-rt does (adding a 'M' state).

Thanks for noticing. The -rt patch has more priority inheritance
situations than vanilla kernel (sleeping spinlocks or semaphors, and even
the Preempt RCU Boost logic).

>
> swapper (idle)    --> softirq-timer (RT)
> softirq-timer (RT) --> softirq-rcu (RT)
> softirq-rcu(RT)  --> picks up se == 0 for SCHED_NORMAL upon scheduling
> out ---> OOPS
>
> 'hackbench' was of SCHED_NORMAL upon scheduling _in_, and it's of RT
> type (prio: 49 and schedule() --> put_prev_task_rt()) upon scheduling
> _out_.
>
> Unless you run some modified version of 'hackbench', it doesn't chenge
> scheduling classes... so maybe a lifted prio is a consequence of the
> resource contention with some RT task ?

Yes. Which means it could be an spinlock, mutex, semaphore or RCU read
lock. But since it is in the TASK_UNINTERRUPTIBLE state, I'm willing to
bet this is a mutex (or converted spinlock).

>
> This 'hackbench' was the last SCHED_NORMAL task to run on this CPU...
> so however this NORMAL -> RT transition happened, it might leave a
> sched_fair's runqueue corrupted...

Could very well have. The PI uses task_setprio (aka. rt_mutex_setprio) to
raise the priority.  I'll start looking there.

>
> (Will try to look more when time allows).

Thanks, I'll probably spend the rest of the day on this.

-- Steve
