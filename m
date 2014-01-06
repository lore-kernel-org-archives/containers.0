From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Mon, 6 Jan 2014 16:42:29 +0000
Message-ID: <1389026538.32504.11.camel__49959.1745589443$1389026565$gmane$org@ppwaskie-mobl.amr.corp.intel.com>
References: <1388781285-18067-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
	<20140106110803.GA5623@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140106110803.GA5623-ndre7Fmf5hadTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
Content-Language: en-US
Content-ID: <8D57DD7440A0D04186515BF31508FF8E-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H.
	Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2014-01-06 at 12:08 +0100, Peter Zijlstra wrote:
> On Fri, Jan 03, 2014 at 12:34:41PM -0800, Peter P Waskiewicz Jr wrote:
> > The CPU features themselves are relatively straight-forward, but
> > the presentation of the data is less straight-forward.  Since this
> > tracks cache usage and occupancy per process (by swapping Resource
> > Monitor IDs, or RMIDs, when processes are rescheduled), perf would
> > not be a good fit for this data, which does not report on a
> > per-process level.  Therefore, a new cgroup subsystem, cacheqos, has
> > been added.  This operates very similarly to the cpu and cpuacct
> > cgroup subsystems, where tasks can be grouped into sub-leaves of the
> > root-level cgroup.
> 
> This doesn't make any sense.. From a quick SDM read you can do pretty
> much whatever with those RMIDs. If you allocate a RMID per task (thread
> in userspace) you can actually measure things on a task basis.

Exactly.  An RMID can be assigned to a single task or a group of tasks.
Because the RMID is a hardware resource and is limited, the
implementation of using it is what we're really discussing here.  Our
approach is to either monitor per-task, or per group of tasks.

> From then on you can use perf-cgroup to group whatever tasks you want.
> 
> So please be more explicit in why you think this doesn't fit into perf.

I said this in my other reply to the other thread, but I'll ask again
because I'm not following.  I'm looking for information on perf-cgroup,
and I all see is a way to monitor CPU events for tasks in a cgroup (perf
-G option).

The other part I'm not seeing is how to control the RMIDs being
allocated across to different groups.  There may be 100 task groups to
monitor, but only 32 RMIDs.  So the RMIDs need to be handed out to
active tasks and then enabled, data extracted, then disabled.  That was
the intent of the cacheqos.monitor_cache knob.

The bottom line is I'm asking for a bit more information from you about
perf-cgroup, since it sounds like you see a fit for CQM here, and I'm
not seeing what you're looking at yet.  Any information is much
appreciated.

Cheers,
-PJ

-- 
PJ Waskiewicz				Open Source Technology Center
peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org		Intel Corp.
