From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] io-controller: Fix task hanging when there are more	than
	one groups
Date: Wed, 16 Sep 2009 10:58:10 +0800
Message-ID: <4AB05442.6080004__19653.6358599134$1253070156$gmane$org@cn.fujitsu.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<4AA4B905.8010801@cn.fujitsu.com>
	<20090908191941.GF15974@redhat.com>
	<4AA75B71.5060109@cn.fujitsu.com>
	<20090909150537.GD8256@redhat.com> <4AA9A4BE.30005@cn.fujitsu.com>
	<20090915033739.GA4054@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090915033739.GA4054-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> On Fri, Sep 11, 2009 at 09:15:42AM +0800, Gui Jianfeng wrote:
>> Vivek Goyal wrote:
>>> On Wed, Sep 09, 2009 at 03:38:25PM +0800, Gui Jianfeng wrote:
>>>> Vivek Goyal wrote:
>>>>> On Mon, Sep 07, 2009 at 03:40:53PM +0800, Gui Jianfeng wrote:
>>>>>> Hi Vivek,
>>>>>>
>>>>>> I happened to encount a bug when i test IO Controller V9.
>>>>>> When there are three tasks to run concurrently in three group,
>>>>>> that is, one is parent group, and other two tasks are running 
>>>>>> in two different child groups respectively to read or write 
>>>>>> files in some disk, say disk "hdb", The task may hang up, and 
>>>>>> other tasks which access into "hdb" will also hang up.
>>>>>>
>>>>>> The bug only happens when using AS io scheduler.
>>>>>> The following scirpt can reproduce this bug in my box.
>>>>>>
>>>>> Hi Gui,
>>>>>
>>>>> I tried reproducing this on my system and can't reproduce it. All the
>>>>> three processes get killed and system does not hang.
>>>>>
>>>>> Can you please dig deeper a bit into it. 
>>>>>
>>>>> - If whole system hangs or it is just IO to disk seems to be hung.
>>>>     Only when the task is trying do IO to disk it will hang up.
>>>>
>>>>> - Does io scheduler switch on the device work
>>>>     yes, io scheduler can be switched, and the hung task will be resumed.
>>>>
>>>>> - If the system is not hung, can you capture the blktrace on the device.
>>>>>   Trace might give some idea, what's happening.
>>>> I run a "find" task to do some io on that disk, it seems that task hangs 
>>>> when it is issuing getdents() syscall.
>>>> kernel generates the following message:
>>>>
>>>> INFO: task find:3260 blocked for more than 120 seconds.
>>>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>>>> find          D a1e95787  1912  3260   2897 0x00000004
>>>>  f6af2db8 00000096 f660075c a1e95787 00000032 f6600270 f6600508 c2037820
>>>>  00000000 c09e0820 f655f0c0 f6af2d8c fffebbf1 00000000 c0447323 f7152a1c
>>>>  0006a144 f7152a1c 0006a144 f6af2e04 f6af2db0 c04438df c2037820 c2037820
>>>> Call Trace:
>>>>  [<c0447323>] ? getnstimeofday+0x57/0xe0
>>>>  [<c04438df>] ? ktime_get_ts+0x4a/0x4e
>>>>  [<c068ab68>] io_schedule+0x47/0x79
>>>>  [<c04c12ee>] sync_buffer+0x36/0x3a
>>>>  [<c068ae14>] __wait_on_bit+0x36/0x5d
>>>>  [<c04c12b8>] ? sync_buffer+0x0/0x3a
>>>>  [<c068ae93>] out_of_line_wait_on_bit+0x58/0x60
>>>>  [<c04c12b8>] ? sync_buffer+0x0/0x3a
>>>>  [<c0440fa4>] ? wake_bit_function+0x0/0x43
>>>>  [<c04c1249>] __wait_on_buffer+0x19/0x1c
>>>>  [<f81e4186>] ext3_bread+0x5e/0x79 [ext3]
>>>>  [<f81e77a8>] htree_dirblock_to_tree+0x1f/0x120 [ext3]
>>>>  [<f81e7923>] ext3_htree_fill_tree+0x7a/0x1bb [ext3]
>>>>  [<c04a01f9>] ? kmem_cache_alloc+0x86/0xf3
>>>>  [<c044c428>] ? trace_hardirqs_on_caller+0x107/0x12f
>>>>  [<c044c45b>] ? trace_hardirqs_on+0xb/0xd
>>>>  [<f81e09e4>] ? ext3_readdir+0x9e/0x692 [ext3]
>>>>  [<f81e0b34>] ext3_readdir+0x1ee/0x692 [ext3]
>>>>  [<c04b1100>] ? filldir64+0x0/0xcd
>>>>  [<c068b86a>] ? mutex_lock_killable_nested+0x2b1/0x2c5
>>>>  [<c068b874>] ? mutex_lock_killable_nested+0x2bb/0x2c5
>>>>  [<c04b12db>] ? vfs_readdir+0x46/0x94
>>>>  [<c04b12fd>] vfs_readdir+0x68/0x94
>>>>  [<c04b1100>] ? filldir64+0x0/0xcd
>>>>  [<c04b1387>] sys_getdents64+0x5e/0x9f
>>>>  [<c04028b4>] sysenter_do_call+0x12/0x32
>>>> 1 lock held by find/3260:
>>>>  #0:  (&sb->s_type->i_mutex_key#7){+.+.+.}, at: [<c04b12db>] vfs_readdir+0x46/0x94
>>>>
>>>> ext3 calls wait_on_buffer() to wait buffer, and schedule the task out in TASK_UNINTERRUPTIBLE
>>>> state, and I found this task will be resumed after a quite long period(more than 10 mins).
>>> Thanks Gui. As Jens said, it does look like a case of missing queue
>>> restart somewhere and now we are stuck, no requests are being dispatched
>>> to the disk and queue is already unplugged.
>>>
>>> Can you please also try capturing the trace of events at io scheduler
>>> (blktrace) to see how did we get into that situation.
>>>
>>> Are you using ide drivers and not libata? As jens said, I will try to make
>>> use of ide drivers and see if I can reproduce it.
>>>
>> Hi Vivek, Jens,
>>
>> Currently, If there's only the root cgroup and no other child cgroup available, io-controller will
>> optimize to stop expiring the current ioq, and we thought the current ioq belongs to root group. But
>> in some cases, this assumption is not true. Consider the following scenario, if there is a child cgroup
>> located in root cgroup, and task A is running in the child cgroup, and task A issues some IOs. Then we
>> kill task A and remove the child cgroup, at this time, there is only root cgroup available. But the ioq
>> is still under service, and from now on, this ioq won't expire because "only root" optimization.
>> The following patch ensures the ioq do belongs to the root group if there's only root group existing.
>>
>> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> Hi Gui,
> 
> I have modified your patch a bit to improve readability. Looking at the
> issue closely I realized that this optimization of not expiring the 
> queue can lead to other issues like high vdisktime in certain scenarios.
> While fixing that also noticed the issue of high rate of as queue
> expiration in certain cases which could have been avoided. 
> 
> Here is a patch which should fix all that. I am still testing this patch
> to make sure that something is not obiviously broken. Will merge it if
> there are no issues.
> 
> Thanks
> Vivek
> 
> o Fixed the issue of not expiring the queue for single ioq schedulers. Reported
>   and fixed by Gui.
> 
> o If an AS queue is not expired for a long time and suddenly somebody
>   decides to create a group and launch a job there, in that case old AS
>   queue will be expired with a very high value of slice used and will get
>   a very high disk time. Fix it by marking the queue as "charge_one_slice"
>   and charge the queue only for a single time slice and not for whole
>   of the duration when queue was running.
> 
> o There are cases where in case of AS, excessive queue expiration will take
>   place by elevator fair queuing layer because of few reasons.
> 	- AS does not anticipate on a queue if there are no competing requests.
> 	  So if only a single reader is present in a group, anticipation does
> 	  not get turn on.
> 
> 	- elevator layer does not know that As is anticipating hence initiates
> 	  expiry requests in select_ioq() thinking queue is empty.
> 
> 	- elevaotr layer tries to aggressively expire last empty queue. This
> 	  can lead to lof of queue expiry
> 
> o This patch now starts ANITC_WAIT_NEXT anticipation if last request in the
>   queue completed and associated io context is eligible to anticipate. Also
>   AS lets elevatory layer know that it is anticipating (elv_ioq_wait_request())
>   . This solves above mentioned issues.
>  
> o Moved some of the code in separate functions to improve readability.
> 
...

