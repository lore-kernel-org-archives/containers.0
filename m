From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/3] blk-throttle: async write throttling
Date: Mon, 07 Mar 2011 15:31:11 +0800
Message-ID: <4D7489BF.9030808__14235.8174700805$1299483287$gmane$org@cn.fujitsu.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
	<20110228230114.GB20845@redhat.com>
	<20110302132830.GB2061@linux.develer.com>
	<20110302214705.GD2547@redhat.com>
	<20110306155247.GA1687@linux.develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110306155247.GA1687-fxUVXftIFDlZdMzt4l2sLQC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> On Wed, Mar 02, 2011 at 04:47:05PM -0500, Vivek Goyal wrote:
>> On Wed, Mar 02, 2011 at 02:28:30PM +0100, Andrea Righi wrote:
>>> On Mon, Feb 28, 2011 at 06:01:14PM -0500, Vivek Goyal wrote:
>>>> On Mon, Feb 28, 2011 at 11:15:02AM +0100, Andrea Righi wrote:
>>>>> Overview
>>>>> ========
>>>>> Currently the blkio.throttle controller only support synchronous IO requests.
>>>>> This means that we always look at the current task to identify the "owner" of
>>>>> each IO request.
>>>>>
>>>>> However dirty pages in the page cache can be wrote to disk asynchronously by
>>>>> the per-bdi flusher kernel threads or by any other thread in the system,
>>>>> according to the writeback policy.
>>>>>
>>>>> For this reason the real writes to the underlying block devices may
>>>>> occur in a different IO context respect to the task that originally
>>>>> generated the dirty pages involved in the IO operation. This makes the
>>>>> tracking and throttling of writeback IO more complicate respect to the
>>>>> synchronous IO from the blkio controller's perspective.
>>>>>
>>>>> Proposed solution
>>>>> =================
>>>>> In the previous patch set http://lwn.net/Articles/429292/ I proposed to resolve
>>>>> the problem of the buffered writes limitation by tracking the ownership of all
>>>>> the dirty pages in the system.
>>>>>
>>>>> This would allow to always identify the owner of each IO operation at the block
>>>>> layer and apply the appropriate throttling policy implemented by the
>>>>> blkio.throttle controller.
>>>>>
>>>>> This solution makes the blkio.throttle controller to work as expected also for
>>>>> writeback IO, but it does not resolve the problem of faster cgroups getting
>>>>> blocked by slower cgroups (that would expose a potential way to create DoS in
>>>>> the system).
>>>>>
>>>>> In fact, at the moment critical IO requests (that have dependency with other IO
>>>>> requests made by other cgroups) and non-critical requests are mixed together at
>>>>> the filesystem layer in a way that throttling a single write request may stop
>>>>> also other requests in the system, and at the block layer it's not possible to
>>>>> retrieve such informations to make the right decision.
>>>>>
>>>>> A simple solution to this problem could be to just limit the rate of async
>>>>> writes at the time a task is generating dirty pages in the page cache. The
>>>>> big advantage of this approach is that it does not need the overhead of
>>>>> tracking the ownership of the dirty pages, because in this way from the blkio
>>>>> controller perspective all the IO operations will happen from the process
>>>>> context: writes in memory and synchronous reads from the block device.
>>>>>
>>>>> The drawback of this approach is that the blkio.throttle controller becomes a
>>>>> little bit leaky, because with this solution the controller is still affected
>>>>> by the IO spikes during the writeback of dirty pages executed by the kernel
>>>>> threads.
>>>>>
>>>>> Probably an even better approach would be to introduce the tracking of the
>>>>> dirty page ownership to properly account the cost of each IO operation at the
>>>>> block layer and apply the throttling of async writes in memory only when IO
>>>>> limits are exceeded.
>>>> Andrea, I am curious to know more about it third option. Can you give more
>>>> details about accouting in block layer but throttling in memory. So say 
>>>> a process starts IO, then it will still be in throttle limits at block
>>>> layer (because no writeback has started), then the process will write
>>>> bunch of pages in cache. By the time throttle limits are crossed at
>>>> block layer, we already have lots of dirty data in page cache and
>>>> throttling process now is already late?
>>> Charging the cost of each IO operation at the block layer would allow
>>> tasks to write in memory at the maximum speed. Instead, with the 3rd
>>> approach, tasks are forced to write in memory at the rate defined by the
>>> blkio.throttle.write_*_device (or blkio.throttle.async.write_*_device).
>>>
>>> When we'll have the per-cgroup dirty memory accounting and limiting
>>> feature, with this approach each cgroup could write to its dirty memory
>>> quota at the maximum rate.
>> Ok, so this is option 3 which you have already implemented in this
>> patchset. 
>>
>> I guess then I am confused with option 2. Can you elaborate a little
>> more there.
> 
> With option 3, we can just limit the rate at which dirty pages are
> generated in memory. And this can be done introducing the files
> blkio.throttle.async.write_bps/iops_device.
> 
> At the moment in blk_throtl_bio() we charge the dispatched bytes/iops
> _and_ we check if the bio can be dispatched. These two distinct
> operations are now done by the same function.
> 
> With option 2, I'm proposing to split these two operations and place
> throtl_charge_io() at the block layer in __generic_make_request() and an
> equivalent of tg_may_dispatch_bio() (maybe a better name would be
> blk_is_throttled()) at the page cache layer, in
> balance_dirty_pages_ratelimited_nr():
> 
> A prototype for blk_is_throttled() could be the following:
> 
> bool blk_is_throttled(void);
> 
> This means in balance_dirty_pages_ratelimited_nr() we won't charge any
> bytes/iops to the cgroup, but we'll just check if the limits are
> exceeded. And stop it in that case, so that no more dirty pages can be
> generated by this cgroup.
> 
> Instead at the block layer WRITEs will be always dispatched in
> blk_throtl_bio() (tg_may_dispatch_bio() will always return true), but
> the throtl_charge_io() would charge the cost of the IO operation to the
> right cgroup.
> 
> To summarize:
> 
> __generic_make_request():
> 	blk_throtl_bio(q, &bio);
> 
> balance_dirty_pages_ratelimited_nr():
> 	if (blk_is_throttled())
> 		// add the current task into a per-group wait queue and
> 		// wake up once this cgroup meets its quota
> 
> What do you think?

Hi Andrea,

This means when you throttle writes, the reads issued by this task are also throttled?

Thanks,
Gui

> 
> Thanks,
> -Andrea
> 
