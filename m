From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 0/7] cpuset: implement sane hierarchy behaviors
Date: Sun, 9 Jun 2013 17:14:02 +0800
Message-ID: <51B4475A.8030509__28800.6465802484$1370769287$gmane$org@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

v2 -> v3:

- remove async hotplug propagation work
- do propagation work in one place for both hotplug and unplug

v1 -> v2:

- add documentation in include/linux/cgroup.h
- drop rcu_read_lock() before calling update_task_nodemask() when iterating
cpuset hierarchy

======================================

Currently some cpuset behaviors are not friendly when cpuset is co-mounted
with other cgroup controllers.

Now with this patchset if cpuset is mounted with sane_behavior option, it
behaves differently:

- Tasks will be kept in empty cpusets when hotplug happens and take masks
of ancestors with non-empty cpus/mems, instead of being moved to an ancestor.

- A task can be moved into an empty cpuset, and again it takes masks of
ancestors, so the user can drop a task into a newly created cgroup without
having to do anything for it.

As tasks can reside in empy cpusets, here're some rules:

- They can be moved to another cpuset, regardless it's empty or not.

- Though it takes masks from ancestors, it takes other configs from the
empty cpuset.

- If the ancestors' masks are changed, those tasks will also be updated
to take new masks.

Li Zefan (7):
  cpuset: let hotplug propagation work wait for task attaching
  cpuset: remove async hotplug propagation work
  cpuset: record old_mems_allowed in struct cpuset
  cpuset: introduce effective_{cpumask|nodemask}_cpuset()
  cpuset: allow to keep tasks in empty cpusets
  cpuset: allow to move tasks to empty cpusets
  cpuset: fix to migrate mm correctly in a corner case

 include/linux/cgroup.h |   7 +
 kernel/cpuset.c        | 390 ++++++++++++++++++++++++++++++++-----------------
 2 files changed, 264 insertions(+), 133 deletions(-)

-- 
1.8.0.2
