From: "IKEDA, Munehiro" <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: Re: IO Controller per cgroup request descriptors (Re: [PATCH 01/10]
	Documentation)
Date: Mon, 04 May 2009 13:18:43 -0400
Message-ID: <49FF2373.7040905__23822.4016422921$1241457977$gmane$org@ds.jp.nec.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>	
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>	
	<20090406143556.GK7082@balbir.in.ibm.com>	
	<20090413134017.GC18007@redhat.com> <49FB71F7.90309@ds.jp.nec.com>	
	<20090501224506.GC6130@redhat.com>
	<e98e18940905011639o63c048f1n79c7e7648441a06d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e98e18940905011639o63c048f1n79c7e7648441a06d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Nauman Rafique wrote:
> On Fri, May 1, 2009 at 3:45 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> On Fri, May 01, 2009 at 06:04:39PM -0400, IKEDA, Munehiro wrote:
>>> Vivek Goyal wrote:
>>>>>> +TODO
>>>>>> +====
>>>>>> +- Lots of cleanups, testing, bug fixing, optimizations, benchmarking etc...
>>>>>> +- Convert cgroup ioprio to notion of weight.
>>>>>> +- Anticipatory code will need more work. It is not working properly currently
>>>>>> +  and needs more thought.
>>>>> What are the problems with the code?
>>>> Have not got a chance to look into the issues in detail yet. Just a crude run
>>>> saw drop in performance. Will debug it later the moment I have got async writes
>>>> handled...
>>>>
>>>>>> +- Use of bio-cgroup patches.
>>>>> I saw these posted as well
>>>>>
>>>>>> +- Use of Nauman's per cgroup request descriptor patches.
>>>>>> +
>>>>> More details would be nice, I am not sure I understand
>>>> Currently the number of request descriptors which can be allocated per
>>>> device/request queue are fixed by a sysfs tunable (q->nr_requests). So
>>>> if there is lots of IO going on from one cgroup then it will consume all
>>>> the available request descriptors and other cgroup might starve and not
>>>> get its fair share.
>>>>
>>>> Hence we also need to introduce the notion of request descriptor limit per
>>>> cgroup so that if request descriptors from one group are exhausted, then
>>>> it does not impact the IO of other cgroup.
>>> Unfortunately I couldn't find and I've never seen the Nauman's patches.
>>> So I tried to make a patch below against this todo.  The reason why
>>> I'm posting this despite this is just a quick and ugly hack (and it
>>> might be a reinvention of wheel) is that I would like to discuss how
>>> we should define the limitation of requests per cgroup.
>>> This patch should be applied on Vivek's I/O controller patches
>>> posted on Mar 11.
>> Hi IKEDA,
>>
>> Sorry for the confusion here. Actually Nauman had sent a patch to select group
>> of people who were initially copied on the mail thread.
> 
> I am sorry about that. Since I dropped my whole patch set in favor of
> Vivek's stuff, this stuff fell through the cracks.

No problem at all guys.  I'm glad to see your patch Vivek sent, thanks.


>>> This patch temporarily distribute q->nr_requests to each cgroup.
>>> I think the number should be weighted like BFQ's budget.  But in
>>> this case, if the hierarchy of cgroup is deep, leaf cgroups are
>>> allowed to allocate very few numbers of requests.  I don't think
>>> this is reasonable...but I don't have specific idea to solve this
>>> problem.  Does anyone have the good idea?
>>>
>> Thanks for the patch. Yes, ideally one would expect the request descriptor
>> to be allocated also in proportion to the weight but I guess that would
>> become very comlicated.
>>
>> In terms of simpler things, two thoughts come to mind.
>>
>> - First approach is to make q->nr_requests per group. So every group is
>>  entitled for q->nr_requests as set by the user. This is what your patch
>>  seems to have done.
>>
>>  I had some concerns with this approach. First of all it does not seem to
>>  have an upper bound on number of request descriptors allocated per queue
>>  because if a user creates more cgroups, total number of request
>>  descriptors increase.
>>
>> - Second approach can be that we retain the meaning of q->nr_requests
>>  which defines the total number of request descriptors on the queue (with
>>  the exception of 50% more descriptors for batching processes). And we
>>  define a new per group limit q->nr_group_requests which defines how many
>>  requests per group can be assigned. So q->nr_requests defines total pool
>>  size on the queue and q->nr_group_requests will define how many requests
>>  each group can allocate out of that pool.
>>
>>  Here the issue is that a user shall have to balance the q->nr_group_requests    and q->nr_requests properly.
>>
>> To experiment, I have implemented the second approach. I am attaching the
>> patch which is in my current tree. It probably will not apply on my march
>> 11 posting as since then patches have changed. But posting it here so that
>> at least it will give an idea behind the thought process.
>>
>> Ideas are welcome...
> 
> I had started with the first option, but the second option sounds good
> too. But one problem that comes to mind is how we deal with
> hierarchies? The sys admin can limit the root level cgroups to
> specific number of request descriptors, but if applications running in
> a cgroup are allowed to create their own cgroups, then the total
> request descriptors of all child cgroups should be capped by the
> number assigned to parent cgroups.

I think the second option cannot coexist with hierarchy support of
per cgroup request descriptors limitation.  I guess the fundamental
idea of the second approach is to make logic simpler by giving up
hierarchy, isn't it correct?
IIUC, for hierarchy support, we need to have some good idea to solve
the issue that a cgroup which belongs to deep hierarchy can have only
few requests, as I mentioned.
Anyway, I keep my eyes on this issue.  I'm looking forward to Vivek's
next version patches.


(snip)
>> +#ifdef CONFIG_GROUP_IOSCHED
>> +static ssize_t queue_group_requests_show(struct request_queue *q, char *page)
>> +{
>> +       return queue_var_show(q->nr_group_requests, (page));
>> +}
>> +
>> +static ssize_t
>> +queue_group_requests_store(struct request_queue *q, const char *page,
>> +                                       size_t count)
>> +{
>> +       unsigned long nr;
>> +       int ret = queue_var_store(&nr, page, count);
>> +       if (nr < BLKDEV_MIN_RQ)
>> +               nr = BLKDEV_MIN_RQ;
>> +
>> +       spin_lock_irq(q->queue_lock);
>> +       q->nr_group_requests = nr;
>> +       spin_unlock_irq(q->queue_lock);
>> +       return ret;
>> +}
>> +#endif
(snip)

Unchanging io_context "batching" status is on purpose?



Thanks,
Muuhh

-- 
IKEDA, Munehiro
  NEC Corporation of America
    m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
