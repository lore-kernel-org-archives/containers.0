From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH 00/11 v5] cgroups: Task counter subsystem
Date: Tue, 13 Sep 2011 01:11:20 +0200
Message-ID: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>, Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

No functional changes. Only documentation and comments added.
Checkpatch.pl fixes, etc...

This mostly addresses Andrew's reviews on v4.

Changes in v5:

- commented res_counter_common_ancestor (patch 6)
- commented res_counter_inherit (patch 2)
- merged documentation and task counter subsystem patch (patch 9)
- rename cgroup_task_counter_res in cgroup_task_res_counter (patch 9)
- more comments/ fix comments in cgroup_task_counter.c (patch 9)
- document res_counter_charge return value (patch 8)
- document res_counter_charge_until (patch 5)
- more comment in kconfig help (patch 9)
- fix various checkpatch reported issues

Frederic Weisbecker (11):
  cgroups: Add res_counter_write_u64() API
  cgroups: New resource counter inheritance API
  cgroups: Add previous cgroup in can_attach_task/attach_task callbacks
  cgroups: New cancel_attach_task subsystem callback
  cgroups: Ability to stop res charge propagation on bounded ancestor
  cgroups: Add res counter common ancestor searching
  res_counter: Allow charge failure pointer to be null
  cgroups: Pull up res counter charge failure interpretation to caller
  cgroups: Add a task counter subsystem
  cgroups: Allow subsystems to cancel a fork
  cgroups: Convert task counter to use the subsys fork callback

 Documentation/cgroups/cgroups.txt          |   13 ++-
 Documentation/cgroups/resource_counter.txt |   20 +++-
 Documentation/cgroups/task_counter.txt     |  126 +++++++++++++++
 block/blk-cgroup.c                         |   12 +-
 include/linux/cgroup.h                     |   22 ++-
 include/linux/cgroup_subsys.h              |    8 +
 include/linux/res_counter.h                |   27 +++-
 init/Kconfig                               |    9 +
 kernel/Makefile                            |    1 +
 kernel/cgroup.c                            |   58 ++++++--
 kernel/cgroup_freezer.c                    |    9 +-
 kernel/cgroup_task_counter.c               |  239 ++++++++++++++++++++++++++++
 kernel/cpuset.c                            |    6 +-
 kernel/events/core.c                       |    5 +-
 kernel/exit.c                              |    2 +-
 kernel/fork.c                              |    7 +-
 kernel/res_counter.c                       |   86 +++++++++--
 kernel/sched.c                             |    6 +-
 18 files changed, 601 insertions(+), 55 deletions(-)
 create mode 100644 Documentation/cgroups/task_counter.txt
 create mode 100644 kernel/cgroup_task_counter.c

-- 
1.7.5.4
