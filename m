From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mm 0/6] cgroup: block device i/o controller (v11)
Date: Mon, 10 Nov 2008 17:52:21 +0800
Message-ID: <49180455.6060202@cn.fujitsu.com>
References: <> <1223373818-13687-1-git-send-email-righi.andrea@gmail.com>
	<490EA1B4.9070600@cn.fujitsu.com> <4917F62A.20800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4917F62A.20800-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> On 2008-11-03 08:01, Gui Jianfeng wrote:
>> Hi Andrea,
>>
>> I'v tested io-throttle(v11), it seems io-throttle doesn't work well 
>> when a process writes(delay-write) a small file(<50M may be). it can't 
>> throttle the request process accurately.
>> I guess the following reason causes this problem.
>> The write-request process terminates too early to see all accounting
>> calculated in pdflush. So io-throttle can't throttle
>> enough time for that process. Am i right?
> 
> Hi Gui,
> 
> sorry for my late first of all. You're right in part. The fact is that
> with asynchronous IO (no O_DIRECT more exactly) the accounting is
> performed when the blocks are submitted to the IO subsystem (submit_bio)
> and the throttling is performed post-facto when the same process or the
> other processes in the same cgroup write additional pages mapped to the
> limited device (throttling is performed in
> balance_dirty_pages_ratelimited_nr).
> 
> Anyway, if the process did a single small write in memory the operation
> is not accounted until pdflush writes the data back to the block device.
> When pdflush (or the process itself) performs the writeback the
> operation is accounted and next reads/writes that come from the same
> cgroup can now be throttled according to the defined limits.
> 
> So, the accounting is not lost, this information is only used later to
> throttle the next operations that will cause IO requests. IO spikes in
> this way are not prevented. With an early version of io-throttle I did
> both throttling and accounting in balance_dirty_pages_ratelimited_nr
> (when pages are written to memory), this can prevent IO spikes, but only
> if dirty_ratio is set to small values.

  Hi, Andrea,

  Thanks for your detailed explanation, I'v got your point.
  I think it makes more sense if throttling can be fair among other tasks. ;-)

> 
> Hope this clarify,
> -Andrea
> 
> 
> 

-- 
Regards
Gui Jianfeng
