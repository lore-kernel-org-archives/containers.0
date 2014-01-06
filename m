From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Mon, 6 Jan 2014 23:12:51 +0100
Message-ID: <20140106221251.GJ30183@twins.programming.kicks-ass.net>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1389044899.32504.43.camel-29DAm2eTeB2q+SSgkFU3IPooFf0ArEBIu+b9c/7xato@public.gmane.org>
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

On Mon, Jan 06, 2014 at 09:48:29PM +0000, Waskiewicz Jr, Peter P wrote:
> On Mon, 2014-01-06 at 22:26 +0100, Peter Zijlstra wrote:
> > On Mon, Jan 06, 2014 at 08:10:45PM +0000, Waskiewicz Jr, Peter P wrote:
> > > There is one per logical CPU.  However, in the current generation, they
> > > report on the usage of the same L3 cache.  But the CPU takes care of the
> > > resolution of which MSR write and read comes from the logical CPU, so
> > > software doesn't need to lock access to it from different CPUs.
> > 
> > What are the rules of RMIDs, I can't seem to find that in the SDM and I
> > think you're tagging cachelines with them. Which would mean that in
> > order to (re) use them you need a complete cache (L3) wipe.
> 
> The cacheline is tagged internally with the RMID as part of the waymask
> for the thread in the core.
> 
> > Without a wipe you keep having stale entries of the former user and no
> > clear indication on when your numbers are any good.
> 
> That can happen, yes.  If you have leftover cache data from a process
> that died that hasn't been evicted yet and it's assigned to the RMID
> you're using, you will see its included cache occupancy to the overall
> numbers.
> 
> > Also, is there any sane way of shooting down the entire L3?
> 
> That is a question I'd punt to hpa, but I'll ask him.  Looking around
> though, a WBINVD would certainly nuke things, but would hurt
> performance.  We could get creative with INVPCID as a process dies.  Let
> me ask him though and see if there's a good way to tidy up.

You seem to be assuming a RMID is for the entire task lifetime.

Since its a very limited resource that seems like a weird assumption to
me; there's plenty scenarios in which you'd want to re-use RMIDs that
belong to a still running context.

At which point you need to force wipe.. otherwise its impossible to tell
when the number reported makes any kind of sense.
