From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO controller discussion (Was: Re: [PATCH 01/10] Documentation)
Date: Sun, 19 Apr 2009 17:53:59 +0200
Message-ID: <20090419155358.GC5514__12954.0628441193$1240156804$gmane$org@linux>
References: <20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com> <49D8CB17.7040501@gmail.com>
	<20090407064046.GB20498@redhat.com> <20090408203756.GB10077@linux>
	<20090416183753.GE8896@redhat.com> <20090417093656.GA5246@linux>
	<20090417141358.GD29086@redhat.com>
	<661de9470904180619k34e7998ch755a2ad3bed9ce5e@mail.gmail.com>
	<20090419134508.GG8493@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090419134508.GG8493-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Apr 19, 2009 at 09:45:08AM -0400, Vivek Goyal wrote:
> On Sat, Apr 18, 2009 at 06:49:33PM +0530, Balbir Singh wrote:
> > On Fri, Apr 17, 2009 at 7:43 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > On Fri, Apr 17, 2009 at 11:37:28AM +0200, Andrea Righi wrote:
> > >> On Thu, Apr 16, 2009 at 02:37:53PM -0400, Vivek Goyal wrote:
> > >> > > I think it would be possible to implement both proportional and limiting
> > >> > > rules at the same level (e.g., the IO scheduler), but we need also to
> > >> > > address the memory consumption problem (I still need to review your
> > >> > > patchset in details and I'm going to test it soon :), so I don't know if
> > >> > > you already addressed this issue).
> > >> > >
> > >> >
> > >> > Can you please elaborate a bit on this? Are you concerned about that data
> > >> > structures created to solve the problem consume a lot of memory?
> > >>
> > >> Sorry I was not very clear here. With memory consumption I mean wasting
> > >> the memory with hard/slow reclaimable dirty pages or pending IO
> > >> requests.
> > >>
> > >> If there's only a global limit on dirty pages, any cgroup can exhaust
> > >> that limit and cause other cgroups/processes to block when they try to
> > >> write to disk.
> > >>
> > >> But, ok, the IO controller is not probably the best place to implement
> > >> such functionality. I should rework on the per cgroup dirty_ratio:
> > >>
> > >> https://lists.linux-foundation.org/pipermail/containers/2008-September/013140.html
> > >>
> > >> Last time we focused too much on the best interfaces to define dirty
> > >> pages limit, and I never re-posted an updated version of this patchset.
> > >> Now I think we can simply provide the same dirty_ratio/dirty_bytes
> > >> interface that we provide globally, but per cgroup.
> > >>
> > >> >
> > >> > > IOW if we simply don't dispatch requests and we don't throttle the tasks
> > >> > > in the cgroup that exceeds its limit, how do we avoid the waste of
> > >> > > memory due to the succeeding IO requests and the increasingly dirty
> > >> > > pages in the page cache (that are also hard to reclaim)? I may be wrong,
> > >> > > but I think we talked about this problem in a previous email... sorry I
> > >> > > don't find the discussion in my mail archives.
> > >> > >
> > >> > > IMHO a nice approach would be to measure IO consumption at the IO
> > >> > > scheduler level, and control IO applying proportional weights / absolute
> > >> > > limits _both_ at the IO scheduler / elevator level _and_ at the same
> > >> > > time block the tasks from dirtying memory that will generate additional
> > >> > > IO requests.
> > >> > >
> > >> > > Anyway, there's no need to provide this with a single IO controller, we
> > >> > > could split the problem in two parts: 1) provide a proportional /
> > >> > > absolute IO controller in the IO schedulers and 2) allow to set, for
> > >> > > example, a maximum limit of dirty pages for each cgroup.
> > >> > >
> > >> >
> > >> > I think setting a maximum limit on dirty pages is an interesting thought.
> > >> > It sounds like as if memory controller can handle it?
> > >>
> > >> Exactly, the same above.
> > >
> > > Thinking more about it. Memory controller can probably enforce the higher
> > > limit but it would not easily translate into a fixed upper async write
> > > rate. Till the process hits the page cache limit or is slowed down by
> > > dirty page writeout, it can get a very high async write BW.
> > >
> > > So memory controller page cache limit will help but it would not direclty
> > > translate into what max bw limit patches are doing.
> > >
> > > Even if we do max bw control at IO scheduler level, async writes are
> > > problematic again. IO controller will not be able to throttle the process
> > > until it sees actuall write request. In big memory systems, writeout might
> > > not happen for some time and till then it will see a high throughput.
> > >
> > > So doing async write throttling at higher layer and not at IO scheduler
> > > layer gives us the opprotunity to produce more accurate results.
> > >
> > > For sync requests, I think IO scheduler max bw control should work fine.
> > >
> > > BTW, andrea, what is the use case of your patches? Andrew had mentioned
> > > that some people are already using it. I am curious to know will a
> > > proportional BW controller will solve the issues/requirements of these
> > > people or they have specific requirement of traffic shaping and max bw
> > > controller only.
> > >
> > > [..]
> > >> > > > Can you please give little more details here regarding how QoS requirements
> > >> > > > are not met with proportional weight?
> > >> > >
> > >> > > With proportional weights the whole bandwidth is allocated if no one
> > >> > > else is using it. When IO is submitted other tasks with a higher weight
> > >> > > can be forced to sleep until the IO generated by the low weight tasks is
> > >> > > not completely dispatched. Or any extent of the priority inversion
> > >> > > problems.
> > >> >
> > >> > Hmm..., I am not very sure here. When admin is allocating the weights, he
> > >> > has the whole picture. He knows how many groups are conteding for the disk
> > >> > and what could be the worst case scenario. So if I have got two groups
> > >> > with A and B with weight 1 and 2 and both are contending, then as an
> > >> > admin one would expect to get 33% of BW for group A in worst case (if
> > >> > group B is continuously backlogged). If B is not contending than A can get
> > >> > 100% of BW. So while configuring the system, will one not plan for worst
> > >> > case (33% for A, and 66 % for B)?
> > >>
> > >> OK, I'm quite convinced.. :)
> > >>
> > >> To a large degree, if we want to provide a BW reservation strategy we
> > >> must provide an interface that allows cgroups to ask for time slices
> > >> such as max/min 5 IO requests every 50ms or something like that.
> > >> Probably the same functionality can be achieved translating time slices
> > >> from weights, percentages or absolute BW limits.
> > >
> > > Ok, I would like to split it in two parts.
> > >
> > > I think providng minimum gurantee in absolute terms like 5 IO request
> > > every 50ms will be very hard because IO scheduler has no control over
> > > how many competitors are there. An easier thing will be to have minimum
> > > gurantees on share basis. For minimum BW (disk time slice) gurantee, admin
> > > shall have to create right cgroup hierarchy and assign weights properly and
> > > then admin can calculate what % of disk slice a particular group will get
> > > as minimum gurantee. (This is more complicated than this as there are
> > > time slices which are not accounted to any groups. During queue switch
> > > cfq starts the time slice counting only after first request has completed
> > > to offset the impact of seeking and i guess also NCQ).
> > >
> > > I think it should be possible to give max bandwidth gurantees in absolute
> > > terms, like io/s or sectors/sec or MB/sec etc, because only thing IO
> > > scheduler has to do is to not allow dispatch from a particular queue if
> > > it has crossed its limit and then either let the disk idle or move onto
> > > next eligible queue.
> > >
> > > The only issue here will be async writes. max bw gurantee for async writes
> > > at IO scheduler level might not mean much to application because of page
> > > cache.
> > 
> > I see so much of the memory controller coming up. Since we've been
> > discussing so many of these design points on mail, I wonder if it
> > makes sense to summarize them somewhere (a wiki?). Would anyone like
> > to take a shot at it?
> 
> Balbir, this is definitely a good idea. Just that once we have had some
> more discussion and some sort of understanding of issues, it might make
> more sense.

Sounds good. A wiki would be perfect IMHO, we could all contribute in
the documentation, integrate thoughts, ideas and easily keep everything
updated.

> 
> Got a question for you. Does memory controller already have the per cgroup
> dirty pages limit? If no, has this been discussed in the past? if yes,
> what was the conclsion?

I think the answer is in the previous email. :)

-Andrea
