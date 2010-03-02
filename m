From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Tue, 2 Mar 2010 18:59:32 -0500
Message-ID: <20100302235932.GA3007__16727.6863278405$1267574473$gmane$org@redhat.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100301220208.GH3109@redhat.com> <20100301221830.GA5460@linux>
	<20100302150529.GA12855@redhat.com> <20100302222248.GD2369@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100302222248.GD2369@linux>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 02, 2010 at 11:22:48PM +0100, Andrea Righi wrote:
> On Tue, Mar 02, 2010 at 10:05:29AM -0500, Vivek Goyal wrote:
> > On Mon, Mar 01, 2010 at 11:18:31PM +0100, Andrea Righi wrote:
> > > On Mon, Mar 01, 2010 at 05:02:08PM -0500, Vivek Goyal wrote:
> > > > > @@ -686,10 +699,14 @@ void throttle_vm_writeout(gfp_t gfp_mask)
> > > > >                   */
> > > > >                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
> > > > >  
> > > > > -                if (global_page_state(NR_UNSTABLE_NFS) +
> > > > > -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> > > > > -                        	break;
> > > > > -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> > > > > +
> > > > > +		dirty = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
> > > > > +		if (dirty < 0)
> > > > > +			dirty = global_page_state(NR_UNSTABLE_NFS) +
> > > > > +				global_page_state(NR_WRITEBACK);
> > > > 
> > > > dirty is unsigned long. As mentioned last time, above will never be true?
> > > > In general these patches look ok to me. I will do some testing with these.
> > > 
> > > Re-introduced the same bug. My bad. :(
> > > 
> > > The value returned from mem_cgroup_page_stat() can be negative, i.e.
> > > when memory cgroup is disabled. We could simply use a long for dirty,
> > > the unit is in # of pages so s64 should be enough. Or cast dirty to long
> > > only for the check (see below).
> > > 
> > > Thanks!
> > > -Andrea
> > > 
> > > Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> > > ---
> > >  mm/page-writeback.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > > index d83f41c..dbee976 100644
> > > --- a/mm/page-writeback.c
> > > +++ b/mm/page-writeback.c
> > > @@ -701,7 +701,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
> > >  
> > >  
> > >  		dirty = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
> > > -		if (dirty < 0)
> > > +		if ((long)dirty < 0)
> > 
> > This will also be problematic as on 32bit systems, your uppper limit of
> > dirty memory will be 2G?
> > 
> > I guess, I will prefer one of the two.
> > 
> > - return the error code from function and pass a pointer to store stats
> >   in as function argument.
> > 
> > - Or Peter's suggestion of checking mem_cgroup_has_dirty_limit() and if
> >   per cgroup dirty control is enabled, then use per cgroup stats. In that
> >   case you don't have to return negative values.
> > 
> >   Only tricky part will be careful accouting so that none of the stats go
> >   negative in corner cases of migration etc.
> 
> What do you think about Peter's suggestion + the locking stuff? (see the
> previous email). Otherwise, I'll choose the other solution, passing a
> pointer and always return the error code is not bad.
> 

Ok, so you are worried about that by the we finish mem_cgroup_has_dirty_limit()
call, task might change cgroup and later we might call
mem_cgroup_get_page_stat() on a different cgroup altogether which might or
might not have dirty limits specified?

But in what cases you don't want to use memory cgroup specified limit? I
thought cgroup disabled what the only case where we need to use global
limits. Otherwise a memory cgroup will have either dirty_bytes specified
or by default inherit global dirty_ratio which is a valid number. If
that's the case then you don't have to take rcu_lock() outside
get_page_stat()?

IOW, apart from cgroup being disabled, what are the other cases where you
expect to not use cgroup's page stat and use global stats?

Thanks
Vivek

> Thanks,
> -Andrea
