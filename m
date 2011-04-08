From: Justin TerAvest <teravest-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] tracing: Adding cgroup aware tracing functionality
Date: Fri, 8 Apr 2011 13:27:00 -0700
Message-ID: <BANLkTin-05pi94_qDw8Qkn2jCpv_V9j6sw__41675.48308983$1302294500$gmane$org@mail.gmail.com>
References: <BANLkTik_jtjWTsOueUzfdQXRx17OcgyDgA@mail.gmail.com>
	<20110407013349.GH1867@nowhere>
	<BANLkTinKsYqkEEUu98t+Gn9ciPn_bmsMFQ@mail.gmail.com>
	<20110407120608.GB1798@nowhere>
	<BANLkTim70Ef0gy+W+4h76PABn32wDRvTtw@mail.gmail.com>
	<20110407213208.GE1798@nowhere>
	<BANLkTimOvWYgiRc6cviB6iiUt9MH-Au1qw@mail.gmail.com>
	<20110408002812.GG1798@nowhere> <1302248268.21026.18.camel@frodo>
	<20110408134537.GA1967@nowhere> <1302271672.9086.155.camel@twins>
	<BANLkTikOi1Y_5RH1juPmchWHjW8f=ynuRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <BANLkTikOi1Y_5RH1juPmchWHjW8f=ynuRA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Sharp <dhsharp-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ken Chen <kenchen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vaibhav Nagarnaik <vnagarnaik-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Apr 8, 2011 at 11:32 AM, Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> Minor history, Google wrote ktrace which we started to push upstream
> and then jumped on the ftrace train. ftrace was a very good drop in
> replacement for us. ftrace has a lot of features ktrace did not. We
> use perf also in other contexts.
>
> We have devoted a lot of time and energy from many engineers outside
> of kernel to use ftrace. It's not just the kernel code, but we have
> built a lot of sw on ftrace as we examine systems in the cloud. It was
> not easy to make this migration since it had a lot of user impact. It
> was less the low level API but the fact that the tracepoints semantics
> had changed. Google is in the process of no longer using ktrace.
>
> Requirements for tracing for us seem to be:
> 1) Around 250ns latencies when enabled

It's worth pointing out that this is a goal for us on ftrace.

We were able to do this well with ktrace, and have devoted effort to
making ftrace faster, but we're not at 250ns yet. We know that is
where we want to be.

> 2) Small events - We have worked on shrinking the ftrace event size.
> Since we are constrained on the amount of memory we can use in the
> ring buffer, every byte counts. A nice sized event is on the order of
> <=3D 8 bytes. Some of the 2.6.34 ftrace events like irq_enter and exit
> were too big around 20 bytes. sched_switch is around 60 bytes.
>
> I am not sure that perf meets these requirements. We need to use
> ftrace for tracing _now_. =A0Google also needs to focus on improving
> ftrace upstream so we can contribute our changes to the community. We
> are submitting patches and working with upstream to improve ftrace.
> Currently we depend on ftrace and being around for a long time.
>
> Fredric wrote:" Nonetheless you can't be such a significant
> user/developer of the upstream kernel tracing and at the same time
> ignore some key problems of the actual big picture of it."
>
> I see less of a big picture issue and more of an awkward two pictures.
> From my view it's a question of whether ftrace should continue to be
> supported and improved or whether perf will do everything as well and
> when. We depend on ftrace today and as such we have invested our time
> there.
>
> mrubin
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
