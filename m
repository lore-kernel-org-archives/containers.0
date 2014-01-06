From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Mon, 6 Jan 2014 16:47:57 +0000
Message-ID: <1389026867.32504.16.camel__36890.674083452$1389026894$gmane$org@ppwaskie-mobl.amr.corp.intel.com>
References: <1388781285-18067-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
	<20140104161050.GA24306@htj.dyndns.org>
	<1388875369.9761.25.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140104225058.GC24306@htj.dyndns.org>
	<1388899376.9761.45.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106111624.GB5623@twins.programming.kicks-ass.net>
	<1389026035.32504.3.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106164150.GQ31570@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140106164150.GQ31570-ndre7Fmf5hadTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
Content-Language: en-US
Content-ID: <4E3A1884C0FEAD4E9927FF129C94CA01-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

On Mon, 2014-01-06 at 17:41 +0100, Peter Zijlstra wrote:
> On Mon, Jan 06, 2014 at 04:34:04PM +0000, Waskiewicz Jr, Peter P wrote:
> > On Mon, 2014-01-06 at 12:16 +0100, Peter Zijlstra wrote:
> > > On Sun, Jan 05, 2014 at 05:23:07AM +0000, Waskiewicz Jr, Peter P wrote:
> > > > The CPU side is easy and clean.  When something in the software wants to
> > > > monitor when a particular task is scheduled and started, write whatever
> > > > RMID that task is assigned to (through some mechanism) to the proper MSR
> > > > in the CPU.  When that task is swapped out, clear the MSR to stop
> > > > monitoring of that RMID.  When that RMID's statistics are requested by
> > > > the software (through some mechanism), then the CPU's MSRs are written
> > > > with the RMID in question, and the value is read of what has been
> > > > collected so far.  In my case, I decided to use a cgroup for this
> > > > "mechanism" since so much of the grouping and task/group association
> > > > already exists and doesn't need to be rebuilt or re-invented.
> > > 
> > > This still doesn't explain why you can't use perf-cgroup for this.
> > 
> > I'm not completely familiar with perf-cgroup, so I looked for some
> > documentation for it to better understand it.  Are you referring to perf
> > -G to monitor an existing cgroup/all cgroups?  Or something else?  If
> > it's the former, I'm not following you how this would fit.
> 
> All the bits under CONFIG_CGROUP_PERF, I've no idea how userspace looks.

Ah ok.  Yes, the userspace side of perf really doesn't fit controlling
the CQM bits at all from what I see.

> > > > > In general, I'm quite strongly opposed against using cgroup as
> > > > > arbitrary grouping mechanism for anything other than resource control,
> > > > > especially given that we're moving away from multiple hierarchies.
> > > > 
> > > > Just to clarify then, would the mechanism in the cpuacct cgroup to
> > > > create a group off the root subsystem be considered multi-hierarchical?
> > > > If not, then the intent for this new cacheqos subsystem is to be
> > > > identical in that regard to cpuacct in the behavior.
> > > > 
> > > > This is a resource controller, it just happens to be tied to a hardware
> > > > resource instead of an OS resource.
> > > 
> > > No, cpuacct and perf-cgroup aren't actually controllers at all. They're
> > > resource monitors at best. Same with your Cache QoS Monitor, it doesn't
> > > control anything.
> > 
> > I may be using controller in a different way than you are.  Yes, the
> > Cache QoS Monitor is monitoring cache data.  But it is also controlling
> > the allocation and deallocation of RMIDs to tasks/task groups as
> > monitoring is enabled and disabled for those groups.  That's why I
> > called it a controller.  If that's not accurate, I apologize.
> 
> Yeah that's not accurate, nor desired I think, because you get into
> horrible problems with hierarchies, do child groups belong to your RMID
> or not?

I'd rather not support a child group of a child group.  Only groups off
the root, and each group would be assigned an RMID when it's activated
for monitoring.

> As is I don't really see a good use for RMIDs and I would simply not use
> them.

If you want to use CQM in the hardware, then the RMID is how you get the
cache usage data from the CPU.  If you don't want to use CQM, then you
can ignore RMIDs.

One of the best use cases for using RMIDs is in virtualization.  A VM
may be a heavy cache user, or a light cache user.  Tracing different VMs
on different RMIDs can allow an admin to identify which VM may be
causing high levels of eviction, and either migrate it to another host,
or move other tasks/VMs to other hosts.  Without CQM, it's much harder
to find which process is eating the cache up.

Cheers,
-PJ

-- 
PJ Waskiewicz				Open Source Technology Center
peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org		Intel Corp.
