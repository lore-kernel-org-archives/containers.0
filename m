From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: dm-ioband + bio-cgroup benchmarks
Date: Thu, 18 Sep 2008 17:18:50 +0200
Message-ID: <48D2715A.6060002__27820.5048678958$1221751350$gmane$org@gmail.com>
References: <20080918.210418.226794540.ryov@valinux.co.jp>
	<20080918131554.GB20640@redhat.com> <48D267B5.20402@gmail.com>
	<20080918150634.GH20640@redhat.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080918150634.GH20640-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> On Thu, Sep 18, 2008 at 04:37:41PM +0200, Andrea Righi wrote:
>> Vivek Goyal wrote:
>>> On Thu, Sep 18, 2008 at 09:04:18PM +0900, Ryo Tsuruta wrote:
>>>> Hi All,
>>>>
>>>> I have got excellent results of dm-ioband, that controls the disk I/O
>>>> bandwidth even when it accepts delayed write requests.
>>>>
>>>> In this time, I ran some benchmarks with a high-end storage. The
>>>> reason was to avoid a performance bottleneck due to mechanical factors
>>>> such as seek time.
>>>>
>>>> You can see the details of the benchmarks at:
>>>> http://people.valinux.co.jp/~ryov/dm-ioband/hps/
>>>>
>>> Hi Ryo,
>>>
>>> I had a query about dm-ioband patches. IIUC, dm-ioband patches will break
>>> the notion of process priority in CFQ because now dm-ioband device will
>>> hold the bio and issue these to lower layers later based on which bio's
>>> become ready. Hence actual bio submitting context might be different and
>>> because cfq derives the io_context from current task, it will be broken.
>>>
>>> To mitigate that problem, we probably need to implement Fernando's
>>> suggestion of putting io_context pointer in bio. 
>>>
>>> Have you already done something to solve this issue?
>>>
>>> Secondly, why do we have to create an additional dm-ioband device for 
>>> every device we want to control using rules. This looks little odd
>>> atleast to me. Can't we keep it in line with rest of the controllers
>>> where task grouping takes place using cgroup and rules are specified in
>>> cgroup itself (The way Andrea Righi does for io-throttling patches)?
>>>
>>> To avoid creation of stacking another device (dm-ioband) on top of every
>>> device we want to subject to rules, I was thinking of maintaining an
>>> rb-tree per request queue. Requests will first go into this rb-tree upon
>>> __make_request() and then will filter down to elevator associated with the
>>> queue (if there is one). This will provide us the control of releasing
>>> bio's to elevaor based on policies (proportional weight, max bandwidth
>>> etc) and no need of stacking additional block device.
>>>
>>> I am working on some experimental proof of concept patches. It will take
>>> some time though.
>>>
>>> I was thinking of following.
>>>
>>> - Adopt the Andrea Righi's style of specifying rules for devices and
>>>   group the tasks using cgroups.
>>>
>>> - To begin with, adopt dm-ioband's approach of proportional bandwidth
>>>   controller. It makes sense to me limit the bandwidth usage only in
>>>   case of contention. If there is really a need to limit max bandwidth,
>>>   then probably we can do something to implement additional rules or
>>>   implement some policy switcher where user can decide what kind of
>>>   policies need to be implemented.
>>>
>>> - Get rid of dm-ioband and instead buffer requests on an rb-tree on every
>>>   request queue which is controlled by some kind of cgroup rules.
>>>
>>> It would be good to discuss above approach now whether it makes sense or 
>>> not. I think it is kind of fusion of io-throttling and dm-ioband patches
>>> with additional idea of doing io-control just above elevator on the request
>>> queue using an rb-tree.
>> Thanks Vivek. All sounds reasonable to me and I think this is be the right way
>> to proceed.
>>
>> I'll try to design and implement your rb-tree per request-queue idea into my
>> io-throttle controller, maybe we can reuse it also for a more generic solution.
>> Feel free to send me your experimental proof of concept if you want, even if
>> it's not yet complete, I can review it, test and contribute.
> 
> Currently I have taken code from bio-cgroup to implement cgroups and to
> provide functionality to associate a bio to a cgroup. I need this to be
> able to queue the bio's at right node in the rb-tree and then also to be
> able to take a decision when is the right time to release few requests.
> 
> Right now in crude implementation, I am working on making system boot.
> Once patches are at least in little bit working shape, I will send it to you
> to have a look.
> 
> Thanks
> Vivek

I wonder... wouldn't be simpler to just use the memory controller
to retrieve this information starting from struct page?

I mean, following this path (in short, obviously using the appropriate
interfaces for locking and referencing the different objects):

cgrp = page->page_cgroup->mem_cgroup->css.cgroup

Once you get the cgrp it's very easy to use the corresponding controller
structure.

Actually, this is how I'm doing in cgroup-io-throttle to associate a bio
to a cgroup. What other functionalities/advantages bio-cgroup provide in
addition to that?

Thanks,
-Andrea
