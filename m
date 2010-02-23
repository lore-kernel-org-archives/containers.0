From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] memcg: dirty pages instrumentation
Date: Tue, 23 Feb 2010 10:45:23 +0100
Message-ID: <20100223094523.GD1882__46045.1337894939$1266918419$gmane$org@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-3-git-send-email-arighi@develer.com>
	<20100222165215.GA3096@redhat.com> <20100223094040.GC1882@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100223094040.GC1882@linux>
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

On Tue, Feb 23, 2010 at 10:40:40AM +0100, Andrea Righi wrote:
> > If vm_highmem_is_dirtyable=0, In that case, we can still return with
> > "memcg_memory" which can be more than "memory".  IOW, highmem is not
> > dirtyable system wide but still we can potetially return back saying
> > for this cgroup we can dirty more pages which can potenailly be acutally
> > be more that system wide allowed?
> > 
> > Because you have modified dirtyable_memory() and made it per cgroup, I
> > think it automatically takes care of the cases of per cgroup dirty ratio,
> > I mentioned in my previous mail. So we will use system wide dirty ratio
> > to calculate the allowed dirty pages in this cgroup (dirty_ratio *
> > available_memory()) and if this cgroup wrote too many pages start
> > writeout? 
> 
> OK, if I've understood well, you're proposing to use per-cgroup
> dirty_ratio interface and do something like:
> 
> unsigned long determine_dirtyable_memory(void)
> {
> 	unsigned long memcg_memory, memory;
> 
> 	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> 	if (!vm_highmem_is_dirtyable)
> 		memory -= highmem_dirtyable_memory(memory);
> 
> 	memcg_memory = mem_cgroup_page_state(MEMCG_NR_FREE_PAGES);
> 	if (!memcg_memory)
> 		return memory + 1;      /* Ensure that we never return 0 */
> 	memcg_memory += mem_cgroup_page_state(MEMCG_NR_RECLAIMABLE_PAGES);
> 	if (!vm_highmem_is_dirtyable)
> 		 memcg_memory -= highmem_dirtyable_memory(memory) *
> 					mem_cgroup_dirty_ratio() / 100;

ok, this is wrong:

> 	if (memcg_memory < memory)
> 		return memcg_memory;
> }

	return min(memcg_memory, memory);

-Andrea
