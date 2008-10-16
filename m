From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH -mm 0/6] cgroup: block device i/o controller (v11)
Date: Thu, 16 Oct 2008 11:00:52 +0200
Message-ID: <48F702C4.5080503__46625.5044950687$1224147962$gmane$org@gmail.com>
References: <1223373818-13687-1-git-send-email-righi.andrea@gmail.com>	
	<2891419e0810140217l70f233bbr3b08760188458c35@mail.gmail.com>	
	<48F46CB6.3010904@gmail.com>
	<2891419e0810142313p1aa16295ne2aa8ac3a87be491@mail.gmail.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0810142313p1aa16295ne2aa8ac3a87be491-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Dong-Jae Kang wrote:
>>> I have several question about io-throttle
>>> below is my test reusult of io-throttle(v11) with xdd 6.5
>>> But, I think I have something wrong, as showed in result
>>> In direct IO mode, Only read operation was controlled by io-throttle
>>> Can you check my  test procedure and result and comments to me about that
>> Your procedure is correct. Anyway, you found a known bug in io-throttle
>> v11. If you want to properly use it you need to mount the memory
>> controller together with blockio, since currently blockio depends on it
>> to retrieve the owner of a page during writes in submit_bio().
>>
>> As reported in:
>>
>> [PATCH -mm 4/6] memcg: interface to charge the right cgroup of asynchronous i/o activity
>>
>> this is no more than a hack and in perspective a more generic framework
>> able to provide this functionality should be used (i.e. bio-cgroup).
> 
> But, In my opinion,
> it is some strange that the bandwidth of write operation in direct IO
> mode was not controlled by io-throttle
> I think [PATCH -mm 4/6] is for control of buffered IO.
> Do I misunderstand it?

The approach is the same both for buffered and direct IO. With buffered
IO, writes are accounted in submit_bio() and throttling is performed in
balance_dirty_pages_ratelimited_nr(). With direct IO, accounting is always
performed in submit_bio() and throttling in submit_page_section(). That's
the same also for AIO, accounting in submit_bio() and throttling in
io_submit_one(), returning -EAGAIN in this case when the IO limits are
exceeded (instead of sleeping).

We never sleep in submit_bio() during writes and to account the IO activity
we always look at the owner (cgroup) of the first page in the struct bio,
also when the IO context is the cgroup of the current task (as in the direct
IO case). To correctly retrieve the owner of each page I've used the memory
controller functionality. This part should be improved to use a more generic
framework and remove the dependency of the memory controller. Or better, doesn't
impose to mount blockio and memory controller both to the same mountpoint.

-Andrea
