From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Sun, 7 Jun 2009 21:05:23 +0530
Message-ID: <661de9470906070835l383cd388h67e40a31be07aef6__14872.5327490412$1244388990$gmane$org@mail.gmail.com>
References: <20090604053649.GA3701@in.ibm.com>
	<6599ad830906050153i1afd104fqe70f681317349142@mail.gmail.com>
	<20090605113217.GA20786@in.ibm.com>
	<6599ad830906050518t6cd7d477h36a187f2eaf55578@mail.gmail.com>
	<20090607101120.GB16211@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090607101120.GB16211-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Jun 7, 2009 at 3:41 PM, Srivatsa Vaddagiri<vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, Jun 05, 2009 at 05:18:13AM -0700, Paul Menage wrote:
>> Well yes, it's true that you *could* just enforce shares over a
>> granularity of minutes, and limits over a granularity of milliseconds.
>> But why would you? It could well make sense that you can adjust the
>> granularity over which shares are enforced - e.g. for batch jobs, only
>> enforcing over minutes or tens of seconds might be fine. But if you're
>> doing the fine-grained accounting and scheduling required for the
>> tight hard limit enforcement, it doesn't seem as though it should be
>> much harder to enforce shares at the same granularity for those
>> cgroups that matter. In fact I thought that's what CFS already did -
>> updated the virtual time accounting at each context switch, and picked
>> the runnable child with the oldest virtual time. (Maybe someone like
>> Ingo or Peter who's more familiar than I with the CFS implementation
>> could comment here?)
>
> Using shares to guarantee resources over short period (<2-3 seconds) works
> just well on a single CPU. The complexity is with multi-cpu case, where C=
FS can
> take a long time to converge to a fair point. This is because fairness is=
 based
> on rebalancing tasks equally across all CPUs.
>
> For something like 4 tasks on 4 CPUs, it will converge pretty quickly
> (2-3 seconds):
>
> [top o/p refreshed every 2sec on 2.6.30-rc5-tip]
>
> 14753 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 99.9 =A00.0 =A0 0:39.54 =
hog
> 14754 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 99.9 =A00.0 =A0 0:38.69 =
hog
> 14756 vatsa =A0 =A0 20 =A0 0 63812 1076 =A0924 R 99.9 =A00.0 =A0 0:38.27 =
hog
> 14755 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 99.6 =A00.0 =A0 0:38.27 =
hog
>
> whereas for something like 5 tasks on 4 CPUs, it will take a sufficiently
> longer time (>30 seconds)
>
> [top o/p refreshed every 2sec]:
>
> 14754 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 86.0 =A00.0 =A0 2:06.45 =
hog
> 14766 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 83.0 =A00.0 =A0 0:07.95 =
hog
> 14756 vatsa =A0 =A0 20 =A0 0 63812 1076 =A0924 R 81.7 =A00.0 =A0 2:06.48 =
hog
> 14753 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 78.7 =A00.0 =A0 2:07.10 =
hog
> 14755 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 69.4 =A00.0 =A0 2:05.62 =
hog
>
> [top o/p refreshed every 120sec]:
>
> 14766 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 90.1 =A00.0 =A0 5:57.22 =
hog
> 14755 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 84.8 =A00.0 =A0 8:01.61 =
hog
> 14754 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 77.3 =A00.0 =A0 7:52.04 =
hog
> 14753 vatsa =A0 =A0 20 =A0 0 63812 1072 =A0924 R 74.1 =A00.0 =A0 7:29.01 =
hog
> 14756 vatsa =A0 =A0 20 =A0 0 63812 1076 =A0924 R 73.5 =A00.0 =A0 7:34.69 =
hog
>
> [Note that even over 2min, we haven't achieved perfect fairness]
>

Good observation, Thanks!

>> > By having hard-limits, we are
>> > "reserving" (potentially idle) slots where the high-priority group can=
 run and
>> > claim its guaranteed share almost immediately.
>
> On further thinking, this is not as simple as that. In above example of
> 5 tasks on 4 CPUs, we could cap each task at a hard limit of 80%
> (4 CPUs/5 tasks), which is still not sufficient to ensure that each
> task gets the perfect fairness of 80%! Not just that, hard-limit
> for a group (on each CPU) will have to be adjusted based on its task
> distribution. For ex: a group that has a hard-limit of 25% on a 4-cpu
> system and that has a single task, is entitled to claim a whole CPU. So
> the per-cpu hard-limit for the group should be 100% on whatever CPU the
> task is running. This adjustment of per-cpu hard-limit should happen
> whenever the task distribution of the group across CPUs change - which
> in theory would require you to monitor every task exit/migration
> event and readjust limits, making it very complex and high-overhead.
>

We already do that for shares right? I mean instead of 25% hard limit,
if the group had 25% of the shares the same thing would apply - no?

> Balbir,
> =A0 =A0 =A0 =A0I dont think guarantee can be met easily thr' hard-limits =
in
> case of CPU resource. Atleast its not as straightforward as in case of
> memory!

OK, based on the discussion - leaving implementation issues out,
speaking of whether it is possible to implement guarantees using
shares? My answer would be

1. Yes - but then the hard limits will prevent you and can cause idle
times, some of those can be handled in the implementation. There might
be other fairness and SMP concerns about the accuracy of the fairness,
thank you for that data.
2. We'll update the RFC (second version) with the findings and send it
out, so that the expectations are clearer
3. From what I've read and seen there seems to be no strong objection
to hard limits, but some reservations (based on 1) about using them
for guarantees and our RFC will reflect that.

Do you agree?
Balbir

Balbir
