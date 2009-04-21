From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Tue, 21 Apr 2009 22:53:17 +0530
Message-ID: <20090421172317.GM19637__10977.8292746798$1240334920$gmane$org@balbir.in.ibm.com>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-10-git-send-email-righi.andrea@gmail.com>
	<20090417123805.GC7117@mit.edu> <20090417125004.GY4593@kernel.dk>
	<20090417143903.GA30365@linux> <20090421001822.GB19186@mit.edu>
	<20090421083001.GA8441@linux> <20090421140631.GF19186@mit.edu>
	<20090421143130.GA22626@linux> <20090421163537.GI19186@mit.edu>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090421163537.GI19186-3s7WtUTddSA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Gui Jianfeng <guijianfeng-LZPS87bAVCA@public.gmane.org>
List-Id: containers.vger.kernel.org

* Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org> [2009-04-21 12:35:37]:

> On Tue, Apr 21, 2009 at 04:31:31PM +0200, Andrea Righi wrote:
> > 
> > Some months ago I posted a proposal to account, track and limit per
> > cgroup dirty pages in the memory cgroup subsystem:
> > 
> > https://lists.linux-foundation.org/pipermail/containers/2008-September/013140.html
> > 
> > At the moment I'm reworking on a similar and updated version. I know
> > that Kamezawa is also implementing something to account per cgroup dirty
> > pages in memory cgroup.
> > 
> > Moreover, io-throttle v14 already uses the page_cgroup structure to
> > encode into page_cgroup->flags the cgroup ID (io-throttle css_id()
> > actually) that originally dirtied the page.
> > 
> > This should be enough to track dirty pages and charge the right cgroup.
> 
> I'm not convinced this will work that well.  Right now the associating
> a page with a cgroup is done on a very rough basis --- basically,
> whoever touches a page last "owns" the page.  That means if one
> process first tries reading from the cgroup, it will "own" the page.
> This can get quite arbitrary for shared libraries, for example.
> However, while it may be the best that you can do for RSS accounting,
> it gets worse for tracking dirties pages.
> 
> Now if you have processes from one cgroup that always reading from
> some data file, and a process from another cgroup which is updating
> said data file, the writes won't be charged to the correct cgroup.
> 
> So using the same data structures to assign page ownership for RSS
> accounting and page dirtying accounting might not be such a great
> idea.  On the other hand, using a completely different set of data
> structures increases your overhead.
> 
> That being said, it's not obvious to me that trying to track RSS
> ownership on a per-page basis makes sense.  It may not be worth the
> overhead, particularly on a machine with a truly large amount of
> memory.  So for example, tracking on a per vm_area_struct, and
> splitting the cost across cgroups, might be a better way of tracking
> RSS accounting.  But for dirty pages, where there will be much fewer
> such pages, maybe using a per-page scheme makes more sense.  The
> take-home here is that using different mechanisms for tracking RSS
> accounting and dirty page accounting on a per-cgroup basis, with the
> understanding that this will all be horribly rough and non-exact, may
> make a lot of sense.
> 

We need to do this tracking for per cgroup reclaim, we need to track
pages in their own LRU. I've been working on some optimizations not to
track LRU pages for the largest cgroup (or root cgroup mostly) to help
optimize the memory resource controller, but I've not posted them out
yet. We also have a mechanism by which a page reclaimed from one
cgroup, might stay back in the global LRU and get reassigned depending
on usage.

Coming to the dirty page tracking issue, the issue that is being
brought about is the same issue that we have shared page accounting. I
am working on estimates for shared page accounting and it should be
possible to extend it to dirty shared page accounting. Using the
shared ratios for decisions might be a better strategy.


-- 
	Balbir
