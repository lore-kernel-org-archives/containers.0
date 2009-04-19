From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO controller discussion (Was: Re: [PATCH 01/10] Documentation)
Date: Sun, 19 Apr 2009 09:21:29 -0400
Message-ID: <20090419132129.GD8493@redhat.com>
References: <1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com> <49D8CB17.7040501@gmail.com>
	<20090407064046.GB20498@redhat.com> <20090408203756.GB10077@linux>
	<20090416183753.GE8896@redhat.com> <20090417093656.GA5246@linux>
	<20090417141358.GD29086@redhat.com> <20090417223809.GA3758@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090417223809.GA3758@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jen
List-Id: containers.vger.kernel.org

On Sat, Apr 18, 2009 at 12:38:10AM +0200, Andrea Righi wrote:
> On Fri, Apr 17, 2009 at 10:13:58AM -0400, Vivek Goyal wrote:
> > > > I think setting a maximum limit on dirty pages is an interesting thought.
> > > > It sounds like as if memory controller can handle it?
> > > 
> > > Exactly, the same above.
> > 
> > Thinking more about it. Memory controller can probably enforce the higher
> > limit but it would not easily translate into a fixed upper async write
> > rate. Till the process hits the page cache limit or is slowed down by
> > dirty page writeout, it can get a very high async write BW.
> > 
> > So memory controller page cache limit will help but it would not direclty
> > translate into what max bw limit patches are doing.
> 
> The memory controller can be used to set an upper limit of the dirty
> pages. When this limit is exceeded the tasks in the cgroup can be forced
> to write the exceeding dirty pages to disk. At this point the IO
> controller can: 1) throttle the task that is going to submit the IO
> requests, if the guy that dirtied the pages was actually the task
> itself, or 2) delay the submission of those requests to the elevator (or
> at the IO scheduler level) if it's writeback IO (e.g., made by pdflush).
> 

True, per cgroup dirty pages limit will help in making sure one cgroup
does not run away mojority share of the page cache. And once a cgroup 
hits dirty limit it is forced to do write back.

But my point is that it hels in bandwidth control but it does not directly
translate into what max bw patches are doing. I thought your goal with
max bw patches was to provide the consistent upper limit on BW seem by
the application. So till an application hits the per cgroup dirty limit,
it might see an spike in async write BW (much more than what has been 
specified by per cgroup max bw limit) and that will defeat the purpose
of max bw controller up to some extent?

> Both functionalities should allow to have a BW control and avoid that
> any single cgroup can entirely exhaust the global limit of dirty pages.
> 
> > 
> > Even if we do max bw control at IO scheduler level, async writes are
> > problematic again. IO controller will not be able to throttle the process
> > until it sees actuall write request. In big memory systems, writeout might
> > not happen for some time and till then it will see a high throughput.
> > 
> > So doing async write throttling at higher layer and not at IO scheduler
> > layer gives us the opprotunity to produce more accurate results.
> 
> Totally agree.

I will correct myself here. After going through the documentation of
max bw controller patches, it looks like that you are also controlling
async writes only after they are actually being written to the disk and
not at the time of async write admission in page cache.

If that's the case then doing this control at IO scheduler level should
produce the similar results what you are seeing now with higher level 
control. In fact throttling at IO scheduler has advantage that one does
not have to worry about maintaining multiple queues for separate class
and prio requests as IO scheduler already does it.

Thanks
Vivek

> 
> > 
> > For sync requests, I think IO scheduler max bw control should work fine.
> 
> ditto
> 
> -Andrea
