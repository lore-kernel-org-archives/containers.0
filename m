From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Wed, 18 Mar 2009 15:23:29 +0800
Message-ID: <49C0A171.8060009__47757.9007893384$1237361326$gmane$org@cn.fujitsu.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312100054.GA8024@linux.vnet.ibm.com>
	<20090312140450.GE10919@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312140450.GE10919-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
>> Hi Vivek,
>>
>> I would be interested in knowing if these are the results expected?
>>
> 
> Hi Dhaval, 
> 
> Good question. Keeping current expectation in mind, yes these are expected
> results. To begin with, current expectations are that try to emulate
> cfq behavior and the kind of service differentiation we get between
> threads of different priority, same kind of service differentiation we
> should get from different cgroups.
>  
> Having said that, in theory a more accurate estimate should be amount 
> of actual disk time a queue/cgroup got. I have put a tracing message
> to keep track of total service received by a queue. If you run "blktrace"
> then you can see that. Ideally, total service received by two threads
> over a period of time should be in same proportion as their cgroup
> weights.
> 
> It will not be easy to achive it given the constraints we have got in
> terms of how to accurately we can account for disk time actually used by a
> queue in certain situations. So to begin with I am targetting that
> try to meet same kind of service differentation between cgroups as
> cfq provides between threads and then slowly refine it to see how
> close one can come to get accurate numbers in terms of "total_serivce"
> received by each queue.

  Hi Vivek,

  I simply tested with blktrace opened. I create two groups and set ioprio
  4 and 7 respectively(the corresponding weight should 4:1, right?), and 
  start two dd concurrently. UUIC, Ideally, the proportion of service two 
  dd got should be 4:1 in a period of time when they are running. I extract 
  *served* value from blktrace output and sum them up. I found the proportion 
  of the sum of *served* value is about 1.7:1
  Am i missing something?

  I extract the following highlight value
  8,0  0   0   18.914906549     0  m   N 6601ioq served=*0x13* total service=0x184d

> 
> Thanks
> Vivek
> 
> 
> 

-- 
Regards
Gui Jianfeng
