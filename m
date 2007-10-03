From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [BUGFIX][RFC][PATCH][only -mm] FIX memory leak in memory cgroup
 vs. page migration [1/1] fix page migration under memory contoller
Date: Wed, 3 Oct 2007 09:53:16 +0900
Message-ID: <20071003095316.4fff115e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071002183031.3352be6a.kamezawa.hiroyu@jp.fujitsu.com>
	<20071002183306.0c132ff4.kamezawa.hiroyu@jp.fujitsu.com>
	<47026510.2000708@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47026510.2000708-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 02 Oct 2007 21:04:40 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > While using memory control cgroup, page-migration under it works as following.
> > ==
> >  1. uncharge all refs at try to unmap.
> >  2. charge regs again remove_migration_ptes()
> > ==
> > This is simple but has following problems.
> > ==
> >  The page is uncharged and chaged back again if *mapped*.
> >     - This means that cgroup before migraion can be different from one after
> >       migraion
> 
> >From the test case mentioned earlier, this happens because the task has
> moved from one cgroup to another, right?
Ah, yes.


> > And migration can migrate *not mapped* pages in future by migration-by-kernel
> > driven by memory-unplug and defragment-by-migration at el.
> > 
> > This patch tries to keep memory cgroup at page migration by increasing
> > one refcnt during it. 3 functions are added.
> >  mem_cgroup_prepare_migration() --- increase refcnt of page->page_cgroup
> >  mem_cgroup_end_migration()     --- decrease refcnt of page->page_cgroup
> >  mem_cgroup_page_migration() --- copy page->page_cgroup from old page to
> >                                  new page.
> > 
> > Obviously, mem_cgroup_isolate_pages() and this page migration, which
> > copies page_cgroup from old page to new page, has race.
> > 
> > There seem to be  3 ways for avoiding this race.
> >  A. take mem_group->lock while mem_cgroup_page_migration().
> >  B. isolate pc from mem_cgroup's LRU when we isolate page from zone's LRU.
> >  C. ignore non-LRU page at mem_cgroup_isolate_pages(). 
> > 
> > This patch uses method (C.) and modifes mem_cgroup_isolate_pages() igonres
> > !PageLRU pages.
> > 
> 
> The page(s) is(are) !PageLRU only during page migration right?
> 
Hmm...!PageLRU() means that page is not on LRU.
Then, kswapd can remove a page from LRU.

> > -		if (page_zone(page) != z)
> > +		if (page_zone(page) != z || !PageLRU(page)) {
> 
> I would prefer to do unlikely(!PageLRU(page)), since most of the
> times the page is not under migration
> 
I see.

> > +			/* Skip this */
> > +			/* Don't decrease scan here for avoiding dead lock */
> 
> Could we merge the two comments to one block comment?
> 
will do

> >  			continue;
> > +		}
> > 
> >  		/*
> >  		 * Check if the meta page went away from under us
> > @@ -417,8 +424,14 @@ void mem_cgroup_uncharge(struct page_cgr
> >  		return;
> > 
> >  	if (atomic_dec_and_test(&pc->ref_cnt)) {
> > +retry:
> >  		page = pc->page;
> >  		lock_page_cgroup(page);
> > +		/* migration occur ? */
> > +		if (page_get_page_cgroup(page) != pc) {
> > +			unlock_page_cgroup(page);
> > +			goto retry;
> 
> Shouldn't we check if page_get_page_cgroup(page) returns
> NULL, if so, unlock and return?
Hmm, I think page_get_page_cgroup(page) != pc covers it. pc is not NULL.

Thanks,
-Kame
