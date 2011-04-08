From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] tracing: Adding cgroup aware tracing functionality
Date: Fri, 8 Apr 2011 02:28:16 +0200
Message-ID: <20110408002812.GG1798__7015.67829023606$1302226201$gmane$org@nowhere>
References: <BANLkTik_jtjWTsOueUzfdQXRx17OcgyDgA@mail.gmail.com>
	<20110407013349.GH1867@nowhere>
	<BANLkTinKsYqkEEUu98t+Gn9ciPn_bmsMFQ@mail.gmail.com>
	<20110407120608.GB1798@nowhere>
	<BANLkTim70Ef0gy+W+4h76PABn32wDRvTtw@mail.gmail.com>
	<20110407213208.GE1798@nowhere>
	<BANLkTimOvWYgiRc6cviB6iiUt9MH-Au1qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTimOvWYgiRc6cviB6iiUt9MH-Au1qw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Sharp <dhsharp-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ken Chen <kenchen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vaibhav Nagarnaik <vnagarnaik-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 07, 2011 at 03:42:08PM -0700, David Sharp wrote:
> On Thu, Apr 7, 2011 at 2:32 PM, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Nothing significant since then, I believe. But the hotspots are known
> > and some are relatively low hanging fruits if you want to get closer to
> > ftrace throughput:
> >
> > * When an event triggers, we do a double copy. A first one in a temporary
> > buffer and a second one from the temporary buffer to the event'ss one.
> > This is because we don't have the same discard feature than in ftrace
> > buffer. We need to first filter on the temporary buffer and give up if the filter
> > matched instead of copying to the main buffer.
> >
> > As a short term solution: have a fast path tracing for the case where we
> > don't have a filter: directly copy to the main buffer.
> >
> > In the longer term I think we want to filter on tracepoint parameters
> > rather than in the ending trace.
> >
> > * We save more things in perf, because we have the perf headers. So we
> > save the pid twice: once in trace event headers, second in perf headers.
> > We need to drop the one from the trace event.
> > Also in the case of pure tracing, we don't need to save the ip in the perf
> > headers.
> >
> > * We have lots of conditionals in the fast path, due to some exclusion options,
> > overflow count tracking, etc... We probably want a fastpath tracing function
> > for the high volume tracing case, something that goes quickly to the buffer
> > saving.
> >
> > And there are things common to ftrace and perf that we probably want to have:
> > like tracking of pids using sched switch event if one is running, instead
> > of saving the pid on each traces. And get rid of the preempt_count in the
> > trace event headers, at least have the possibility to choose whether we want
> > it.
> >
> >
> > Any help in any of these tasks would be very welcome.
> >
> 
> This is all very interesting, but doesn't really help us. I'd prefer
> to focus on the proposal itself than discuss the merits of perf and
> ftrace. We're using ftrace for the foreseeable future, and afaik, it's
> still a maintained part of the kernel. If perf improves its
> performance for tracing, then we can consider switching to it. We
> could invest time improving perf, and that might be worthwhile, but
> ftrace is here now.

You are investing upstream for your tracing needs. And that's really
a nice step that I appreciate, as IIRC, Google had its own internal tracing
(ktrace?) before. Nonetheless you can't be such a significant
user/developer of the upstream kernel tracing and at the same time ignore some
key problems of the actual big picture of it.

You need to be aware that we are not going anywhere if we duplicate
every features between perf and ftrace. We want to merge the common
pieces, keep the best of them and not expand the two tier tracing of today.

I wish people stop thinking about perf and ftrace as
competitors. Probably developers could start having a sane view
once both will have close performances and then we can start
thinking about a common backend (a buffer abstraction, which development
can be iterated incrementally, usable with a syscall) and eliminate the
overlapping pieces.

I'm not asking you to unify the kernel tracing all alone. But you need to
start to enlarge your view.

I tend to think perf is more suitable for finegrained context definition
in general.
