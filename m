From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Wed, 5 Nov 2008 14:21:47 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0811051415360.31450@quilx.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
 <20081104124753.fb1dde5a.akpm@linux-foundation.org> <1225831988.7803.1939.camel@twins>
 <20081104131637.68fbe055.akpm@linux-foundation.org> <1225833710.7803.1993.camel@twins>
 <20081104135004.f1717fcf.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041601100.5077@quilx.com>
 <20081104143534.b5c16147.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041648350.6254@quilx.com>
 <20081104153610.bbfd5ed8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811042036000.31167@quilx.com> <20081104190505.769b93ec.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811050747040.11867@quilx.com> <20081105104145.abd6fc91.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757664AbYKEUWi@vger.kernel.org>
In-Reply-To: <20081105104145.abd6fc91.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: peterz@infradead.org, rientjes@google.com, npiggin@suse.de, menage@google.com, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, 5 Nov 2008, Andrew Morton wrote:

> > > Doable.  lru->page->mapping->host is a good start.
> >
> > The block layer has a list of inodes that are dirty. From that we need to
> > select ones that will improve the situation from the cpuset/memcg. How
> > does the LRU come into this?
>
> In the simplest case, dirty-memory throttling can just walk the LRU
> writing back pages in the same way that kswapd does.

That means running reclaim. But we are only interested in getting rid of
dirty pages. Plus the filesystem guys have repeatedly pointed out that
page sized I/O to random places in a file is not a good thing to do. There
was actually talk of stopping kswapd from writing out pages!

> There would probably be performance benefits in doing
> address_space-ordered writeback, so the dirty-memory throttling could
> pick a dirty page off the LRU, go find its inode and then feed that
> into __sync_single_inode().

We cannot call into the writeback functions for an inode from a reclaim
context. We can write back single pages but not a range of pages from an
inode due to various locking issues (see discussion on slab defrag
patchset).

> > How do I get to the LRU from the dirtied list of inodes?
>
> Don't need it.
>
> It'll be approximate and has obvious scenarios of great inaccuraracy
> but it'll suffice for the workloads which this patchset addresses.

Sounds like a wild hack that runs against known limitations in terms
of locking etc.

> It sounds like any memcg-based approach just won't be suitable for the
> people who are hitting this problem.

Why not? If you can determine which memcgs an inode has dirty pages on
then the same scheme as proposed here will work.

> But _are_ people hitting this problem?  I haven't seen any real-looking
> reports in ages.  Is there some workaround?  If so, what is it?  How
> serious is this problem now?

Are there people who are actually having memcg based solutions deployed?
No enterprise release includes it yet so I guess that there is not much of
a use yet.
