From: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 2/2] scheduler: cgroups cpuaccouting: Make cpuusage atomic
Date: Thu, 20 May 2010 12:53:08 +0200
Message-ID: <201005201253.08904.trenn__5861.50292442671$1274352866$gmane$org@suse.de>
References: <1274264877.5605.10541.camel@twins>
	<1274295539-7798-3-git-send-email-trenn@suse.de>
	<1274295743.1674.1545.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274295743.1674.1545.camel@laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 19 May 2010 21:02:23 Peter Zijlstra wrote:
> On Wed, 2010-05-19 at 20:58 +0200, Thomas Renninger wrote:
> > and avoid locking on 32 bit.
> > This resolves an ugly dependency in cgroups_cpuaccount.c
> > to per_cpu runqueues lock variable.
> 
> While I totally agree with the sentiments here, atomic64_t isn't
> available on all 32bit archs and is _terribly_ expensive on ARCH=i386.

Please ignore the 2nd patch.
If nobody objects about the creation of kernel/sched.h which should get
used for further cleanups IMO, the first patch should get in.
I thought a bit about it, but taking the per_cpu rq lock is the most sane
thing I could think of.

Here is a fix (bug always was there), for "on top" patching of the first.
It should also be possible to fix this by exchanging:
CONFIG_64BIT to CONFIG_X86_64, but removing the #ifdefs should
be preferred over a lock that is only grabbed via sysfs access...

Thanks,

    Thomas

scheduler: cgroup_cpuaccount - Fix race on cpuusage

A u64 access is not atomic on all 64 bit archs.
Especially this:
*cpuusage += cputime;
should not necessarily be atomic on non X86_64 archs.
As cpuacct_cpuusage_{read,write} is only used during
sysfs access, the lock should be acquired rather rarely
and the code is nicer as well.

Signed-off-by: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org
CC: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
CC: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
CC: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
CC: mingo-X9Un+BFzKDI@public.gmane.org
CC: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org

diff --git a/kernel/cgroup_cpuaccount.c b/kernel/cgroup_cpuaccount.c
index 0ad356a..a9e0345 100644
--- a/kernel/cgroup_cpuaccount.c
+++ b/kernel/cgroup_cpuaccount.c
@@ -95,16 +95,12 @@ static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
 	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
 	u64 data;
 
-#ifndef CONFIG_64BIT
 	/*
-	 * Take rq->lock to make 64-bit read safe on 32-bit platforms.
+	 * Take rq->lock to make 64-bit read safe
 	 */
 	lock_runqueue(cpu);
 	data = *cpuusage;
 	unlock_runqueue(cpu);
-#else
-	data = *cpuusage;
-#endif
 
 	return data;
 }
@@ -113,16 +109,12 @@ static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
 {
 	u64 *cpuusage = per_cpu_ptr(ca->cpuusage, cpu);
 
-#ifndef CONFIG_64BIT
 	/*
-	 * Take rq->lock to make 64-bit write safe on 32-bit platforms.
+	 * Take rq->lock to make 64-bit write safe
 	 */
 	lock_runqueue(cpu);
 	*cpuusage = val;
 	unlock_runqueue(cpu);
-#else
-	*cpuusage = val;
-#endif
 }
 
 /* return total cpu usage (in nanoseconds) of a group */
