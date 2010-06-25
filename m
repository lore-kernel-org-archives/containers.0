From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [RFC] [PATCH v3 0/2] cgroups: implement moving a threadgroup's
	threads atomically with cgroup.procs
Date: Fri, 25 Jun 2010 01:45:41 -0400
Message-ID: <20100625054541.GA20610__22981.8324013197$1277444825$gmane$org@ghc01.ghc.andrew.cmu.edu>
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

This patch series is a revision of http://lkml.org/lkml/2010/5/29/126 .

These patches use an rwlock in signal_struct which access is dependent
on Oleg's recent changes to signal_struct's lifetime rules.

It is okay to write the tid of any task in the threadgroup. This is
implemented by taking task->group_leader right after find_task_by_vpid
while still rcu_read-side. This makes it necessary to check if
thread_group_leader(leader) every time we want to iterate over
->thread_group; each of these checks can fail with -EAGAIN.
Unfortunately this also means I needed to put these checks in can_attach
for each subsystem that needs to check each thread in the group.

I handle EAGAIN in the file's write handler, since hey, it's a super
expensive operation, might as well make it unbounded-time to boot - this
is optional and would work just as well with -EAGAIN sent to userspace.

-- bblum

---
 Documentation/cgroups/cgroups.txt |   13 -
 include/linux/cgroup.h            |   15 -
 include/linux/init_task.h         |    9
 include/linux/sched.h             |   10
 kernel/cgroup.c                   |  449 +++++++++++++++++++++++++++++++++-----
 kernel/cgroup_freezer.c           |    4
 kernel/cpuset.c                   |    4
 kernel/fork.c                     |   10
 kernel/ns_cgroup.c                |    4
 kernel/sched.c                    |    4
 10 files changed, 462 insertions(+), 60 deletions(-)
