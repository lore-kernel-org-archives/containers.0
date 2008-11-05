From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Wed, 5 Nov 2008 10:41:45 -0800
Message-ID: <20081105104145.abd6fc91.akpm@linux-foundation.org>
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
	<20081104190505.769b93ec.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811050747040.11867@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756701AbYKESmk@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811050747040.11867@quilx.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: peterz@infradead.org, rientjes@google.com, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, 5 Nov 2008 07:52:44 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Tue, 4 Nov 2008, Andrew Morton wrote:
> 
> >> That is one aspect. When performing writeback then we need to figure out
> >> which inodes have dirty pages in the memcg and we need to start writeout
> >> on those inodes and not on others that have their dirty pages elsewhere.
> >> There are two components of this that are in this patch and that would
> >> also have to be implemented for a memcg.
> >
> > Doable.  lru->page->mapping->host is a good start.
> 
> The block layer has a list of inodes that are dirty. From that we need to 
> select ones that will improve the situation from the cpuset/memcg. How 
> does the LRU come into this?

In the simplest case, dirty-memory throttling can just walk the LRU
writing back pages in the same way that kswapd does.

There would probably be performance benefits in doing
address_space-ordered writeback, so the dirty-memory throttling could
pick a dirty page off the LRU, go find its inode and then feed that
into __sync_single_inode().

> >> This patch would solve the problem if the calculation of the dirty pages
> >> would consider the active memcg and be able to determine the amount of
> >> dirty pages (through some sort of additional memcg counters). That is just
> >> the first part though. The second part of finding the inodes that have
> >> dirty pages for writeback would require an association between memcgs and
> >> inodes.
> >
> > We presently have that via the LRU.  It has holes, but so does this per-cpuset
> > scheme.
> 
> How do I get to the LRU from the dirtied list of inodes?

Don't need it.

It'll be approximate and has obvious scenarios of great inaccuraracy
but it'll suffice for the workloads which this patchset addresses.



It sounds like any memcg-based approach just won't be suitable for the
people who are hitting this problem.

But _are_ people hitting this problem?  I haven't seen any real-looking
reports in ages.  Is there some workaround?  If so, what is it?  How
serious is this problem now?
