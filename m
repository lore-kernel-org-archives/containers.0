From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] memcg: dirty pages instrumentation
Date: Tue, 23 Feb 2010 10:40:40 +0100
Message-ID: <20100223094040.GC1882__32466.508067637$1266918082$gmane$org@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-3-git-send-email-arighi@develer.com>
	<20100222165215.GA3096@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100222165215.GA3096-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 22, 2010 at 11:52:15AM -0500, Vivek Goyal wrote:
> >  unsigned long determine_dirtyable_memory(void)
> >  {
> > -	unsigned long x;
> > -
> > -	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> > -
> > +	unsigned long memcg_memory, memory;
> > +
> > +	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> > +	memcg_memory = mem_cgroup_page_state(MEMCG_NR_FREE_PAGES);
> > +	if (memcg_memory > 0) {
> 
> it could be just 
> 
> 	if (memcg_memory) {

Agreed.

> 	}
> 
> > +		memcg_memory +=
> > +			mem_cgroup_page_state(MEMCG_NR_RECLAIMABLE_PAGES);
> > +		if (memcg_memory < memory)
> > +			return memcg_memory;
> > +	}
> >  	if (!vm_highmem_is_dirtyable)
> > -		x -= highmem_dirtyable_memory(x);
> > +		memory -= highmem_dirtyable_memory(memory);
> >  
> 
> If vm_highmem_is_dirtyable=0, In that case, we can still return with
> "memcg_memory" which can be more than "memory".  IOW, highmem is not
> dirtyable system wide but still we can potetially return back saying
> for this cgroup we can dirty more pages which can potenailly be acutally
> be more that system wide allowed?
> 
> Because you have modified dirtyable_memory() and made it per cgroup, I
> think it automatically takes care of the cases of per cgroup dirty ratio,
> I mentioned in my previous mail. So we will use system wide dirty ratio
> to calculate the allowed dirty pages in this cgroup (dirty_ratio *
> available_memory()) and if this cgroup wrote too many pages start
> writeout? 

OK, if I've understood well, you're proposing to use per-cgroup
dirty_ratio interface and do something like:

unsigned long determine_dirtyable_memory(void)
{
	unsigned long memcg_memory, memory;

	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
	if (!vm_highmem_is_dirtyable)
		memory -= highmem_dirtyable_memory(memory);

	memcg_memory = mem_cgroup_page_state(MEMCG_NR_FREE_PAGES);
	if (!memcg_memory)
		return memory + 1;      /* Ensure that we never return 0 */
	memcg_memory += mem_cgroup_page_state(MEMCG_NR_RECLAIMABLE_PAGES);
	if (!vm_highmem_is_dirtyable)
		 memcg_memory -= highmem_dirtyable_memory(memory) *
					mem_cgroup_dirty_ratio() / 100;
	if (memcg_memory < memory)
		return memcg_memory;
}


> 
> > -	return x + 1;	/* Ensure that we never return 0 */
> > +	return memory + 1;	/* Ensure that we never return 0 */
> >  }
> >  
> >  void
> > @@ -421,12 +428,13 @@ get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
> >  		 unsigned long *pbdi_dirty, struct backing_dev_info *bdi)
> >  {
> >  	unsigned long background;
> > -	unsigned long dirty;
> > +	unsigned long dirty, dirty_bytes;
> >  	unsigned long available_memory = determine_dirtyable_memory();
> >  	struct task_struct *tsk;
> >  
> > -	if (vm_dirty_bytes)
> > -		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> > +	dirty_bytes = mem_cgroup_dirty_bytes();
> > +	if (dirty_bytes)
> > +		dirty = DIV_ROUND_UP(dirty_bytes, PAGE_SIZE);
> >  	else {
> >  		int dirty_ratio;
> >  
> > @@ -505,9 +513,17 @@ static void balance_dirty_pages(struct address_space *mapping,
> >  		get_dirty_limits(&background_thresh, &dirty_thresh,
> >  				&bdi_thresh, bdi);
> >  
> > -		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> > +		nr_reclaimable = mem_cgroup_page_state(MEMCG_NR_FILE_DIRTY);
> > +		if (nr_reclaimable == 0) {
> > +			nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> >  					global_page_state(NR_UNSTABLE_NFS);
> > -		nr_writeback = global_page_state(NR_WRITEBACK);
> > +			nr_writeback = global_page_state(NR_WRITEBACK);
> > +		} else {
> > +			nr_reclaimable +=
> > +				mem_cgroup_page_state(MEMCG_NR_UNSTABLE_NFS);
> > +			nr_writeback =
> > +				mem_cgroup_page_state(MEMCG_NR_WRITEBACK);
> > +		}
> >  
> >  		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> >  		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> > @@ -660,6 +676,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
> >  	unsigned long dirty_thresh;
> >  
> >          for ( ; ; ) {
> > +		unsigned long dirty;
> > +
> >  		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
> >  
> >                  /*
> > @@ -668,10 +686,15 @@ void throttle_vm_writeout(gfp_t gfp_mask)
> >                   */
> >                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
> >  
> > -                if (global_page_state(NR_UNSTABLE_NFS) +
> > -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> > -                        	break;
> > -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +		dirty = mem_cgroup_page_state(MEMCG_NR_WRITEBACK);
> > +		if (dirty < 0)
> 
> dirty is unsigned long. Will above condition be ever true? 
> 
> Are you expecting that NR_WRITEBACK can go negative?

No, this is a bug, indeed. The right check is just "if (dirty)".

Thanks!
-Andrea
