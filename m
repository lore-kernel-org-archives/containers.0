From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 00/11] cpuset: separate configured masks and effective masks
Date: Wed, 21 Aug 2013 17:58:42 +0800
Message-ID: <52148F52.0__36027.1373334855$1377079149$gmane$org@huawei.com>
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

This patcheset introduces behavior changes, but only if you mount cgroupfs
with sane_behavior option:

- We introduce new interfaces cpuset.effective_cpus and cpuset.effective_mems,
  while cpuset.cpus and cpuset.mems will be configured masks.

- The configured masks can be changed by writing cpuset.cpus/mems only. They
  won't be changed when hotplug happens.

- Users can config cpus and mems without restrictions from the parent cpuset.
  effective masks will enforce the hierarchical behavior.

- Users can also config cpus and mems to have already offlined CPU/nodes.

- When a CPU/node is onlined, it will be brought back to the effective masks
  if it's in the configured masks.

- We build sched domains based on effective cpumask but not configured cpumask.

Li Zefan (11):
  cgroup: allow subsystems to create files for sane_behavior only
  cpuset: add cs->real_cpus_allowed and cs->real_mems_allowed
  cpuset: update cpuset->real_{cpus,mems}_allowed at hotplug
  cpuset: update cs->real_{cpus,mems}_allowed when config changes
  cpuset: inherite ancestor's masks if real_{cpus,mems}_allowed become empty
  cpuset: apply cs->real_{cpus,mems}_allowed
  cpuset: use effective cpumask to build sched domains
  cpuset: separate configured masks and efffective masks
  cpuset: enable onlined cpu/node in effective masks
  cpuset: allow writing offlined masks to cpuset.cpus/mems
  cpuset: export effective masks to userspace

 include/linux/cgroup.h |   1 +
 kernel/cgroup.c        |   2 +
 kernel/cpuset.c        | 466 ++++++++++++++++++++++++++++---------------------
 3 files changed, 271 insertions(+), 198 deletions(-)

-- 
1.8.0.2
