From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/6] CGroups: cgroup memberlist enhancement+fix
Date: Thu, 23 Jul 2009 20:21:35 -0700
Message-ID: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
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

(This patch series contains revisions of the patches from
http://lkml.org/lkml/2009/7/10/396 and a few more.)

The following series adds a "cgroup.procs" file to each cgroup that reports
unique tgids rather than pids, which can also be written to for moving all
threads in a threadgroup at once.

Patch #5 introduces a new rwsem that must be taken for reading in the fork()
path, and patch #6 reveals potential for a race when forking in certain
subsystems before the subsystem's attach() function is called, the naive
solution to which would be holding on to the fork rwsem until after the attach
loop. Suggestions for alternative approaches or tweaks to the current approach
are welcome; one potential fix is to make the fork rwsem per-threadgroup,
which will involve adding a field to task_struct, thereby drastically reducing
contention when a write to the procs file is in progress.

This patch series was written at the same time as Li Zefan's pid namespace
bugfix patch (from http://lkml.org/lkml/2009/7/1/559 ), and contains a similar
but finer-grained fix for the same bug. These patches can either be rewritten
to be applied on top of Li's patch, or be applied as they are with Li's patch
reversed.

---

Ben Blum (6):
      Lets ss->can_attach and ss->attach do whole threadgroups at a time
      Makes procs file writable to move all threads by tgid at once
      Changes css_set freeing mechanism to be under RCU
      Quick vmalloc vs kmalloc fix to the case where array size is too large
      Ensures correct concurrent opening/reading of pidlists across pid namespaces
      Adds a read-only "procs" file similar to "tasks" that shows only unique tgids


 Documentation/cgroups/cgroups.txt |   12 -
 include/linux/cgroup.h            |   58 ++-
 kernel/cgroup.c                   |  816 ++++++++++++++++++++++++++++++-------
 kernel/cgroup_freezer.c           |   15 +
 kernel/cpuset.c                   |   65 ++-
 kernel/fork.c                     |    2 
 kernel/ns_cgroup.c                |   16 +
 kernel/sched.c                    |   37 ++
 mm/memcontrol.c                   |    3 
 security/device_cgroup.c          |    3 
 10 files changed, 843 insertions(+), 184 deletions(-)
