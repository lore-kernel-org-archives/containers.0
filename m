From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Wed, 18 Apr 2012 09:00:00 -0300
Message-ID: <4F8EACC0.50204__31487.548890482$1334750519$gmane$org@parallels.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<20120412010745.GE1787@cmpxchg.org>
	<20120412145507.GC11455@somewhere.redhat.com>
	<4F87042A.2000902@parallels.com>
	<20120412165922.GA12484@somewhere.redhat.com>
	<20120417151753.GB32402@google.com>
	<20120418065430.GB25568@somewhere>
	<CAFTL4hxXT+hXWEnKop84JQ8ieHX4e=otpHnXYxdxaPgsiZYCiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFTL4hxXT+hXWEnKop84JQ8ieHX4e=otpHnXYxdxaPgsiZYCiw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/18/2012 05:10 AM, Frederic Weisbecker wrote:
> 2012/4/18 Frederic Weisbecker<fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>> On Tue, Apr 17, 2012 at 08:17:53AM -0700, Tejun Heo wrote:
>>> Hello, Frederic.
>>>
>>> On Thu, Apr 12, 2012 at 06:59:27PM +0200, Frederic Weisbecker wrote:
>>>> I want:
>>>>
>>>> a) to prevent the forkbomb from going far enough to DDOS the machine
>>>> b) to be able to kill that forkbomb once detected, in one go without race
>>>> against concurrent forks.
>>>>
>>>> I think a) can work just fine with kernel stack limiting. I also need
>>>> to be notified about the fact we reached the limit. And b) should
>>>> be feasible with the help of the cgroup freezer.
>>>
>>> kmem allocation fail after reaching the limit which in turn should
>>> fail task creation.  Isn't that the same effect as the task_counter as
>>> implemented?
>>
>> That's it.
>>
>>>
>>>>> Is there anything for which you need to know exactly the number of
>>>>> processes?
>>>>
>>>> No that's really about prevent/kill forkbomb as far as I'm concerned.
>>>
>>> Hmm... so, accounting overhead aside, if the only purpose is
>>> preventing the whole machine being brought down by a fork bomb, kmem
>>> limiting is enough, right?
>>
>> I think so yeah.
>
> But this needs to be a well defined kind of kmem I think. Relying on
> kernel memory
> alone is too general to just protect against forkbombs. Kernel stack,
> OTOH, should be
> a good criteria.

The problem is not it being too general. The problem is it is 
slab-based, and it takes a lot of allocations to fill a slab page. It
is a small object, but you still have one per task. If you set the limit 
too high, it won't help you. If you set it too low, it will harm
other object users.

> But now I'm worrying, do you think this kmem.kernel_stack limitation
> is going to be useful
> for other kind of usecase?

Yes. Ultimately, we want to track as many kinds of kernel memory to 
avoid having one container harming the others. Page tables and stack 
were already briefly discussed, so I think we would get to that 
eventually anyway.
