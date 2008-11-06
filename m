From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Thu, 6 Nov 2008 12:35:03 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0811061220370.7767@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com> <1225831988.7803.1939.camel@twins> <20081104131637.68fbe055.akpm@linux-foundation.org> <1225833710.7803.1993.camel@twins> <20081104135004.f1717fcf.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811041601100.5077@quilx.com> <20081104143534.b5c16147.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041648350.6254@quilx.com> <20081104153610.bbfd5ed8.akpm@linux-foundation.org> <Pine.LNX.4.64.0811042036000.31167@quilx.com>
 <20081104190505.769b93ec.akpm@linux-foundation.org> <Pine.LNX.4.64.0811050747040.11867@quilx.com> <20081105104145.abd6fc91.akpm@linux-foundation.org> <Pine.LNX.4.64.0811051415360.31450@quilx.com> <20081105123150.d6628805.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811051434300.31450@quilx.com> <20081105125603.36d0c222.akpm@linux-foundation.org> <alpine.DEB.2.00.0811051347240.21365@chino.kir.corp.google.com> <20081106103455.f3277a72.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753369AbYKFUhI@vger.kernel.org>
In-Reply-To: <20081106103455.f3277a72.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, Christoph Lameter <cl@linux-foundation.org>, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Paul Menage <menage@google.com>, Andrea Righi <righi.andrea@gmail.com>
List-Id: containers.vger.kernel.org

On Thu, 6 Nov 2008, KAMEZAWA Hiroyuki wrote:

> > Agreed.  This patchset is admittedly from a different time when cpusets 
> > was the only relevant extension that needed to be done.
> > 
> BTW, what is the problem this patch wants to fix ?
>   1. avoid slow-down of memory allocation by triggering write-out earlier.
>   2. avoid OOM by throttoling dirty pages.
> 
> About 1, memcg's diry_ratio can help if mounted as
>    mount -t cgroup none /somewhere/  -o cpuset,memory
> (If the user can accept overheads of memcg.)
> If implemented.
> 

Yeah, it needs to be generalized to its own cgroup so that it doesn't 
depend on both CONFIG_CPUSETS or CONFIG_CGROUP_MEM_RES_CTLR.  If we get 
the dirty and writeback page statistics added to memcg, this becomes much 
simpler.

> About 2, A Google guy posted OOM handler cgroup to linux-mm.
> 

Yeah, this could enable one of the workarounds that Christoph earlier 
described: the oom handler has the ability to notify userspace and allows 
it to defer invoking the oom killer if there's an alternative way to 
remedy the situation.  So the oom handler posted to linux-mm could work by 
doing a sync anytime it ran low on memory, but the objective of this 
patchset is different.

The idea here is to implement per-cpuset (and now per-memcg) dirty and 
background dirty ratios to avoid using the global sysctls.  This is 
currently problematic for users of cpusets who divide their machine for 
batches of tasks, usually for NUMA optimizations: a cpuset, for example, 
can represent 40% of the system's memory and if the global dirty ratio is 
set to 50%, we still won't begin writeback even if all the memory in the 
cpuset is dirty.

> > If we are to support memcg-specific dirty ratios, that requires the 
> > aforementioned statistics to be collected so that the calculation is even 
> > possible.  The series at 
> > 
> > 	http://marc.info/?l=linux-kernel&m=122123225006571
> > 	http://marc.info/?l=linux-kernel&m=122123241106902
> > 
> yes. we(memcg) need this kind of.
> 

Andrea, what's the status of the patch to add dirty and writeback 
statistics to memcg?  I don't see it in the October 30 mmotm or any 
followup discussion on it.

> > is a step in that direction, although I'd prefer to see NR_UNSTABLE_NFS to 
> > be extracted separately from MEM_CGROUP_STAT_FILE_DIRTY so 
> > throttle_vm_writeout() can also use the new statistics.
> > 

Is this possible in a second version?
