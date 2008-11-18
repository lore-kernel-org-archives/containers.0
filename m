From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Tue, 18 Nov 2008 14:23:29 -0800
Message-ID: <e98e18940811181423y770cb6bay19dd520e5f010f33__24661.0365728431$1227047172$gmane$org@mail.gmail.com>
References: <20081106153022.215696930@redhat.com>
	<af41c7c40811131041t1b8491b6la5574ebe75f89000@mail.gmail.com>
	<20081113214642.GG7542@redhat.com>
	<af41c7c40811131457w472e4a86tb5344cc1d3d366fb@mail.gmail.com>
	<20081114160525.GE24624@redhat.com>
	<e98e18940811141444u5947b806v27fac453ed1e8a5@mail.gmail.com>
	<20081117142309.GA15564@redhat.com> <4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
	<492271EF.4050002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <492271EF.4050002-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Nov 17, 2008 at 11:42 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Nauman Rafique wrote:
>> If we start with bfq patches, this is how plan would look like:
>>
>> 1 Start with BFQ take 2.
>> 2 Do the following to support proportional division:
>>  a) Expose the per device weight interface to user, instead of calculating
>>  from priority.
>>  b) Add support for disk time budgets, besides sector budget that is currently
>>  available (configurable option). (Fabio: Do you think we can just emulate
>> that using the existing code?). Another approach would be to give time slices
>> just like CFQ (discussing?)
>> 4 Do the following to support the goals of 2 level schedulers:
>>  a) Limit the request descriptors allocated to each cgroup by adding
>>  functionality to elv_may_queue()
>>  b) Add support for putting an absolute limit on IO consumed by a
>>  cgroup. Such support is provided by Andrea
>>  Righi's patches too.
>>  c) Add support (configurable option) to keep track of total disk
>> time/sectors/count
>>  consumed at each device, and factor that into scheduling decision
>>  (more discussion needed here)
>> 6 Incorporate an IO tracking approach which re-uses memory resource
>> controller code but is not dependent on it (may be biocgroup patches from
>> dm-ioband can be used here directly)
>
> The newest bio_cgroup doesn't use much memcg code I think. The older biocgroup
> tracks IO using mem_cgroup_charge(), and mem_cgroup_charge() remembers a struct page
> owns by which cgroup. But now biocgroup changes to directly put some hooks in
> __set_page_dirty() and some other places to track pages.

I did not look into latest biocgroup patches, so may be you are right.
Nevertheless, bfq currently gets cgroup info out of io context and so
would handle only synchronous reads. For this action item, we have to
make the latest biocgroup patches to work with bfq.

>
>> 7 Start an offline email thread to keep track of progress on the above
>> goals.
>>
>> BFQ's support for hierarchy of cgroups means that its close to where
>> we want to get. Any comments on what approach looks better?
>>
>
> Looks like a sane way :) . We are also trying to keep track of the discussion and
> development of IO controller. I'll start to have a look into BFQ.
>
>> On Mon, Nov 17, 2008 at 6:02 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>> Vivek Goyal wrote:
>>>> On Fri, Nov 14, 2008 at 02:44:22PM -0800, Nauman Rafique wrote:
>>>>> In an attempt to make sure that this discussion leads to
>>>>> something useful, we have summarized the points raised in this
>>>>> discussion and have come up with a strategy for future.
>>>>> The goal of this is to find common ground between all the approaches
>>>>> proposed on this mailing list.
>>>>>
>>>>> 1 Start with Satoshi's latest patches.
>>>> I have had a brief look at both Satoshi's patch and bfq. I kind of like
>>>> bfq's patches for keeping track of per cgroup, per queue data structures.
>>>> May be we can look there also.
>>>>
>>>>> 2 Do the following to support propotional division:
>>>>>  a) Give time slices in proportion to weights (configurable
>>>>>  option). We can support both priorities and weights by doing
>>>>>  propotional division between requests with same priorities.
>>>>> 3 Schedule time slices using WF2Q+ instead of round robin.
>>>>>  Test the performance impact (both throughput and jitter in latency).
>>>>> 4 Do the following to support the goals of 2 level schedulers:
>>>>>  a) Limit the request descriptors allocated to each cgroup by adding
>>>>>  functionality to elv_may_queue()
>>>>>  b) Add support for putting an absolute limit on IO consumed by a
>>>>>  cgroup. Such support exists in dm-ioband and is provided by Andrea
>>>>>  Righi's patches too.
>>>> Does dm-iobnd support abosolute limit? I think till last version they did
>>>> not. I have not check the latest version though.
>>>>
>>> No, dm-ioband still provides weight/share control only. Only Andrea Righi's
>>> patches support absolute limit.
>>
>> Thanks for the correction.
>>
>>>>>  c) Add support (configurable option) to keep track of total disk
>>>>> time/sectors/count
>>>>>  consumed at each device, and factor that into scheduling decision
>>>>>  (more discussion needed here)
>>>>> 5 Support multiple layers of cgroups to align IO controller behavior
>>>>>  with CPU scheduling behavior (more discussion?)
>>>>> 6 Incorporate an IO tracking approach which re-uses memory resource
>>>>> controller code but is not dependent on it (may be biocgroup patches from
>>>>> dm-ioband can be used here directly)
>>>>> 7 Start an offline email thread to keep track of progress on the above
>>>>> goals.
>>>>>
>>>>> Please feel free to add/modify items to the list
>>>>> when you respond back. Any comments/suggestions are more than welcome.
>>>>>
>>>
>>
>
