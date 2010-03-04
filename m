From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 4/4] memcg: dirty pages instrumentation
Date: Thu, 4 Mar 2010 17:28:58 +0100
Message-ID: <20100304162858.GE4566__7889.71416554904$1267720370$gmane$org@linux>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
	<1267699215-4101-5-git-send-email-arighi@develer.com>
	<20100304161828.GC18786@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100304161828.GC18786-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 04, 2010 at 11:18:28AM -0500, Vivek Goyal wrote:
> On Thu, Mar 04, 2010 at 11:40:15AM +0100, Andrea Righi wrote:
> 
> [..]
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 5a0f8f3..c5d14ea 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -137,13 +137,16 @@ static struct prop_descriptor vm_dirties;
> >   */
> >  static int calc_period_shift(void)
> >  {
> > +	struct dirty_param dirty_param;
> >  	unsigned long dirty_total;
> >  
> > -	if (vm_dirty_bytes)
> > -		dirty_total = vm_dirty_bytes / PAGE_SIZE;
> > +	get_dirty_param(&dirty_param);
> > +
> > +	if (dirty_param.dirty_bytes)
> > +		dirty_total = dirty_param.dirty_bytes / PAGE_SIZE;
> >  	else
> > -		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> > -				100;
> > +		dirty_total = (dirty_param.dirty_ratio *
> > +				determine_dirtyable_memory()) / 100;
> >  	return 2 + ilog2(dirty_total - 1);
> >  }
> >  
> > @@ -408,41 +411,46 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
> >   */
> >  unsigned long determine_dirtyable_memory(void)
> >  {
> > -	unsigned long x;
> > -
> > -	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> > +	unsigned long memory;
> > +	s64 memcg_memory;
> >  
> > +	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> >  	if (!vm_highmem_is_dirtyable)
> > -		x -= highmem_dirtyable_memory(x);
> > -
> > -	return x + 1;	/* Ensure that we never return 0 */
> > +		memory -= highmem_dirtyable_memory(memory);
> > +	if (mem_cgroup_has_dirty_limit())
> > +		return memory + 1;
> 
> Should above be?
> 	if (!mem_cgroup_has_dirty_limit())
> 		return memory + 1;

Very true.

I'll post another patch with this and Kirill's fixes.

Thanks,
-Andrea

> 
> Vivek
> 
> > +	memcg_memory = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
> > +	return min((unsigned long)memcg_memory, memory + 1);
> >  }
