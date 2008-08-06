From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Date: Wed,  6 Aug 2008 18:10:05 +0900 (JST)
Message-ID: <20080806091005.B883A5A7B@siro.lan>
References: <20080806175352.6330c00a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Wed, 6 Aug 2008 17:53:52 +0900"
	<20080806175352.6330c00a.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

hi,

> On Wed,  6 Aug 2008 17:20:46 +0900 (JST)
> yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:
> 
> > hi,
> > 
> > > On Fri, 11 Jul 2008 17:34:46 +0900 (JST)
> > > yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:
> > > 
> > > > hi,
> > > > 
> > > > > > my patch penalizes heavy-writer cgroups as task_dirty_limit does
> > > > > > for heavy-writer tasks.  i don't think that it's necessary to be
> > > > > > tied to the memory subsystem because i merely want to group writers.
> > > > > > 
> > > > > Hmm, maybe what I need is different from this ;)
> > > > > Does not seem to be a help for memory reclaim under memcg.
> > > > 
> > > > to implement what you need, i think that we need to keep track of
> > > > the numbers of dirty-pages in each memory cgroups as a first step.
> > > > do you agree?
> > > > 
> > > yes, I think so, now.
> > > 
> > > may be not difficult but will add extra overhead ;( Sigh..
> > 
> > the following is a patch to add the overhead. :)
> > any comments?
> > 
> Do you have some numbers ? ;) 

not yet.

> I like this because this seems very straightforward. thank you.

good to hear.

> How about changing these to be
> 
> ==
> void mem_cgroup_test_set_page_dirty()
> {
> 	if (try_lock_page_cgroup(pg)) {
> 		pc = page_get_page_cgroup(pg);
> 		if (pc ......) {
> 		}
> 		unlock_page_cgroup(pg)
> 	}
> }
> ==

i'm not sure how many opportunities to update statistics
we would lose for the trylock failure.
although the statistics don't need to be too precise,
its error should have a reasonable upper-limit to be useful.

> Off-topic: I wonder we can delete this "lock" in future.
> 
> Because page->page_cgroup is
>  1. attached at first use.(Obiously no race with set_dirty)
>  2. deleted at removal. (force_empty is problematic here..)

i hope it's possible. :)

YAMAMOTO Takashi

> 
> But, now, we need this lock.
> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
