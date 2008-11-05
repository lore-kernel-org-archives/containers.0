From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Tue, 4 Nov 2008 19:05:05 -0800
Message-ID: <20081104190505.769b93ec.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
	<20081104124753.fb1dde5a.akpm@linux-foundation.org>
	<1225831988.7803.1939.camel@twins>
	<20081104131637.68fbe055.akpm@linux-foundation.org>
	<1225833710.7803.1993.camel@twins>
	<20081104135004.f1717fcf.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811041601100.5077@quilx.com>
	<20081104143534.b5c16147.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811041648350.6254@quilx.com>
	<20081104153610.bbfd5ed8.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811042036000.31167@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755394AbYKEDGE@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811042036000.31167@quilx.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: peterz@infradead.org, rientjes@google.com, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Tue, 4 Nov 2008 20:45:17 -0600 (CST) Christoph Lameter <cl@linux-foundation.org> wrote:

> On Tue, 4 Nov 2008, Andrew Morton wrote:
> 
> > In a memcg implementation what we would implement is "throttle
> > page-dirtying tasks in this memcg when the memcg's dirty memory reaches
> > 40% of its total".
> 
> Right that is similar to what this patch does for cpusets. A memcg 
> implementation would need to figure out if we are currently part of a 
> memcg and then determine the percentage of memory that is dirty.
> 
> That is one aspect. When performing writeback then we need to figure out 
> which inodes have dirty pages in the memcg and we need to start writeout 
> on those inodes and not on others that have their dirty pages elsewhere. 
> There are two components of this that are in this patch and that would 
> also have to be implemented for a memcg.

Doable.  lru->page->mapping->host is a good start.

> > But that doesn't solve the problem which this patchset is trying to
> > solve, which is "don't let all the memory in all this group of nodes
> > get dirty".
> 
> This patch would solve the problem if the calculation of the dirty pages 
> would consider the active memcg and be able to determine the amount of 
> dirty pages (through some sort of additional memcg counters). That is just 
> the first part though. The second part of finding the inodes that have 
> dirty pages for writeback would require an association between memcgs and 
> inodes.

We presently have that via the LRU.  It has holes, but so does this per-cpuset
scheme.

> > What happens if cpuset A uses nodes 0,1,2,3,4,5,6,7,8,9 and cpuset B
> > uses nodes 0,1?  Can activity in cpuset A cause ooms in cpuset B?
> 
> Yes if the activities of cpuset A cause all pages to be dirtied in cpuset 
> B and then cpuset B attempts to do writeback. This will fail to acquire 
> enough memory for writeback and make reclaim impossible.
> 
> Typically cpusets are not overlapped like that but used to segment the 
> system.
> 
> The system would work correctly if the dirty ratio calculation would be 
> done on all overlapping cpusets/memcg groups that contain nodes from 
> which allocations are permitted.

That.


Generally, I worry that this is a specific fix to a specific problem
encountered on specific machines with specific setups and specific
workloads, and that it's just all too low-level and myopic.

And now we're back in the usual position where there's existing code and
everyone says it's terribly wonderful and everyone is reluctant to step
back and look at the big picture.  Am I wrong?


Plus: we need per-memcg dirty-memory throttling, and this is more
important than per-cpuset, I suspect.  How will the (already rather
buggy) code look once we've stuffed both of them in there?


I agree that there's a problem here, although given the amount of time
that it's been there, I suspect that it is a very small problem. 
Someone please convince me that in three years time we will agree that
merging this fix to that problem was a correct decision?
