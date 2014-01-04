From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Sat, 4 Jan 2014 22:43:00 +0000
Message-ID: <1388875369.9761.25.camel@ppwaskie-mobl.amr.corp.intel.com>
References: <1388781285-18067-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
	<20140104161050.GA24306@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140104161050.GA24306-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
Content-Language: en-US
Content-ID: <8B0348237BEE1143A5E490EC6FA26B12-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "H.
	Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, 2014-01-04 at 11:10 -0500, Tejun Heo wrote:
> Hello,

Hi Tejun,

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
> I don't really understand why this is implemented as part of cgroup.
> There doesn't seem to be anything which requires cgroup.  Wouldn't
> just doing it per-process make more sense?  Even grouping would be
> better done along the traditional process hierarchy, no?  And
> per-cgroup accounting can be trivially achieved from userland by just
> accumulating the stats according to the process's cgroup membership.
> What am I missing here?

Thanks for the quick response!  I knew the approach would generate
questions, so let me explain.

The feature I'm enabling in the Xeon processors is fairly simple.  It
has a set of Resource Monitoring ID's (RMIDs), and those are used by the
CPU cores to track the cache usage while any process associated with the
RMID is running.  The more complicated part is how to present the
interface of creating RMID groups and assigning processes to them for
both tracking, and for stat collection.

We discussed (internally) a few different approaches to implement this.
The first natural thought was this is similar to other PMU features, but
this deals with processes and groups of processes, not overall CPU core
or uncore state.  Given the way processes in a cgroup can be grouped
together and treated as single entities, this felt like a natural fit
with the RMID concept.

Simply put, when we want to allocate an RMID for monitoring httpd
traffic, we can create a new child in the subsystem hierarchy, and
assign the httpd processes to it.  Then the RMID can be assigned to the
subsystem, and each process inherits that RMID.  So instead of dealing
with assigning an RMID to each and every process, we can leverage the
existing cgroup mechanisms for grouping processes and their children to
a group, and they inherit the RMID.

Please let me know if this is a better explanation, and gives a better
picture of why we decided to approach the implementation this way.  Also
note that this feature, Cache QoS Monitoring, is the first in a series
of Platform QoS Monitoring features that will be coming.  So this isn't
a one-off feature, so however this first piece gets accepted, we want to
make sure it's easy to expand and not impact userspace tools repeatedly
(if possible).

Cheers,
-PJ Waskiewicz

--------------
Intel Open Source Technology Center
