From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Wed, 5 Nov 2008 07:52:44 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0811050747040.11867@quilx.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
 <20081104124753.fb1dde5a.akpm@linux-foundation.org> <1225831988.7803.1939.camel@twins>
 <20081104131637.68fbe055.akpm@linux-foundation.org> <1225833710.7803.1993.camel@twins>
 <20081104135004.f1717fcf.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041601100.5077@quilx.com>
 <20081104143534.b5c16147.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041648350.6254@quilx.com>
 <20081104153610.bbfd5ed8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811042036000.31167@quilx.com> <20081104190505.769b93ec.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755783AbYKENxb@vger.kernel.org>
In-Reply-To: <20081104190505.769b93ec.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: peterz@infradead.org, rientjes@google.com, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Tue, 4 Nov 2008, Andrew Morton wrote:

>> That is one aspect. When performing writeback then we need to figure out
>> which inodes have dirty pages in the memcg and we need to start writeout
>> on those inodes and not on others that have their dirty pages elsewhere.
>> There are two components of this that are in this patch and that would
>> also have to be implemented for a memcg.
>
> Doable.  lru->page->mapping->host is a good start.

The block layer has a list of inodes that are dirty. From that we need to 
select ones that will improve the situation from the cpuset/memcg. How 
does the LRU come into this?

>> This patch would solve the problem if the calculation of the dirty pages
>> would consider the active memcg and be able to determine the amount of
>> dirty pages (through some sort of additional memcg counters). That is just
>> the first part though. The second part of finding the inodes that have
>> dirty pages for writeback would require an association between memcgs and
>> inodes.
>
> We presently have that via the LRU.  It has holes, but so does this per-cpuset
> scheme.

How do I get to the LRU from the dirtied list of inodes?

> Generally, I worry that this is a specific fix to a specific problem
> encountered on specific machines with specific setups and specific
> workloads, and that it's just all too low-level and myopic.
>
> And now we're back in the usual position where there's existing code and
> everyone says it's terribly wonderful and everyone is reluctant to step
> back and look at the big picture.  Am I wrong?

Well everyone is just reluctant to do work it seems. Thus they fall back 
to a solution that I provided when memcg groups were not yet available. It 
would be best if someone could find a general scheme or generalize this 
patchset.

> Plus: we need per-memcg dirty-memory throttling, and this is more
> important than per-cpuset, I suspect.  How will the (already rather
> buggy) code look once we've stuffed both of them in there?

The basics will still be the same

1. One need to establish the dirty ratio of memcgs and monitor them.
2. There needs to be mechanism to perform writeout on the right inodes.

> I agree that there's a problem here, although given the amount of time
> that it's been there, I suspect that it is a very small problem.

It used to be only a problem for NUMA systems. Now its also a problem for 
memcgs.

> Someone please convince me that in three years time we will agree that
> merging this fix to that problem was a correct decision?

At the mininum: It provides a basis on top of which memcg support 
can be developed. There are likely major modifications needed to VM 
statistics to get there for memcg groups.
