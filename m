From: Rolando Martins <rolando.martins-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: cgroup, RT reservation per core(s)?
Date: Tue, 10 Feb 2009 10:45:40 +0000
Message-ID: <b6a2d2e20902100245y1880d3e6ke2a34f55c9c4914e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,
I would like to have in a quad-core, 1 core totally (100%) dedicated
to RT tasks (SCHED_RR and SCHED_FIFO) and the other 3 cores with
normal behavior, better said,  allowing SCHED_OTHER & SCHED_FIFO &
SCHED_RR tasks but still with a RT reservation. Follows an example:


# Setup first domain (cpu 0,1,2)
echo 0-2 > /dev/cgroup/0/cpuset.cpus
echo 0 > /dev/cgroup/0/cpuset.mems

# Setup RT bandwidth for firstdomain (80% for RT, 20% others)
echo 1000000 > /dev/cgroup/0/cpu.rt_period_us
echo 800000 > /dev/cgroup/0/cpu.rt_runtime_us


# Setup second domain (cpu 3)
mkdir /dev/cgroup/1
echo 3 > /dev/cgroup/1/cpuset.cpus
echo 0 > /dev/cgroup/1/cpuset.mems

# Setup RT bandwidth for second domain (100% for RT)
echo 1000000 > /dev/cgroup/1/cpu.rt_period_us
echo 1000000 > /dev/cgroup/1/cpu.rt_runtime_us

# Setup RT bandwidth for third domain
echo 1000000 > /dev/cgroup/1/0/cpu.rt_period_us
echo 500000 > /dev/cgroup/1/0/cpu.rt_runtime_us

# Setup RT bandwidth for fourth domain
echo 1000000 > /dev/cgroup/1/1/cpu.rt_period_us
echo 500000 > /dev/cgroup/1/1/cpu.rt_runtime_us


                                            root
                                         ----|----
                                         |          |
(80% rt, 20% others         0         1 (100% rt @ core 3)
@ cores 1,2,3)                          ------
                                                  |    |
                                                  0   1   (50% rt for
each group @ core 3)




Is there anyway for doing this?
Or must we have a separate /proc/sys/kernel/sched_rt_runtime_us &
/proc/sys/kernel/sched_rt_period_us for each core/cpu?
In this case:
/proc/sys/kernel/sched_rt_runtime_us_0
/proc/sys/kernel/sched_rt_period_us_0
...
/proc/sys/kernel/sched_rt_runtime_us_n (n, cpu count)
/proc/sys/kernel/sched_rt_period_us_n

Thanks,
Rol
