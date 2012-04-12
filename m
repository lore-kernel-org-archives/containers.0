From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 12 Apr 2012 11:26:13 +0800
Message-ID: <4F864B55.10906@huawei.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<20120412010745.GE1787@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <20120412010745.GE1787-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
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

Johannes Weiner wrote:

> On Wed, Apr 11, 2012 at 08:57:20PM +0200, Frederic Weisbecker wrote:
>> Hi,
>>
>> While talking with Tejun about targetting the cgroup task counter subsystem
>> for the next merge window, he suggested to check if this could be merged into
>> the memcg subsystem rather than creating a new one cgroup subsystem just
>> for task count limit purpose.
>>
>> So I'm pinging you guys to seek your insight.
> 
> I'm sorry you are given a runaround like this with that code.
> 


I don't like the idea of putting this stuff into memcg either.

>> I assume not everybody in the Cc list knows what the task counter subsystem
>> is all about. So here is a summary: this is a cgroup subsystem (latest version
>> in https://lwn.net/Articles/478631/) that keeps track of the number of tasks
>> present in a cgroup. Hooks are set in task fork/exit and cgroup migration to
>> maintain this accounting visible to a special tasks.usage file. The user can
>> set a limit on the number of tasks by writing on the tasks.limit file.
>> Further forks or cgroup migration are then rejected if the limit is exceeded.
>>
>> This feature is especially useful to protect against forkbombs in containers.
>> Or more generally to limit the resources on the number of tasks on a cgroup
>> as it involves some kernel memory allocation.
> 
> You could also twist this around and argue the same for cpu usage and
> make it part of the cpu cgroup, but it doesn't really fit in either
> subsystem, IMO.
> 
>> Now the dilemna is how to implement it?
>>
>> 1) As a standalone subsystem, as it stands currently (https://lwn.net/Articles/478631/)
> 
> What was wrong with that again?
> 
>> 2) As a feature in memcg, part of the memory.kmem.* files. This makes sense
>> because this is about kernel memory allocation limitation. We could have a
>> memory.kmem.tasks.count
>>
>> My personal opinion is that the task counter brings some overhead: a charge
>> across the whole hierarchy at every fork, and the mirrored uncharge on task exit.
>> And this overhead happens even in the off-case (when the task counter susbsystem
>> is mounted but the limit is the default: ULLONG_MAX).
> 
> 3) Make it an integral part of cgroups, because keeping track of tasks
> in them already is, so it would be a more natural approach than
> bolting it onto the memory controller.
> 

> But this has the same overhead.

This makes the most sense to me. Task counting and limiting sounds part of
cgroups in nature.

It has overhead, but what makes it worse than that in the single hierarchy
that we are aiming at?

> And even if this would end up being a

> better idea, we could still do this after merging it as a separate
> controller as long as we maintain the interface.
> 


That would add some tricky messy code, so better no.
