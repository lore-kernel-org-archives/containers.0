From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Mon, 6 Jan 2014 22:45:24 +0000
Message-ID: <1389048315.32504.57.camel@ppwaskie-mobl.amr.corp.intel.com>
References: <20140104225058.GC24306@htj.dyndns.org>
	<1388899376.9761.45.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106111624.GB5623@twins.programming.kicks-ass.net>
	<1389026035.32504.3.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106164150.GQ31570@twins.programming.kicks-ass.net>
	<1389026867.32504.16.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106180636.GG30183@twins.programming.kicks-ass.net>
	<1389039035.32504.35.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106212623.GH30183@twins.programming.kicks-ass.net>
	<1389044899.32504.43.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106221251.GJ30183@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140106221251.GJ30183-ndre7Fmf5hadTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
Content-Language: en-US
Content-ID: <2F8419A77762AE43956DF97F14578252-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

On Mon, 2014-01-06 at 23:12 +0100, Peter Zijlstra wrote:
> On Mon, Jan 06, 2014 at 09:48:29PM +0000, Waskiewicz Jr, Peter P wrote:
> > The cacheline is tagged internally with the RMID as part of the waymask
> > for the thread in the core.
> > 
> > > Without a wipe you keep having stale entries of the former user and no
> > > clear indication on when your numbers are any good.
> > 
> > That can happen, yes.  If you have leftover cache data from a process
> > that died that hasn't been evicted yet and it's assigned to the RMID
> > you're using, you will see its included cache occupancy to the overall
> > numbers.
> > 
> > > Also, is there any sane way of shooting down the entire L3?
> > 
> > That is a question I'd punt to hpa, but I'll ask him.  Looking around
> > though, a WBINVD would certainly nuke things, but would hurt
> > performance.  We could get creative with INVPCID as a process dies.  Let
> > me ask him though and see if there's a good way to tidy up.
> 
> You seem to be assuming a RMID is for the entire task lifetime.

No, the RMID can be changed if the user wants to reassign the process to
a different group/RMID.  If I'm coming across otherwise, then my
apologies.

> Since its a very limited resource that seems like a weird assumption to
> me; there's plenty scenarios in which you'd want to re-use RMIDs that
> belong to a still running context.

I think I see what you're really asking, let me rephrase to see if I'm
now understanding you:  What happens to a running process' cache
assigned to one RMID when it's reassigned to a different RMID?  Does the
RMID get updated internally or does it appear as still belonging to the
old RMID?

If that's your question, then the CPU will update the cache entry with
the correct RMID.  It knows to do this because the when the process is
scheduled, the OS will write the IA32_PQR_ASSOC MSR with the RMID map to
start monitoring.  That's when the RMID will be updated in the cache.
However, any cacheline for a process that is moved to a different RMID,
but doesn't have an opportunity to be scheduled, will still show up on
the old RMID until it gets to run with the new RMID.

Let me know if that better explains what I think you're asking.

-PJ

-- 
PJ Waskiewicz				Open Source Technology Center
peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org		Intel Corp.
