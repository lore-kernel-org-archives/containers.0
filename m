From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] IO Controller
Date: Tue, 07 Apr 2009 14:40:10 +0800
Message-ID: <49DAF54A.10909@cn.fujitsu.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<49D45DAC.2060508@cn.fujitsu.com>
	<20090402140037.GC12851@redhat.com>
	<49DAAF25.8010702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49DAAF25.8010702-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Gui Jianfeng wrote:
> Vivek Goyal wrote:
>> On Thu, Apr 02, 2009 at 02:39:40PM +0800, Gui Jianfeng wrote:
>>> Vivek Goyal wrote:
>>>> Hi All,
>>>>
>>>> Here is another posting for IO controller patches. Last time I had posted
>>>> RFC patches for an IO controller which did bio control per cgroup.
>>>>
>>>> http://lkml.org/lkml/2008/11/6/227
>>>>
>>>> One of the takeaway from the discussion in this thread was that let us
>>>> implement a common layer which contains the proportional weight scheduling
>>>> code which can be shared by all the IO schedulers.
>>>>
>>>   
>>>   Hi Vivek,
>>>
>>>   I did some tests on my *old* i386 box(with two concurrent dd running), and notice 
>>>   that IO Controller doesn't work fine in such situation. But it can work perfectly 
>>>   in my *new* x86 box. I dig into this problem, and i guess the major reason is that
>>>   my *old* i386 box is too slow, it can't ensure two running ioqs are always backlogged.
>> Hi Gui,
>>
>> Have you run top to see what's the percentage cpu usage. I suspect that
>> cpu is not keeping up pace disk to enqueue enough requests. I think
>> process might be blocked somewhere else so that it could not issue
>> requests. 
>>
>>>   If that is the case, I happens to have a thought. when an ioq uses up it time slice, 
>>>   we don't expire it immediately. May be we can give a piece of bonus time for idling 
>>>   to wait new requests if this ioq's finish time and its ancestor's finish time are all 
>>>   much smaller than other entities in each corresponding service tree.
>> Have you tried it with "fairness" enabled? With "fairness" enabled, for
>> sync queues I am waiting for one extra idle time slice "8ms" for queue
>> to get backlogged again before I move to the next queue?
>>
>> Otherwise try to increase the idle time length to higher value say "12ms"
>> just to see if that has any impact.
>>
>> Can you please also send me output of blkparse. It might give some idea
>> how IO schedulers see IO pattern.
> 
>   Hi Vivek,
> 
>   Sorry for the late reply, I tried the "fairness" patch, it seems not working.
>   I'v also tried to extend the idle value, not working either.
>   The blktrace output is attached. It seems that the high priority ioq is deleting
>   from busy tree too often due to lacking of requests. My box is single CPU and CPU
>   speed is a little slow. May be two concurrent dd is contending CPU to submit
>   requests, that's the reason for not always backlogged for ioqs.

  Hi Vivek,

  Sorry for bothering, there were some configure errors when i tested, and got the improper
  result.
  The "fairness" patch seems to work fine now! It makes the high priority ioq *always* backlogged :)

> 
>> Thanks
>> Vivek
>>
>>
>>
> 

-- 
Regards
Gui Jianfeng
