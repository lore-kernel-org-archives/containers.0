From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] memory cgroup enhancements [1/5]  force_empty for
 memory cgroup
Date: Wed, 17 Oct 2007 14:26:42 +0900
Message-ID: <20071017142642.f4881e4e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>
	<47159836.9030506@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47159836.9030506-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 17 Oct 2007 10:35:58 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > If the only use of this is for rmdir, why not just make it part of the 
> > rmdir operation on the memory cgroup if there are no tasks by default?
> > 
> 
> That's a good idea, but sometimes an administrator might want to force
> a cgroup empty and start fresh without necessary deleting the cgroup.
> 
I'll make a "automatic force_empty at rmdir()" patch as another patch depends
on this. If we make concensus that "force_empty interface is redundant", I'll
remove it later.


> I am not convinced of this hack either, specially the statement of
> setting count to SWAP_CLUSTER_MAX.
> 
Just because I think there should be "unlock and rest" in this busy loop,
I need some number. Should I define other number ?
as
#define FORCE_RECALIM_BATCH	(128)


> >> +		/* drop all page_cgroup in inactive_list */
> >> +		mem_cgroup_force_empty_list(mem, &mem->inactive_list);
> >> +	}
> > 
> > This implementation as a while loop looks very suspect since 
> > mem_cgroup_force_empty_list() uses while (!list_empty(list)) as well.  
> > Perhaps it's just easier here as
> > 
> > 	if (list_empty(&mem->active_list) && list_empty(&mem->inactive_list))
> > 		return 0;
> > 
> 
> Do we VM_BUG_ON() in case the lists are not empty after calling
> mem_cgroup_force_empty_list()
>
Okay, I will add.
 

> > Reading memory.force_empty is pretty useless, so why allow it to be read 
> > at all?
> 
> I agree, this is not required. I wonder if we could set permissions at
> group level to mark this file as *write only*. We could use the new
> read_uint and write_uint callbacks for reading/writing integers.
> 
ok, will remove.

Thanks,
-Kame
