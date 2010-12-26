From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v7 0/3] cgroups: implement moving a threadgroup's threads
	atomically with cgroup.procs
Date: Sun, 26 Dec 2010 07:09:19 -0500
Message-ID: <20101226120919.GA28529__45257.8761069619$1293365434$gmane$org@ghc17.ghc.andrew.cmu.edu>
References: <20101224082226.GA13872@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101224082226.GA13872-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 24, 2010 at 03:22:26AM -0500, Ben Blum wrote:
> On Wed, Aug 11, 2010 at 01:46:04AM -0400, Ben Blum wrote:
> > On Fri, Jul 30, 2010 at 07:56:49PM -0400, Ben Blum wrote:
> > > This patch series is a revision of http://lkml.org/lkml/2010/6/25/11 .
> > > 
> > > This patch series implements a write function for the 'cgroup.procs'
> > > per-cgroup file, which enables atomic movement of multithreaded
> > > applications between cgroups. Writing the thread-ID of any thread in a
> > > threadgroup to a cgroup's procs file causes all threads in the group to
> > > be moved to that cgroup safely with respect to threads forking/exiting.
> > > (Possible usage scenario: If running a multithreaded build system that
> > > sucks up system resources, this lets you restrict it all at once into a
> > > new cgroup to keep it under control.)
> > > 
> > > Example: Suppose pid 31337 clones new threads 31338 and 31339.
> > > 
> > > # cat /dev/cgroup/tasks
> > > ...
> > > 31337
> > > 31338
> > > 31339
> > > # mkdir /dev/cgroup/foo
> > > # echo 31337 > /dev/cgroup/foo/cgroup.procs
> > > # cat /dev/cgroup/foo/tasks
> > > 31337
> > > 31338
> > > 31339
> > > 
> > > A new lock, called threadgroup_fork_lock and living in signal_struct, is
> > > introduced to ensure atomicity when moving threads between cgroups. It's
> > > taken for writing during the operation, and taking for reading in fork()
> > > around the calls to cgroup_fork() and cgroup_post_fork(). I put calls to
> > > down_read/up_read directly in copy_process(), since new inline functions
> > > seemed like overkill.
> > > 
> > > -- Ben
> > > 
> > > ---
> > >  Documentation/cgroups/cgroups.txt |   13 -
> > >  include/linux/init_task.h         |    9
> > >  include/linux/sched.h             |   10
> > >  kernel/cgroup.c                   |  426 +++++++++++++++++++++++++++++++++-----
> > >  kernel/cgroup_freezer.c           |    4
> > >  kernel/cpuset.c                   |    4
> > >  kernel/fork.c                     |   16 +
> > >  kernel/ns_cgroup.c                |    4
> > >  kernel/sched.c                    |    4
> > >  9 files changed, 440 insertions(+), 50 deletions(-)
> > 
> > Here's an updated patchset. I've added an extra patch to implement the 
> > callback scheme Paul suggested (note how there are twice as many deleted
> > lines of code as before :) ), and also moved the up_read/down_read calls
> > to static inline functions in sched.h near the other threadgroup-related
> > calls.
> 
> One more go at this. I've refreshed the patches for some conflicts in
> cgroup_freezer.c, by adding an extra argument to the per_thread() call,
> "need_rcu", which makes the function take rcu_read_lock even around the
> single-task case (like freezer now requires). So no semantics have been
> changed.
> 
> I also poked around at some attach() calls which also iterate over the
> threadgroup (blkiocg_attach, cpuset_attach, cpu_cgroup_attach). I was
> borderline about making another function, cgroup_attach_per_thread(),
> but decided against.
> 
> There is a big issue in cpuset_attach, as explained in this email:
> http://www.spinics.net/lists/linux-containers/msg22223.html
> but the actual code/diffs for this patchset are independent of that
> getting fixed, so I'm putting this up for consideration now.
> 
> -- Ben

Well this time everything here is actually safe and correct, as far as
my best efforts and keen eyes can tell. I dropped the per_thread call
from the last series in favour of revising the subsystem callback
interface. It now looks like this:

ss->can_attach()
 - Thread-independent, possibly expensive/sleeping.

ss->can_attach_task()
 - Called per-thread, run with rcu_read so must not sleep.

ss->pre_attach()
 - Thread independent, must be atomic, happens before attach_task.

ss->attach_task()
 - Called per-thread, run with tasklist_lock so must not sleep.

ss->attach()
 - Thread independent, possibly expensive/sleeping, called last.

I think this makes the most sense, since it keeps all of the threadgroup
logic confined to cgroup_attach_proc, and also by splitting up the
callbacks, many subsystems get to have less code about stuff they don't
need to worry about. It makes the issue mentioned here:
http://www.spinics.net/lists/linux-containers/msg22236.html decoupled
from this patchset (since mmap_sem stuff is done in thread-independent
callbacks, and also fixes (this particular case of) this problem:
http://www.spinics.net/lists/linux-containers/msg22223.html (by using
global nodemasks for the three attach callbacks).

One final bullet to dodge: cpuset_change_task_nodemask() is implemented
using a loop around yield() to synchronize the mems_allowed, so it can't
be used in the atomic attach_task(). (It looks like a total mess to me -
can anybody justify why it was done that way, instead of using a better
concurrency primitive?) Rather than dirty my hands by changing any of
it, I just moved it out of the per-thread function - explained more in
the second patch. If it gets rewritten to avoid yielding, it can be
moved back to attach_task (I left a TODO).

Other than that, a quick review of why everything here is safe:
 - Iterating over the thread_group is done only under rcu_read_lock or
   tasklist_lock, always checking first that thread_group_leader(task).
   (And, a reference is held on that task the whole time.)
 - All allocation is done outside of rcu_read/tasklist_lock.
 - All subsystem callbacks for can_attach_task() and attach_task() never
   call any function that can block or otherwise yield.

(It'd be really nice if the functions that might sleep and regions of
code that must not sleep could be checked for automatically at build.)

-- Ben

---
 Documentation/cgroups/cgroups.txt |   44 ++-
 Documentation/cgroups/cpusets.txt |    9 
 block/blk-cgroup.c                |   18 -
 include/linux/cgroup.h            |   10 
 include/linux/init_task.h         |    9 
 include/linux/sched.h             |   35 ++
 kernel/cgroup.c                   |  489 ++++++++++++++++++++++++++++++++++----
 kernel/cgroup_freezer.c           |   27 --
 kernel/cpuset.c                   |  116 ++++-----
 kernel/fork.c                     |   10 
 kernel/ns_cgroup.c                |   23 -
 kernel/sched.c                    |   38 --
 mm/memcontrol.c                   |   18 -
 security/device_cgroup.c          |    3 
 14 files changed, 635 insertions(+), 214 deletions(-)
