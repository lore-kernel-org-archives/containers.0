From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v4 0/2] cgroups: implement moving a threadgroup's threads
	atomically with cgroup.procs
Date: Fri, 30 Jul 2010 19:56:49 -0400
Message-ID: <20100730235649.GA22644__20875.5341046073$1280534280$gmane$org@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

This patch series is a revision of http://lkml.org/lkml/2010/6/25/11 .

This patch series implements a write function for the 'cgroup.procs'
per-cgroup file, which enables atomic movement of multithreaded
applications between cgroups. Writing the thread-ID of any thread in a
threadgroup to a cgroup's procs file causes all threads in the group to
be moved to that cgroup safely with respect to threads forking/exiting.
(Possible usage scenario: If running a multithreaded build system that
sucks up system resources, this lets you restrict it all at once into a
new cgroup to keep it under control.)

Example: Suppose pid 31337 clones new threads 31338 and 31339.

# cat /dev/cgroup/tasks
...
31337
31338
31339
# mkdir /dev/cgroup/foo
# echo 31337 > /dev/cgroup/foo/cgroup.procs
# cat /dev/cgroup/foo/tasks
31337
31338
31339

A new lock, called threadgroup_fork_lock and living in signal_struct, is
introduced to ensure atomicity when moving threads between cgroups. It's
taken for writing during the operation, and taking for reading in fork()
around the calls to cgroup_fork() and cgroup_post_fork(). I put calls to
down_read/up_read directly in copy_process(), since new inline functions
seemed like overkill.

-- Ben

---
 Documentation/cgroups/cgroups.txt |   13 -
 include/linux/init_task.h         |    9
 include/linux/sched.h             |   10
 kernel/cgroup.c                   |  426 +++++++++++++++++++++++++++++++++-----
 kernel/cgroup_freezer.c           |    4
 kernel/cpuset.c                   |    4
 kernel/fork.c                     |   16 +
 kernel/ns_cgroup.c                |    4
 kernel/sched.c                    |    4
 9 files changed, 440 insertions(+), 50 deletions(-)
