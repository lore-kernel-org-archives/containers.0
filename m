From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Wed, 5 Nov 2008 12:31:50 -0800
Message-ID: <20081105123150.d6628805.akpm@linux-foundation.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0811051415360.31450-dRBSpnHQED8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: npiggin-l3A5Bk7waGM@public.gmane.org, dfults-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 5 Nov 2008 14:21:47 -0600 (CST)
Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> On Wed, 5 Nov 2008, Andrew Morton wrote:
> 
> > > > Doable.  lru->page->mapping->host is a good start.
> > >
> > > The block layer has a list of inodes that are dirty. From that we need to
> > > select ones that will improve the situation from the cpuset/memcg. How
> > > does the LRU come into this?
> >
> > In the simplest case, dirty-memory throttling can just walk the LRU
> > writing back pages in the same way that kswapd does.
> 
> That means running reclaim. But we are only interested in getting rid of
> dirty pages. Plus the filesystem guys have repeatedly pointed out that
> page sized I/O to random places in a file is not a good thing to do. There
> was actually talk of stopping kswapd from writing out pages!

They don't have to be reclaimed.

> > There would probably be performance benefits in doing
> > address_space-ordered writeback, so the dirty-memory throttling could
> > pick a dirty page off the LRU, go find its inode and then feed that
> > into __sync_single_inode().
> 
> We cannot call into the writeback functions for an inode from a reclaim
> context. We can write back single pages but not a range of pages from an
> inode due to various locking issues (see discussion on slab defrag
> patchset).

We're not in a reclaim context.  We're in sys_write() context.

> > But _are_ people hitting this problem?  I haven't seen any real-looking
> > reports in ages.  Is there some workaround?  If so, what is it?  How
> > serious is this problem now?
> 
> Are there people who are actually having memcg based solutions deployed?
> No enterprise release includes it yet so I guess that there is not much of
> a use yet.

If you know the answer then please provide it.  If you don't, please
say "I don't know".
