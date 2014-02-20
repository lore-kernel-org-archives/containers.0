From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Thu, 20 Feb 2014 17:58:09 +0100
Message-ID: <20140220165809.GI9987@twins.programming.kicks-ass.net>
References: <20140107083440.GL30183@twins.programming.kicks-ass.net>
	<1389107743.32504.69.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107211229.GF2480@laptop.programming.kicks-ass.net>
	<1389380100.32504.172.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140113075528.GR7572@laptop.programming.kicks-ass.net>
	<52D57AC2.3090109@zytor.com>
	<20140127173420.GA9636@twins.programming.kicks-ass.net>
	<1392744567.3069.42.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140218193528.GQ14089@laptop.programming.kicks-ass.net>
	<1392753259.607.9.camel@ppwaskie-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392753259.607.9.camel-29DAm2eTeB2q+SSgkFU3IPooFf0ArEBIu+b9c/7xato@public.gmane.org>
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

On Tue, Feb 18, 2014 at 07:54:34PM +0000, Waskiewicz Jr, Peter P wrote:
> On Tue, 2014-02-18 at 20:35 +0100, Peter Zijlstra wrote:
> > On Tue, Feb 18, 2014 at 05:29:42PM +0000, Waskiewicz Jr, Peter P wrote:
> > > > Its not a problem that changing the task:RMID map is expensive, what is
> > > > a problem is that there's no deterministic fashion of doing it.
> > > 
> > > We are going to add to the SDM that changing RMID's often/frequently is
> > > not the intended use case for this feature, and can cause bogus data.
> > > The real intent is to land threads into an RMID, and run that until the
> > > threads are effectively done.
> > > 
> > > That being said, reassigning a thread to a new RMID is certainly
> > > supported, just "frequent" updates is not encouraged at all.
> > 
> > You don't even need really high frequency, just unsynchronized wrt
> > reading the counter. Suppose A flips the RMIDs about and just when its
> > done programming B reads them.
> > 
> > At that point you've got 0 guarantee the data makes any kind of sense.
> 
> Agreed, there is no guarantee with how the hardware is designed.  We
> don't have an instruction that can nuke RMID-tagged cachelines from the
> cache, and the CPU guys (along with hpa) have been very explicit that
> wbinv is not an option.

Right; but if you wait for the 'unused' RMID to drop to 0 occupancy you
have a fair chance all lines have an active RMID tag. There are a few
corner cases where this is not so, but given the hardware this is the
best I could come up with.

Under constant L3 pressure it basically means that your new RMID
assignment has reached steady state (in as far as the workload has one
to begin with).

wbinv is actually worse in that it wipes everything, it will guarantee
any occupancy read will not over-report, but almost guarantees
under-reporting if you're 'quick'.

The only really sucky part is that we have to poll for this situation to
occur.

> > > I do see that, however the userspace interface for this isn't ideal for
> > > how the feature is intended to be used.  I'm still planning to have this
> > > be managed per process in /proc/<pid>, I just had other priorities push
> > > this back a bit on my stovetop.
> > 
> > So I really don't like anything /proc/$pid/ nor do I really see a point in
> > doing that. What are you going to do in the /proc/$pid/ thing anyway?
> > Exposing raw RMIDs is an absolute no-no, and anything else is going to
> > end up being yet-another-grouping thing and thus not much different from
> > cgroups.
> 
> Exactly.  The cgroup grouping mechanisms fit really well with this
> feature.  I was exploring another way to do it given the pushback on
> using cgroups initially.  The RMID's won't be exposed, rather a group
> identifier (in cgroups it's the new subdirectory in the subsystem), and
> RMIDs are assigned by the kernel, completely hidden to userspace.

So I don't see the need for a custom controller; what's wrong with the
perf-cgroup approach I proposed?

The thing is, a custom controller will have to jump through most of the
same hoops anyway.

> > > Also, now that the new SDM is available
> > 
> > Can you guys please set up a mailing list already so we know when
> > there's new versions out? Ideally mailing out the actual PDF too so I
> > get the automagic download and archive for all versions.
> 
> I assume this has been requested before.  As I'm typing this, I just
> received the notification internally that the new SDM is now published.
> I'll forward your request along and see what I hear back.

Yeah, just about every time an Intel person tells me I've been staring
at the wrong version -- usually several emails down a confused
discussion.

The even better option would be the TeX source of the document so we can
diff(1) for changes (and yes; I suspect you're not using TeX like you
should be :-).

Currently we manually keep histerical versions and hope to spot the
differences by hand, but its very painful.

> > > , there is a new feature added to
> > > the same family as CQM, called Memory Bandwidth Monitoring (MBM).  The
> > > original cgroup approach would have allowed another subsystem be added
> > > next to cacheqos; the perf-cgroup here is not easily expandable.
> > > The /proc/<pid> approach can add MBM pretty easily alongside CQM.
> > 
> > I'll have to go read up what you've done now, but if its also RMID based
> > I don't see why the proposed scheme won't work.

OK; so in the Feb 2014 edition of the Intel SDM for x86_64...

Vol 3c, table 35-23, lists the QM_EVTSEL, QM_CTR and PQR_ASSOC as per
thread, which I read to mean per logical cpu.

(and here I ask what's a PQR)

Vol 3b. 17.14.7 has the following text:

"Thread access to the IA32_QM_EVTSEL and IA32_QM_CTR MSR pair should be
serialized to avoid situations where one thread changes the RMID/EvtID
just before another thread reads monitoring data from IA32_QM_CTR."

The PQR_ASSOC is also stated to be per logical CPU in 17.14.3; but that
same section fails to be explicit for the QM_* thingies.

So which is it; are the QM_* MSRs shared across threads or is it per
thread?

Vol 3b. 17.14.5.2 MBM is rather sparse, but what I can gather from the
text in 17.14.5 the MBM events work more like normal PMU events in that
once you program the QM_EVTSEL it starts counting.

However, there doesn't appear to be an EN bit, nor is CTR writable. So
it appears we must simply set EVTSEL, quickly read CTR as start value,
and at some time later (while also keeping track of time) read it again
and compute the lines/time for bandwidth?

I suppose that since we have multiple cores (or threads, depending on
how the MSRs are implemented) per L3 we can model the thing as having
that many counters.

A bit crappy because we'll have to IPI ourselves into oblivion to
control all those counters, a better deal would've been that many MSRs
package wide -- like the other uncore PMUs have.
