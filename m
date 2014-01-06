From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Mon, 6 Jan 2014 20:10:45 +0000
Message-ID: <1389039035.32504.35.camel@ppwaskie-mobl.amr.corp.intel.com>
References: <1388781285-18067-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
	<20140104161050.GA24306@htj.dyndns.org>
	<1388875369.9761.25.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140104225058.GC24306@htj.dyndns.org>
	<1388899376.9761.45.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106111624.GB5623@twins.programming.kicks-ass.net>
	<1389026035.32504.3.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106164150.GQ31570@twins.programming.kicks-ass.net>
	<1389026867.32504.16.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106180636.GG30183@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140106180636.GG30183-ndre7Fmf5hadTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
Content-Language: en-US
Content-ID: <EECFCE1508C26C4C9CF641EE47BEEE96-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2014-01-06 at 19:06 +0100, Peter Zijlstra wrote:
> On Mon, Jan 06, 2014 at 04:47:57PM +0000, Waskiewicz Jr, Peter P wrote:
> > > As is I don't really see a good use for RMIDs and I would simply not use
> > > them.
> > 
> > If you want to use CQM in the hardware, then the RMID is how you get the
> > cache usage data from the CPU.  If you don't want to use CQM, then you
> > can ignore RMIDs.
> 
> I think you can make do with a single RMID (per cpu). When you program
> the counter (be it for a task, cpu or cgroup context) you set the 1 RMID
> and EVSEL and read the CTR.
> 
> What I'm not entirely clear on is if the EVSEL and CTR MSR are per
> logical CPU or per L3 (package); /me prays they're per logical CPU.

There is one per logical CPU.  However, in the current generation, they
report on the usage of the same L3 cache.  But the CPU takes care of the
resolution of which MSR write and read comes from the logical CPU, so
software doesn't need to lock access to it from different CPUs.

> > One of the best use cases for using RMIDs is in virtualization.
> 
> *groan*.. /me plugs wax in ears and goes la-la-la-la
> 
> > A VM
> > may be a heavy cache user, or a light cache user.  Tracing different VMs
> > on different RMIDs can allow an admin to identify which VM may be
> > causing high levels of eviction, and either migrate it to another host,
> > or move other tasks/VMs to other hosts.  Without CQM, it's much harder
> > to find which process is eating the cache up.
> 
> Not necessarily VMs, there's plenty large processes that exhibit similar
> problems.. why must people always do VMs :-(

Completely agreed.  It's just the loudest people right now asking for
this capability are using VMs for the most part.

> That said, even with a single RMID you can get that information by
> simply running it against all competing processes one at a time. Since
> there's limited RMID space you need to rotate at some point anyway.
> 
> The cgroup interface you propose wouldn't allow for rotation; other than
> manual by creating different cgroups one after another.

I see your points, and I also think that the cgroup approach now isn't
the best way to make this completely flexible.  What about this:

Add a new read/write entry to the /proc/<pid> attributes that is the
RMID to assign that process to.  Then expose all the available RMIDs
in /sys/devices/system/cpu, say in a new directory platformqos (or
whatever), which then have all the statistics inside those, plus a knob
to enable monitoring or not.  Then all the kernel exposes is a way to
assign a PID to an RMID, and a way to turn on monitoring or turn it off,
and get the data.  I can then put a simple userspace tool together to
make the management suck less.

Thoughts?

Cheers,
-PJ

-- 
PJ Waskiewicz				Open Source Technology Center
peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org		Intel Corp.
