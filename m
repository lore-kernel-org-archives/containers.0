From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/5] blk-throttle: track buffered and anonymous pages
Date: Tue, 22 Feb 2011 19:07:19 -0500
Message-ID: <20110223000718.GN28269__22209.4066128649$1298419816$gmane$org@redhat.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-5-git-send-email-arighi@develer.com>
	<20110222210030.GI28269@redhat.com>
	<20110222230534.GD23723@linux.develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110222230534.GD23723-fxUVXftIFDlZdMzt4l2sLQC/G2K4zDHf@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 23, 2011 at 12:05:34AM +0100, Andrea Righi wrote:
> On Tue, Feb 22, 2011 at 04:00:30PM -0500, Vivek Goyal wrote:
> > On Tue, Feb 22, 2011 at 06:12:55PM +0100, Andrea Righi wrote:
> > > Add the tracking of buffered (writeback) and anonymous pages.
> > > 
> > > Dirty pages in the page cache can be processed asynchronously by the
> > > per-bdi flusher kernel threads or by any other thread in the system,
> > > according to the writeback policy.
> > > 
> > > For this reason the real writes to the underlying block devices may
> > > occur in a different IO context respect to the task that originally
> > > generated the dirty pages involved in the IO operation. This makes
> > > the tracking and throttling of writeback IO more complicate respect to
> > > the synchronous IO from the blkio controller's point of view.
> > > 
> > > The idea is to save the cgroup owner of each anonymous page and dirty
> > > page in page cache. A page is associated to a cgroup the first time it
> > > is dirtied in memory (for file cache pages) or when it is set as
> > > swap-backed (for anonymous pages). This information is stored using the
> > > page_cgroup functionality.
> > > 
> > > Then, at the block layer, it is possible to retrieve the throttle group
> > > looking at the bio_page(bio). If the page was not explicitly associated
> > > to any cgroup the IO operation is charged to the current task/cgroup, as
> > > it was done by the previous implementation.
> > > 
> > > Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> > > ---
> > >  block/blk-throttle.c   |   87 +++++++++++++++++++++++++++++++++++++++++++++++-
> > >  include/linux/blkdev.h |   26 ++++++++++++++-
> > >  2 files changed, 111 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/block/blk-throttle.c b/block/blk-throttle.c
> > > index 9ad3d1e..a50ee04 100644
> > > --- a/block/blk-throttle.c
> > > +++ b/block/blk-throttle.c
> > > @@ -8,6 +8,10 @@
> > >  #include <linux/slab.h>
> > >  #include <linux/blkdev.h>
> > >  #include <linux/bio.h>
> > > +#include <linux/memcontrol.h>
> > > +#include <linux/mm_inline.h>
> > > +#include <linux/pagemap.h>
> > > +#include <linux/page_cgroup.h>
> > >  #include <linux/blktrace_api.h>
> > >  #include <linux/blk-cgroup.h>
> > >  
> > > @@ -221,6 +225,85 @@ done:
> > >  	return tg;
> > >  }
> > >  
> > > +static inline bool is_kernel_io(void)
> > > +{
> > > +	return !!(current->flags & (PF_KTHREAD | PF_KSWAPD | PF_MEMALLOC));
> > > +}
> > > +
> > > +static int throtl_set_page_owner(struct page *page, struct mm_struct *mm)
> > > +{
> > > +	struct blkio_cgroup *blkcg;
> > > +	unsigned short id = 0;
> > > +
> > > +	if (blkio_cgroup_disabled())
> > > +		return 0;
> > > +	if (!mm)
> > > +		goto out;
> > > +	rcu_read_lock();
> > > +	blkcg = task_to_blkio_cgroup(rcu_dereference(mm->owner));
> > > +	if (likely(blkcg))
> > > +		id = css_id(&blkcg->css);
> > > +	rcu_read_unlock();
> > > +out:
> > > +	return page_cgroup_set_owner(page, id);
> > > +}
> > > +
> > > +int blk_throtl_set_anonpage_owner(struct page *page, struct mm_struct *mm)
> > > +{
> > > +	return throtl_set_page_owner(page, mm);
> > > +}
> > > +EXPORT_SYMBOL(blk_throtl_set_anonpage_owner);
> > > +
> > > +int blk_throtl_set_filepage_owner(struct page *page, struct mm_struct *mm)
> > > +{
> > > +	if (is_kernel_io() || !page_is_file_cache(page))
> > > +		return 0;
> > > +	return throtl_set_page_owner(page, mm);
> > > +}
> > > +EXPORT_SYMBOL(blk_throtl_set_filepage_owner);
> > 
> > Why are we exporting all these symbols?
> 
> Right. Probably a single one is enough:
> 
>  int blk_throtl_set_page_owner(struct page *page,
> 			struct mm_struct *mm, bool anon);

Who is going to use this single export? Which module?

Thanks
Vivek
