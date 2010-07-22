From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 16417] New: Slow context switches with SMP and
	CONFIG_FAIR_GROUP_SCHED
Date: Thu, 22 Jul 2010 15:52:22 -0700
Message-ID: <20100722155222.f0fdc50a.akpm@linux-foundation.org>
References: <bug-16417-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <bug-16417-10286-3bo0kxnWaOQUvHkbgXJLS5sdmw4N0Rt+2LY78lusg7I@public.gmane.org/>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Th
Cc: pbourdon-SxHCd5+OuqTrt3ojHgZu+w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
List-Id: containers.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

sched suckage!  Do we have a linear search in there?


On Mon, 19 Jul 2010 14:38:09 GMT
bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16417
> 
>            Summary: Slow context switches with SMP and
>                     CONFIG_FAIR_GROUP_SCHED
>            Product: Process Management
>            Version: 2.5
>     Kernel Version: 2.6.34.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Scheduler
>         AssignedTo: mingo-X9Un+BFzKDI@public.gmane.org
>         ReportedBy: pbourdon-SxHCd5+OuqTrt3ojHgZu+w@public.gmane.org
>         Regression: No
> 
> 
> Hello,
> 
> We have been experiencing slow context switches using a large number of cgroups
> (around 600 groups) and CONFIG_FAIR_GROUP_SCHED. This causes a system time
> usage increase on context switching heavy processes (measured with pidstat -w)
> and a drop in timer interrupts handling.
> 
> This problem only appears on SMP : when booting with nosmp, the issue does not
> appear. From maxprocs=2 to maxprocs=8 we were able to reproduce it accurately.
> 
> Steps to reproduce :
> - mount the cgroup filesystem in /dev/cgroup
> - cd /dev/cgroup && for i in $(seq 1 5000); do mkdir test_group_$i; done
> - launch lat_ctx from lmbench, for instance ./lat_ctx -N 200 100
> 
> The results from lat_ctx were the following :
> - SMP enabled, no cgroups : 2.65
> - SMP enabled, 1000 cgroups : 3.40
> - SMP enabled, 6000 cgroups : 3957.36
> - SMP disabled, 6000 cgroups : 1.58
> 
> We can see that from a certain amount of cgroups, the context switching starts
> taking a lot of time. Another way to reproduce this problem :
> - launch cat /dev/zero | pv -L 1G > /dev/null
> - look at the CPU usage (about 40% here)
> - cd /dev/cgroup && for i in $(seq 1 5000); do mkdir test_group_$i; done
> - look at the CPU usage (about 80% here)
> 
> Also note that when a lot of cgroups are present, the system is spending a lot
> of time in softirqs, and there are less timer interrupts handled than normally
> (according to our graphs).
> 
