From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH 1/5] Revert recent removal of set_curr_task()
Date: Mon, 24 Sep 2007 18:35:25 +0200
Message-ID: <20070924163525.GA12745@elte.hu>
References: <20070924163326.GA10291@linux.vnet.ibm.com>
	<20070924163653.GB10291@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070924163653.GB10291-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: efault-Mmb7MZpHnFY@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


* Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> > (3) rework enqueue/dequeue_entity() to get rid of
> > sched_class::set_curr_task()
> 
> Dmitry/Ingo,
> 	I am sorry for not having reviewed this change properly, but I 
> think we need to revert this.

ah, i was wondering about that already. We can certainly skip that 
optimization.

> In theory its possible to solve these problems w/o reintroducing 
> set_curr_task(). I tried doing so, but found it clutters 
> dequeue_entity and enqueue_entity a lot and makes it less readable. It 
> will duplicate what put_prev_entity() and set_next_entity() are 
> supposed to do. Moreoever it is slightly inefficient to do all these 
> in dequeue_entity() if we consider that dequeue_entity can be called 
> on current task for other reasons as well (like when it is abt to 
> sleep or change its nice value).

yeah, it's not worth it. I'd go for keeping the code unified even if 
adds a few instructions runtime overhead, as i'd expect most distros to 
enable fair-group-scheduling by default in the future. (once all the 
containers infrastructure and tools has trickled down to them)

	Ingo
