From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 00/10] cpuset: implement sane hierarchy behaviors
Date: Fri, 19 Apr 2013 20:25:11 +0800
Message-ID: <517137A7.4020605__29798.4834680848$1366374342$gmane$org@huawei.com>
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

Currently some cpuset behaviors are not friendly when cpuset is co-mounted
with other cgroup controllers.

Now with this patchset if cpuset is mounted with sane_behavior option, it
behaves differently:

- Tasks will be kept in empty cpusets when hotplug happens and take masks
of ancestors with non-empty cpus/mems, instead of being moved to an ancestor.

- A task can be moved into an empty cpuset, and again it takes masks of
ancestors, so we drop a task into a newly created cgroup without the user
having to do anything for it.

As tasks can reside in empy cpusets, here're some rules:

- They can be moved to another cpuset, regardless it's empty or not.

- Though it takes masks from ancestors, it takes other configs from the
empty cpuset.

- If the ancestors' masks are changed, those tasks will also be updated
to take new masks.

The first 6 patches are actually cleanups which can be applied no matter
if the last 4 patches are acceptable or not.

Li Zefan (10):
      cpuset: remove redundant check in cpuset_cpus_allowed_fallback()
      cpuset: cleanup guarantee_online_{cpus|mems}()
      cpuset: remove unnecessary variable in cpuset_attach()
      cpuset: remove cpuset_test_cpumask()
      cpuset: don't update tasks' cpumask and nodemask in an empty cpuset
      cpuset: re-structure update_cpumask() a bit
      cpuset: record old_mems_allowed in struct cpuset
      cpuset: introduce effective_{cpumask|nodemask}_cpuset()
      cpuset: allow to keep tasks in empty cpusets
      cpuset: allow to move tasks to empty cpusets

--
 kernel/cpuset.c | 363 +++++++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 262 insertions(+), 101 deletions(-)
