From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] memory cgroup enhancements updated [10/10] NUMA
 aware account
Date: Thu, 25 Oct 2007 00:53:04 +0900
Message-ID: <20071025005304.ba1e373c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071019182436.485e20cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20071019183730.a6e8c105.kamezawa.hiroyu@jp.fujitsu.com>
	<471F5DBC.2070303@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <471F5DBC.2070303-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 24 Oct 2007 20:29:08 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> > +	for_each_possible_cpu(cpu) {
> > +		int nid = cpu_to_node(cpu);
> > +		struct mem_cgroup_stat_cpu *mcsc;
> > +		if (sizeof(*mcsc) < PAGE_SIZE)
> > +			mcsc = kmalloc_node(sizeof(*mcsc), GFP_KERNEL, nid);
> > +		else
> > +			mcsc = vmalloc_node(sizeof(*mcsc), nid);
> 
> Do we need to use the vmalloc() pool? I think we might be better off
> using a dedicated slab for ourselves
> 
I admit this part is complicated. But ia64's MAX_NUMNODES=1024 and stat
can be increased. we need vmalloc. I'll rewrite this part to be
better looking.

> > +		memset(mcsc, 0, sizeof(*mcsc));
> > +		mem->stat.cpustat[cpu] = mcsc;
> > +	}
> >  	return &mem->css;
> >  }
> > 
> > @@ -969,7 +1006,15 @@ static void mem_cgroup_pre_destroy(struc
> >  static void mem_cgroup_destroy(struct cgroup_subsys *ss,
> >  				struct cgroup *cont)
> >  {
> > -	kfree(mem_cgroup_from_cont(cont));
> > +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> > +	int cpu;
> > +	for_each_possible_cpu(cpu) {
> > +		if (sizeof(struct mem_cgroup_stat_cpu) < PAGE_SIZE)
> > +			kfree(mem->stat.cpustat[cpu]);
> > +		else
> > +			vfree(mem->stat.cpustat[cpu]);
> > +	}
> > +	kfree(mem);
> >  }
> > 
> >  static int mem_cgroup_populate(struct cgroup_subsys *ss,
> > @@ -1021,5 +1066,5 @@ struct cgroup_subsys mem_cgroup_subsys =
> >  	.destroy = mem_cgroup_destroy,
> >  	.populate = mem_cgroup_populate,
> >  	.attach = mem_cgroup_move_task,
> > -	.early_init = 1,
> > +	.early_init = 0,
> 
> I don't understand why this change is required here?
> 
If early_init = 1, we cannot call kmalloc/vmalloc at initializing init_mem_cgroup.
It's too early.

Thanks,
-Kame
