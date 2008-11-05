From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Wed, 5 Nov 2008 12:56:03 -0800
Message-ID: <20081105125603.36d0c222.akpm@linux-foundation.org>
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
	<20081105104145.abd6fc91.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811051415360.31450@quilx.com>
	<20081105123150.d6628805.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811051434300.31450@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756923AbYKEU5D@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811051434300.31450@quilx.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: peterz@infradead.org, rientjes@google.com, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, 5 Nov 2008 14:40:05 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Wed, 5 Nov 2008, Andrew Morton wrote:
> 
> > > That means running reclaim. But we are only interested in getting rid of
> > > dirty pages. Plus the filesystem guys have repeatedly pointed out that
> > > page sized I/O to random places in a file is not a good thing to do. There
> > > was actually talk of stopping kswapd from writing out pages!
> >
> > They don't have to be reclaimed.
> 
> Well the LRU is used for reclaim. If you step over it then its using the
> existing reclaim logic in vmscan.c right?

Only if you use it that way.

I imagine that a suitable implementation would start IO on the page
then move it to the other end of the LRU.  ie: treat it as referenced. 
Pretty simple stuff.

If we were to do writeout on the page's inode instead then we'd need
to move the page out of the way somehow, presumably by rotating it.

It's all workable outable.

> > > > There would probably be performance benefits in doing
> > > > address_space-ordered writeback, so the dirty-memory throttling could
> > > > pick a dirty page off the LRU, go find its inode and then feed that
> > > > into __sync_single_inode().
> > >
> > > We cannot call into the writeback functions for an inode from a reclaim
> > > context. We can write back single pages but not a range of pages from an
> > > inode due to various locking issues (see discussion on slab defrag
> > > patchset).
> >
> > We're not in a reclaim context.  We're in sys_write() context.
> 
> Dirtying a page can occur from a variety of kernel contexts.

This writeback will occur from one quite specific place:
balance_dirty_pages().  That's called from sys_write() and pagefaults. 
Other scruffy places like splice too.

But none of that matters - the fact is that we're _already_ doing
writeback from balance_dirty_pages().  All we're talking about here is
alternative schemes for looking up the pages to write.

> > > > But _are_ people hitting this problem?  I haven't seen any real-looking
> > > > reports in ages.  Is there some workaround?  If so, what is it?  How
> > > > serious is this problem now?
> > >
> > > Are there people who are actually having memcg based solutions deployed?
> > > No enterprise release includes it yet so I guess that there is not much of
> > > a use yet.
> >
> > If you know the answer then please provide it.  If you don't, please
> > say "I don't know".
> 
> I thought we were talking about memcg related reports. I have dealt with
> scores of the cpuset related ones in my prior job.
> 
> Workarounds are:
> 
> 1. Reduce the global dirty ratios so that the number of dirty pages in a
> cpuset cannot become too high.

That would be less than the smallest node's memory capacity, I guess.

> 2. Do not create small cpusets where the system can dirty all pages.
> 
> 3. Find other ways to limit the dirty pages (run sync once in a while or
> so).

hm, OK.


See, here's my problem: we have a pile of new code which fixes some
problem.  But the problem seems to be fairly small - it only affects a
small number of sophisticated users and they already have workarounds
in place.

So the world wouldn't end if we just didn't merge it.  Those users
stick with their workarounds and the kernel remains simpler and
smaller.

How do we work out which is the best choice here?  I don't have enough
information to do this.
