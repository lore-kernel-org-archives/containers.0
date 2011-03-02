From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] blk-throttle: async write throttling
Date: Wed, 2 Mar 2011 16:47:05 -0500
Message-ID: <20110302214705.GD2547__15782.8985401013$1299102604$gmane$org@redhat.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
	<20110228230114.GB20845@redhat.com>
	<20110302132830.GB2061@linux.develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110302132830.GB2061-fxUVXftIFDlZdMzt4l2sLQC/G2K4zDHf@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 02, 2011 at 02:28:30PM +0100, Andrea Righi wrote:
> On Mon, Feb 28, 2011 at 06:01:14PM -0500, Vivek Goyal wrote:
> > On Mon, Feb 28, 2011 at 11:15:02AM +0100, Andrea Righi wrote:
> > > Overview
> > > ========
> > > Currently the blkio.throttle controller only support synchronous IO requests.
> > > This means that we always look at the current task to identify the "owner" of
> > > each IO request.
> > > 
> > > However dirty pages in the page cache can be wrote to disk asynchronously by
> > > the per-bdi flusher kernel threads or by any other thread in the system,
> > > according to the writeback policy.
> > > 
> > > For this reason the real writes to the underlying block devices may
> > > occur in a different IO context respect to the task that originally
> > > generated the dirty pages involved in the IO operation. This makes the
> > > tracking and throttling of writeback IO more complicate respect to the
> > > synchronous IO from the blkio controller's perspective.
> > > 
> > > Proposed solution
> > > =================
> > > In the previous patch set http://lwn.net/Articles/429292/ I proposed to resolve
> > > the problem of the buffered writes limitation by tracking the ownership of all
> > > the dirty pages in the system.
> > > 
> > > This would allow to always identify the owner of each IO operation at the block
> > > layer and apply the appropriate throttling policy implemented by the
> > > blkio.throttle controller.
> > > 
> > > This solution makes the blkio.throttle controller to work as expected also for
> > > writeback IO, but it does not resolve the problem of faster cgroups getting
> > > blocked by slower cgroups (that would expose a potential way to create DoS in
> > > the system).
> > > 
> > > In fact, at the moment critical IO requests (that have dependency with other IO
> > > requests made by other cgroups) and non-critical requests are mixed together at
> > > the filesystem layer in a way that throttling a single write request may stop
> > > also other requests in the system, and at the block layer it's not possible to
> > > retrieve such informations to make the right decision.
> > > 
> > > A simple solution to this problem could be to just limit the rate of async
> > > writes at the time a task is generating dirty pages in the page cache. The
> > > big advantage of this approach is that it does not need the overhead of
> > > tracking the ownership of the dirty pages, because in this way from the blkio
> > > controller perspective all the IO operations will happen from the process
> > > context: writes in memory and synchronous reads from the block device.
> > > 
> > > The drawback of this approach is that the blkio.throttle controller becomes a
> > > little bit leaky, because with this solution the controller is still affected
> > > by the IO spikes during the writeback of dirty pages executed by the kernel
> > > threads.
> > > 
> > > Probably an even better approach would be to introduce the tracking of the
> > > dirty page ownership to properly account the cost of each IO operation at the
> > > block layer and apply the throttling of async writes in memory only when IO
> > > limits are exceeded.
> > 
> > Andrea, I am curious to know more about it third option. Can you give more
> > details about accouting in block layer but throttling in memory. So say 
> > a process starts IO, then it will still be in throttle limits at block
> > layer (because no writeback has started), then the process will write
> > bunch of pages in cache. By the time throttle limits are crossed at
> > block layer, we already have lots of dirty data in page cache and
> > throttling process now is already late?
> 
> Charging the cost of each IO operation at the block layer would allow
> tasks to write in memory at the maximum speed. Instead, with the 3rd
> approach, tasks are forced to write in memory at the rate defined by the
> blkio.throttle.write_*_device (or blkio.throttle.async.write_*_device).
> 
> When we'll have the per-cgroup dirty memory accounting and limiting
> feature, with this approach each cgroup could write to its dirty memory
> quota at the maximum rate.

Ok, so this is option 3 which you have already implemented in this
patchset. 

I guess then I am confused with option 2. Can you elaborate a little
more there.

> 
> BTW, another thing that we probably need is that any cgroup should be
> forced to write their own inodes when the limit defined by dirty_ratio
> is exceeded. I mean, avoid to select inodes from the list of dirty
> inodes in a FIFO way, but provides a better logic to "assign" the
> ownership of each inode to a cgroup (maybe that one that had generated
> most of the dirty pages in the inodes) and use for example a list of
> dirty inodes per cgroup or something similar.
> 
> In this way we should really be able to provide a good quality of
> service for the most part of the cases IMHO.
> 
> I also plan to write down another patch set to implement this logic.

Yes, triggering writeout of inodes of a cgroup once it crosses dirty
ratio is desirable. A patch like that can go on top of Greg's per cgroup
dirty ratio patacehes.

Thanks
Vivek
