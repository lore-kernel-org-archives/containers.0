From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [BUG] cpu controller can't provide fair CPU time for each group
Date: Mon, 9 Nov 2009 16:22:58 -0800
Message-ID: <20091109162258.25d3f202.akpm__4442.55312108925$1257812701$gmane$org@linux-foundation.org>
References: <4AEF94E8.3030403@cn.fujitsu.com> <4AF23EC0.2070606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AF23EC0.2070606-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

(cc containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org)

On Thu, 05 Nov 2009 11:56:00 +0900
Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> Hi, Ingo
> 
> Could you see the following problems?
> 
> Regards
> Miao
> 
> on 2009-11-3 11:26, Miao Xie wrote:
> > Hi, Peter.
> > 
> > I found two problems about cpu controller:
> > 1) cpu controller didn't provide fair CPU time to groups when the tasks
> >    attached into those groups were bound to the same logic CPU.
> > 2) cpu controller didn't provide fair CPU time to groups when shares of
> >    each group <= 2 * nr_cpus.
> > 
> > The detail is following:
> > 1) The first one is that cpu controller didn't provide fair CPU time to
> >    groups when the tasks attached into those groups were bound to the
> >    same logic CPU.
> > 
> >    The reason is that there is something with the computing of the per
> >    cpu shares.
> > 
> >    on my test box with 16 logic CPU, I did the following manipulation:
> >    a. create 2 cpu controller groups.
> >    b. attach a task into one group and 2 tasks into the other.
> >    c. bind three tasks to the same logic cpu.
> >             +--------+     +--------+
> >             | group1 |     | group2 |
> >             +--------+     +--------+
> >                 |              |
> >    CPU0      Task A      Task B & Task C
> > 
> >    The following is the reproduce steps:
> >    # mkdir /dev/cpuctl
> >    # mount -t cgroup -o cpu,noprefix cpuctl /dev/cpuctl
> >    # mkdir /dev/cpuctl/1
> >    # mkdir /dev/cpuctl/2
> >    # cat /dev/zero > /dev/null &
> >    # pid1=$!
> >    # echo $pid1 > /dev/cpuctl/1/tasks
> >    # taskset -p -c 0 $pid1
> >    # cat /dev/zero > /dev/null &
> >    # pid2=$!
> >    # echo $pid2 > /dev/cpuctl/2/tasks
> >    # taskset -p -c 0 $pid2
> >    # cat /dev/zero > /dev/null &
> >    # pid3=$!
> >    # echo $pid3 > /dev/cpuctl/2/tasks
> >    # taskset -p -c 0 $pid3
> > 
> >    some time later, I found the the task in the group1 got the 35% CPU 
> > time not
> >    50% CPU time. It was very strange that this result against the expected.
> > 
> >    this problem was caused by the wrong computing of the per cpu shares.
> >    According to the design of the cpu controller, the shares of each cpu
> >    controller group will be divided for every CPU by the workload of each
> >    logic CPU.
> >       cpu[i] shares = group shares * CPU[i] workload / sum(CPU workload)
> > 
> >    But if the CPU has no task, cpu controller will pretend there is one of
> >    average load, usually this average load is 1024, the load of the task 
> > whose
> >    nice is zero. So in the test, the shares of group1 on CPU0 is:
> >       1024 * (1 * 1024) / ((1 * 1024 + 15 * 1024)) = 64
> >    and the shares of group2 on CPU0 is:
> >       1024 * (2 * 1024) / ((2 * 1024 + 15 * 1024)) = 120
> >    The scheduler of the CPU0 provided CPU time to each group by the shares
> >    above. The bug occured.
> > 
> > 2) The second problem is that cpu controller didn't provide fair CPU 
> > time to
> >    groups when shares of each group <= 2 * nr_cpus
> > 
> >    The reason is that per cpu shares was set to MIN_SHARES(=2) if shares of
> >    each group <= 2 * nr_cpus.
> > 
> >    on the test box with 16 logic CPU, we do the following test:
> >    a. create two cpu controller groups
> >    b. attach 32 tasks into each group
> >    c. set shares of the first group to 16, the other to 32
> >             +--------+     +--------+
> >             | group1 |     | group2 |
> >             +--------+     +--------+
> >             |shares=16     |shares=32
> >                 |              |
> >              16 Tasks       32 Tasks
> > 
> >    some time later, the first group got 50% CPU time, not 33%. It also 
> > was very
> >    strange that this result against the expected.
> > 
> >    It is because the shares of cpuctl group was small, and there is many 
> > logic
> >    CPU. So per cpu shares that was computed was less than MIN_SHARES, 
> > and then
> >    was set to MIN_SHARES.
> > 
> >    Maybe 16 and 32 is not used usually. We can set a usual number(such 
> > as 1024)
> >    to avoid this problem on my box. But the number of CPU on a machine will
> >    become more and more in the future. If the number of CPU is greater 
> > than 512,
> >    this bug will occur even we set shares of group to 1024. This is a usual
> >    number. At this rate, the usual user will feel strange.
> > 
> > 
> > 
> > -- 
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> > 
> > 
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
