From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO controller discussion (Was: Re: [PATCH 01/10] Documentation)
Date: Sun, 19 Apr 2009 09:08:49 -0400
Message-ID: <20090419130849.GC8493__4773.10405481166$1240146801$gmane$org@redhat.com>
References: <1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com> <49D8CB17.7040501@gmail.com>
	<20090407064046.GB20498@redhat.com> <20090408203756.GB10077@linux>
	<20090416183753.GE8896@redhat.com> <20090417093656.GA5246@linux>
	<20090417141358.GD29086@redhat.com>
	<e98e18940904171109r17ccb054kb7879f8d02ac26b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940904171109r17ccb054kb7879f8d02ac26b5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 17, 2009 at 11:09:51AM -0700, Nauman Rafique wrote:
> On Fri, Apr 17, 2009 at 7:13 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Fri, Apr 17, 2009 at 11:37:28AM +0200, Andrea Righi wrote:
> >> On Thu, Apr 16, 2009 at 02:37:53PM -0400, Vivek Goyal wrote:
> >> > > I think it would be possible to implement both proportional and limiting
> >> > > rules at the same level (e.g., the IO scheduler), but we need also to
> >> > > address the memory consumption problem (I still need to review your
> >> > > patchset in details and I'm going to test it soon :), so I don't know if
> >> > > you already addressed this issue).
> >> > >
> >> >
> >> > Can you please elaborate a bit on this? Are you concerned about that data
> >> > structures created to solve the problem consume a lot of memory?
> >>
> >> Sorry I was not very clear here. With memory consumption I mean wasting
> >> the memory with hard/slow reclaimable dirty pages or pending IO
> >> requests.
> >>
> >> If there's only a global limit on dirty pages, any cgroup can exhaust
> >> that limit and cause other cgroups/processes to block when they try to
> >> write to disk.
> >>
> >> But, ok, the IO controller is not probably the best place to implement
> >> such functionality. I should rework on the per cgroup dirty_ratio:
> >>
> >> https://lists.linux-foundation.org/pipermail/containers/2008-September/013140.html
> >>
> >> Last time we focused too much on the best interfaces to define dirty
> >> pages limit, and I never re-posted an updated version of this patchset.
> >> Now I think we can simply provide the same dirty_ratio/dirty_bytes
> >> interface that we provide globally, but per cgroup.
> >>
> >> >
> >> > > IOW if we simply don't dispatch requests and we don't throttle the tasks
> >> > > in the cgroup that exceeds its limit, how do we avoid the waste of
> >> > > memory due to the succeeding IO requests and the increasingly dirty
> >> > > pages in the page cache (that are also hard to reclaim)? I may be wrong,
> >> > > but I think we talked about this problem in a previous email... sorry I
> >> > > don't find the discussion in my mail archives.
> >> > >
> >> > > IMHO a nice approach would be to measure IO consumption at the IO
> >> > > scheduler level, and control IO applying proportional weights / absolute
> >> > > limits _both_ at the IO scheduler / elevator level _and_ at the same
> >> > > time block the tasks from dirtying memory that will generate additional
> >> > > IO requests.
> >> > >
> >> > > Anyway, there's no need to provide this with a single IO controller, we
> >> > > could split the problem in two parts: 1) provide a proportional /
> >> > > absolute IO controller in the IO schedulers and 2) allow to set, for
> >> > > example, a maximum limit of dirty pages for each cgroup.
> >> > >
> >> >
> >> > I think setting a maximum limit on dirty pages is an interesting thought.
> >> > It sounds like as if memory controller can handle it?
> >>
> >> Exactly, the same above.
> >
> > Thinking more about it. Memory controller can probably enforce the higher
> > limit but it would not easily translate into a fixed upper async write
> > rate. Till the process hits the page cache limit or is slowed down by
> > dirty page writeout, it can get a very high async write BW.
> >
> > So memory controller page cache limit will help but it would not direclty
> > translate into what max bw limit patches are doing.
> >
> > Even if we do max bw control at IO scheduler level, async writes are
> > problematic again. IO controller will not be able to throttle the process
> > until it sees actuall write request. In big memory systems, writeout might
> > not happen for some time and till then it will see a high throughput.
> >
> > So doing async write throttling at higher layer and not at IO scheduler
> > layer gives us the opprotunity to produce more accurate results.
> 
> Wouldn't 'doing control on writes at a higher layer' have the same
> problems as the ones we talk about in dm-ioband? What if the cgroup
> being throttled for dirtying pages has a high weight assigned to it at
> the IO scheduler level? What if there are threads of different classes
> within that cgroup, and we would want to let RT task dirty the pages
> before BE tasks? I am not sure all these questions make sense, but
> just wanted to raise issues that might pop up.
> 
> If the whole system is designed with cgroups in mind, then throttling
> at IO scheduler layer should lead to backlog, that could be seen at
> higher level. For example, if a cgroup is not getting service at IO
> scheduler level, it should run out of request descriptors, and thus
> the thread writing back dirty pages should notice it (if its pdflush,
> blocking it is probably not the best idea). And that should mean the
> cgroup should hit the dirty threshold, and disallow the task to dirty
> further pages. There is a possibility though that getting all this
> right might be an overkill and we can get away with a simpler
> solution.

Currently, if pdflush can't keep up and processes are dirtying the
page cache at higher rate than we will cross vm_dirty_ratio and
process will be made to write back some of dirty pages. That should
make sure that processes will be automatically throttled at IO scheduler
(Assuming process tries to write its own pages and does not pick randomly
some other processes's pages). Currently I think a processes can pick
any inode for writeback and not necessarily the inode the process is
dirtying.

Thanks
Vivek
