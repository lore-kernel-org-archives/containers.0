From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [RFC] tracing: Adding cgroup aware tracing functionality
Date: Sat, 09 Apr 2011 13:08:35 +0200
Message-ID: <1302347315.9086.1246.camel__31978.424875024$1302347383$gmane$org@twins>
References: <BANLkTik_jtjWTsOueUzfdQXRx17OcgyDgA@mail.gmail.com>
	<20110407013349.GH1867@nowhere>
	<BANLkTinKsYqkEEUu98t+Gn9ciPn_bmsMFQ@mail.gmail.com>
	<20110407120608.GB1798@nowhere>
	<BANLkTim70Ef0gy+W+4h76PABn32wDRvTtw@mail.gmail.com>
	<20110407213208.GE1798@nowhere>
	<BANLkTimOvWYgiRc6cviB6iiUt9MH-Au1qw@mail.gmail.com>
	<20110408002812.GG1798@nowhere>  <1302248268.21026.18.camel@frodo>
	<1302271670.9086.154.camel@twins>  <1302282130.21026.45.camel@frodo>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1302282130.21026.45.camel@frodo>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Cc: Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Sharp <dhsharp-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ken Chen <kenchen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vaibhav Nagarnaik <vnagarnaik-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2011-04-08 at 13:02 -0400, Steven Rostedt wrote:
> On Fri, 2011-04-08 at 16:07 +0200, Peter Zijlstra wrote:
> 
> > > As you said perf has a lot of overhead due to data that it saves per
> > > event. 
> > 
> > Someday you should actually read the perf code before you say something.
> 
> I have looked at the code although not as much recently, but I do plan
> on looking at it again in much more detail. But you are correct that I
> did not make this comment on the code itself, but on looking at the
> data:

> 1051776/8766 = 119

> 2957312/38268 = 77
> 
> As you stated, I need to look more into the perf code (which I plan on
> doing), but it seems that perf adds 42 bytes more per event. Perhaps
> this is something we can fix. 

Aside from the 8 byte header everything else is configurable with
PERF_SAMPLE_flags and probably has some overlap with stuff we also have
in the tracepoint data we then get through PERF_SAMPLE_RAW

> I'd love to make both perf and ftrace be
> able to limit its header. There's no reason to record the pid for every
> event if we don't need to. As well as the preempt count and interrupt
> status. But these are legacy from the latency tracer code from -rt.

Right.

> I think there's a lot of work that we can do make tracing in perf more
> compatible with the tracing features of ftrace. I did say the ugly word
> "roadmap" but perhaps it's just direction that we need. I feel we are
> all a bunch of cooks with their own taste, and we don't all like the
> spices used by each other.

Partly yeah, but there's also real functional differences, the last time
I profiled perf with perf (yay for recursion) we spend a lot of time in
conditionals. Due to the fact that perf is mainly sampling based (and
tracing being samples with period==1) and all that output
configurability there's a true forest of if statements to pass through
and I'm fairly sure we totally trash the branch predictor on that.
