From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 0/7] cgroups: Allow to bind/unbind subsystems to/from
	non-trival hierarchy
Date: Fri, 22 Oct 2010 16:09:08 +0800
Message-ID: <4CC146A4.9090505__17581.0875407935$1287734943$gmane$org@cn.fujitsu.com>
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
To: "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Stephane posted a patchset to add perf_cgroup subsystem, so perf can
be used to monitor all threads belonging to a cgroup.

But if you already mounted a cgroup hierarchy but without perf_cgroup
and the hierarchy has sub-cgroups, you can't bind perf_cgroup to it,
and thus you're not able to use per-cgroup perf feature.

This patchset alleviates the pain, and then a subsytem can be
bound/unbound to/from a hierarchy which has sub-cgroups in it.

Some subsystems still can't take advantage of this patchset, memcgroup
and cpuset in specific.

For cpuset, if a hierarchy has a sub-cgroup and the cgroup has tasks,
we can't decide sub-cgroup's cpuset.mems and cpuset.cpus automatically
if we try to bind cpuset to this hierarchy.

For memcgroup, memcgroup uses css_get/put(), and due to some complexity,
for now bindable subsystems should not use css_get/put().

Usage:

# mount -t cgroup -o cpuset xxx /mnt
# mkdir /mnt/tmp
# echo $$ > /mnt/tmp/tasks

(add cpuacct to the hierarchy)
# mount -o remount,cpuset,cpuacct xxx /mnt

(remove it from the hierarchy)
# mount -o remount,cpuset xxx /mnt

There's another limitation, cpuacct should not be bound to any mounted
hierarchy before the above operation. But that's not a problem, as you
can remove it from a hierarchy and bind it to another one.

---
 Documentation/cgroups/cgroups.txt |   26 ++-
 include/linux/cgroup.h            |   25 +++-
 kernel/cgroup.c                   |  305 +++++++++++++++++++++++++++++++------
 kernel/cgroup_freezer.c           |   19 ++-
 kernel/sched.c                    |    1 +
 net/sched/cls_cgroup.c            |    1 +
 security/device_cgroup.c          |    1 +
 7 files changed, 311 insertions(+), 67 deletions(-)
