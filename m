From: Srivatsa Vaddagiri <vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Sun, 7 Jun 2009 15:41:20 +0530
Message-ID: <20090607101120.GB16211@in.ibm.com>
References: <20090604053649.GA3701@in.ibm.com>
	<6599ad830906050153i1afd104fqe70f681317349142@mail.gmail.com>
	<20090605113217.GA20786@in.ibm.com>
	<6599ad830906050518t6cd7d477h36a187f2eaf55578@mail.gmail.com>
Reply-To: vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830906050518t6cd7d477h36a187f2eaf55578-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jun 05, 2009 at 05:18:13AM -0700, Paul Menage wrote:
> Well yes, it's true that you *could* just enforce shares over a
> granularity of minutes, and limits over a granularity of milliseconds.
> But why would you? It could well make sense that you can adjust the
> granularity over which shares are enforced - e.g. for batch jobs, only
> enforcing over minutes or tens of seconds might be fine. But if you're
> doing the fine-grained accounting and scheduling required for the
> tight hard limit enforcement, it doesn't seem as though it should be
> much harder to enforce shares at the same granularity for those
> cgroups that matter. In fact I thought that's what CFS already did -
> updated the virtual time accounting at each context switch, and picked
> the runnable child with the oldest virtual time. (Maybe someone like
> Ingo or Peter who's more familiar than I with the CFS implementation
> could comment here?)

Using shares to guarantee resources over short period (<2-3 seconds) works 
just well on a single CPU. The complexity is with multi-cpu case, where CFS can 
take a long time to converge to a fair point. This is because fairness is based 
on rebalancing tasks equally across all CPUs.

For something like 4 tasks on 4 CPUs, it will converge pretty quickly 
(2-3 seconds):

[top o/p refreshed every 2sec on 2.6.30-rc5-tip]

14753 vatsa     20   0 63812 1072  924 R 99.9  0.0   0:39.54 hog
14754 vatsa     20   0 63812 1072  924 R 99.9  0.0   0:38.69 hog
14756 vatsa     20   0 63812 1076  924 R 99.9  0.0   0:38.27 hog
14755 vatsa     20   0 63812 1072  924 R 99.6  0.0   0:38.27 hog

whereas for something like 5 tasks on 4 CPUs, it will take a sufficiently 
longer time (>30 seconds)

[top o/p refreshed every 2sec]:

14754 vatsa     20   0 63812 1072  924 R 86.0  0.0   2:06.45 hog
14766 vatsa     20   0 63812 1072  924 R 83.0  0.0   0:07.95 hog
14756 vatsa     20   0 63812 1076  924 R 81.7  0.0   2:06.48 hog
14753 vatsa     20   0 63812 1072  924 R 78.7  0.0   2:07.10 hog
14755 vatsa     20   0 63812 1072  924 R 69.4  0.0   2:05.62 hog

[top o/p refreshed every 120sec]:

14766 vatsa     20   0 63812 1072  924 R 90.1  0.0   5:57.22 hog
14755 vatsa     20   0 63812 1072  924 R 84.8  0.0   8:01.61 hog
14754 vatsa     20   0 63812 1072  924 R 77.3  0.0   7:52.04 hog
14753 vatsa     20   0 63812 1072  924 R 74.1  0.0   7:29.01 hog
14756 vatsa     20   0 63812 1076  924 R 73.5  0.0   7:34.69 hog

[Note that even over 2min, we haven't achieved perfect fairness]

> > By having hard-limits, we are
> > "reserving" (potentially idle) slots where the high-priority group can run and
> > claim its guaranteed share almost immediately.

On further thinking, this is not as simple as that. In above example of
5 tasks on 4 CPUs, we could cap each task at a hard limit of 80% 
(4 CPUs/5 tasks), which is still not sufficient to ensure that each
task gets the perfect fairness of 80%! Not just that, hard-limit 
for a group (on each CPU) will have to be adjusted based on its task
distribution. For ex: a group that has a hard-limit of 25% on a 4-cpu
system and that has a single task, is entitled to claim a whole CPU. So
the per-cpu hard-limit for the group should be 100% on whatever CPU the
task is running. This adjustment of per-cpu hard-limit should happen
whenever the task distribution of the group across CPUs change - which
in theory would require you to monitor every task exit/migration
event and readjust limits, making it very complex and high-overhead.

Balbir,
	I dont think guarantee can be met easily thr' hard-limits in
case of CPU resource. Atleast its not as straightforward as in case of
memory!

- vatsa
