From: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Thu, 19 Apr 2012 22:26:35 +0200
Message-ID: <20120419202635.GA4795@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404175124.GA8931@localhost>
	<20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120406095934.GA10465@localhost>
	<20120417223854.GG19975@google.com>
	<20120419142343.GA12684@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120419142343.GA12684@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu 19-04-12 22:23:43, Wu Fengguang wrote:
> For one instance, splitting the request queues will give rise to
> PG_writeback pages.  Those pages have been the biggest source of
> latency issues in the various parts of the system.
  Well, if we allow more requests to be in flight in total then yes, number
of PG_Writeback pages can be higher as well.

> It's not uncommon for me to see filesystems sleep on PG_writeback
> pages during heavy writeback, within some lock or transaction, which in
> turn stall many tasks that try to do IO or merely dirty some page in
> memory. Random writes are especially susceptible to such stalls. The
> stable page feature also vastly increase the chances of stalls by
> locking the writeback pages. 
> 
> Page reclaim may also block on PG_writeback and/or PG_dirty pages. In
> the case of direct reclaim, it means blocking random tasks that are
> allocating memory in the system.
> 
> PG_writeback pages are much worse than PG_dirty pages in that they are
> not movable. This makes a big difference for high-order page allocations.
> To make room for a 2MB huge page, vmscan has the option to migrate
> PG_dirty pages, but for PG_writeback it has no better choices than to
> wait for IO completion.
> 
> The difficulty of THP allocation goes up *exponentially* with the
> number of PG_writeback pages. Assume PG_writeback pages are randomly
> distributed in the physical memory space. Then we have formula
> 
>         P(reclaimable for THP) = 1 - P(hit PG_writeback)^256
  Well, this implicitely assumes that PG_Writeback pages are scattered
across memory uniformly at random. I'm not sure to which extent this is
true... Also as a nitpick, this isn't really an exponential growth since
the exponent is fixed (256 - actually it should be 512, right?). It's just
a polynomial with a big exponent. But sure, growth in number of PG_Writeback
pages will cause relatively steep drop in the number of available huge
pages.

...
> It's worth to note that running multiple flusher threads per bdi means
> not only disk seeks for spin disks, smaller IO size for SSD, but also
> lock contentions and cache bouncing for metadata heavy workloads and
> fast storage.
  Well, this heavily depends on particular implementation (and chosen
data structures). But yes, we should have that in mind.

...
> > > To me, balance_dirty_pages() is *the* proper layer for buffered writes.
> > > It's always there doing 1:1 proportional throttling. Then you try to
> > > kick in to add *double* throttling in block/cfq layer. Now the low
> > > layer may enforce 10:1 throttling and push balance_dirty_pages() away
> > > from its balanced state, leading to large fluctuations and program
> > > stalls.
> > 
> > Just do the same 1:1 inside each cgroup.
> 
> Sure. But the ratio mismatch I'm talking about is inter-cgroup.
> For example there are only 2 dd tasks doing buffered writes in the
> system. Now consider the mismatch that cfq is dispatching their IO
> requests at 10:1 weights, while balance_dirty_pages() is throttling
> the dd tasks at 1:1 equal split because it's not aware of the cgroup
> weights.
> 
> What will happen in the end? The 1:1 ratio imposed by
> balance_dirty_pages() will take effect and the dd tasks will progress
> at the same pace. The cfq weights will be defeated because the async
> queue for the second dd (and cgroup) constantly runs empty.
  Yup. This just shows that you have to have per-cgroup dirty limits. Once
you have those, things start working again.

								Honza
-- 
Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
SUSE Labs, CR
