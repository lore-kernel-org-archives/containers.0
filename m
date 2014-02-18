From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Tue, 18 Feb 2014 20:35:28 +0100
Message-ID: <20140218193528.GQ14089__15215.4570016593$1392752156$gmane$org@laptop.programming.kicks-ass.net>
References: <20140106221251.GJ30183@twins.programming.kicks-ass.net>
	<1389048315.32504.57.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107083440.GL30183@twins.programming.kicks-ass.net>
	<1389107743.32504.69.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107211229.GF2480@laptop.programming.kicks-ass.net>
	<1389380100.32504.172.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140113075528.GR7572@laptop.programming.kicks-ass.net>
	<52D57AC2.3090109@zytor.com>
	<20140127173420.GA9636@twins.programming.kicks-ass.net>
	<1392744567.3069.42.camel@ppwaskie-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392744567.3069.42.camel-29DAm2eTeB2q+SSgkFU3IPooFf0ArEBIu+b9c/7xato@public.gmane.org>
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
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 18, 2014 at 05:29:42PM +0000, Waskiewicz Jr, Peter P wrote:
> > Its not a problem that changing the task:RMID map is expensive, what is
> > a problem is that there's no deterministic fashion of doing it.
> 
> We are going to add to the SDM that changing RMID's often/frequently is
> not the intended use case for this feature, and can cause bogus data.
> The real intent is to land threads into an RMID, and run that until the
> threads are effectively done.
> 
> That being said, reassigning a thread to a new RMID is certainly
> supported, just "frequent" updates is not encouraged at all.

You don't even need really high frequency, just unsynchronized wrt
reading the counter. Suppose A flips the RMIDs about and just when its
done programming B reads them.

At that point you've got 0 guarantee the data makes any kind of sense.

> I do see that, however the userspace interface for this isn't ideal for
> how the feature is intended to be used.  I'm still planning to have this
> be managed per process in /proc/<pid>, I just had other priorities push
> this back a bit on my stovetop.

So I really don't like anything /proc/$pid/ nor do I really see a point in
doing that. What are you going to do in the /proc/$pid/ thing anyway?
Exposing raw RMIDs is an absolute no-no, and anything else is going to
end up being yet-another-grouping thing and thus not much different from
cgroups.

> Also, now that the new SDM is available

Can you guys please set up a mailing list already so we know when
there's new versions out? Ideally mailing out the actual PDF too so I
get the automagic download and archive for all versions.

> , there is a new feature added to
> the same family as CQM, called Memory Bandwidth Monitoring (MBM).  The
> original cgroup approach would have allowed another subsystem be added
> next to cacheqos; the perf-cgroup here is not easily expandable.
> The /proc/<pid> approach can add MBM pretty easily alongside CQM.

I'll have to go read up what you've done now, but if its also RMID based
I don't see why the proposed scheme won't work.

> > The below is a rough draft, most if not all XXXs should be
> > fixed/finished. But given I don't actually have hardware that supports
> > this stuff (afaik) I couldn't be arsed.
> 
> The hardware is not publicly available yet, but I know that Red Hat and
> others have some of these platforms for testing.

Yeah, not in my house therefore it doesn't exist :-)

> I really appreciate the patch.  There was a good amount of thought put
> into this, and gave a good set of different viewpoints.  I'll keep the
> comments all here in one place, it'll be easier to discuss than
> disjointed in the code.
> 
> The rotation idea to reclaim RMID's no longer in use is interesting.
> This differs from the original patch where the original patch would
> reclaim the RMID when monitoring was disabled for that group of
> processes.
> 
> I can see a merged sort of approach, where if monitoring for a group of
> processes is disabled, we can place that RMID onto a reclaim list.  The
> next time an RMID is requested (monitoring is enabled for a
> process/group of processes), the reclaim list is searched for an RMID
> that has 0 occupancy (i.e. not in use), or worst-case, find and assign
> one with the lowest occupancy.  I did discuss this with hpa offline and
> this seemed reasonable.
> 
> Thoughts?

So you have to wait for one 'freed' RMID to become empty before
'allowing' reads of the other RMIDs, otherwise the visible value can be
complete rubbish. Even for low frequency rotation, see the above
scenario about asynchronous operations.

This means you have to always have at least one free RMID.
