From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Mon, 6 Jan 2014 19:06:36 +0100
Message-ID: <20140106180636.GG30183@twins.programming.kicks-ass.net>
References: <1388781285-18067-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
	<20140104161050.GA24306@htj.dyndns.org>
	<1388875369.9761.25.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140104225058.GC24306@htj.dyndns.org>
	<1388899376.9761.45.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106111624.GB5623@twins.programming.kicks-ass.net>
	<1389026035.32504.3.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106164150.GQ31570@twins.programming.kicks-ass.net>
	<1389026867.32504.16.camel@ppwaskie-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1389026867.32504.16.camel-29DAm2eTeB2q+SSgkFU3IPooFf0ArEBIu+b9c/7xato@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jan 06, 2014 at 04:47:57PM +0000, Waskiewicz Jr, Peter P wrote:
> > As is I don't really see a good use for RMIDs and I would simply not use
> > them.
> 
> If you want to use CQM in the hardware, then the RMID is how you get the
> cache usage data from the CPU.  If you don't want to use CQM, then you
> can ignore RMIDs.

I think you can make do with a single RMID (per cpu). When you program
the counter (be it for a task, cpu or cgroup context) you set the 1 RMID
and EVSEL and read the CTR.

What I'm not entirely clear on is if the EVSEL and CTR MSR are per
logical CPU or per L3 (package); /me prays they're per logical CPU.

> One of the best use cases for using RMIDs is in virtualization.

*groan*.. /me plugs wax in ears and goes la-la-la-la

> A VM
> may be a heavy cache user, or a light cache user.  Tracing different VMs
> on different RMIDs can allow an admin to identify which VM may be
> causing high levels of eviction, and either migrate it to another host,
> or move other tasks/VMs to other hosts.  Without CQM, it's much harder
> to find which process is eating the cache up.

Not necessarily VMs, there's plenty large processes that exhibit similar
problems.. why must people always do VMs :-(

That said, even with a single RMID you can get that information by
simply running it against all competing processes one at a time. Since
there's limited RMID space you need to rotate at some point anyway.

The cgroup interface you propose wouldn't allow for rotation; other than
manual by creating different cgroups one after another.
