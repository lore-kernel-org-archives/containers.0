From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Tue, 14 Jan 2014 09:58:26 -0800
Message-ID: <52D57AC2.3090109__8101.5282813043$1389723562$gmane$org@zytor.com>
References: <20140106180636.GG30183@twins.programming.kicks-ass.net>
	<1389039035.32504.35.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106212623.GH30183@twins.programming.kicks-ass.net>
	<1389044899.32504.43.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106221251.GJ30183@twins.programming.kicks-ass.net>
	<1389048315.32504.57.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107083440.GL30183@twins.programming.kicks-ass.net>
	<1389107743.32504.69.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107211229.GF2480@laptop.programming.kicks-ass.net>
	<1389380100.32504.172.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140113075528.GR7572@laptop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140113075528.GR7572-RM5+C6weyIYnLiPH7yDmwOa11wxjtiyuLtmvbW2Dspo@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 01/12/2014 11:55 PM, Peter Zijlstra wrote:
> 
> The problem is, since there's a limited number of RMIDs we have to
> rotate at some point, but since changing RMIDs is nondeterministic we
> can't.
> 

This is fundamentally the crux here.  RMIDs are quite expensive for the
hardware to implement, so they are limited - but recycling them is
*very* expensive because you literally have to touch every line in the
cache.

	-hpa
