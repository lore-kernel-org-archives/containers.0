From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/8] CGroups: cgroup memberlist enhancements/fixes
Date: Tue, 18 Aug 2009 16:58:06 -0700
Message-ID: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

The following series adds a "cgroup.procs" file to each cgroup that
reports unique tgids rather than pids, and allows all threads in a
threadgroup to be atomically moved to a new cgroup.

The subsystem "attach" interface is modified to support attaching
whole threadgroups at a time, which could introduce potential problems
if any subsystem were to need to access the old cgroup of every thread
being moved. The attach interface may need to be revised if this
becomes the case.

Also added is functionality for read/write locking all CLONE_THREAD
fork()ing within a threadgroup, by means of an rwsem that lives in the
sighand_struct, for per-threadgroup-ness and also for sharing a
cacheline with the sighand's atomic count. This scheme should
introduce no extra overhead in the fork path when there's no
contention.

The final patch reveals potential for a race when forking before a
subsystem's attach function is called - one potential solution in case
any subsystem has this problem is to hang on to the group's fork mutex
through the attach() calls, though no subsystem yet demonstrates need
for an extended critical section.

---

Ben Blum (7):
      Adds ability to move all threads in a process to a new cgroup atomically
      Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup
      Lets ss->can_attach and ss->attach do whole threadgroups at a time
      Changes css_set freeing mechanism to be under RCU
      Use vmalloc for large cgroups pidlist allocations
      Ensures correct concurrent opening/reading of pidlists across pid namespaces
      Adds a read-only "procs" file similar to "tasks" that shows only unique tgids

Paul Menage (1):
      Revert commit 8827c288feb7810185aa7c2e37537202fc709869


 Documentation/cgroups/cgroups.txt |   25 +
 include/linux/cgroup.h            |   67 ++-
 include/linux/init_task.h         |    9 
 include/linux/sched.h             |   15 +
 kernel/cgroup.c                   |  948 +++++++++++++++++++++++++++++--------
 kernel/cgroup_freezer.c           |   15 +
 kernel/cpuset.c                   |   66 ++-
 kernel/fork.c                     |    9 
 kernel/ns_cgroup.c                |   16 +
 kernel/sched.c                    |   35 +
 mm/memcontrol.c                   |    3 
 security/device_cgroup.c          |    3 
 12 files changed, 974 insertions(+), 237 deletions(-)
