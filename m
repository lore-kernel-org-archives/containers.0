From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] io-controller: Fix task hanging when there are more	than
	one groups
Date: Thu, 17 Sep 2009 14:08:18 +0800
Message-ID: <4AB1D252.8060406__39661.6997234107$1253167862$gmane$org@cn.fujitsu.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<4AA4B905.8010801@cn.fujitsu.com>
	<20090908191941.GF15974@redhat.com>
	<4AA75B71.5060109@cn.fujitsu.com>
	<20090909150537.GD8256@redhat.com> <4AA9A4BE.30005@cn.fujitsu.com>
	<20090915033739.GA4054@redhat.com>
	<4AB05442.6080004@cn.fujitsu.com>
	<20090916180915.GE5221@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090916180915.GE5221-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> On Wed, Sep 16, 2009 at 10:58:10AM +0800, Gui Jianfeng wrote:
> 
> [..]
>>> o Fixed the issue of not expiring the queue for single ioq schedulers. Reported
>>>   and fixed by Gui.
>>>
>>> o If an AS queue is not expired for a long time and suddenly somebody
>>>   decides to create a group and launch a job there, in that case old AS
>>>   queue will be expired with a very high value of slice used and will get
>>>   a very high disk time. Fix it by marking the queue as "charge_one_slice"
>>>   and charge the queue only for a single time slice and not for whole
>>>   of the duration when queue was running.
>>>
>>> o There are cases where in case of AS, excessive queue expiration will take
>>>   place by elevator fair queuing layer because of few reasons.
>>> 	- AS does not anticipate on a queue if there are no competing requests.
>>> 	  So if only a single reader is present in a group, anticipation does
>>> 	  not get turn on.
>>>
>>> 	- elevator layer does not know that As is anticipating hence initiates
>>> 	  expiry requests in select_ioq() thinking queue is empty.
>>>
>>> 	- elevaotr layer tries to aggressively expire last empty queue. This
>>> 	  can lead to lof of queue expiry
>>>
>>> o This patch now starts ANITC_WAIT_NEXT anticipation if last request in the
>>>   queue completed and associated io context is eligible to anticipate. Also
>>>   AS lets elevatory layer know that it is anticipating (elv_ioq_wait_request())
>>>   . This solves above mentioned issues.
>>>  
>>> o Moved some of the code in separate functions to improve readability.
>>>
>> ...
>>
>>>  /* A request got completed from io_queue. Do the accounting. */
>>>  void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
>>>  {
>>> @@ -3470,16 +3572,16 @@ void elv_ioq_completed_request(struct re
>>>  			elv_set_prio_slice(q->elevator->efqd, ioq);
>>>  			elv_clear_ioq_slice_new(ioq);
>>>  		}
>>> +
>>>  		/*
>>>  		 * If there is only root group present, don't expire the queue
>>>  		 * for single queue ioschedulers (noop, deadline, AS). It is
>>>  		 * unnecessary overhead.
>>>  		 */
>>>  
>>> -		if (is_only_root_group() &&
>>> -			elv_iosched_single_ioq(q->elevator)) {
>>> -			elv_log_ioq(efqd, ioq, "select: only root group,"
>>> -					" no expiry");
>>> +		if (single_ioq_no_timed_expiry(q)) {
>>   Hi Vivek,
>>
>>   So we make use of single_ioq_no_timed_expiry() to decide whether there is only
>>   root ioq to be busy, right? But single_ioq_no_timed_expiry() only checks if
>>   the root cgroup is the only group and if there is only one busy_ioq there. As
>>   I explained in previous mail, these two checks are not sufficient to say the
>>   current active ioq comes from root group. Because when the child cgroup is just
>>   removed, and the ioq which belongs to child group is still there(maybe some
>>   requests are in flight). In this case, only root cgroup and only one active ioq
>>   (child ioq) checks are satisfied. So IMHO, in single_ioq_no_timed_expiry() we 
>>   still need to check "efqd->root_group->ioq" is already created to ensure the only
>>   ioq comes from root group. Am i missing something?
>>
> 
> Hi Gui,
> 
> The only side effect of not checking for "efqd->root_group->ioq" seems to
> be that this ioq hence io group of the child will not be freed immediately
> and release will be delayed until a some other queue in the system gets
> backlogged or ioscheduler exits. At that point of time, this child queue will
> be expired and ioq and iog will be freed.
> 
> The advantage is that if there is IO happening only in child group in that
> case we can avoid expiring that queue.
> 
> So may be keeping the queue around for sometime is not a very idea. 
> 
> Am I missing something?

  Hi Vivek,

  I think you're right.
  A thought comes to my mind, whether can we extend optimization for not expiring
  an ioq not only for root group, but for single ioq case? IOW, if there is only
  one ioq in hierarchy, we don't exipre it until another ioq gets backlogged, and
  we just charge only one time slice for that ioq when it schedule out. This might
  help if IO only happens in child group.

> 
> Thanks
> Vivek
> 
> 
> 

-- 
Regards
Gui Jianfeng
