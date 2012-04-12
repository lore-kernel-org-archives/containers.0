From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 12 Apr 2012 14:13:49 -0300
Message-ID: <4F870D4D.6020405@parallels.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F862851.3040208@jp.fujitsu.com>
	<20120412113217.GB11455@somewhere.redhat.com>
	<4F86BFC6.2050400@parallels.com>
	<20120412123256.GI1787@cmpxchg.org>
	<4F86D4BD.1040305@parallels.com>
	<20120412153055.GL1787@cmpxchg.org>
	<20120412163825.GB13069@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120412163825.GB13069-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

>
> The reason why I asked Frederic whether it would make more sense as
> part of memcg wasn't about flexibility but mostly about the type of
> the resource.  I'll continue below.
>
>>> Agree. Even people aiming for unified hierarchies are okay with an
>>> opt-in/out system, I believe. So the controllers need not to be
>>> active at all times. One way of doing this is what I suggested to
>>> Frederic: If you don't limit, don't account.
>>
>> I don't agree, it's a valid usecase to monitor a workload without
>> limiting it in any way.  I do it all the time.
>
> AFAICS, this seems to be the most valid use case for different
> controllers seeing different part of the hierarchy, even if the
> hierarchies aren't completely separate.  Accounting and control being
> in separate controllers is pretty sucky too as it ends up accounting
> things multiple times.  Maybe all controllers should learn how to do
> accounting w/o applying limits?  Not sure yet.

Well...

* I don't know how blkcgrp applies limits
* the cpu cgroup, is limiting by nature, in the sense that it divides 
shares in proportion to the number of cgroups in a hierarchy
* memcg has a RESOURCE_MAX default limit that is bigger than anything 
you can possibly count.

So one of the problems, is that "limiting" may mean different thing to 
each controller.

I am mostly talking about memory cgroup here. And there. "Accounting 
without limiting" can trivially be done by setting limit to 
RESOURCE_MAX-delta. This won't work when we start having machines with 
2^64 physical memory, but I guess we have some time until it happens.

The way I see, it's just a technicality over a way to runtime disable 
the accounting of a resource without filling the hierarchy with flags.


>> To reraise a point from my other email that was ignored: do users
>> actually really care about the number of tasks when they want to
>> prevent forkbombs?  If a task would use neither CPU nor memory, you
>> would not be interested in limiting the number of tasks.
>>
>> Because the number of tasks is not a resource.  CPU and memory are.
>>
>> So again, if we would include the memory impact of tasks properly
>> (structures, kernel stack pages) in the kernel memory counters which
>> we allow to limit, shouldn't this solve our problem?
>
> The task counter is trying to control the *number* of tasks, which is
> purely memory overhead.

No, it is not. As we talk, it is becoming increasingly clear that given 
the use case, the correct term is "translating task *back* into the 
actual amount of memory".

> Translating #tasks into the actual amount of
> memory isn't too trivial tho - the task stack isn't the only
> allocation and the numbers should somehow make sense to the userland
> in consistent way.  Also, I'm not sure whether this particular limit
> should live in its silo or should be summed up together as part of
> kmem (kmem itself is in its own silo after all apart from user memory,
> right?).


It is accounted together, but limited separately. Setting 
memory.kmem.limit > memory.limit is a trivial way to say "Don't limit 
kmem". (and yet account it)

Same thing would go for a stack limit (Well, assuming it won't be merged 
into kmem itself as well)

> So, if those can be settled, I think protecting against fork
> bombs could fit memcg better in the sense that the whole thing makes
> more sense.

I myself will advise against merging anything not byte-based to memcg.
"task counter" is not byte-based.
"fork bomb preventer" might be.
