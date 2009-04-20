From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/9] io-throttle documentation
Date: Mon, 20 Apr 2009 17:28:27 -0400
Message-ID: <20090420212827.GA9080@redhat.com>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-2-git-send-email-righi.andrea@gmail.com>
	<20090417173955.GF29086@redhat.com> <20090417231244.GB6972@linux>
	<20090419134201.GF8493@redhat.com> <20090419154717.GB5514@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090419154717.GB5514@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, KAMEZ
List-Id: containers.vger.kernel.org

On Sun, Apr 19, 2009 at 05:47:18PM +0200, Andrea Righi wrote:
> On Sun, Apr 19, 2009 at 09:42:01AM -0400, Vivek Goyal wrote:
> > > The difference between synchronous IO and writeback IO is that in the
> > > first case the task itself is throttled via schedule_timeout_killable();
> > > in the second case pdflush is never throttled, the IO requests instead
> > > are simply added into a rbtree and dispatched asynchronously by another
> > > kernel thread (kiothrottled) using a EDF-like scheduling. More exactly,
> > > a deadline is evaluated for each writeback IO request looking at the
> > > cgroup BW and iops/sec limits, then kiothrottled periodically selects
> > > and dispatches the requests with an elapsed deadline.
> > > 
> > 
> > Ok, i will look into the logic of translating cgroup BW limits into
> > deadline. But as Nauman pointed out that we probably will run into 
> > issues of tasks with in cgroup as we loose that notion of class and prio.
> 
> Correct. I've not addressed the IO class and priority inside cgroup, and
> there is a lot of space for optimizations and tunings for this in the
> io-throttle controller. In the current implementation the delay is only
> imposed to the first task that hits the BW limit. This is not fair at
> all.
> 
> Ideally the throttling should be distributed equally among the tasks
> within the same cgroup that exhaust the available BW. With equally I
> mean depending of a function of the previous generated IO, class and IO
> priority.
> 
> The same concept of fairness (for ioprio and class) will be reflected to
> the underlying IO scheduler (only CFQ at the moment) for the requests
> that passed the BW limits.
> 
> This doesn't seem a bad idea, well.. at least in theory... :) Do you see
> evident weak points? or motivations to move to another direction?
> 
> > 
> > > > 
> > > > If that's the case, will a process not see an increased rate of writes
> > > > till we are not hitting dirty_background_ratio?
> > > 
> > > Correct. And this is a good behaviour IMHO. At the same time we have a
> > > smooth BW usage (according to the cgroup limits I mean) even in presence
> > > of writeback IO only.
> > > 
> > 
> > Hmm.., I am not able to understand this. The very fact that you will see
> > a high rate of async writes (more than specified by cgroup max BW), till
> > you hit dirty_background_ratio, isn't it against the goals of max bw
> > controller? You wanted to see a consistent view of rate even if spare BW
> > is available, and this scenario goes against that? 
> 
> The goal of the io-throttle controller is to guarantee a constant BW for
> the IO to the block devices. If you write data in cache, buffers, etc.
> you shouldn't be affected by any IO limitation, but you will be when the
> data is be written out to the disk.
> 
> OTOH if an application needs a predictable IO BW, we can always set a
> max limit and use direct IO.
> 
> > 
> > Think of an hypothetical configuration of 10G RAM with dirty ratio say
> > set to 20%. Assume not much of write out is taking place in the system.
> > So for first 2G of writes, application will be able to write it at cpu
> > speed and no throttling will kick in and a cgroup will easily cross it
> > max BW? 
> 
> Yes.
> 
> >   
> > > > 
> > > > Secondly, if above is giving acceptable performance resutls, then we
> > > > should be able to provide max bw control at IO scheduler level (along
> > > > with proportional bw control)?
> > > > 
> > > > So instead of doing max bw and proportional bw implementation in two
> > > > places with the help of different controllers, I think we can do it
> > > > with the help of one controller at one place. 
> > > > 
> > > > Please do have a look at my patches also to figure out if that's possible
> > > > or not. I think it should be possible.
> > > > 
> > > > Keeping both at single place should simplify the things.
> > > 
> > > Absolutely agree to do both proportional and max BW limiting in a single
> > > place. I still need to figure which is the best place, if the IO
> > > scheduler in the elevator, when the IO requests are submitted. A natural
> > > way IMHO is to control the submission of requests, also Andrew seemed to
> > > be convinced about this approach. Anyway, I've already scheduled to test
> > > your patchset and I'd like to see if it's possible to merge our works,
> > > or select the best from ours patchsets.
> > > 
> > 
> > Are we not already controlling submission of request (at crude level).
> > If application is doing writeout at high rate, then it hits vm_dirty_ratio
> > hits and this application is forced to do write out and hence it is slowed
> > down and is not allowed to submit writes at high rate.
> > 
> > Just that it is not a very fair scheme right now as during right out
> > a high prio/high weight cgroup application can start writing out some
> > other cgroups' pages.
> > 
> > For this we probably need to have some combination of solutions like
> > per cgroup upper limit on dirty pages. Secondly probably if an application
> > is slowed down because of hitting vm_drity_ratio, it should try to
> > write out the inode it is dirtying first instead of picking any random
> > inode and associated pages. This will ensure that a high weight
> > application can quickly get through the write outs and see higher
> > throughput from the disk.
> 
> For the first, I submitted a patchset some months ago to provide this
> feature in the memory controller:
> 
> https://lists.linux-foundation.org/pipermail/containers/2008-September/013140.html
> 
> We focused on the best interface to use for setting the dirty pages
> limit, but we didn't finalize it. I can rework on that and repost an
> updated version. Now that we have the dirty_ratio/dirty_bytes to set the
> global limit I think we can use the same interface and the same semantic
> within the cgroup fs, something like:
> 
>   memory.dirty_ratio
>   memory.dirty_bytes
> 
> For the second point something like this should be enough to force tasks
> to write out only the inode they're actually dirtying when they hit the
> vm_dirty_ratio limit. But it should be tested carefully and may cause
> heavy performance regressions.
> 
> Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  mm/page-writeback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 2630937..1e07c9d 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -543,7 +543,7 @@ static void balance_dirty_pages(struct address_space *mapping)
>  		 * been flushed to permanent storage.
>  		 */
>  		if (bdi_nr_reclaimable) {
> -			writeback_inodes(&wbc);
> +			sync_inode(mapping->host, &wbc);
>  			pages_written += write_chunk - wbc.nr_to_write;
>  			get_dirty_limits(&background_thresh, &dirty_thresh,
>  				       &bdi_thresh, bdi);

This patch seems to be helping me a bit in getting more service
differentiation between two writer dd of different weights. But strangely
it is helping only for ext3 and not ext4. Debugging is on.

Thanks
Vivek
