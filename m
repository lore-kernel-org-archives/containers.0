From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 12 Apr 2012 10:41:55 -0700
Message-ID: <20120412174155.GC13069@google.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F862851.3040208@jp.fujitsu.com>
	<20120412113217.GB11455@somewhere.redhat.com>
	<4F86BFC6.2050400@parallels.com>
	<20120412123256.GI1787@cmpxchg.org>
	<4F86D4BD.1040305@parallels.com>
	<20120412153055.GL1787@cmpxchg.org>
	<20120412163825.GB13069@google.com>
	<20120412172309.GM1787@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120412172309.GM1787-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Johannes.

On Thu, Apr 12, 2012 at 07:23:09PM +0200, Johannes Weiner wrote:
> > The task counter is trying to control the *number* of tasks, which is
> > purely memory overhead.  Translating #tasks into the actual amount of
> > memory isn't too trivial tho - the task stack isn't the only
> > allocation and the numbers should somehow make sense to the userland
> > in consistent way.
> 
> But why would you ever even care about that number, though?  It has no
> intrinsic value.  We used it in a past because we had no other control
> over kernel memory and CPU usage.

I was describing task_counter as implemented mostly to point out that
it's not cpu related.  It's fundamentally a memory overhead which is
coarsely / impreciesly mapped to some number, so umm... we're actually
agreeing.

> Even if we start out accounting just the kernel stack (which should be
> the biggest chunk), it won't be less accurate than limiting numbers of
> tasks.  It's just a different unit, but one which we can account and
> limit with less extra code, and even improve as we go along.
> 
> [ You could have tuned your task counter limit perfectly to one kernel
>   version, the next version will have changed the memory required per
>   task, file, random object, and suddenly your working setup runs out
>   of memory.  So it's not like starting with kernel stack and adding
>   more stuff later would be any less predictable. ]
> 
> I don't think anyone wants to come back in a few months and discuss
> where the nr-of-open-files counter subsystem should live.
>
> > Also, I'm not sure whether this particular limit should live in its
> > silo or should be summed up together as part of kmem (kmem itself is
> > in its own silo after all apart from user memory, right?).
> 
> There is k and u+k.  I don't see a technical problem with adding a
> separate stat for it later, but also not a particular reason to treat
> it differently, because it's nothing special.  It's just kernel
> memory.  Do you care if your cgroup has 2M tasks with one open socket
> each or one task with 2M sockets, as long as the group plays along
> nicely with the others?

I'm still split on the issue.

* #tasks as unit of accounting / limiting is well understood (or at
  least known).  I think this holds the same to #open files, to a
  lesser extent.  It means there are and will continue to be people
  wanting them.  So, they have some value in familiarity - "but... I
  want to limit the resources consumed by tasks cuz that's what I
  know!" factor.

* People could want counting and limiting #tasks or #open files
  without the overhead of tracking all memory resources.  This stems
  from the same reason #tasks was used for this sort of things in the
  first place.  Counting tasks or open files tends to be easier and
  cheaper than tracking all memory allocations.

So, there's spectrum of solutions between merging task counter and
just directing everyone to kmem without distinguishing task resource
at all, and at the moment voices in my head are succeeding at making
cases for both directions.  What do you guys think about the above two
issues?

Thanks.

-- 
tejun
