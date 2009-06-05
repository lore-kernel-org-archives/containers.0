From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 5 Jun 2009 05:18:13 -0700
Message-ID: <6599ad830906050518t6cd7d477h36a187f2eaf55578__35638.0271296532$1244204436$gmane$org@mail.gmail.com>
References: <20090604053649.GA3701@in.ibm.com>
	<6599ad830906050153i1afd104fqe70f681317349142@mail.gmail.com>
	<20090605113217.GA20786@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090605113217.GA20786-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
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
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jun 5, 2009 at 4:32 AM, Srivatsa Vaddagiri<vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org> wrote:
>
> I think the interval over which we need guarantee matters here. Shares
> can generally provide guaranteed share of resource over longer (sometimes
> minutes) intervals. For high-priority bursty workloads, the latency in
> achieving guaranteed resource usage matters.

Well yes, it's true that you *could* just enforce shares over a
granularity of minutes, and limits over a granularity of milliseconds.
But why would you? It could well make sense that you can adjust the
granularity over which shares are enforced - e.g. for batch jobs, only
enforcing over minutes or tens of seconds might be fine. But if you're
doing the fine-grained accounting and scheduling required for the
tight hard limit enforcement, it doesn't seem as though it should be
much harder to enforce shares at the same granularity for those
cgroups that matter. In fact I thought that's what CFS already did -
updated the virtual time accounting at each context switch, and picked
the runnable child with the oldest virtual time. (Maybe someone like
Ingo or Peter who's more familiar than I with the CFS implementation
could comment here?)

> By having hard-limits, we are
> "reserving" (potentially idle) slots where the high-priority group can run and
> claim its guaranteed share almost immediately.

But you can always create an "idle" slot by forcibly preempting
whatever's running currently when you need to - you don't need to keep
the CPU deliberately idle just in case a cgroup with a guarantee wakes
up.

Paul
