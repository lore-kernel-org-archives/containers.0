From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Tue, 7 Jan 2014 09:34:40 +0100
Message-ID: <20140107083440.GL30183@twins.programming.kicks-ass.net>
References: <20140106111624.GB5623@twins.programming.kicks-ass.net>
	<1389026035.32504.3.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106164150.GQ31570@twins.programming.kicks-ass.net>
	<1389026867.32504.16.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106180636.GG30183@twins.programming.kicks-ass.net>
	<1389039035.32504.35.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106212623.GH30183@twins.programming.kicks-ass.net>
	<1389044899.32504.43.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106221251.GJ30183@twins.programming.kicks-ass.net>
	<1389048315.32504.57.camel@ppwaskie-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1389048315.32504.57.camel-29DAm2eTeB2q+SSgkFU3IPooFf0ArEBIu+b9c/7xato@public.gmane.org>
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

On Mon, Jan 06, 2014 at 10:45:24PM +0000, Waskiewicz Jr, Peter P wrote:
> > Since its a very limited resource that seems like a weird assumption to
> > me; there's plenty scenarios in which you'd want to re-use RMIDs that
> > belong to a still running context.
> 
> I think I see what you're really asking, let me rephrase to see if I'm
> now understanding you:  What happens to a running process' cache
> assigned to one RMID when it's reassigned to a different RMID?  Does the
> RMID get updated internally or does it appear as still belonging to the
> old RMID?
> 
> If that's your question, then the CPU will update the cache entry with
> the correct RMID.  It knows to do this because the when the process is
> scheduled, the OS will write the IA32_PQR_ASSOC MSR with the RMID map to
> start monitoring.  That's when the RMID will be updated in the cache.
> However, any cacheline for a process that is moved to a different RMID,
> but doesn't have an opportunity to be scheduled, will still show up on
> the old RMID until it gets to run with the new RMID.
> 
> Let me know if that better explains what I think you're asking.

Still confused here. So what you're saying is that cachelines get tagged
with {CR3,RMID} and when they observe the same CR3 with a different RMID
the hardware will iterate the entire cache and update all tuples?

That seems both very expensive and undesirable. It would mean you could
never use the RMID to creates slices of a process since you're stuck to
the CR3.

It also makes me wonder why we have the RMID at all; because if you're
already tagging every line with the CR3, why not build the cache monitor
on that. Just query the occupancy for all CR3s in your group and add.


The other possible interpretation is that it updates on-demand whenever
it touches a cacheline. But in that case, how do you deal with the
non-exclusive states? Does the last RMID to touch a non-exclusive
cacheline simply claim the entire line?

But that doesn't avoid the problem; because as soon as you change the
PQR_ASSOC RMID you still need to go run for a while to touch 'all' your
lines.

This duration is indeterminate; which again brings us back to needing to
first wipe the entire cache.
