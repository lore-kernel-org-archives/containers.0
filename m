From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] io-throttle documentation
Date: Tue, 21 Apr 2009 10:37:03 +0200
Message-ID: <20090421083702.GC8441__32805.6707549424$1240303190$gmane$org@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-2-git-send-email-righi.andrea@gmail.com>
	<20090417173955.GF29086@redhat.com> <20090417231244.GB6972@linux>
	<20090419134201.GF8493@redhat.com> <20090419154717.GB5514@linux>
	<20090420212827.GA9080@redhat.com> <20090420220511.GA8740@linux>
	<20090421010846.GA15850@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090421010846.GA15850-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 20, 2009 at 09:08:46PM -0400, Vivek Goyal wrote:
> On Tue, Apr 21, 2009 at 12:05:12AM +0200, Andrea Righi wrote:
> 
> [..]
> > > > > Are we not already controlling submission of request (at crude level).
> > > > > If application is doing writeout at high rate, then it hits vm_dirty_ratio
> > > > > hits and this application is forced to do write out and hence it is slowed
> > > > > down and is not allowed to submit writes at high rate.
> > > > > 
> > > > > Just that it is not a very fair scheme right now as during right out
> > > > > a high prio/high weight cgroup application can start writing out some
> > > > > other cgroups' pages.
> > > > > 
> > > > > For this we probably need to have some combination of solutions like
> > > > > per cgroup upper limit on dirty pages. Secondly probably if an application
> > > > > is slowed down because of hitting vm_drity_ratio, it should try to
> > > > > write out the inode it is dirtying first instead of picking any random
> > > > > inode and associated pages. This will ensure that a high weight
> > > > > application can quickly get through the write outs and see higher
> > > > > throughput from the disk.
> > > > 
> > > > For the first, I submitted a patchset some months ago to provide this
> > > > feature in the memory controller:
> > > > 
> > > > https://lists.linux-foundation.org/pipermail/containers/2008-September/013140.html
> > > > 
> > > > We focused on the best interface to use for setting the dirty pages
> > > > limit, but we didn't finalize it. I can rework on that and repost an
> > > > updated version. Now that we have the dirty_ratio/dirty_bytes to set the
> > > > global limit I think we can use the same interface and the same semantic
> > > > within the cgroup fs, something like:
> > > > 
> > > >   memory.dirty_ratio
> > > >   memory.dirty_bytes
> > > > 
> > > > For the second point something like this should be enough to force tasks
> > > > to write out only the inode they're actually dirtying when they hit the
> > > > vm_dirty_ratio limit. But it should be tested carefully and may cause
> > > > heavy performance regressions.
> > > > 
> > > > Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > > ---
> > > >  mm/page-writeback.c |    2 +-
> > > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > > 
> > > > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > > > index 2630937..1e07c9d 100644
> > > > --- a/mm/page-writeback.c
> > > > +++ b/mm/page-writeback.c
> > > > @@ -543,7 +543,7 @@ static void balance_dirty_pages(struct address_space *mapping)
> > > >  		 * been flushed to permanent storage.
> > > >  		 */
> > > >  		if (bdi_nr_reclaimable) {
> > > > -			writeback_inodes(&wbc);
> > > > +			sync_inode(mapping->host, &wbc);
> > > >  			pages_written += write_chunk - wbc.nr_to_write;
> > > >  			get_dirty_limits(&background_thresh, &dirty_thresh,
> > > >  				       &bdi_thresh, bdi);
> > > 
> > > This patch seems to be helping me a bit in getting more service
> > > differentiation between two writer dd of different weights. But strangely
> > > it is helping only for ext3 and not ext4. Debugging is on.
> > 
> > Are you explicitly mounting ext3 with data=ordered?
> 
> Yes. Still using 29-rc8 and data=ordered was the default then.
> 
> I got two partitions on same disk and created one ext3 filesystem on each
> partition (just to take journaling intereference out of two dd threads 
> for the time being).
> 
> Two dd threads doing writes to each partition. 

...and if you're using data=writeback with ext4 sync_inode() should sync
the metadata only. If this is the case, could you check data=ordered
also for ext4?

-Andrea
