From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 12 Apr 2012 13:54:10 -0300
Message-ID: <4F8708B2.5050301__12253.1098350466$1334249764$gmane$org@parallels.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F862851.3040208@jp.fujitsu.com>
	<20120412113217.GB11455@somewhere.redhat.com>
	<4F86BFC6.2050400@parallels.com>
	<20120412123256.GI1787@cmpxchg.org>
	<4F86D4BD.1040305@parallels.com>
	<20120412153055.GL1787@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120412153055.GL1787-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
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
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


>
>>>> If this gets really integrated, out of a sudden the overhead will
>>>> appear. So better care about it now.
>>>
>>> Forcing people that want to account/limit one resource to take the hit
>>> for something else they are not interested in requires justification.
>>
>> Agree. Even people aiming for unified hierarchies are okay with an
>> opt-in/out system, I believe. So the controllers need not to be
>> active at all times. One way of doing this is what I suggested to
>> Frederic: If you don't limit, don't account.
>
> I don't agree, it's a valid usecase to monitor a workload without
> limiting it in any way.  I do it all the time.

That's side-tracking. This is one way to do it, not the way to do it.
The main point is that a controller can be trivially made present in a 
hierarchy, without doing anything.


>>
>> A big number of controllers creates complexity. When coding, we can
>> assume a lot less things about their relationships, and more
>> importantly: at some point people get confused. Fuck, sometimes *we*
>> get confused about which controller do what, where its
>> responsibility end and where the other's begin. And we're the ones
>> writing it! Avoiding complexity is an engineering principle, not a
>> gut feeling.
>
> And that's why I have a horrible feeling about extending the cgroup
> core to do hierarchical accounting and limiting.  See below.
>
>> Now, of course, we should aim to make things as simple as possible,
>> but not simpler: So you can argue that in Frederic's specific case,
>> it is justified. And I'd be fine with that 100 %. If I agreed...
>>
>> There are two natural points for inclusion here:
>>
>> 1) every cgroup has a task counter by itself. If we're putting the
>> tasks there anyway, this provides a natural point of accounting.
>
> I do think there is a big difference between having a list of tasks
> per individual cgroup to manage basic task-cgroup relationship on one
> hand, and accounting and limiting the number of allowed tasks over
> multi-level group hierarchies on the other.  It may seem natural on
> the face of it, but it really isn't, IMO.

It makes less sense to me now after I read Frederic's last e-mail. 
Indeed, you are both right in this point.

> To reraise a point from my other email that was ignored: do users
> actually really care about the number of tasks when they want to
> prevent forkbombs?  If a task would use neither CPU nor memory, you
> would not be interested in limiting the number of tasks.
>
> Because the number of tasks is not a resource.  CPU and memory are.
>
> So again, if we would include the memory impact of tasks properly
> (structures, kernel stack pages) in the kernel memory counters which
> we allow to limit, shouldn't this solve our problem?
>
> You said in private email that you didn't like the idea because
> administrators wouldn't know how big the kernel stack was and that the
> number of tasks would be a more natural thing to limit.  But I think
> that is actually an argument in favor of the kmem approach: the user
> has no idea how much impact a task actually has resource-wise!  On the
> other hand, he knows exactly how much memory and CPU his machine has
> and how he wants to distribute these resources.  So why provide him
> with an interface to control some number in an unknowwn unit?
>
> You don't propose we allow limiting the number of dcache entries,
> either, but rather the memory they use.
>
> The historical limiting of number of tasks through rlimit is anything
> but scientific or natural.  You essentially set it to a random value
> between allowing most users to do their job and preventing things from
> taking down the machine.  With proper resource accounting, which we
> want to have anyway, we can do much better than that, so why shouldn't
> we?

Okay.

I may agree with you, I might not.

It really depends on Frederic's real use case - (Frederic, please 
comment on it).

If we're trying to limit the number of processes *as a way* of limiting 
the amount of memory they use, then yes, what you say makes total sense.

I was always under the assumption that they wanted something more. One 
of the things I remember reading on the descriptions, was that some 
services shouldn't be allowed to fork after a certain point. Then you 
could limit its amount of processes to whatever value it has now.

For that, stack usage may not help for much.

Now, my personal take on this: Use cases like that, if really needed, 
can be achieved in some other ways, that does not even involve cgroups.

One of the things for the near future, is start putting more kinds of 
data in the kmem controller. Things like page tables and the stack are 
the natural candidates. I am in Hannes side in saying that it should be 
enough to disallow any malicious container to do any harm.

But it is not even necessary!

- Each process has a task struct
- task struct comes from the slab.

Even my slab accounting patches are enough to prevent harm outside the 
container. Because if you fill all your kmem with task_structs, you will 
be stopped to go any further.

As a matter of fact, I've being doing it all the time during the last 
few days while testing the patchset.
