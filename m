From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Fri, 26 Sep 2008 19:30:26 +0200
Message-ID: <48DD1C32.60207__19717.2029097148$1222450535$gmane$org@gmail.com>
References: <20080919131019.GA3606@redhat.com>
	<20080922.183651.62951479.taka@valinux.co.jp>
	<20080922143042.GA19222@redhat.com>
	<20080924.172937.72827863.taka@valinux.co.jp>
	<20080924140355.GB547@redhat.com> <48DD09AD.2010200@gmail.com>
	<48DD17A9.9080607@gmail.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48DD17A9.9080607-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> Andrea Righi wrote:
>> Vivek Goyal wrote:
>> [snip]
>>> Ok, I will give more details of the thought process.
>>>
>>> I was thinking of maintaing an rb-tree per request queue and not an
>>> rb-tree per cgroup. This tree can contain all the bios submitted to that
>>> request queue through __make_request(). Every node in the tree will represent
>>> one cgroup and will contain a list of bios issued from the tasks from that
>>> cgroup.
>>>
>>> Every bio entering the request queue through __make_request() function
>>> first will be queued in one of the nodes in this rb-tree, depending on which
>>> cgroup that bio belongs to.
>>>
>>> Once the bios are buffered in rb-tree, we release these to underlying
>>> elevator depending on the proportionate weight of the nodes/cgroups.
>>>
>>> Some more details which I was trying to implement yesterday.
>>>
>>> There will be one bio_cgroup object per cgroup. This object will contain
>>> many bio_group objects. Each bio_group object will be created for each
>>> request queue where a bio from bio_cgroup is queued. Essentially the idea
>>> is that bios belonging to a cgroup can be on various request queues in the
>>> system. So a single object can not serve the purpose as it can not be on
>>> many rb-trees at the same time.  Hence create one sub object which will keep
>>> track of bios belonging to one cgroup on a particular request queue.
>>>
>>> Each bio_group will contain a list of bios and this bio_group object will
>>> be a node in the rb-tree of request queue. For example. Lets say there are
>>> two request queues in the system q1 and q2 (lets say they belong to /dev/sda
>>> and /dev/sdb). Let say a task t1 in /cgroup/io/test1 is issueing io both
>>> for /dev/sda and /dev/sdb.
>>>
>>> bio_cgroup belonging to /cgroup/io/test1 will have two sub bio_group
>>> objects, say bio_group1 and bio_group2. bio_group1 will be in q1's rb-tree
>>> and bio_group2 will be in q2's rb-tree. bio_group1 will contain a list of
>>> bios issued by task t1 for /dev/sda and bio_group2 will contain a list of
>>> bios issued by task t1 for /dev/sdb. I thought the same can be extended
>>> for stacked devices also.
>>>   
>>> I am still trying to implementing it and hopefully this is doable idea.
>>> I think at the end of the day it will be something very close to dm-ioband
>>> algorithm just that there will be no lvm driver and no notion of separate
>>> dm-ioband device. 
>> Vivek, thanks for the detailed explanation. Only a comment. I guess, if
>> we don't change also the per-process optimizations/improvements made by
>> some IO scheduler, I think we can have undesirable behaviours.
>>
>> For example: CFQ uses the per-process iocontext to improve fairness
>> between *all* the processes in a system. But it doesn't have the concept
>> that there's a cgroup context on-top-of the processes.
>>
>> So, some optimizations made to guarantee fairness among processes could
>> conflict with algorithms implemented at the cgroup layer. And
>> potentially lead to undesirable behaviours.
>>
>> For example an issue I'm experiencing with my cgroup-io-throttle
>> patchset is that a cgroup can consistently increase the IO rate (always
>> respecting the max limits), simply increasing the number of IO worker
>> tasks respect to another cgroup with a lower number of IO workers. This
>> is probably due to the fact the CFQ tries to give the same amount of
>> "IO time" to all the tasks, without considering that they're organized
>> in cgroup.
> 
> BTW this is why I proposed to use a single shared iocontext for all the
> processes running in the same cgroup. Anyway, this is not the best
> solution, because in this way all the IO requests coming from a cgroup
> will be queued to the same cfq queue. If I'm not wrong in this way we
> would implement noop (FIFO) between tasks belonging to the same cgroup
> and CFQ between cgroups. But, at least for this particular case, we
> would be able to provide fairness among cgroups.

Ah! also have a look at this:

http://download.systemimager.org/~arighi/linux/patches/io-throttle/benchmark/graph/effect-of-per-process-cfq-fairness-on-the-cgroup-context.png

The graph highlights the dependency between the IO rate and the number
of tasks running in a cgroup. For this testcase I've used 2 cgroups:

- cgroup A, with a single task doing IO (large O_DIRECT read stream)
- cgroup B, with a variable number of tasks ranging from 1 to 16 doing
  IO in parallel

If we want to be "fair" the gap of IO performance between the cgroups
should be close to 0.

Using "plain" cfq (red line) the gap of performance increases
incrementing the number of tasks in a cgroup.

Using cgroup-io-throttle on top of cfq (green line) the gap of
performance is lower (the asymptotic curve is due to the bandwidth
capping provided by cgroup-io-throttle).

Using cgroup-io-throttle and a single shared iocontext for each cgroup
(blue line) the gap of performance is really close to 0.

Anyway, I repeat, I don't think this is a wonderful solution, it is just
to highlights this issue and share with you the results of some tests I
did.

-Andrea
