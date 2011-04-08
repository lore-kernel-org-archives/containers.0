From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [RFC] tracing: Adding cgroup aware tracing functionality
Date: Fri, 08 Apr 2011 03:37:48 -0400
Message-ID: <1302248268.21026.18.camel__10137.3831894763$1302248423$gmane$org@frodo>
References: <BANLkTik_jtjWTsOueUzfdQXRx17OcgyDgA@mail.gmail.com>
	<20110407013349.GH1867@nowhere>
	<BANLkTinKsYqkEEUu98t+Gn9ciPn_bmsMFQ@mail.gmail.com>
	<20110407120608.GB1798@nowhere>
	<BANLkTim70Ef0gy+W+4h76PABn32wDRvTtw@mail.gmail.com>
	<20110407213208.GE1798@nowhere>
	<BANLkTimOvWYgiRc6cviB6iiUt9MH-Au1qw@mail.gmail.com>
	<20110408002812.GG1798@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110408002812.GG1798@nowhere>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, David Sharp <dhsharp-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ken Chen <kenchen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Vaibhav Nagarnaik <vnagarnaik-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2011-04-08 at 02:28 +0200, Frederic Weisbecker wrote:

> > This is all very interesting, but doesn't really help us. I'd prefer
> > to focus on the proposal itself than discuss the merits of perf and
> > ftrace. We're using ftrace for the foreseeable future, and afaik, it's
> > still a maintained part of the kernel. If perf improves its
> > performance for tracing, then we can consider switching to it. We
> > could invest time improving perf, and that might be worthwhile, but
> > ftrace is here now.
> 
> You are investing upstream for your tracing needs. And that's really
> a nice step that I appreciate, as IIRC, Google had its own internal tracing
> (ktrace?) before. Nonetheless you can't be such a significant
> user/developer of the upstream kernel tracing and at the same time ignore some
> key problems of the actual big picture of it.
> 
> You need to be aware that we are not going anywhere if we duplicate
> every features between perf and ftrace. We want to merge the common
> pieces, keep the best of them and not expand the two tier tracing of today.


I agree that it would be great if we can start to merge the two. But
until we have a road map that we can all agree upon, I don't see that
happening in the near future. But I may be wrong ;)

> 
> I wish people stop thinking about perf and ftrace as
> competitors.

I don't think this is about perf and ftrace as competitors, but they are
currently two different infrastructures that are existing in the kernel.
They are currently optimized for different purposes. ftrace is optimized
for system tracing (persistent buffers and such) where as perf is
optimized for user tracing. But the two can do both but the other
feature is not as efficient as the other tool.

As you said perf has a lot of overhead due to data that it saves per
event. How easy is it to modify that without breaking the ABI?

>  Probably developers could start having a sane view
> once both will have close performances and then we can start
> thinking about a common backend (a buffer abstraction, which development
> can be iterated incrementally, usable with a syscall) and eliminate the
> overlapping pieces.

I wouldn't say eliminate, but at least merge the overlapping pieces. I'm
still totally against stripping out the debugfs code, and as tools have
been made to depend on it, I'm not sure we can rip it out. But I do not
see any harm in supporting both a debugfs feature along with a syscall
interface. I'm willing to do the leg work here to keep it.

> 
> I'm not asking you to unify the kernel tracing all alone. But you need to
> start to enlarge your view.

You might want to be a bit more specific by what you mean here.
 
> 
> I tend to think perf is more suitable for finegrained context definition
> in general.

I actually agree, as perf is more focused on per process (or group) than
ftrace. But that said, I guess the issue is also, if they have a simple
solution that is not invasive and suits their needs, what's the harm in
accepting it?

-- Steve
