From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 9/9] ext3: do not throttle metadata and journal IO
Date: Wed, 22 Apr 2009 12:22:41 +0200
Message-ID: <20090422102239.GA1935__35281.3568817966$1240395992$gmane$org@linux>
References: <20090421140631.GF19186@mit.edu> <20090421143130.GA22626@linux>
	<20090421163537.GI19186@mit.edu>
	<20090421172317.GM19637@balbir.in.ibm.com>
	<20090421174620.GD15541@mit.edu>
	<20090421181429.GO19637@balbir.in.ibm.com>
	<20090421191401.GF15541@mit.edu> <20090421204905.GA5573@linux>
	<20090422093349.1ee9ae82.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422102153.9aec17b9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090422102153.9aec17b9.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Gui-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 22, 2009 at 10:21:53AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 22 Apr 2009 09:33:49 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> 
> 
> > > And this should be probably strictly connected to the IO controller. If
> > > we throttle or delay the dispatching/submission of some IO requests
> > > without throttling the dirty pages rate a cgroup could completely waste
> > > its own available memory with dirty (hard and slow to reclaim) pages.
> > > 
> > > That is in part the approach I used in io-throttle v12, adding a hook in
> > > balance_dirty_pages_ratelimited_nr() to throttle the current task when
> > > cgroup's IO limit are exceeded. Argh!
> > > 
> > > So, another proposal could be to re-add in io-throttle v14 the old hook
> > > also in balance_dirty_pages_ratelimited_nr().
> > > 
> > > In this way io-throttle would:
> > > 
> > > - use page_cgroup infrastructure and page_cgroup->flags to encode the
> > >   cgroup id that firstly dirtied a generic page
> > > - account and opportunely throttle sync and writeback IO requests in
> > >   submit_bio()
> > > - at the same time throttle the tasks in
> > >   balance_dirty_pages_ratelimited_nr() if the cgroup they belong has
> > >   exhausted the IO BW (or quota, share, etc. in case of proportional BW
> > >   limit)
> > > 
> > 
> > IMHO, io-controller should just work as I/O subsystem as bdi. Now, per-bdi dirty_ratio
> > is suppoted and it seems to work well.  
> > 
> > Can't we write a function like  bdi_writeout_fraction() ?;
> > It will be a simple choice.
> > 
> One more thing, if you want dirty_ratio for throttoling I/O not for supporing page reclaim,
> Something like task_dirty_limit() will be apporpriate.
> 
> Thanks,
> -Kame

Actually I was proposing something quite similar, if I've understood
well. Just add a hook in balance_dirty_pages() to throttle tasks in
cgroups that exhausted their IO BW.

The way to do so will be similar to the per-bdi write throttling, taking
in account the IO requests previously submitted per cgroup, the pages
dirtied per cgroup (considering that are not necessarily dirtied by the
owner of the page) and apply something like congestion_wait() to
throttle the tasks in the cgroups that exceeded the BW limit.

Maybe we can just introduce cgroup_dirty_limit() simply replicating what
we're doing for task_dirty_limit(), but using per cgroup statistics of
course.

I can change the io-throttle controller to do so. This feature should be
valid also for the proportional BW approach.

BTW Vivek's proposal to also dispatch IO requests according to cgroup
proportional BW limits can be still valid and it is worth to be tested
IMHO. But we must also find a way to say to the right cgroup: hey! stop
to waste the memory with dirty pages, because you've directly or
indirectly generated too much IO in the system and I'm throttling and/or
not scheduling your IO requests.

Objections?

-Andrea
