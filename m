From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: RT Scheduler and Network Namespaces - possible issue
Date: Tue, 28 Oct 2014 17:42:38 +0100
Message-ID: <20141028164238.GS3337@twins.programming.kicks-ass.net>
References: <CAKYTaBK1zO3uuGUps7=1Bu0wV_ydmd1+HPVrSJmqFH6xjGCvrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAKYTaBK1zO3uuGUps7=1Bu0wV_ydmd1+HPVrSJmqFH6xjGCvrA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Florin Medrea (Gmail)" <florinmedrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 28, 2014 at 04:13:42PM +0100, Florin Medrea (Gmail) wrote:
> Hello all,
> 
> I have a doubt about a certain issue I encounter on my embedded Linux
> Kernel.
> 
> *Use case*: Use Network Namespaces on RT Processes
> *Environment*: 2.6.35 Linux Kernel + some patches for netns (
> https://github.com/unicell/redpatch/commits/rhel-2.6.32-358.6.2.ns.el6)
> *Configuration*: the *CONFIG_RT_GROUP_SCHED* option is activated

At this point I was about ready to ignore the rest, 2.6.35 is just too
ancient to spend more time on.

> In my user space application (RT priority) I attemp to *unshare* to a new
> Network Namespace. This fais with *EINVAL*. By debugging with printks in
> the kernel scheduler, I found that the *unshare* request is refused at this
> point: http://lxr.free-electrons.com/source/kernel/sched.c?v=2.6.35#L8392
> (because *rt_bandwidth.rt_runtime* is 0).

Have you co-mounted stuff? why would network namespaces have anything to
do with cpu cgroups?

> Digging more in the trace calls, I see that the bandwidth is initialised
> here: http://lxr.free-electrons.com/source/kernel/sched.c?v=2.6.35#L7932
> and remains set to 0 during the *can_attach* check. Can someone explain why
> the bandwidth is initialised to 0 runtime, whilst initialised to
> *global_rt_runtime()* at other places in *sched.c* (
> http://lxr.free-electrons.com/source/kernel/sched.c?v=2.6.35#L7533)?

Sure, the rule is that the sum of all child cgroup's utilization must
not be more than that of the parent cgroup's, and the root cgroup must
not have more than is maximally available -- the second line you cite is
the root cgroup, its special as per the above.

[where the utilization is runtime/period]

This means that there is no possible right value to initialize child
cgroups to, any value !0 might be more than the parent cgroup has,
also, any !0 value will lead to having to fail creating more cgroups
because the sum of children will exceed their parent's.

Furthermore any random !0 value will be wrong for your workload, only
the administrator that knows the workload can set a meaningful period and
runtime. The kernel cannot possibly know this, and therefore doesn't
attempt.
