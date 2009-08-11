From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 0/7] CGroups: cgroup memberlist enhancement+fix
Date: Mon, 10 Aug 2009 17:57:30 -0700
Message-ID: <20090811004737.21950.29188.stgit@hastromil.mtv.corp.google.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

(This patch series is a revision of http://lkml.org/lkml/2009/7/30/382 .)

The following series adds a "cgroup.procs" file to each cgroup that reports
unique tgids rather than pids, which can also be written to for moving all
threads in a threadgroup at once.

Patch #5 modifies the subsystem attach interface to be able to attach whole
threadgroups at a time, which could introduce potential problems if any
subsystem were to need the old cgroup of every thread being moved. The attach
interface would need to be revised if this becomes the case.

Patch #6 implements functionality for read/write locking all CLONE_THREAD
fork()ing within a threadgroup, by means of an rwsem that lives in the
sighand_struct, for per-threadgroup-ness and also for sharing a cacheline with
the sighand's atomic count. This scheme should introduce no extra overhead in
the fork path when there's no contention.

Patch #7 reveals potential for a race when forking before a subsystem's attach
function is called - one potential solution in case any subsystem has this
problem is to hang on to the group's fork mutex through the attach() calls,
though no subsystem yet demonstrates need for an extended critical section.

This patch series was written at the same time as Li Zefan's pid namespace
bugfix patch (from http://lkml.org/lkml/2009/7/1/559 ), and contains a similar
but finer-grained fix for the same bug. These patches can either be rewritten
to be applied on top of Li's patch, or be applied as they are with Li's patch
reversed.

---

Ben Blum (7):
      Makes procs file writable to move all threads by tgid at once
      Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup
      Lets ss->can_attach and ss->attach do whole threadgroups at a time
      Changes css_set freeing mechanism to be under RCU
      Quick vmalloc vs kmalloc fix to the case where array size is too large
      Ensures correct concurrent opening/reading of pidlists across pid namespaces
      Adds a read-only "procs" file similar to "tasks" that shows only unique tgids


 Documentation/cgroups/cgroups.txt |   25 +
 include/linux/cgroup.h            |   70 ++-
 include/linux/init_task.h         |    9 
 include/linux/sched.h             |   15 +
 kernel/cgroup.c                   |  881 +++++++++++++++++++++++++++++++------
 kernel/cgroup_freezer.c           |   15 +
 kernel/cpuset.c                   |   66 ++-
 kernel/fork.c                     |    9 
 kernel/ns_cgroup.c                |   16 +
 kernel/sched.c                    |   35 +
 mm/memcontrol.c                   |    3 
 security/device_cgroup.c          |    3 
 12 files changed, 954 insertions(+), 193 deletions(-)
