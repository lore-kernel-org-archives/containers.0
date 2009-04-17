From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO controller discussion (Was: Re: [PATCH 01/10] Documentation)
Date: Sat, 18 Apr 2009 00:38:10 +0200
Message-ID: <20090417223809.GA3758__13300.9699442939$1240008145$gmane$org@linux>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090312001146.74591b9d.akpm@linux-foundation.org>
	<20090312180126.GI10919@redhat.com> <49D8CB17.7040501@gmail.com>
	<20090407064046.GB20498@redhat.com> <20090408203756.GB10077@linux>
	<20090416183753.GE8896@redhat.com> <20090417093656.GA5246@linux>
	<20090417141358.GD29086@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090417141358.GD29086-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 17, 2009 at 10:13:58AM -0400, Vivek Goyal wrote:
> > > I think setting a maximum limit on dirty pages is an interesting thought.
> > > It sounds like as if memory controller can handle it?
> > 
> > Exactly, the same above.
> 
> Thinking more about it. Memory controller can probably enforce the higher
> limit but it would not easily translate into a fixed upper async write
> rate. Till the process hits the page cache limit or is slowed down by
> dirty page writeout, it can get a very high async write BW.
> 
> So memory controller page cache limit will help but it would not direclty
> translate into what max bw limit patches are doing.

The memory controller can be used to set an upper limit of the dirty
pages. When this limit is exceeded the tasks in the cgroup can be forced
to write the exceeding dirty pages to disk. At this point the IO
controller can: 1) throttle the task that is going to submit the IO
requests, if the guy that dirtied the pages was actually the task
itself, or 2) delay the submission of those requests to the elevator (or
at the IO scheduler level) if it's writeback IO (e.g., made by pdflush).

Both functionalities should allow to have a BW control and avoid that
any single cgroup can entirely exhaust the global limit of dirty pages.

> 
> Even if we do max bw control at IO scheduler level, async writes are
> problematic again. IO controller will not be able to throttle the process
> until it sees actuall write request. In big memory systems, writeout might
> not happen for some time and till then it will see a high throughput.
> 
> So doing async write throttling at higher layer and not at IO scheduler
> layer gives us the opprotunity to produce more accurate results.

Totally agree.

> 
> For sync requests, I think IO scheduler max bw control should work fine.

ditto

-Andrea
