From: "Florin Medrea (Gmail)" <florinmedrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: RT Scheduler and Network Namespaces - possible issue
Date: Tue, 28 Oct 2014 16:13:42 +0100
Message-ID: <CAKYTaBK1zO3uuGUps7=1Bu0wV_ydmd1+HPVrSJmqFH6xjGCvrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: mingo-X9Un+BFzKDI@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello all,

I have a doubt about a certain issue I encounter on my embedded Linux
Kernel.

*Use case*: Use Network Namespaces on RT Processes
*Environment*: 2.6.35 Linux Kernel + some patches for netns (
https://github.com/unicell/redpatch/commits/rhel-2.6.32-358.6.2.ns.el6)
*Configuration*: the *CONFIG_RT_GROUP_SCHED* option is activated

In my user space application (RT priority) I attemp to *unshare* to a new
Network Namespace. This fais with *EINVAL*. By debugging with printks in
the kernel scheduler, I found that the *unshare* request is refused at this
point: http://lxr.free-electrons.com/source/kernel/sched.c?v=2.6.35#L8392
(because *rt_bandwidth.rt_runtime* is 0).

Digging more in the trace calls, I see that the bandwidth is initialised
here: http://lxr.free-electrons.com/source/kernel/sched.c?v=2.6.35#L7932
and remains set to 0 during the *can_attach* check. Can someone explain why
the bandwidth is initialised to 0 runtime, whilst initialised to
*global_rt_runtime()* at other places in *sched.c* (
http://lxr.free-electrons.com/source/kernel/sched.c?v=2.6.35#L7533)?
As a test, I have replaced the 0 value during this *init_rt_bandwidth* call
to *def_rt_bandwidth.rt_runtime* and my *unshare *system call succeeds.
Firsts tests of network namespaces with this workaround seem to work.

*To resume*, my question is related to this code line:
http://lxr.free-electrons.com/source/kernel/sched.c?v=2.6.35#L7932

*Why initialise to 0 and not to the global/default value?*

    init_rt_bandwidth(&tg->rt_bandwidth,
            ktime_to_ns(def_rt_bandwidth.rt_period),
def_rt_bandwidth.rt_runtime);

Kind regards,
Florin Medrea
