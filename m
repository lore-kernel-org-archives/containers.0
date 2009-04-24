From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 5/7] kiothrottled: throttle buffered (writeback) IO
Date: Fri, 24 Apr 2009 14:36:34 +0800
Message-ID: <49F15DF2.30200__689.379106234078$1240555214$gmane$org@cn.fujitsu.com>
References: <1240090712-1058-1-git-send-email-righi.andrea@gmail.com>
	<1240090712-1058-6-git-send-email-righi.andrea@gmail.com>
	<49F01E8F.80807@cn.fujitsu.com> <20090423102551.GB16768@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090423102551.GB16768@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> On Thu, Apr 23, 2009 at 03:53:51PM +0800, Gui Jianfeng wrote:
>> Andrea Righi wrote:
>>> Together with cgroup_io_throttle() the kiothrottled kernel thread
>>> represents the core of the io-throttle subsystem.
>>>
>>> All the writeback IO requests that need to be throttled are not
>>> dispatched immediately in submit_bio(). Instead, they are added into an
>>> rbtree by iothrottle_make_request() and processed asynchronously by
>>> kiothrottled.
>>>
>>> A deadline is associated to each request depending on the bandwidth
>>> usage of the cgroup it belongs. When a request is inserted into the
>>> rbtree kiothrottled is awakened. This thread selects all the requests
>>> with an expired deadline and submit the bunch of selected requests to
>>> the underlying block devices using generic_make_request().
>>   Hi Andrea,
>>
>>   What if an user issues "sync", will the bios still be buffered in the rb-tree?
>>   Do we need to flush the whole tree?
> 
> Good question. From The sync(2) man page:
> 
> 	According to the standard specification (e.g., POSIX.1-2001), sync()
> 	schedules the writes, but may return before the actual writing is done.
> 	However, since  version  1.3.20  Linux does  actually  wait.  (This
> 	still  does not guarantee data integrity: modern disks have large
> 	caches.)
> 
> It is not completely wrong looking at the standard. The writes are
> actually scheduled, but pending in the rbtree. Anyway, if we immediately
> dispatch them anyone can evade the IO controller simply issuing a lot of
> sync while doing IO. OTOH dispatching the requests respecting the max
> rate for each cgroup can cause the sync to wait for all the others' BW
> limitations.
> 
> Honestly I don't have a good answer for this. Opinions?

  IMHO, buffered bios should be submitted immediately even if this
  regards as evading when an user issues "sync". Restricting an user
  from issuing "sync" also helps, but seems not easy.


-- 
Regards
Gui Jianfeng
