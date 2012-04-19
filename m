From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Integrated IO controller for buffered+direct writes
Date: Thu, 19 Apr 2012 15:12:06 -0400
Message-ID: <20120419191206.GN10216__40499.0283110694$1334862764$gmane$org@redhat.com>
References: <20120419052811.GA11543@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120419052811.GA11543@localhost>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Apr 19, 2012 at 01:28:11PM +0800, Fengguang Wu wrote:
[..]
> The key ideas and comments can be found in two functions in the patch:
> - cfq_scale_slice()
> - blkcg_update_dirty_ratelimit()
> The other changes are mainly supporting bits.
> 
> It adapts the existing interfaces
> - blkio.throttle.write_bps_device 
> - blkio.weight
> from the semantics "for direct IO" to "for direct+buffered IO" (it
> now handles write IO only, but should be trivial to cover reads). It
> tries to do 1:1 split of direct:buffered writes inside the cgroup
> which essentially implements intra-cgroup proportional weights.

Hey, if you can explain in few lines the design and what's the objective
its much easier to understand then going through the patch and first
trying to understand the internals of writeback.

Regarding upper limit (blkio.throttle_write_bps_device) thre are only
two problems with doing it a device layer.

- We lose context information for buffered writes.
	- This can be solved by per inode cgroup association.

	- Or solve it by throttling writer synchronously in
	  balance_dirty_pages(). I had done that by exporting a hook from
	  blk-throttle so that writeback layer does not have to worry
	  about all the details.

- Filesystems can get seriliazed.
	- This needs to be solved by filesystems.

	- Or again, invoke blk-throttle hook from balance_dirty_pages. It
	  will solve the problem for buffered writes but direct writes
	  will still have filesystem serialization issue. So it needs to
	  be solved by filesystems anyway.  

- Throttling for network file systems.
	- This would be the only advantage or implementing things at
	  higher layer so that we don't have to build special knowledge
	  of throttling in lower layers.

So which of the above problem you are exactly solving by throttling
by writes in writeback layer and why exporting a throttling hook from
blk-throttle to balance_drity_pages()is not a good idea?

Thanks
Vivek
