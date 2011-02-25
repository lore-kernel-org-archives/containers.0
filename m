From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/5] page_cgroup: make page tracking available for blkio
Date: Fri, 25 Feb 2011 01:48:05 +0100
Message-ID: <20110225004805.GA3044__41879.5559708544$1298594995$gmane$org@linux.develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-4-git-send-email-arighi@develer.com>
	<20110222130145.37cb151e@bike.lwn.net>
	<20110222230146.GB23723@linux.develer.com>
	<20110222230630.GL28269@redhat.com>
	<20110222233718.GF23723@linux.develer.com>
	<20110223134910.abbdc931.kamezawa.hiroyu@jp.fujitsu.com>
	<20110223085911.GC2174@linux.develer.com>
	<20110224085805.14766e93.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110224085805.14766e93.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Feb 24, 2011 at 08:58:05AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Feb 2011 09:59:11 +0100
> Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > > 
> > > I wonder I can make pc->mem_cgroup to be pc->memid(16bit), then, 
> > > ==
> > > static inline struct mem_cgroup *get_memcg_from_pc(struct page_cgroup *pc)
> > > {
> > >     struct cgroup_subsys_state *css = css_lookup(&mem_cgroup_subsys, pc->memid);
> > >     return container_of(css, struct mem_cgroup, css);
> > > }
> > > ==
> > > Overhead will be seen at updating file statistics and LRU management.
> > > 
> > > But, hmm, can't you do that tracking without page_cgroup ?
> > > Because the number of dirty/writeback pages are far smaller than total pages,
> > > chasing I/O with dynamic structure is not very bad..
> > > 
> > > prepareing [pfn -> blkio] record table and move that information to struct bio
> > > in dynamic way is very difficult ?
> > 
> > This would be ok for dirty pages, but consider that we're also tracking
> > anonymous pages. So, if we want to control the swap IO we actually need
> > to save this information for a lot of pages and at the end I think we'll
> > basically duplicate the page_cgroup code.
> > 
> 
> swap io is always started with bio and the task/mm_struct.
> So, if we can record information in bio, no page tracking is required.
> You can record information to bio just by reading mm->owner.

OK, you're right. And BTW probably swap io control is not a feature that
we need immediately. Moreover, as also said in the previous email with
Vivek, it seems we can even get rid of the page tracking stuff for now
and try to implement async write control at the time pages are written
in memory. I'm going forward to add this logic to the blk-throttle
controller.

Thanks,
-Andrea
