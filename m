From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/9] cgroup: io-throttle controller (v13)
Date: Fri, 17 Apr 2009 11:37:44 +0200
Message-ID: <20090417093744.GA8689@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<20090416152433.aaaba300.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090416152433.aaaba300.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Apr 16, 2009 at 03:24:33PM -0700, Andrew Morton wrote:
> On Tue, 14 Apr 2009 22:21:11 +0200
> Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > Objective
> > ~~~~~~~~~
> > The objective of the io-throttle controller is to improve IO performance
> > predictability of different cgroups that share the same block devices.
> 
> We should get an IO controller into Linux.  Does anyone have a reason
> why it shouldn't be this one?
> 
> > Respect to other priority/weight-based solutions the approach used by
> > this controller is to explicitly choke applications' requests
> 
> Yes, blocking the offending application at a high level has always
> seemed to me to be the best way of implementing the controller.
> 
> > that
> > directly or indirectly generate IO activity in the system (this
> > controller addresses both synchronous IO and writeback/buffered IO).
> 
> The problem I've seen with some of the proposed controllers was that
> they didn't handle delayed writeback very well, if at all.
> 
> Can you explain at a high level but in some detail how this works?  If
> an application is doing a huge write(), how is that detected and how is
> the application made to throttle?

The writeback writes are handled in three steps:

1) track the owner of the dirty pages
2) detect writeback IO
3) delay writeback IO that exceeds the cgroup limits

For 1) I barely used the bio-cgroup functionality. The bio-cgroup use
the page_cgroup structure to store the owner of each dirty page when the
page is dirtied. At this point the actual owner of the page can be
retrieved looking at current->mm->owner (i.e. in __set_page_dirty()),
and its bio_cgroup id is stored into the page_cgroup structure.

Then for 2) we can detect writeback IO placing a hook,
cgroup_io_throttle(), in submit_bio():

unsigned long long
cgroup_io_throttle(struct bio *bio, struct block_device *bdev, ssize_t bytes);

If the IO operation is a write we look at the owner of the pages
involved (from bio) and we check if we must throttle the operation. If
the owner of that page is "current", we throttle the current task
directly (via schedule_timeout_killable()) and we just return 0 from
cgroup_io_throttle() after the sleep.

3) If the owner of the page must be throttled and the current task is
not the same task, e.g., it's a kernel thread (current->flags &
(PF_KTHREAD | PF_FLUSHER | PF_KSWAPD)), then we assume it's a writeback
IO and we immediately return the amount of jiffies that the real owner
should sleep.

void submit_bio(int rw, struct bio *bio)
{
...
	if (bio_has_data(bio)) {
		unsigned long sleep = 0;

		if (rw & WRITE) {
			count_vm_events(PGPGOUT, count);
			sleep = cgroup_io_throttle(bio,
					bio->bi_bdev, bio->bi_size);
		} else {
			task_io_account_read(bio->bi_size);
			count_vm_events(PGPGIN, count);
			cgroup_io_throttle(NULL, bio->bi_bdev, bio->bi_size);
		}
...

		if (sleep && !iothrottle_make_request(bio, jiffies + sleep))
			return;
	}

	generic_make_request(bio);
...
}

Since the current task must not be throttled here, we set a deadline
jiffies + sleep and we add this request in a rbtree via
iothrottle_make_request().

This request will be dispatched ansychronously by a kernel thread -
kiothrottled() - using generic_make_request() when the deadline will
expire. There's a lot of space for optimizations here, i.e. use many
threads per block device, workqueue, slow-work, ...

In the old version (v12) I simply throttled writeback IO in
balance_dirty_pages_ratelimited_nr() but this obviously leads to bursty
writebacks. In v13 the writeback IO is hugely more smooth.

> 
> Does it add new metadata to `struct page' for this?

struct page_cgroup

> 
> I assume that the write throttling is also wired up into the MAP_SHARED
> write-fault path?
> 

mmmh.. in case of writeback IO we account and throttle requests for
mm->owner. In case of synchronous IO (read/write) we always throttle the
current task in submit_bio().

> 
> 
> Does this patchset provide a path by which we can implement IO control
> for (say) NFS mounts?

Honestly I didn't looked at all at this. :) I'll check, but in principle
adding the cgroup_io_throttle() hook in the opportune NFS path is enough
to provide IO control also for NFS mounts.

-Andrea