>  /* A request got completed from io_queue. Do the accounting. */
>  void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
>  {
> @@ -3470,16 +3572,16 @@ void elv_ioq_completed_request(struct re
>  			elv_set_prio_slice(q->elevator->efqd, ioq);
>  			elv_clear_ioq_slice_new(ioq);
>  		}
> +
>  		/*
>  		 * If there is only root group present, don't expire the queue
>  		 * for single queue ioschedulers (noop, deadline, AS). It is
>  		 * unnecessary overhead.
>  		 */
>  
> -		if (is_only_root_group() &&
> -			elv_iosched_single_ioq(q->elevator)) {
> -			elv_log_ioq(efqd, ioq, "select: only root group,"
> -					" no expiry");
> +		if (single_ioq_no_timed_expiry(q)) {

  Hi Vivek,

  So we make use of single_ioq_no_timed_expiry() to decide whether there is only
  root ioq to be busy, right? But single_ioq_no_timed_expiry() only checks if
  the root cgroup is the only group and if there is only one busy_ioq there. As
  I explained in previous mail, these two checks are not sufficient to say the
  current active ioq comes from root group. Because when the child cgroup is just
  removed, and the ioq which belongs to child group is still there(maybe some
  requests are in flight). In this case, only root cgroup and only one active ioq
  (child ioq) checks are satisfied. So IMHO, in single_ioq_no_timed_expiry() we 
  still need to check "efqd->root_group->ioq" is already created to ensure the only
  ioq comes from root group. Am i missing something?


> +			elv_mark_ioq_charge_one_slice(ioq);
> +			elv_log_ioq(efqd, ioq, "single ioq no timed expiry");
>  			goto done;
>  		}
>  

-- 
Regards
Gui Jianfeng
