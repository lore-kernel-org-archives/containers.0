From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: consolidate cgroup documents
Date: Fri, 09 Jan 2009 10:16:35 +0800
Message-ID: <4966B383.3030106__28749.7659134262$1231467893$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000001060706060400070609"
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------000001060706060400070609
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Move Documentation/cpusets.txt and Documentation/controllers/* to
Documentation/cgroups/

This inlined patch is generated with git-show -M (rename detected)
and is for review, and the attached one is for apply.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt            |    5 +++--
 Documentation/cgroups/memcg_test.txt         |    2 +-
 Documentation/scheduler/sched-design-CFS.txt |    2 +-
 include/linux/res_counter.h                  |    2 +-
 init/Kconfig                                 |    9 ++++-----
 kernel/cpuset.c                              |    2 +-
 11 files changed, 11 insertions(+), 11 deletions(-)

 rename Documentation/{controllers => cgroups}/cpuacct.txt (100%)
 rename Documentation/{ => cgroups}/cpusets.txt (100%)
 rename Documentation/{controllers => cgroups}/devices.txt (100%)
 rename Documentation/{controllers => cgroups}/memcg_test.txt (99%)
 rename Documentation/{controllers => cgroups}/memory.txt (100%)
 rename Documentation/{controllers => cgroups}/resource_counter.txt (100%)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index e33ee74..d9e5d6f 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -1,7 +1,8 @@
 				CGROUPS
 				-------
 
-Written by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> based on Documentation/cpusets.txt
+Written by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> based on
+Documentation/cgroups/cpusets.txt
 
 Original copyright statements from cpusets.txt:
 Portions Copyright (C) 2004 BULL SA.
@@ -68,7 +69,7 @@ On their own, the only use for cgroups is for simple job
 tracking. The intention is that other subsystems hook into the generic
 cgroup support to provide new attributes for cgroups, such as
 accounting/limiting the resources which processes in a cgroup can
-access. For example, cpusets (see Documentation/cpusets.txt) allows
+access. For example, cpusets (see Documentation/cgroups/cpusets.txt) allows
 you to associate a set of CPUs and a set of memory nodes with the
 tasks in each cgroup.
 
diff --git a/Documentation/controllers/cpuacct.txt b/Documentation/cgroups/cpuacct.txt
similarity index 100%
rename from Documentation/controllers/cpuacct.txt
rename to Documentation/cgroups/cpuacct.txt
diff --git a/Documentation/cpusets.txt b/Documentation/cgroups/cpusets.txt
similarity index 100%
rename from Documentation/cpusets.txt
rename to Documentation/cgroups/cpusets.txt
diff --git a/Documentation/controllers/devices.txt b/Documentation/cgroups/devices.txt
similarity index 100%
rename from Documentation/controllers/devices.txt
rename to Documentation/cgroups/devices.txt
diff --git a/Documentation/controllers/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
similarity index 99%
rename from Documentation/controllers/memcg_test.txt
rename to Documentation/cgroups/memcg_test.txt
index 08d4d3e..19533f9 100644
--- a/Documentation/controllers/memcg_test.txt
+++ b/Documentation/cgroups/memcg_test.txt
@@ -6,7 +6,7 @@ Because VM is getting complex (one of reasons is memcg...), memcg's behavior
 is complex. This is a document for memcg's internal behavior.
 Please note that implementation details can be changed.
 
-(*) Topics on API should be in Documentation/controllers/memory.txt)
+(*) Topics on API should be in Documentation/cgroups/memory.txt)
 
 0. How to record usage ?
    2 objects are used.
diff --git a/Documentation/controllers/memory.txt b/Documentation/cgroups/memory.txt
similarity index 100%
rename from Documentation/controllers/memory.txt
rename to Documentation/cgroups/memory.txt
diff --git a/Documentation/controllers/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
similarity index 100%
rename from Documentation/controllers/resource_counter.txt
rename to Documentation/cgroups/resource_counter.txt
diff --git a/Documentation/scheduler/sched-design-CFS.txt b/Documentation/scheduler/sched-design-CFS.txt
index 8398ca4..6f33593 100644
--- a/Documentation/scheduler/sched-design-CFS.txt
+++ b/Documentation/scheduler/sched-design-CFS.txt
@@ -231,7 +231,7 @@ CPU bandwidth control purposes:
 
    This options needs CONFIG_CGROUPS to be defined, and lets the administrator
    create arbitrary groups of tasks, using the "cgroup" pseudo filesystem.  See
-   Documentation/cgroups.txt for more information about this filesystem.
+   Documentation/cgroups/cgroups.txt for more information about this filesystem.
 
 Only one of these options to group tasks can be chosen and not both.
 
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index dede0a2..4c5bcf6 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -9,7 +9,7 @@
  *
  * Author: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
  *
- * See Documentation/controllers/resource_counter.txt for more
+ * See Documentation/cgroups/resource_counter.txt for more
  * info about what this counter is.
  */
 
diff --git a/init/Kconfig b/init/Kconfig
index 56fd93c..2af8382 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -323,8 +323,8 @@ config CGROUP_SCHED
 	  This option allows you to create arbitrary task groups
 	  using the "cgroup" pseudo filesystem and control
 	  the cpu bandwidth allocated to each such task group.
-	  Refer to Documentation/cgroups.txt for more information
-	  on "cgroup" pseudo filesystem.
+	  Refer to Documentation/cgroups/cgroups.txt for more
+	  information on "cgroup" pseudo filesystem.
 
 endchoice
 
@@ -335,10 +335,9 @@ menuconfig CGROUPS
 	  use with process control subsystems such as Cpusets, CFS, memory
 	  controls or device isolation.
 	  See
-		- Documentation/cpusets.txt	(Cpusets)
 		- Documentation/scheduler/sched-design-CFS.txt	(CFS)
-		- Documentation/cgroups/ (features for grouping, isolation)
-		- Documentation/controllers/ (features for resource control)
+		- Documentation/cgroups/ (features for grouping, isolation
+					  and resource control)
 
 	  Say N if unsure.
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 647c77a..a856788 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -568,7 +568,7 @@ update_domain_attr_tree(struct sched_domain_attr *dattr, struct cpuset *c)
  * load balancing domains (sched domains) as specified by that partial
  * partition.
  *
- * See "What is sched_load_balance" in Documentation/cpusets.txt
+ * See "What is sched_load_balance" in Documentation/cgroups/cpusets.txt
  * for a background explanation of this.
  *
  * Does not return errors, on the theory that the callers of this

--------------000001060706060400070609
Content-Type: text/x-patch;
 name="cgroups-consolidate-cgroup-documents.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cgroups-consolidate-cgroup-documents.patch"

From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Fri, 9 Jan 2009 09:52:13 +0800
Subject: [PATCH] cgroups: consolidate cgroup documents

Move Documentation/cpusets.txt and Documentation/controllers/* to
Documentation/cgroups/

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt              |    5 +-
 Documentation/cgroups/cpuacct.txt              |   32 +
 Documentation/cgroups/cpusets.txt              |  808 ++++++++++++++++++++++++
 Documentation/cgroups/devices.txt              |   52 ++
 Documentation/cgroups/memcg_test.txt           |  342 ++++++++++
 Documentation/cgroups/memory.txt               |  399 ++++++++++++
 Documentation/cgroups/resource_counter.txt     |  181 ++++++
 Documentation/controllers/cpuacct.txt          |   32 -
 Documentation/controllers/devices.txt          |   52 --
 Documentation/controllers/memcg_test.txt       |  342 ----------
 Documentation/controllers/memory.txt           |  399 ------------
 Documentation/controllers/resource_counter.txt |  181 ------
 Documentation/cpusets.txt                      |  808 ------------------------
 Documentation/scheduler/sched-design-CFS.txt   |    2 +-
 include/linux/res_counter.h                    |    2 +-
 init/Kconfig                                   |    9 +-
 kernel/cpuset.c                                |    2 +-
 17 files changed, 1824 insertions(+), 1824 deletions(-)
 create mode 100644 Documentation/cgroups/cpuacct.txt
 create mode 100644 Documentation/cgroups/cpusets.txt
 create mode 100644 Documentation/cgroups/devices.txt
 create mode 100644 Documentation/cgroups/memcg_test.txt
 create mode 100644 Documentation/cgroups/memory.txt
 create mode 100644 Documentation/cgroups/resource_counter.txt
 delete mode 100644 Documentation/controllers/cpuacct.txt
 delete mode 100644 Documentation/controllers/devices.txt
 delete mode 100644 Documentation/controllers/memcg_test.txt
 delete mode 100644 Documentation/controllers/memory.txt
 delete mode 100644 Documentation/controllers/resource_counter.txt
 delete mode 100644 Documentation/cpusets.txt

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index e33ee74..d9e5d6f 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -1,7 +1,8 @@
 				CGROUPS
 				-------
 
-Written by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> based on Documentation/cpusets.txt
+Written by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> based on
+Documentation/cgroups/cpusets.txt
 
 Original copyright statements from cpusets.txt:
 Portions Copyright (C) 2004 BULL SA.
@@ -68,7 +69,7 @@ On their own, the only use for cgroups is for simple job
 tracking. The intention is that other subsystems hook into the generic
 cgroup support to provide new attributes for cgroups, such as
 accounting/limiting the resources which processes in a cgroup can
-access. For example, cpusets (see Documentation/cpusets.txt) allows
+access. For example, cpusets (see Documentation/cgroups/cpusets.txt) allows
 you to associate a set of CPUs and a set of memory nodes with the
 tasks in each cgroup.
 
diff --git a/Documentation/cgroups/cpuacct.txt b/Documentation/cgroups/cpuacct.txt
new file mode 100644
index 0000000..bb775fb
--- /dev/null
+++ b/Documentation/cgroups/cpuacct.txt
@@ -0,0 +1,32 @@
+CPU Accounting Controller
+-------------------------
+
+The CPU accounting controller is used to group tasks using cgroups and
+account the CPU usage of these groups of tasks.
+
+The CPU accounting controller supports multi-hierarchy groups. An accounting
+group accumulates the CPU usage of all of its child groups and the tasks
+directly present in its group.
+
+Accounting groups can be created by first mounting the cgroup filesystem.
+
+# mkdir /cgroups
+# mount -t cgroup -ocpuacct none /cgroups
+
+With the above step, the initial or the parent accounting group
+becomes visible at /cgroups. At bootup, this group includes all the
+tasks in the system. /cgroups/tasks lists the tasks in this cgroup.
+/cgroups/cpuacct.usage gives the CPU time (in nanoseconds) obtained by
+this group which is essentially the CPU time obtained by all the tasks
+in the system.
+
+New accounting groups can be created under the parent group /cgroups.
+
+# cd /cgroups
+# mkdir g1
+# echo $$ > g1
+
+The above steps create a new group g1 and move the current shell
+process (bash) into it. CPU time consumed by this bash and its children
+can be obtained from g1/cpuacct.usage and the same is accumulated in
+/cgroups/cpuacct.usage also.
diff --git a/Documentation/cgroups/cpusets.txt b/Documentation/cgroups/cpusets.txt
new file mode 100644
index 0000000..5c86c25
--- /dev/null
+++ b/Documentation/cgroups/cpusets.txt
@@ -0,0 +1,808 @@
+				CPUSETS
+				-------
+
+Copyright (C) 2004 BULL SA.
+Written by Simon.Derr-6ktuUTfB/bM@public.gmane.org
+
+Portions Copyright (c) 2004-2006 Silicon Graphics, Inc.
+Modified by Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
+Modified by Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
+Modified by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
+Modified by Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
+
+CONTENTS:
+=========
+
+1. Cpusets
+  1.1 What are cpusets ?
+  1.2 Why are cpusets needed ?
+  1.3 How are cpusets implemented ?
+  1.4 What are exclusive cpusets ?
+  1.5 What is memory_pressure ?
+  1.6 What is memory spread ?
+  1.7 What is sched_load_balance ?
+  1.8 What is sched_relax_domain_level ?
+  1.9 How do I use cpusets ?
+2. Usage Examples and Syntax
+  2.1 Basic Usage
+  2.2 Adding/removing cpus
+  2.3 Setting flags
+  2.4 Attaching processes
+3. Questions
+4. Contact
+
+1. Cpusets
+==========
+
+1.1 What are cpusets ?
+----------------------
+
+Cpusets provide a mechanism for assigning a set of CPUs and Memory
+Nodes to a set of tasks.   In this document "Memory Node" refers to
+an on-line node that contains memory.
+
+Cpusets constrain the CPU and Memory placement of tasks to only
+the resources within a tasks current cpuset.  They form a nested
+hierarchy visible in a virtual file system.  These are the essential
+hooks, beyond what is already present, required to manage dynamic
+job placement on large systems.
+
+Cpusets use the generic cgroup subsystem described in
+Documentation/cgroups/cgroups.txt.
+
+Requests by a task, using the sched_setaffinity(2) system call to
+include CPUs in its CPU affinity mask, and using the mbind(2) and
+set_mempolicy(2) system calls to include Memory Nodes in its memory
+policy, are both filtered through that tasks cpuset, filtering out any
+CPUs or Memory Nodes not in that cpuset.  The scheduler will not
+schedule a task on a CPU that is not allowed in its cpus_allowed
+vector, and the kernel page allocator will not allocate a page on a
+node that is not allowed in the requesting tasks mems_allowed vector.
+
+User level code may create and destroy cpusets by name in the cgroup
+virtual file system, manage the attributes and permissions of these
+cpusets and which CPUs and Memory Nodes are assigned to each cpuset,
+specify and query to which cpuset a task is assigned, and list the
+task pids assigned to a cpuset.
+
+
+1.2 Why are cpusets needed ?
+----------------------------
+
+The management of large computer systems, with many processors (CPUs),
+complex memory cache hierarchies and multiple Memory Nodes having
+non-uniform access times (NUMA) presents additional challenges for
+the efficient scheduling and memory placement of processes.
+
+Frequently more modest sized systems can be operated with adequate
+efficiency just by letting the operating system automatically share
+the available CPU and Memory resources amongst the requesting tasks.
+
+But larger systems, which benefit more from careful processor and
+memory placement to reduce memory access times and contention,
+and which typically represent a larger investment for the customer,
+can benefit from explicitly placing jobs on properly sized subsets of
+the system.
+
+This can be especially valuable on:
+
+    * Web Servers running multiple instances of the same web application,
+    * Servers running different applications (for instance, a web server
+      and a database), or
+    * NUMA systems running large HPC applications with demanding
+      performance characteristics.
+
+These subsets, or "soft partitions" must be able to be dynamically
+adjusted, as the job mix changes, without impacting other concurrently
+executing jobs. The location of the running jobs pages may also be moved
+when the memory locations are changed.
+
+The kernel cpuset patch provides the minimum essential kernel
+mechanisms required to efficiently implement such subsets.  It
+leverages existing CPU and Memory Placement facilities in the Linux
+kernel to avoid any additional impact on the critical scheduler or
+memory allocator code.
+
+
+1.3 How are cpusets implemented ?
+---------------------------------
+
+Cpusets provide a Linux kernel mechanism to constrain which CPUs and
+Memory Nodes are used by a process or set of processes.
+
+The Linux kernel already has a pair of mechanisms to specify on which
+CPUs a task may be scheduled (sched_setaffinity) and on which Memory
+Nodes it may obtain memory (mbind, set_mempolicy).
+
+Cpusets extends these two mechanisms as follows:
+
+ - Cpusets are sets of allowed CPUs and Memory Nodes, known to the
+   kernel.
+ - Each task in the system is attached to a cpuset, via a pointer
+   in the task structure to a reference counted cgroup structure.
+ - Calls to sched_setaffinity are filtered to just those CPUs
+   allowed in that tasks cpuset.
+ - Calls to mbind and set_mempolicy are filtered to just
+   those Memory Nodes allowed in that tasks cpuset.
+ - The root cpuset contains all the systems CPUs and Memory
+   Nodes.
+ - For any cpuset, one can define child cpusets containing a subset
+   of the parents CPU and Memory Node resources.
+ - The hierarchy of cpusets can be mounted at /dev/cpuset, for
+   browsing and manipulation from user space.
+ - A cpuset may be marked exclusive, which ensures that no other
+   cpuset (except direct ancestors and descendents) may contain
+   any overlapping CPUs or Memory Nodes.
+ - You can list all the tasks (by pid) attached to any cpuset.
+
+The implementation of cpusets requires a few, simple hooks
+into the rest of the kernel, none in performance critical paths:
+
+ - in init/main.c, to initialize the root cpuset at system boot.
+ - in fork and exit, to attach and detach a task from its cpuset.
+ - in sched_setaffinity, to mask the requested CPUs by what's
+   allowed in that tasks cpuset.
+ - in sched.c migrate_all_tasks(), to keep migrating tasks within
+   the CPUs allowed by their cpuset, if possible.
+ - in the mbind and set_mempolicy system calls, to mask the requested
+   Memory Nodes by what's allowed in that tasks cpuset.
+ - in page_alloc.c, to restrict memory to allowed nodes.
+ - in vmscan.c, to restrict page recovery to the current cpuset.
+
+You should mount the "cgroup" filesystem type in order to enable
+browsing and modifying the cpusets presently known to the kernel.  No
+new system calls are added for cpusets - all support for querying and
+modifying cpusets is via this cpuset file system.
+
+The /proc/<pid>/status file for each task has four added lines,
+displaying the tasks cpus_allowed (on which CPUs it may be scheduled)
+and mems_allowed (on which Memory Nodes it may obtain memory),
+in the two formats seen in the following example:
+
+  Cpus_allowed:   ffffffff,ffffffff,ffffffff,ffffffff
+  Cpus_allowed_list:      0-127
+  Mems_allowed:   ffffffff,ffffffff
+  Mems_allowed_list:      0-63
+
+Each cpuset is represented by a directory in the cgroup file system
+containing (on top of the standard cgroup files) the following
+files describing that cpuset:
+
+ - cpus: list of CPUs in that cpuset
+ - mems: list of Memory Nodes in that cpuset
+ - memory_migrate flag: if set, move pages to cpusets nodes
+ - cpu_exclusive flag: is cpu placement exclusive?
+ - mem_exclusive flag: is memory placement exclusive?
+ - mem_hardwall flag:  is memory allocation hardwalled
+ - memory_pressure: measure of how much paging pressure in cpuset
+
+In addition, the root cpuset only has the following file:
+ - memory_pressure_enabled flag: compute memory_pressure?
+
+New cpusets are created using the mkdir system call or shell
+command.  The properties of a cpuset, such as its flags, allowed
+CPUs and Memory Nodes, and attached tasks, are modified by writing
+to the appropriate file in that cpusets directory, as listed above.
+
+The named hierarchical structure of nested cpusets allows partitioning
+a large system into nested, dynamically changeable, "soft-partitions".
+
+The attachment of each task, automatically inherited at fork by any
+children of that task, to a cpuset allows organizing the work load
+on a system into related sets of tasks such that each set is constrained
+to using the CPUs and Memory Nodes of a particular cpuset.  A task
+may be re-attached to any other cpuset, if allowed by the permissions
+on the necessary cpuset file system directories.
+
+Such management of a system "in the large" integrates smoothly with
+the detailed placement done on individual tasks and memory regions
+using the sched_setaffinity, mbind and set_mempolicy system calls.
+
+The following rules apply to each cpuset:
+
+ - Its CPUs and Memory Nodes must be a subset of its parents.
+ - It can't be marked exclusive unless its parent is.
+ - If its cpu or memory is exclusive, they may not overlap any sibling.
+
+These rules, and the natural hierarchy of cpusets, enable efficient
+enforcement of the exclusive guarantee, without having to scan all
+cpusets every time any of them change to ensure nothing overlaps a
+exclusive cpuset.  Also, the use of a Linux virtual file system (vfs)
+to represent the cpuset hierarchy provides for a familiar permission
+and name space for cpusets, with a minimum of additional kernel code.
+
+The cpus and mems files in the root (top_cpuset) cpuset are
+read-only.  The cpus file automatically tracks the value of
+cpu_online_map using a CPU hotplug notifier, and the mems file
+automatically tracks the value of node_states[N_HIGH_MEMORY]--i.e.,
+nodes with memory--using the cpuset_track_online_nodes() hook.
+
+
+1.4 What are exclusive cpusets ?
+--------------------------------
+
+If a cpuset is cpu or mem exclusive, no other cpuset, other than
+a direct ancestor or descendent, may share any of the same CPUs or
+Memory Nodes.
+
+A cpuset that is mem_exclusive *or* mem_hardwall is "hardwalled",
+i.e. it restricts kernel allocations for page, buffer and other data
+commonly shared by the kernel across multiple users.  All cpusets,
+whether hardwalled or not, restrict allocations of memory for user
+space.  This enables configuring a system so that several independent
+jobs can share common kernel data, such as file system pages, while
+isolating each job's user allocation in its own cpuset.  To do this,
+construct a large mem_exclusive cpuset to hold all the jobs, and
+construct child, non-mem_exclusive cpusets for each individual job.
+Only a small amount of typical kernel memory, such as requests from
+interrupt handlers, is allowed to be taken outside even a
+mem_exclusive cpuset.
+
+
+1.5 What is memory_pressure ?
+-----------------------------
+The memory_pressure of a cpuset provides a simple per-cpuset metric
+of the rate that the tasks in a cpuset are attempting to free up in
+use memory on the nodes of the cpuset to satisfy additional memory
+requests.
+
+This enables batch managers monitoring jobs running in dedicated
+cpusets to efficiently detect what level of memory pressure that job
+is causing.
+
+This is useful both on tightly managed systems running a wide mix of
+submitted jobs, which may choose to terminate or re-prioritize jobs that
+are trying to use more memory than allowed on the nodes assigned them,
+and with tightly coupled, long running, massively parallel scientific
+computing jobs that will dramatically fail to meet required performance
+goals if they start to use more memory than allowed to them.
+
+This mechanism provides a very economical way for the batch manager
+to monitor a cpuset for signs of memory pressure.  It's up to the
+batch manager or other user code to decide what to do about it and
+take action.
+
+==> Unless this feature is enabled by writing "1" to the special file
+    /dev/cpuset/memory_pressure_enabled, the hook in the rebalance
+    code of __alloc_pages() for this metric reduces to simply noticing
+    that the cpuset_memory_pressure_enabled flag is zero.  So only
+    systems that enable this feature will compute the metric.
+
+Why a per-cpuset, running average:
+
+    Because this meter is per-cpuset, rather than per-task or mm,
+    the system load imposed by a batch scheduler monitoring this
+    metric is sharply reduced on large systems, because a scan of
+    the tasklist can be avoided on each set of queries.
+
+    Because this meter is a running average, instead of an accumulating
+    counter, a batch scheduler can detect memory pressure with a
+    single read, instead of having to read and accumulate results
+    for a period of time.
+
+    Because this meter is per-cpuset rather than per-task or mm,
+    the batch scheduler can obtain the key information, memory
+    pressure in a cpuset, with a single read, rather than having to
+    query and accumulate results over all the (dynamically changing)
+    set of tasks in the cpuset.
+
+A per-cpuset simple digital filter (requires a spinlock and 3 words
+of data per-cpuset) is kept, and updated by any task attached to that
+cpuset, if it enters the synchronous (direct) page reclaim code.
+
+A per-cpuset file provides an integer number representing the recent
+(half-life of 10 seconds) rate of direct page reclaims caused by
+the tasks in the cpuset, in units of reclaims attempted per second,
+times 1000.
+
+
+1.6 What is memory spread ?
+---------------------------
+There are two boolean flag files per cpuset that control where the
+kernel allocates pages for the file system buffers and related in
+kernel data structures.  They are called 'memory_spread_page' and
+'memory_spread_slab'.
+
+If the per-cpuset boolean flag file 'memory_spread_page' is set, then
+the kernel will spread the file system buffers (page cache) evenly
+over all the nodes that the faulting task is allowed to use, instead
+of preferring to put those pages on the node where the task is running.
+
+If the per-cpuset boolean flag file 'memory_spread_slab' is set,
+then the kernel will spread some file system related slab caches,
+such as for inodes and dentries evenly over all the nodes that the
+faulting task is allowed to use, instead of preferring to put those
+pages on the node where the task is running.
+
+The setting of these flags does not affect anonymous data segment or
+stack segment pages of a task.
+
+By default, both kinds of memory spreading are off, and memory
+pages are allocated on the node local to where the task is running,
+except perhaps as modified by the tasks NUMA mempolicy or cpuset
+configuration, so long as sufficient free memory pages are available.
+
+When new cpusets are created, they inherit the memory spread settings
+of their parent.
+
+Setting memory spreading causes allocations for the affected page
+or slab caches to ignore the tasks NUMA mempolicy and be spread
+instead.    Tasks using mbind() or set_mempolicy() calls to set NUMA
+mempolicies will not notice any change in these calls as a result of
+their containing tasks memory spread settings.  If memory spreading
+is turned off, then the currently specified NUMA mempolicy once again
+applies to memory page allocations.
+
+Both 'memory_spread_page' and 'memory_spread_slab' are boolean flag
+files.  By default they contain "0", meaning that the feature is off
+for that cpuset.  If a "1" is written to that file, then that turns
+the named feature on.
+
+The implementation is simple.
+
+Setting the flag 'memory_spread_page' turns on a per-process flag
+PF_SPREAD_PAGE for each task that is in that cpuset or subsequently
+joins that cpuset.  The page allocation calls for the page cache
+is modified to perform an inline check for this PF_SPREAD_PAGE task
+flag, and if set, a call to a new routine cpuset_mem_spread_node()
+returns the node to prefer for the allocation.
+
+Similarly, setting 'memory_spread_slab' turns on the flag
+PF_SPREAD_SLAB, and appropriately marked slab caches will allocate
+pages from the node returned by cpuset_mem_spread_node().
+
+The cpuset_mem_spread_node() routine is also simple.  It uses the
+value of a per-task rotor cpuset_mem_spread_rotor to select the next
+node in the current tasks mems_allowed to prefer for the allocation.
+
+This memory placement policy is also known (in other contexts) as
+round-robin or interleave.
+
+This policy can provide substantial improvements for jobs that need
+to place thread local data on the corresponding node, but that need
+to access large file system data sets that need to be spread across
+the several nodes in the jobs cpuset in order to fit.  Without this
+policy, especially for jobs that might have one thread reading in the
+data set, the memory allocation across the nodes in the jobs cpuset
+can become very uneven.
+
+1.7 What is sched_load_balance ?
+--------------------------------
+
+The kernel scheduler (kernel/sched.c) automatically load balances
+tasks.  If one CPU is underutilized, kernel code running on that
+CPU will look for tasks on other more overloaded CPUs and move those
+tasks to itself, within the constraints of such placement mechanisms
+as cpusets and sched_setaffinity.
+
+The algorithmic cost of load balancing and its impact on key shared
+kernel data structures such as the task list increases more than
+linearly with the number of CPUs being balanced.  So the scheduler
+has support to  partition the systems CPUs into a number of sched
+domains such that it only load balances within each sched domain.
+Each sched domain covers some subset of the CPUs in the system;
+no two sched domains overlap; some CPUs might not be in any sched
+domain and hence won't be load balanced.
+
+Put simply, it costs less to balance between two smaller sched domains
+than one big one, but doing so means that overloads in one of the
+two domains won't be load balanced to the other one.
+
+By default, there is one sched domain covering all CPUs, except those
+marked isolated using the kernel boot time "isolcpus=" argument.
+
+This default load balancing across all CPUs is not well suited for
+the following two situations:
+ 1) On large systems, load balancing across many CPUs is expensive.
+    If the system is managed using cpusets to place independent jobs
+    on separate sets of CPUs, full load balancing is unnecessary.
+ 2) Systems supporting realtime on some CPUs need to minimize
+    system overhead on those CPUs, including avoiding task load
+    balancing if that is not needed.
+
+When the per-cpuset flag "sched_load_balance" is enabled (the default
+setting), it requests that all the CPUs in that cpusets allowed 'cpus'
+be contained in a single sched domain, ensuring that load balancing
+can move a task (not otherwised pinned, as by sched_setaffinity)
+from any CPU in that cpuset to any other.
+
+When the per-cpuset flag "sched_load_balance" is disabled, then the
+scheduler will avoid load balancing across the CPUs in that cpuset,
+--except-- in so far as is necessary because some overlapping cpuset
+has "sched_load_balance" enabled.
+
+So, for example, if the top cpuset has the flag "sched_load_balance"
+enabled, then the scheduler will have one sched domain covering all
+CPUs, and the setting of the "sched_load_balance" flag in any other
+cpusets won't matter, as we're already fully load balancing.
+
+Therefore in the above two situations, the top cpuset flag
+"sched_load_balance" should be disabled, and only some of the smaller,
+child cpusets have this flag enabled.
+
+When doing this, you don't usually want to leave any unpinned tasks in
+the top cpuset that might use non-trivial amounts of CPU, as such tasks
+may be artificially constrained to some subset of CPUs, depending on
+the particulars of this flag setting in descendent cpusets.  Even if
+such a task could use spare CPU cycles in some other CPUs, the kernel
+scheduler might not consider the possibility of load balancing that
+task to that underused CPU.
+
+Of course, tasks pinned to a particular CPU can be left in a cpuset
+that disables "sched_load_balance" as those tasks aren't going anywhere
+else anyway.
+
+There is an impedance mismatch here, between cpusets and sched domains.
+Cpusets are hierarchical and nest.  Sched domains are flat; they don't
+overlap and each CPU is in at most one sched domain.
+
+It is necessary for sched domains to be flat because load balancing
+across partially overlapping sets of CPUs would risk unstable dynamics
+that would be beyond our understanding.  So if each of two partially
+overlapping cpusets enables the flag 'sched_load_balance', then we
+form a single sched domain that is a superset of both.  We won't move
+a task to a CPU outside it cpuset, but the scheduler load balancing
+code might waste some compute cycles considering that possibility.
+
+This mismatch is why there is not a simple one-to-one relation
+between which cpusets have the flag "sched_load_balance" enabled,
+and the sched domain configuration.  If a cpuset enables the flag, it
+will get balancing across all its CPUs, but if it disables the flag,
+it will only be assured of no load balancing if no other overlapping
+cpuset enables the flag.
+
+If two cpusets have partially overlapping 'cpus' allowed, and only
+one of them has this flag enabled, then the other may find its
+tasks only partially load balanced, just on the overlapping CPUs.
+This is just the general case of the top_cpuset example given a few
+paragraphs above.  In the general case, as in the top cpuset case,
+don't leave tasks that might use non-trivial amounts of CPU in
+such partially load balanced cpusets, as they may be artificially
+constrained to some subset of the CPUs allowed to them, for lack of
+load balancing to the other CPUs.
+
+1.7.1 sched_load_balance implementation details.
+------------------------------------------------
+
+The per-cpuset flag 'sched_load_balance' defaults to enabled (contrary
+to most cpuset flags.)  When enabled for a cpuset, the kernel will
+ensure that it can load balance across all the CPUs in that cpuset
+(makes sure that all the CPUs in the cpus_allowed of that cpuset are
+in the same sched domain.)
+
+If two overlapping cpusets both have 'sched_load_balance' enabled,
+then they will be (must be) both in the same sched domain.
+
+If, as is the default, the top cpuset has 'sched_load_balance' enabled,
+then by the above that means there is a single sched domain covering
+the whole system, regardless of any other cpuset settings.
+
+The kernel commits to user space that it will avoid load balancing
+where it can.  It will pick as fine a granularity partition of sched
+domains as it can while still providing load balancing for any set
+of CPUs allowed to a cpuset having 'sched_load_balance' enabled.
+
+The internal kernel cpuset to scheduler interface passes from the
+cpuset code to the scheduler code a partition of the load balanced
+CPUs in the system. This partition is a set of subsets (represented
+as an array of cpumask_t) of CPUs, pairwise disjoint, that cover all
+the CPUs that must be load balanced.
+
+Whenever the 'sched_load_balance' flag changes, or CPUs come or go
+from a cpuset with this flag enabled, or a cpuset with this flag
+enabled is removed, the cpuset code builds a new such partition and
+passes it to the scheduler sched domain setup code, to have the sched
+domains rebuilt as necessary.
+
+This partition exactly defines what sched domains the scheduler should
+setup - one sched domain for each element (cpumask_t) in the partition.
+
+The scheduler remembers the currently active sched domain partitions.
+When the scheduler routine partition_sched_domains() is invoked from
+the cpuset code to update these sched domains, it compares the new
+partition requested with the current, and updates its sched domains,
+removing the old and adding the new, for each change.
+
+
+1.8 What is sched_relax_domain_level ?
+--------------------------------------
+
+In sched domain, the scheduler migrates tasks in 2 ways; periodic load
+balance on tick, and at time of some schedule events.
+
+When a task is woken up, scheduler try to move the task on idle CPU.
+For example, if a task A running on CPU X activates another task B
+on the same CPU X, and if CPU Y is X's sibling and performing idle,
+then scheduler migrate task B to CPU Y so that task B can start on
+CPU Y without waiting task A on CPU X.
+
+And if a CPU run out of tasks in its runqueue, the CPU try to pull
+extra tasks from other busy CPUs to help them before it is going to
+be idle.
+
+Of course it takes some searching cost to find movable tasks and/or
+idle CPUs, the scheduler might not search all CPUs in the domain
+everytime.  In fact, in some architectures, the searching ranges on
+events are limited in the same socket or node where the CPU locates,
+while the load balance on tick searchs all.
+
+For example, assume CPU Z is relatively far from CPU X.  Even if CPU Z
+is idle while CPU X and the siblings are busy, scheduler can't migrate
+woken task B from X to Z since it is out of its searching range.
+As the result, task B on CPU X need to wait task A or wait load balance
+on the next tick.  For some applications in special situation, waiting
+1 tick may be too long.
+
+The 'sched_relax_domain_level' file allows you to request changing
+this searching range as you like.  This file takes int value which
+indicates size of searching range in levels ideally as follows,
+otherwise initial value -1 that indicates the cpuset has no request.
+
+  -1  : no request. use system default or follow request of others.
+   0  : no search.
+   1  : search siblings (hyperthreads in a core).
+   2  : search cores in a package.
+   3  : search cpus in a node [= system wide on non-NUMA system]
+ ( 4  : search nodes in a chunk of node [on NUMA system] )
+ ( 5  : search system wide [on NUMA system] )
+
+The system default is architecture dependent.  The system default
+can be changed using the relax_domain_level= boot parameter.
+
+This file is per-cpuset and affect the sched domain where the cpuset
+belongs to.  Therefore if the flag 'sched_load_balance' of a cpuset
+is disabled, then 'sched_relax_domain_level' have no effect since
+there is no sched domain belonging the cpuset.
+
+If multiple cpusets are overlapping and hence they form a single sched
+domain, the largest value among those is used.  Be careful, if one
+requests 0 and others are -1 then 0 is used.
+
+Note that modifying this file will have both good and bad effects,
+and whether it is acceptable or not will be depend on your situation.
+Don't modify this file if you are not sure.
+
+If your situation is:
+ - The migration costs between each cpu can be assumed considerably
+   small(for you) due to your special application's behavior or
+   special hardware support for CPU cache etc.
+ - The searching cost doesn't have impact(for you) or you can make
+   the searching cost enough small by managing cpuset to compact etc.
+ - The latency is required even it sacrifices cache hit rate etc.
+then increasing 'sched_relax_domain_level' would benefit you.
+
+
+1.9 How do I use cpusets ?
+--------------------------
+
+In order to minimize the impact of cpusets on critical kernel
+code, such as the scheduler, and due to the fact that the kernel
+does not support one task updating the memory placement of another
+task directly, the impact on a task of changing its cpuset CPU
+or Memory Node placement, or of changing to which cpuset a task
+is attached, is subtle.
+
+If a cpuset has its Memory Nodes modified, then for each task attached
+to that cpuset, the next time that the kernel attempts to allocate
+a page of memory for that task, the kernel will notice the change
+in the tasks cpuset, and update its per-task memory placement to
+remain within the new cpusets memory placement.  If the task was using
+mempolicy MPOL_BIND, and the nodes to which it was bound overlap with
+its new cpuset, then the task will continue to use whatever subset
+of MPOL_BIND nodes are still allowed in the new cpuset.  If the task
+was using MPOL_BIND and now none of its MPOL_BIND nodes are allowed
+in the new cpuset, then the task will be essentially treated as if it
+was MPOL_BIND bound to the new cpuset (even though its numa placement,
+as queried by get_mempolicy(), doesn't change).  If a task is moved
+from one cpuset to another, then the kernel will adjust the tasks
+memory placement, as above, the next time that the kernel attempts
+to allocate a page of memory for that task.
+
+If a cpuset has its 'cpus' modified, then each task in that cpuset
+will have its allowed CPU placement changed immediately.  Similarly,
+if a tasks pid is written to a cpusets 'tasks' file, in either its
+current cpuset or another cpuset, then its allowed CPU placement is
+changed immediately.  If such a task had been bound to some subset
+of its cpuset using the sched_setaffinity() call, the task will be
+allowed to run on any CPU allowed in its new cpuset, negating the
+affect of the prior sched_setaffinity() call.
+
+In summary, the memory placement of a task whose cpuset is changed is
+updated by the kernel, on the next allocation of a page for that task,
+but the processor placement is not updated, until that tasks pid is
+rewritten to the 'tasks' file of its cpuset.  This is done to avoid
+impacting the scheduler code in the kernel with a check for changes
+in a tasks processor placement.
+
+Normally, once a page is allocated (given a physical page
+of main memory) then that page stays on whatever node it
+was allocated, so long as it remains allocated, even if the
+cpusets memory placement policy 'mems' subsequently changes.
+If the cpuset flag file 'memory_migrate' is set true, then when
+tasks are attached to that cpuset, any pages that task had
+allocated to it on nodes in its previous cpuset are migrated
+to the tasks new cpuset. The relative placement of the page within
+the cpuset is preserved during these migration operations if possible.
+For example if the page was on the second valid node of the prior cpuset
+then the page will be placed on the second valid node of the new cpuset.
+
+Also if 'memory_migrate' is set true, then if that cpusets
+'mems' file is modified, pages allocated to tasks in that
+cpuset, that were on nodes in the previous setting of 'mems',
+will be moved to nodes in the new setting of 'mems.'
+Pages that were not in the tasks prior cpuset, or in the cpusets
+prior 'mems' setting, will not be moved.
+
+There is an exception to the above.  If hotplug functionality is used
+to remove all the CPUs that are currently assigned to a cpuset,
+then all the tasks in that cpuset will be moved to the nearest ancestor
+with non-empty cpus.  But the moving of some (or all) tasks might fail if
+cpuset is bound with another cgroup subsystem which has some restrictions
+on task attaching.  In this failing case, those tasks will stay
+in the original cpuset, and the kernel will automatically update
+their cpus_allowed to allow all online CPUs.  When memory hotplug
+functionality for removing Memory Nodes is available, a similar exception
+is expected to apply there as well.  In general, the kernel prefers to
+violate cpuset placement, over starving a task that has had all
+its allowed CPUs or Memory Nodes taken offline.
+
+There is a second exception to the above.  GFP_ATOMIC requests are
+kernel internal allocations that must be satisfied, immediately.
+The kernel may drop some request, in rare cases even panic, if a
+GFP_ATOMIC alloc fails.  If the request cannot be satisfied within
+the current tasks cpuset, then we relax the cpuset, and look for
+memory anywhere we can find it.  It's better to violate the cpuset
+than stress the kernel.
+
+To start a new job that is to be contained within a cpuset, the steps are:
+
+ 1) mkdir /dev/cpuset
+ 2) mount -t cgroup -ocpuset cpuset /dev/cpuset
+ 3) Create the new cpuset by doing mkdir's and write's (or echo's) in
+    the /dev/cpuset virtual file system.
+ 4) Start a task that will be the "founding father" of the new job.
+ 5) Attach that task to the new cpuset by writing its pid to the
+    /dev/cpuset tasks file for that cpuset.
+ 6) fork, exec or clone the job tasks from this founding father task.
+
+For example, the following sequence of commands will setup a cpuset
+named "Charlie", containing just CPUs 2 and 3, and Memory Node 1,
+and then start a subshell 'sh' in that cpuset:
+
+  mount -t cgroup -ocpuset cpuset /dev/cpuset
+  cd /dev/cpuset
+  mkdir Charlie
+  cd Charlie
+  /bin/echo 2-3 > cpus
+  /bin/echo 1 > mems
+  /bin/echo $$ > tasks
+  sh
+  # The subshell 'sh' is now running in cpuset Charlie
+  # The next line should display '/Charlie'
+  cat /proc/self/cpuset
+
+In the future, a C library interface to cpusets will likely be
+available.  For now, the only way to query or modify cpusets is
+via the cpuset file system, using the various cd, mkdir, echo, cat,
+rmdir commands from the shell, or their equivalent from C.
+
+The sched_setaffinity calls can also be done at the shell prompt using
+SGI's runon or Robert Love's taskset.  The mbind and set_mempolicy
+calls can be done at the shell prompt using the numactl command
+(part of Andi Kleen's numa package).
+
+2. Usage Examples and Syntax
+============================
+
+2.1 Basic Usage
+---------------
+
+Creating, modifying, using the cpusets can be done through the cpuset
+virtual filesystem.
+
+To mount it, type:
+# mount -t cgroup -o cpuset cpuset /dev/cpuset
+
+Then under /dev/cpuset you can find a tree that corresponds to the
+tree of the cpusets in the system. For instance, /dev/cpuset
+is the cpuset that holds the whole system.
+
+If you want to create a new cpuset under /dev/cpuset:
+# cd /dev/cpuset
+# mkdir my_cpuset
+
+Now you want to do something with this cpuset.
+# cd my_cpuset
+
+In this directory you can find several files:
+# ls
+cpu_exclusive  memory_migrate      mems                      tasks
+cpus           memory_pressure     notify_on_release
+mem_exclusive  memory_spread_page  sched_load_balance
+mem_hardwall   memory_spread_slab  sched_relax_domain_level
+
+Reading them will give you information about the state of this cpuset:
+the CPUs and Memory Nodes it can use, the processes that are using
+it, its properties.  By writing to these files you can manipulate
+the cpuset.
+
+Set some flags:
+# /bin/echo 1 > cpu_exclusive
+
+Add some cpus:
+# /bin/echo 0-7 > cpus
+
+Add some mems:
+# /bin/echo 0-7 > mems
+
+Now attach your shell to this cpuset:
+# /bin/echo $$ > tasks
+
+You can also create cpusets inside your cpuset by using mkdir in this
+directory.
+# mkdir my_sub_cs
+
+To remove a cpuset, just use rmdir:
+# rmdir my_sub_cs
+This will fail if the cpuset is in use (has cpusets inside, or has
+processes attached).
+
+Note that for legacy reasons, the "cpuset" filesystem exists as a
+wrapper around the cgroup filesystem.
+
+The command
+
+mount -t cpuset X /dev/cpuset
+
+is equivalent to
+
+mount -t cgroup -ocpuset X /dev/cpuset
+echo "/sbin/cpuset_release_agent" > /dev/cpuset/release_agent
+
+2.2 Adding/removing cpus
+------------------------
+
+This is the syntax to use when writing in the cpus or mems files
+in cpuset directories:
+
+# /bin/echo 1-4 > cpus		-> set cpus list to cpus 1,2,3,4
+# /bin/echo 1,2,3,4 > cpus	-> set cpus list to cpus 1,2,3,4
+
+2.3 Setting flags
+-----------------
+
+The syntax is very simple:
+
+# /bin/echo 1 > cpu_exclusive 	-> set flag 'cpu_exclusive'
+# /bin/echo 0 > cpu_exclusive 	-> unset flag 'cpu_exclusive'
+
+2.4 Attaching processes
+-----------------------
+
+# /bin/echo PID > tasks
+
+Note that it is PID, not PIDs. You can only attach ONE task at a time.
+If you have several tasks to attach, you have to do it one after another:
+
+# /bin/echo PID1 > tasks
+# /bin/echo PID2 > tasks
+	...
+# /bin/echo PIDn > tasks
+
+
+3. Questions
+============
+
+Q: what's up with this '/bin/echo' ?
+A: bash's builtin 'echo' command does not check calls to write() against
+   errors. If you use it in the cpuset file system, you won't be
+   able to tell whether a command succeeded or failed.
+
+Q: When I attach processes, only the first of the line gets really attached !
+A: We can only return one error code per call to write(). So you should also
+   put only ONE pid.
+
+4. Contact
+==========
+
+Web: http://www.bullopensource.org/cpuset
diff --git a/Documentation/cgroups/devices.txt b/Documentation/cgroups/devices.txt
new file mode 100644
index 0000000..7cc6e6a
--- /dev/null
+++ b/Documentation/cgroups/devices.txt
@@ -0,0 +1,52 @@
+Device Whitelist Controller
+
+1. Description:
+
+Implement a cgroup to track and enforce open and mknod restrictions
+on device files.  A device cgroup associates a device access
+whitelist with each cgroup.  A whitelist entry has 4 fields.
+'type' is a (all), c (char), or b (block).  'all' means it applies
+to all types and all major and minor numbers.  Major and minor are
+either an integer or * for all.  Access is a composition of r
+(read), w (write), and m (mknod).
+
+The root device cgroup starts with rwm to 'all'.  A child device
+cgroup gets a copy of the parent.  Administrators can then remove
+devices from the whitelist or add new entries.  A child cgroup can
+never receive a device access which is denied by its parent.  However
+when a device access is removed from a parent it will not also be
+removed from the child(ren).
+
+2. User Interface
+
+An entry is added using devices.allow, and removed using
+devices.deny.  For instance
+
+	echo 'c 1:3 mr' > /cgroups/1/devices.allow
+
+allows cgroup 1 to read and mknod the device usually known as
+/dev/null.  Doing
+
+	echo a > /cgroups/1/devices.deny
+
+will remove the default 'a *:* rwm' entry. Doing
+
+	echo a > /cgroups/1/devices.allow
+
+will add the 'a *:* rwm' entry to the whitelist.
+
+3. Security
+
+Any task can move itself between cgroups.  This clearly won't
+suffice, but we can decide the best way to adequately restrict
+movement as people get some experience with this.  We may just want
+to require CAP_SYS_ADMIN, which at least is a separate bit from
+CAP_MKNOD.  We may want to just refuse moving to a cgroup which
+isn't a descendent of the current one.  Or we may want to use
+CAP_MAC_ADMIN, since we really are trying to lock down root.
+
+CAP_SYS_ADMIN is needed to modify the whitelist or move another
+task to a new cgroup.  (Again we'll probably want to change that).
+
+A cgroup may not be granted more permissions than the cgroup's
+parent has.
diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
new file mode 100644
index 0000000..19533f9
--- /dev/null
+++ b/Documentation/cgroups/memcg_test.txt
@@ -0,0 +1,342 @@
+Memory Resource Controller(Memcg)  Implementation Memo.
+Last Updated: 2008/12/15
+Base Kernel Version: based on 2.6.28-rc8-mm.
+
+Because VM is getting complex (one of reasons is memcg...), memcg's behavior
+is complex. This is a document for memcg's internal behavior.
+Please note that implementation details can be changed.
+
+(*) Topics on API should be in Documentation/cgroups/memory.txt)
+
+0. How to record usage ?
+   2 objects are used.
+
+   page_cgroup ....an object per page.
+	Allocated at boot or memory hotplug. Freed at memory hot removal.
+
+   swap_cgroup ... an entry per swp_entry.
+	Allocated at swapon(). Freed at swapoff().
+
+   The page_cgroup has USED bit and double count against a page_cgroup never
+   occurs. swap_cgroup is used only when a charged page is swapped-out.
+
+1. Charge
+
+   a page/swp_entry may be charged (usage += PAGE_SIZE) at
+
+	mem_cgroup_newpage_charge()
+	  Called at new page fault and Copy-On-Write.
+
+	mem_cgroup_try_charge_swapin()
+	  Called at do_swap_page() (page fault on swap entry) and swapoff.
+	  Followed by charge-commit-cancel protocol. (With swap accounting)
+	  At commit, a charge recorded in swap_cgroup is removed.
+
+	mem_cgroup_cache_charge()
+	  Called at add_to_page_cache()
+
+	mem_cgroup_cache_charge_swapin()
+	  Called at shmem's swapin.
+
+	mem_cgroup_prepare_migration()
+	  Called before migration. "extra" charge is done and followed by
+	  charge-commit-cancel protocol.
+	  At commit, charge against oldpage or newpage will be committed.
+
+2. Uncharge
+  a page/swp_entry may be uncharged (usage -= PAGE_SIZE) by
+
+	mem_cgroup_uncharge_page()
+	  Called when an anonymous page is fully unmapped. I.e., mapcount goes
+	  to 0. If the page is SwapCache, uncharge is delayed until
+	  mem_cgroup_uncharge_swapcache().
+
+	mem_cgroup_uncharge_cache_page()
+	  Called when a page-cache is deleted from radix-tree. If the page is
+	  SwapCache, uncharge is delayed until mem_cgroup_uncharge_swapcache().
+
+	mem_cgroup_uncharge_swapcache()
+	  Called when SwapCache is removed from radix-tree. The charge itself
+	  is moved to swap_cgroup. (If mem+swap controller is disabled, no
+	  charge to swap occurs.)
+
+	mem_cgroup_uncharge_swap()
+	  Called when swp_entry's refcnt goes down to 0. A charge against swap
+	  disappears.
+
+	mem_cgroup_end_migration(old, new)
+	At success of migration old is uncharged (if necessary), a charge
+	to new page is committed. At failure, charge to old page is committed.
+
+3. charge-commit-cancel
+	In some case, we can't know this "charge" is valid or not at charging
+	(because of races).
+	To handle such case, there are charge-commit-cancel functions.
+		mem_cgroup_try_charge_XXX
+		mem_cgroup_commit_charge_XXX
+		mem_cgroup_cancel_charge_XXX
+	these are used in swap-in and migration.
+
+	At try_charge(), there are no flags to say "this page is charged".
+	at this point, usage += PAGE_SIZE.
+
+	At commit(), the function checks the page should be charged or not
+	and set flags or avoid charging.(usage -= PAGE_SIZE)
+
+	At cancel(), simply usage -= PAGE_SIZE.
+
+Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
+
+4. Anonymous
+	Anonymous page is newly allocated at
+		  - page fault into MAP_ANONYMOUS mapping.
+		  - Copy-On-Write.
+ 	It is charged right after it's allocated before doing any page table
+	related operations. Of course, it's uncharged when another page is used
+	for the fault address.
+
+	At freeing anonymous page (by exit() or munmap()), zap_pte() is called
+	and pages for ptes are freed one by one.(see mm/memory.c). Uncharges
+	are done at page_remove_rmap() when page_mapcount() goes down to 0.
+
+	Another page freeing is by page-reclaim (vmscan.c) and anonymous
+	pages are swapped out. In this case, the page is marked as
+	PageSwapCache(). uncharge() routine doesn't uncharge the page marked
+	as SwapCache(). It's delayed until __delete_from_swap_cache().
+
+	4.1 Swap-in.
+	At swap-in, the page is taken from swap-cache. There are 2 cases.
+
+	(a) If the SwapCache is newly allocated and read, it has no charges.
+	(b) If the SwapCache has been mapped by processes, it has been
+	    charged already.
+
+	This swap-in is one of the most complicated work. In do_swap_page(),
+	following events occur when pte is unchanged.
+
+	(1) the page (SwapCache) is looked up.
+	(2) lock_page()
+	(3) try_charge_swapin()
+	(4) reuse_swap_page() (may call delete_swap_cache())
+	(5) commit_charge_swapin()
+	(6) swap_free().
+
+	Considering following situation for example.
+
+	(A) The page has not been charged before (2) and reuse_swap_page()
+	    doesn't call delete_from_swap_cache().
+	(B) The page has not been charged before (2) and reuse_swap_page()
+	    calls delete_from_swap_cache().
+	(C) The page has been charged before (2) and reuse_swap_page() doesn't
+	    call delete_from_swap_cache().
+	(D) The page has been charged before (2) and reuse_swap_page() calls
+	    delete_from_swap_cache().
+
+	    memory.usage/memsw.usage changes to this page/swp_entry will be
+	 Case          (A)      (B)       (C)     (D)
+         Event
+       Before (2)     0/ 1     0/ 1      1/ 1    1/ 1
+          ===========================================
+          (3)        +1/+1    +1/+1     +1/+1   +1/+1
+          (4)          -       0/ 0       -     -1/ 0
+          (5)         0/-1     0/ 0     -1/-1    0/ 0
+          (6)          -       0/-1       -      0/-1
+          ===========================================
+       Result         1/ 1     1/ 1      1/ 1    1/ 1
+
+       In any cases, charges to this page should be 1/ 1.
+
+	4.2 Swap-out.
+	At swap-out, typical state transition is below.
+
+	(a) add to swap cache. (marked as SwapCache)
+	    swp_entry's refcnt += 1.
+	(b) fully unmapped.
+	    swp_entry's refcnt += # of ptes.
+	(c) write back to swap.
+	(d) delete from swap cache. (remove from SwapCache)
+	    swp_entry's refcnt -= 1.
+
+
+	At (b), the page is marked as SwapCache and not uncharged.
+	At (d), the page is removed from SwapCache and a charge in page_cgroup
+	is moved to swap_cgroup.
+
+	Finally, at task exit,
+	(e) zap_pte() is called and swp_entry's refcnt -=1 -> 0.
+	Here, a charge in swap_cgroup disappears.
+
+5. Page Cache
+   	Page Cache is charged at
+	- add_to_page_cache_locked().
+
+	uncharged at
+	- __remove_from_page_cache().
+
+	The logic is very clear. (About migration, see below)
+	Note: __remove_from_page_cache() is called by remove_from_page_cache()
+	and __remove_mapping().
+
+6. Shmem(tmpfs) Page Cache
+	Memcg's charge/uncharge have special handlers of shmem. The best way
+	to understand shmem's page state transition is to read mm/shmem.c.
+	But brief explanation of the behavior of memcg around shmem will be
+	helpful to understand the logic.
+
+	Shmem's page (just leaf page, not direct/indirect block) can be on
+		- radix-tree of shmem's inode.
+		- SwapCache.
+		- Both on radix-tree and SwapCache. This happens at swap-in
+		  and swap-out,
+
+	It's charged when...
+	- A new page is added to shmem's radix-tree.
+	- A swp page is read. (move a charge from swap_cgroup to page_cgroup)
+	It's uncharged when
+	- A page is removed from radix-tree and not SwapCache.
+	- When SwapCache is removed, a charge is moved to swap_cgroup.
+	- When swp_entry's refcnt goes down to 0, a charge in swap_cgroup
+	  disappears.
+
+7. Page Migration
+   	One of the most complicated functions is page-migration-handler.
+	Memcg has 2 routines. Assume that we are migrating a page's contents
+	from OLDPAGE to NEWPAGE.
+
+	Usual migration logic is..
+	(a) remove the page from LRU.
+	(b) allocate NEWPAGE (migration target)
+	(c) lock by lock_page().
+	(d) unmap all mappings.
+	(e-1) If necessary, replace entry in radix-tree.
+	(e-2) move contents of a page.
+	(f) map all mappings again.
+	(g) pushback the page to LRU.
+	(-) OLDPAGE will be freed.
+
+	Before (g), memcg should complete all necessary charge/uncharge to
+	NEWPAGE/OLDPAGE.
+
+	The point is....
+	- If OLDPAGE is anonymous, all charges will be dropped at (d) because
+          try_to_unmap() drops all mapcount and the page will not be
+	  SwapCache.
+
+	- If OLDPAGE is SwapCache, charges will be kept at (g) because
+	  __delete_from_swap_cache() isn't called at (e-1)
+
+	- If OLDPAGE is page-cache, charges will be kept at (g) because
+	  remove_from_swap_cache() isn't called at (e-1)
+
+	memcg provides following hooks.
+
+	- mem_cgroup_prepare_migration(OLDPAGE)
+	  Called after (b) to account a charge (usage += PAGE_SIZE) against
+	  memcg which OLDPAGE belongs to.
+
+        - mem_cgroup_end_migration(OLDPAGE, NEWPAGE)
+	  Called after (f) before (g).
+	  If OLDPAGE is used, commit OLDPAGE again. If OLDPAGE is already
+	  charged, a charge by prepare_migration() is automatically canceled.
+	  If NEWPAGE is used, commit NEWPAGE and uncharge OLDPAGE.
+
+	  But zap_pte() (by exit or munmap) can be called while migration,
+	  we have to check if OLDPAGE/NEWPAGE is a valid page after commit().
+
+8. LRU
+        Each memcg has its own private LRU. Now, it's handling is under global
+	VM's control (means that it's handled under global zone->lru_lock).
+	Almost all routines around memcg's LRU is called by global LRU's
+	list management functions under zone->lru_lock().
+
+	A special function is mem_cgroup_isolate_pages(). This scans
+	memcg's private LRU and call __isolate_lru_page() to extract a page
+	from LRU.
+	(By __isolate_lru_page(), the page is removed from both of global and
+	 private LRU.)
+
+
+9. Typical Tests.
+
+ Tests for racy cases.
+
+ 9.1 Small limit to memcg.
+	When you do test to do racy case, it's good test to set memcg's limit
+	to be very small rather than GB. Many races found in the test under
+	xKB or xxMB limits.
+	(Memory behavior under GB and Memory behavior under MB shows very
+	 different situation.)
+
+ 9.2 Shmem
+	Historically, memcg's shmem handling was poor and we saw some amount
+	of troubles here. This is because shmem is page-cache but can be
+	SwapCache. Test with shmem/tmpfs is always good test.
+
+ 9.3 Migration
+	For NUMA, migration is an another special case. To do easy test, cpuset
+	is useful. Following is a sample script to do migration.
+
+	mount -t cgroup -o cpuset none /opt/cpuset
+
+	mkdir /opt/cpuset/01
+	echo 1 > /opt/cpuset/01/cpuset.cpus
+	echo 0 > /opt/cpuset/01/cpuset.mems
+	echo 1 > /opt/cpuset/01/cpuset.memory_migrate
+	mkdir /opt/cpuset/02
+	echo 1 > /opt/cpuset/02/cpuset.cpus
+	echo 1 > /opt/cpuset/02/cpuset.mems
+	echo 1 > /opt/cpuset/02/cpuset.memory_migrate
+
+	In above set, when you moves a task from 01 to 02, page migration to
+	node 0 to node 1 will occur. Following is a script to migrate all
+	under cpuset.
+	--
+	move_task()
+	{
+	for pid in $1
+        do
+                /bin/echo $pid >$2/tasks 2>/dev/null
+		echo -n $pid
+		echo -n " "
+        done
+	echo END
+	}
+
+	G1_TASK=`cat ${G1}/tasks`
+	G2_TASK=`cat ${G2}/tasks`
+	move_task "${G1_TASK}" ${G2} &
+	--
+ 9.4 Memory hotplug.
+	memory hotplug test is one of good test.
+	to offline memory, do following.
+	# echo offline > /sys/devices/system/memory/memoryXXX/state
+	(XXX is the place of memory)
+	This is an easy way to test page migration, too.
+
+ 9.5 mkdir/rmdir
+	When using hierarchy, mkdir/rmdir test should be done.
+	Use tests like the following.
+
+	echo 1 >/opt/cgroup/01/memory/use_hierarchy
+	mkdir /opt/cgroup/01/child_a
+	mkdir /opt/cgroup/01/child_b
+
+	set limit to 01.
+	add limit to 01/child_b
+	run jobs under child_a and child_b
+
+	create/delete following groups at random while jobs are running.
+	/opt/cgroup/01/child_a/child_aa
+	/opt/cgroup/01/child_b/child_bb
+	/opt/cgroup/01/child_c
+
+	running new jobs in new group is also good.
+
+ 9.6 Mount with other subsystems.
+	Mounting with other subsystems is a good test because there is a
+	race and lock dependency with other cgroup subsystems.
+
+	example)
+	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
+
+	and do task move, mkdir, rmdir etc...under this.
diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
new file mode 100644
index 0000000..e150196
--- /dev/null
+++ b/Documentation/cgroups/memory.txt
@@ -0,0 +1,399 @@
+Memory Resource Controller
+
+NOTE: The Memory Resource Controller has been generically been referred
+to as the memory controller in this document. Do not confuse memory controller
+used here with the memory controller that is used in hardware.
+
+Salient features
+
+a. Enable control of both RSS (mapped) and Page Cache (unmapped) pages
+b. The infrastructure allows easy addition of other types of memory to control
+c. Provides *zero overhead* for non memory controller users
+d. Provides a double LRU: global memory pressure causes reclaim from the
+   global LRU; a cgroup on hitting a limit, reclaims from the per
+   cgroup LRU
+
+NOTE: Swap Cache (unmapped) is not accounted now.
+
+Benefits and Purpose of the memory controller
+
+The memory controller isolates the memory behaviour of a group of tasks
+from the rest of the system. The article on LWN [12] mentions some probable
+uses of the memory controller. The memory controller can be used to
+
+a. Isolate an application or a group of applications
+   Memory hungry applications can be isolated and limited to a smaller
+   amount of memory.
+b. Create a cgroup with limited amount of memory, this can be used
+   as a good alternative to booting with mem=XXXX.
+c. Virtualization solutions can control the amount of memory they want
+   to assign to a virtual machine instance.
+d. A CD/DVD burner could control the amount of memory used by the
+   rest of the system to ensure that burning does not fail due to lack
+   of available memory.
+e. There are several other use cases, find one or use the controller just
+   for fun (to learn and hack on the VM subsystem).
+
+1. History
+
+The memory controller has a long history. A request for comments for the memory
+controller was posted by Balbir Singh [1]. At the time the RFC was posted
+there were several implementations for memory control. The goal of the
+RFC was to build consensus and agreement for the minimal features required
+for memory control. The first RSS controller was posted by Balbir Singh[2]
+in Feb 2007. Pavel Emelianov [3][4][5] has since posted three versions of the
+RSS controller. At OLS, at the resource management BoF, everyone suggested
+that we handle both page cache and RSS together. Another request was raised
+to allow user space handling of OOM. The current memory controller is
+at version 6; it combines both mapped (RSS) and unmapped Page
+Cache Control [11].
+
+2. Memory Control
+
+Memory is a unique resource in the sense that it is present in a limited
+amount. If a task requires a lot of CPU processing, the task can spread
+its processing over a period of hours, days, months or years, but with
+memory, the same physical memory needs to be reused to accomplish the task.
+
+The memory controller implementation has been divided into phases. These
+are:
+
+1. Memory controller
+2. mlock(2) controller
+3. Kernel user memory accounting and slab control
+4. user mappings length controller
+
+The memory controller is the first controller developed.
+
+2.1. Design
+
+The core of the design is a counter called the res_counter. The res_counter
+tracks the current memory usage and limit of the group of processes associated
+with the controller. Each cgroup has a memory controller specific data
+structure (mem_cgroup) associated with it.
+
+2.2. Accounting
+
+		+--------------------+
+		|  mem_cgroup     |
+		|  (res_counter)     |
+		+--------------------+
+		 /            ^      \
+		/             |       \
+           +---------------+  |        +---------------+
+           | mm_struct     |  |....    | mm_struct     |
+           |               |  |        |               |
+           +---------------+  |        +---------------+
+                              |
+                              + --------------+
+                                              |
+           +---------------+           +------+--------+
+           | page          +---------->  page_cgroup|
+           |               |           |               |
+           +---------------+           +---------------+
+
+             (Figure 1: Hierarchy of Accounting)
+
+
+Figure 1 shows the important aspects of the controller
+
+1. Accounting happens per cgroup
+2. Each mm_struct knows about which cgroup it belongs to
+3. Each page has a pointer to the page_cgroup, which in turn knows the
+   cgroup it belongs to
+
+The accounting is done as follows: mem_cgroup_charge() is invoked to setup
+the necessary data structures and check if the cgroup that is being charged
+is over its limit. If it is then reclaim is invoked on the cgroup.
+More details can be found in the reclaim section of this document.
+If everything goes well, a page meta-data-structure called page_cgroup is
+allocated and associated with the page.  This routine also adds the page to
+the per cgroup LRU.
+
+2.2.1 Accounting details
+
+All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
+(some pages which never be reclaimable and will not be on global LRU
+ are not accounted. we just accounts pages under usual vm management.)
+
+RSS pages are accounted at page_fault unless they've already been accounted
+for earlier. A file page will be accounted for as Page Cache when it's
+inserted into inode (radix-tree). While it's mapped into the page tables of
+processes, duplicate accounting is carefully avoided.
+
+A RSS page is unaccounted when it's fully unmapped. A PageCache page is
+unaccounted when it's removed from radix-tree.
+
+At page migration, accounting information is kept.
+
+Note: we just account pages-on-lru because our purpose is to control amount
+of used pages. not-on-lru pages are tend to be out-of-control from vm view.
+
+2.3 Shared Page Accounting
+
+Shared pages are accounted on the basis of the first touch approach. The
+cgroup that first touches a page is accounted for the page. The principle
+behind this approach is that a cgroup that aggressively uses a shared
+page will eventually get charged for it (once it is uncharged from
+the cgroup that brought it in -- this will happen on memory pressure).
+
+Exception: If CONFIG_CGROUP_CGROUP_MEM_RES_CTLR_SWAP is not used..
+When you do swapoff and make swapped-out pages of shmem(tmpfs) to
+be backed into memory in force, charges for pages are accounted against the
+caller of swapoff rather than the users of shmem.
+
+
+2.4 Swap Extension (CONFIG_CGROUP_MEM_RES_CTLR_SWAP)
+Swap Extension allows you to record charge for swap. A swapped-in page is
+charged back to original page allocator if possible.
+
+When swap is accounted, following files are added.
+ - memory.memsw.usage_in_bytes.
+ - memory.memsw.limit_in_bytes.
+
+usage of mem+swap is limited by memsw.limit_in_bytes.
+
+Note: why 'mem+swap' rather than swap.
+The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
+to move account from memory to swap...there is no change in usage of
+mem+swap.
+
+In other words, when we want to limit the usage of swap without affecting
+global LRU, mem+swap limit is better than just limiting swap from OS point
+of view.
+
+2.5 Reclaim
+
+Each cgroup maintains a per cgroup LRU that consists of an active
+and inactive list. When a cgroup goes over its limit, we first try
+to reclaim memory from the cgroup so as to make space for the new
+pages that the cgroup has touched. If the reclaim is unsuccessful,
+an OOM routine is invoked to select and kill the bulkiest task in the
+cgroup.
+
+The reclaim algorithm has not been modified for cgroups, except that
+pages that are selected for reclaiming come from the per cgroup LRU
+list.
+
+2. Locking
+
+The memory controller uses the following hierarchy
+
+1. zone->lru_lock is used for selecting pages to be isolated
+2. mem->per_zone->lru_lock protects the per cgroup LRU (per zone)
+3. lock_page_cgroup() is used to protect page->page_cgroup
+
+3. User Interface
+
+0. Configuration
+
+a. Enable CONFIG_CGROUPS
+b. Enable CONFIG_RESOURCE_COUNTERS
+c. Enable CONFIG_CGROUP_MEM_RES_CTLR
+
+1. Prepare the cgroups
+# mkdir -p /cgroups
+# mount -t cgroup none /cgroups -o memory
+
+2. Make the new group and move bash into it
+# mkdir /cgroups/0
+# echo $$ >  /cgroups/0/tasks
+
+Since now we're in the 0 cgroup,
+We can alter the memory limit:
+# echo 4M > /cgroups/0/memory.limit_in_bytes
+
+NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
+mega or gigabytes.
+
+# cat /cgroups/0/memory.limit_in_bytes
+4194304
+
+NOTE: The interface has now changed to display the usage in bytes
+instead of pages
+
+We can check the usage:
+# cat /cgroups/0/memory.usage_in_bytes
+1216512
+
+A successful write to this file does not guarantee a successful set of
+this limit to the value written into the file.  This can be due to a
+number of factors, such as rounding up to page boundaries or the total
+availability of memory on the system.  The user is required to re-read
+this file after a write to guarantee the value committed by the kernel.
+
+# echo 1 > memory.limit_in_bytes
+# cat memory.limit_in_bytes
+4096
+
+The memory.failcnt field gives the number of times that the cgroup limit was
+exceeded.
+
+The memory.stat file gives accounting information. Now, the number of
+caches, RSS and Active pages/Inactive pages are shown.
+
+4. Testing
+
+Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
+Apart from that v6 has been tested with several applications and regular
+daily use. The controller has also been tested on the PPC64, x86_64 and
+UML platforms.
+
+4.1 Troubleshooting
+
+Sometimes a user might find that the application under a cgroup is
+terminated. There are several causes for this:
+
+1. The cgroup limit is too low (just too low to do anything useful)
+2. The user is using anonymous memory and swap is turned off or too low
+
+A sync followed by echo 1 > /proc/sys/vm/drop_caches will help get rid of
+some of the pages cached in the cgroup (page cache pages).
+
+4.2 Task migration
+
+When a task migrates from one cgroup to another, it's charge is not
+carried forward. The pages allocated from the original cgroup still
+remain charged to it, the charge is dropped when the page is freed or
+reclaimed.
+
+4.3 Removing a cgroup
+
+A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
+cgroup might have some charge associated with it, even though all
+tasks have migrated away from it.
+Such charges are freed(at default) or moved to its parent. When moved,
+both of RSS and CACHES are moved to parent.
+If both of them are busy, rmdir() returns -EBUSY. See 5.1 Also.
+
+Charges recorded in swap information is not updated at removal of cgroup.
+Recorded information is discarded and a cgroup which uses swap (swapcache)
+will be charged as a new owner of it.
+
+
+5. Misc. interfaces.
+
+5.1 force_empty
+  memory.force_empty interface is provided to make cgroup's memory usage empty.
+  You can use this interface only when the cgroup has no tasks.
+  When writing anything to this
+
+  # echo 0 > memory.force_empty
+
+  Almost all pages tracked by this memcg will be unmapped and freed. Some of
+  pages cannot be freed because it's locked or in-use. Such pages are moved
+  to parent and this cgroup will be empty. But this may return -EBUSY in
+  some too busy case.
+
+  Typical use case of this interface is that calling this before rmdir().
+  Because rmdir() moves all pages to parent, some out-of-use page caches can be
+  moved to the parent. If you want to avoid that, force_empty will be useful.
+
+5.2 stat file
+  memory.stat file includes following statistics (now)
+	cache			- # of pages from page-cache and shmem.
+	rss			- # of pages from anonymous memory.
+	pgpgin			- # of event of charging
+	pgpgout			- # of event of uncharging
+	active_anon		- # of pages on active lru of anon, shmem.
+	inactive_anon 		- # of pages on active lru of anon, shmem
+	active_file		- # of pages on active lru of file-cache
+	inactive_file		- # of pages on inactive lru of file cache
+	unevictable		- # of pages cannot be reclaimed.(mlocked etc)
+
+	Below is depend on CONFIG_DEBUG_VM.
+	inactive_ratio		- VM inernal parameter. (see mm/page_alloc.c)
+	recent_rotated_anon	- VM internal parameter. (see mm/vmscan.c)
+	recent_rotated_file	- VM internal parameter. (see mm/vmscan.c)
+	recent_scanned_anon 	- VM internal parameter. (see mm/vmscan.c)
+	recent_scanned_file 	- VM internal parameter. (see mm/vmscan.c)
+
+  Memo:
+	recent_rotated means recent frequency of lru rotation.
+	recent_scanned means recent # of scans to lru.
+	showing for better debug please see the code for meanings.
+
+
+5.3 swappiness
+  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
+
+  Following cgroup's swapiness can't be changed.
+  - root cgroup (uses /proc/sys/vm/swappiness).
+  - a cgroup which uses hierarchy and it has child cgroup.
+  - a cgroup which uses hierarchy and not the root of hierarchy.
+
+
+6. Hierarchy support
+
+The memory controller supports a deep hierarchy and hierarchical accounting.
+The hierarchy is created by creating the appropriate cgroups in the
+cgroup filesystem. Consider for example, the following cgroup filesystem
+hierarchy
+
+		root
+	     /  |   \
+           /	|    \
+	  a	b	c
+			| \
+			|  \
+			d   e
+
+In the diagram above, with hierarchical accounting enabled, all memory
+usage of e, is accounted to its ancestors up until the root (i.e, c and root),
+that has memory.use_hierarchy enabled.  If one of the ancestors goes over its
+limit, the reclaim algorithm reclaims from the tasks in the ancestor and the
+children of the ancestor.
+
+6.1 Enabling hierarchical accounting and reclaim
+
+The memory controller by default disables the hierarchy feature. Support
+can be enabled by writing 1 to memory.use_hierarchy file of the root cgroup
+
+# echo 1 > memory.use_hierarchy
+
+The feature can be disabled by
+
+# echo 0 > memory.use_hierarchy
+
+NOTE1: Enabling/disabling will fail if the cgroup already has other
+cgroups created below it.
+
+NOTE2: This feature can be enabled/disabled per subtree.
+
+7. TODO
+
+1. Add support for accounting huge pages (as a separate controller)
+2. Make per-cgroup scanner reclaim not-shared pages first
+3. Teach controller to account for shared-pages
+4. Start reclamation in the background when the limit is
+   not yet hit but the usage is getting closer
+
+Summary
+
+Overall, the memory controller has been a stable controller and has been
+commented and discussed quite extensively in the community.
+
+References
+
+1. Singh, Balbir. RFC: Memory Controller, http://lwn.net/Articles/206697/
+2. Singh, Balbir. Memory Controller (RSS Control),
+   http://lwn.net/Articles/222762/
+3. Emelianov, Pavel. Resource controllers based on process cgroups
+   http://lkml.org/lkml/2007/3/6/198
+4. Emelianov, Pavel. RSS controller based on process cgroups (v2)
+   http://lkml.org/lkml/2007/4/9/78
+5. Emelianov, Pavel. RSS controller based on process cgroups (v3)
+   http://lkml.org/lkml/2007/5/30/244
+6. Menage, Paul. Control Groups v10, http://lwn.net/Articles/236032/
+7. Vaidyanathan, Srinivasan, Control Groups: Pagecache accounting and control
+   subsystem (v3), http://lwn.net/Articles/235534/
+8. Singh, Balbir. RSS controller v2 test results (lmbench),
+   http://lkml.org/lkml/2007/5/17/232
+9. Singh, Balbir. RSS controller v2 AIM9 results
+   http://lkml.org/lkml/2007/5/18/1
+10. Singh, Balbir. Memory controller v6 test results,
+    http://lkml.org/lkml/2007/8/19/36
+11. Singh, Balbir. Memory controller introduction (v6),
+    http://lkml.org/lkml/2007/8/17/69
+12. Corbet, Jonathan, Controlling memory use in cgroups,
+    http://lwn.net/Articles/243795/
diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
new file mode 100644
index 0000000..f196ac1
--- /dev/null
+++ b/Documentation/cgroups/resource_counter.txt
@@ -0,0 +1,181 @@
+
+		The Resource Counter
+
+The resource counter, declared at include/linux/res_counter.h,
+is supposed to facilitate the resource management by controllers
+by providing common stuff for accounting.
+
+This "stuff" includes the res_counter structure and routines
+to work with it.
+
+
+
+1. Crucial parts of the res_counter structure
+
+ a. unsigned long long usage
+
+ 	The usage value shows the amount of a resource that is consumed
+	by a group at a given time. The units of measurement should be
+	determined by the controller that uses this counter. E.g. it can
+	be bytes, items or any other unit the controller operates on.
+
+ b. unsigned long long max_usage
+
+ 	The maximal value of the usage over time.
+
+ 	This value is useful when gathering statistical information about
+	the particular group, as it shows the actual resource requirements
+	for a particular group, not just some usage snapshot.
+
+ c. unsigned long long limit
+
+ 	The maximal allowed amount of resource to consume by the group. In
+	case the group requests for more resources, so that the usage value
+	would exceed the limit, the resource allocation is rejected (see
+	the next section).
+
+ d. unsigned long long failcnt
+
+ 	The failcnt stands for "failures counter". This is the number of
+	resource allocation attempts that failed.
+
+ c. spinlock_t lock
+
+ 	Protects changes of the above values.
+
+
+
+2. Basic accounting routines
+
+ a. void res_counter_init(struct res_counter *rc)
+
+ 	Initializes the resource counter. As usual, should be the first
+	routine called for a new counter.
+
+ b. int res_counter_charge[_locked]
+			(struct res_counter *rc, unsigned long val)
+
+	When a resource is about to be allocated it has to be accounted
+	with the appropriate resource counter (controller should determine
+	which one to use on its own). This operation is called "charging".
+
+	This is not very important which operation - resource allocation
+	or charging - is performed first, but
+	  * if the allocation is performed first, this may create a
+	    temporary resource over-usage by the time resource counter is
+	    charged;
+	  * if the charging is performed first, then it should be uncharged
+	    on error path (if the one is called).
+
+ c. void res_counter_uncharge[_locked]
+			(struct res_counter *rc, unsigned long val)
+
+	When a resource is released (freed) it should be de-accounted
+	from the resource counter it was accounted to.  This is called
+	"uncharging".
+
+    The _locked routines imply that the res_counter->lock is taken.
+
+
+ 2.1 Other accounting routines
+
+    There are more routines that may help you with common needs, like
+    checking whether the limit is reached or resetting the max_usage
+    value. They are all declared in include/linux/res_counter.h.
+
+
+
+3. Analyzing the resource counter registrations
+
+ a. If the failcnt value constantly grows, this means that the counter's
+    limit is too tight. Either the group is misbehaving and consumes too
+    many resources, or the configuration is not suitable for the group
+    and the limit should be increased.
+
+ b. The max_usage value can be used to quickly tune the group. One may
+    set the limits to maximal values and either load the container with
+    a common pattern or leave one for a while. After this the max_usage
+    value shows the amount of memory the container would require during
+    its common activity.
+
+    Setting the limit a bit above this value gives a pretty good
+    configuration that works in most of the cases.
+
+ c. If the max_usage is much less than the limit, but the failcnt value
+    is growing, then the group tries to allocate a big chunk of resource
+    at once.
+
+ d. If the max_usage is much less than the limit, but the failcnt value
+    is 0, then this group is given too high limit, that it does not
+    require. It is better to lower the limit a bit leaving more resource
+    for other groups.
+
+
+
+4. Communication with the control groups subsystem (cgroups)
+
+All the resource controllers that are using cgroups and resource counters
+should provide files (in the cgroup filesystem) to work with the resource
+counter fields. They are recommended to adhere to the following rules:
+
+ a. File names
+
+ 	Field name	File name
+	---------------------------------------------------
+	usage		usage_in_<unit_of_measurement>
+	max_usage	max_usage_in_<unit_of_measurement>
+	limit		limit_in_<unit_of_measurement>
+	failcnt		failcnt
+	lock		no file :)
+
+ b. Reading from file should show the corresponding field value in the
+    appropriate format.
+
+ c. Writing to file
+
+ 	Field		Expected behavior
+	----------------------------------
+	usage		prohibited
+	max_usage	reset to usage
+	limit		set the limit
+	failcnt		reset to zero
+
+
+
+5. Usage example
+
+ a. Declare a task group (take a look at cgroups subsystem for this) and
+    fold a res_counter into it
+
+	struct my_group {
+		struct res_counter res;
+
+		<other fields>
+	}
+
+ b. Put hooks in resource allocation/release paths
+
+ 	int alloc_something(...)
+	{
+		if (res_counter_charge(res_counter_ptr, amount) < 0)
+			return -ENOMEM;
+
+		<allocate the resource and return to the caller>
+	}
+
+	void release_something(...)
+	{
+		res_counter_uncharge(res_counter_ptr, amount);
+
+		<release the resource>
+	}
+
+    In order to keep the usage value self-consistent, both the
+    "res_counter_ptr" and the "amount" in release_something() should be
+    the same as they were in the alloc_something() when the releasing
+    resource was allocated.
+
+ c. Provide the way to read res_counter values and set them (the cgroups
+    still can help with it).
+
+ c. Compile and run :)
diff --git a/Documentation/controllers/cpuacct.txt b/Documentation/controllers/cpuacct.txt
deleted file mode 100644
index bb775fb..0000000
--- a/Documentation/controllers/cpuacct.txt
+++ /dev/null
@@ -1,32 +0,0 @@
-CPU Accounting Controller
--------------------------
-
-The CPU accounting controller is used to group tasks using cgroups and
-account the CPU usage of these groups of tasks.
-
-The CPU accounting controller supports multi-hierarchy groups. An accounting
-group accumulates the CPU usage of all of its child groups and the tasks
-directly present in its group.
-
-Accounting groups can be created by first mounting the cgroup filesystem.
-
-# mkdir /cgroups
-# mount -t cgroup -ocpuacct none /cgroups
-
-With the above step, the initial or the parent accounting group
-becomes visible at /cgroups. At bootup, this group includes all the
-tasks in the system. /cgroups/tasks lists the tasks in this cgroup.
-/cgroups/cpuacct.usage gives the CPU time (in nanoseconds) obtained by
-this group which is essentially the CPU time obtained by all the tasks
-in the system.
-
-New accounting groups can be created under the parent group /cgroups.
-
-# cd /cgroups
-# mkdir g1
-# echo $$ > g1
-
-The above steps create a new group g1 and move the current shell
-process (bash) into it. CPU time consumed by this bash and its children
-can be obtained from g1/cpuacct.usage and the same is accumulated in
-/cgroups/cpuacct.usage also.
diff --git a/Documentation/controllers/devices.txt b/Documentation/controllers/devices.txt
deleted file mode 100644
index 7cc6e6a..0000000
--- a/Documentation/controllers/devices.txt
+++ /dev/null
@@ -1,52 +0,0 @@
-Device Whitelist Controller
-
-1. Description:
-
-Implement a cgroup to track and enforce open and mknod restrictions
-on device files.  A device cgroup associates a device access
-whitelist with each cgroup.  A whitelist entry has 4 fields.
-'type' is a (all), c (char), or b (block).  'all' means it applies
-to all types and all major and minor numbers.  Major and minor are
-either an integer or * for all.  Access is a composition of r
-(read), w (write), and m (mknod).
-
-The root device cgroup starts with rwm to 'all'.  A child device
-cgroup gets a copy of the parent.  Administrators can then remove
-devices from the whitelist or add new entries.  A child cgroup can
-never receive a device access which is denied by its parent.  However
-when a device access is removed from a parent it will not also be
-removed from the child(ren).
-
-2. User Interface
-
-An entry is added using devices.allow, and removed using
-devices.deny.  For instance
-
-	echo 'c 1:3 mr' > /cgroups/1/devices.allow
-
-allows cgroup 1 to read and mknod the device usually known as
-/dev/null.  Doing
-
-	echo a > /cgroups/1/devices.deny
-
-will remove the default 'a *:* rwm' entry. Doing
-
-	echo a > /cgroups/1/devices.allow
-
-will add the 'a *:* rwm' entry to the whitelist.
-
-3. Security
-
-Any task can move itself between cgroups.  This clearly won't
-suffice, but we can decide the best way to adequately restrict
-movement as people get some experience with this.  We may just want
-to require CAP_SYS_ADMIN, which at least is a separate bit from
-CAP_MKNOD.  We may want to just refuse moving to a cgroup which
-isn't a descendent of the current one.  Or we may want to use
-CAP_MAC_ADMIN, since we really are trying to lock down root.
-
-CAP_SYS_ADMIN is needed to modify the whitelist or move another
-task to a new cgroup.  (Again we'll probably want to change that).
-
-A cgroup may not be granted more permissions than the cgroup's
-parent has.
diff --git a/Documentation/controllers/memcg_test.txt b/Documentation/controllers/memcg_test.txt
deleted file mode 100644
index 08d4d3e..0000000
--- a/Documentation/controllers/memcg_test.txt
+++ /dev/null
@@ -1,342 +0,0 @@
-Memory Resource Controller(Memcg)  Implementation Memo.
-Last Updated: 2008/12/15
-Base Kernel Version: based on 2.6.28-rc8-mm.
-
-Because VM is getting complex (one of reasons is memcg...), memcg's behavior
-is complex. This is a document for memcg's internal behavior.
-Please note that implementation details can be changed.
-
-(*) Topics on API should be in Documentation/controllers/memory.txt)
-
-0. How to record usage ?
-   2 objects are used.
-
-   page_cgroup ....an object per page.
-	Allocated at boot or memory hotplug. Freed at memory hot removal.
-
-   swap_cgroup ... an entry per swp_entry.
-	Allocated at swapon(). Freed at swapoff().
-
-   The page_cgroup has USED bit and double count against a page_cgroup never
-   occurs. swap_cgroup is used only when a charged page is swapped-out.
-
-1. Charge
-
-   a page/swp_entry may be charged (usage += PAGE_SIZE) at
-
-	mem_cgroup_newpage_charge()
-	  Called at new page fault and Copy-On-Write.
-
-	mem_cgroup_try_charge_swapin()
-	  Called at do_swap_page() (page fault on swap entry) and swapoff.
-	  Followed by charge-commit-cancel protocol. (With swap accounting)
-	  At commit, a charge recorded in swap_cgroup is removed.
-
-	mem_cgroup_cache_charge()
-	  Called at add_to_page_cache()
-
-	mem_cgroup_cache_charge_swapin()
-	  Called at shmem's swapin.
-
-	mem_cgroup_prepare_migration()
-	  Called before migration. "extra" charge is done and followed by
-	  charge-commit-cancel protocol.
-	  At commit, charge against oldpage or newpage will be committed.
-
-2. Uncharge
-  a page/swp_entry may be uncharged (usage -= PAGE_SIZE) by
-
-	mem_cgroup_uncharge_page()
-	  Called when an anonymous page is fully unmapped. I.e., mapcount goes
-	  to 0. If the page is SwapCache, uncharge is delayed until
-	  mem_cgroup_uncharge_swapcache().
-
-	mem_cgroup_uncharge_cache_page()
-	  Called when a page-cache is deleted from radix-tree. If the page is
-	  SwapCache, uncharge is delayed until mem_cgroup_uncharge_swapcache().
-
-	mem_cgroup_uncharge_swapcache()
-	  Called when SwapCache is removed from radix-tree. The charge itself
-	  is moved to swap_cgroup. (If mem+swap controller is disabled, no
-	  charge to swap occurs.)
-
-	mem_cgroup_uncharge_swap()
-	  Called when swp_entry's refcnt goes down to 0. A charge against swap
-	  disappears.
-
-	mem_cgroup_end_migration(old, new)
-	At success of migration old is uncharged (if necessary), a charge
-	to new page is committed. At failure, charge to old page is committed.
-
-3. charge-commit-cancel
-	In some case, we can't know this "charge" is valid or not at charging
-	(because of races).
-	To handle such case, there are charge-commit-cancel functions.
-		mem_cgroup_try_charge_XXX
-		mem_cgroup_commit_charge_XXX
-		mem_cgroup_cancel_charge_XXX
-	these are used in swap-in and migration.
-
-	At try_charge(), there are no flags to say "this page is charged".
-	at this point, usage += PAGE_SIZE.
-
-	At commit(), the function checks the page should be charged or not
-	and set flags or avoid charging.(usage -= PAGE_SIZE)
-
-	At cancel(), simply usage -= PAGE_SIZE.
-
-Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
-
-4. Anonymous
-	Anonymous page is newly allocated at
-		  - page fault into MAP_ANONYMOUS mapping.
-		  - Copy-On-Write.
- 	It is charged right after it's allocated before doing any page table
-	related operations. Of course, it's uncharged when another page is used
-	for the fault address.
-
-	At freeing anonymous page (by exit() or munmap()), zap_pte() is called
-	and pages for ptes are freed one by one.(see mm/memory.c). Uncharges
-	are done at page_remove_rmap() when page_mapcount() goes down to 0.
-
-	Another page freeing is by page-reclaim (vmscan.c) and anonymous
-	pages are swapped out. In this case, the page is marked as
-	PageSwapCache(). uncharge() routine doesn't uncharge the page marked
-	as SwapCache(). It's delayed until __delete_from_swap_cache().
-
-	4.1 Swap-in.
-	At swap-in, the page is taken from swap-cache. There are 2 cases.
-
-	(a) If the SwapCache is newly allocated and read, it has no charges.
-	(b) If the SwapCache has been mapped by processes, it has been
-	    charged already.
-
-	This swap-in is one of the most complicated work. In do_swap_page(),
-	following events occur when pte is unchanged.
-
-	(1) the page (SwapCache) is looked up.
-	(2) lock_page()
-	(3) try_charge_swapin()
-	(4) reuse_swap_page() (may call delete_swap_cache())
-	(5) commit_charge_swapin()
-	(6) swap_free().
-
-	Considering following situation for example.
-
-	(A) The page has not been charged before (2) and reuse_swap_page()
-	    doesn't call delete_from_swap_cache().
-	(B) The page has not been charged before (2) and reuse_swap_page()
-	    calls delete_from_swap_cache().
-	(C) The page has been charged before (2) and reuse_swap_page() doesn't
-	    call delete_from_swap_cache().
-	(D) The page has been charged before (2) and reuse_swap_page() calls
-	    delete_from_swap_cache().
-
-	    memory.usage/memsw.usage changes to this page/swp_entry will be
-	 Case          (A)      (B)       (C)     (D)
-         Event
-       Before (2)     0/ 1     0/ 1      1/ 1    1/ 1
-          ===========================================
-          (3)        +1/+1    +1/+1     +1/+1   +1/+1
-          (4)          -       0/ 0       -     -1/ 0
-          (5)         0/-1     0/ 0     -1/-1    0/ 0
-          (6)          -       0/-1       -      0/-1
-          ===========================================
-       Result         1/ 1     1/ 1      1/ 1    1/ 1
-
-       In any cases, charges to this page should be 1/ 1.
-
-	4.2 Swap-out.
-	At swap-out, typical state transition is below.
-
-	(a) add to swap cache. (marked as SwapCache)
-	    swp_entry's refcnt += 1.
-	(b) fully unmapped.
-	    swp_entry's refcnt += # of ptes.
-	(c) write back to swap.
-	(d) delete from swap cache. (remove from SwapCache)
-	    swp_entry's refcnt -= 1.
-
-
-	At (b), the page is marked as SwapCache and not uncharged.
-	At (d), the page is removed from SwapCache and a charge in page_cgroup
-	is moved to swap_cgroup.
-
-	Finally, at task exit,
-	(e) zap_pte() is called and swp_entry's refcnt -=1 -> 0.
-	Here, a charge in swap_cgroup disappears.
-
-5. Page Cache
-   	Page Cache is charged at
-	- add_to_page_cache_locked().
-
-	uncharged at
-	- __remove_from_page_cache().
-
-	The logic is very clear. (About migration, see below)
-	Note: __remove_from_page_cache() is called by remove_from_page_cache()
-	and __remove_mapping().
-
-6. Shmem(tmpfs) Page Cache
-	Memcg's charge/uncharge have special handlers of shmem. The best way
-	to understand shmem's page state transition is to read mm/shmem.c.
-	But brief explanation of the behavior of memcg around shmem will be
-	helpful to understand the logic.
-
-	Shmem's page (just leaf page, not direct/indirect block) can be on
-		- radix-tree of shmem's inode.
-		- SwapCache.
-		- Both on radix-tree and SwapCache. This happens at swap-in
-		  and swap-out,
-
-	It's charged when...
-	- A new page is added to shmem's radix-tree.
-	- A swp page is read. (move a charge from swap_cgroup to page_cgroup)
-	It's uncharged when
-	- A page is removed from radix-tree and not SwapCache.
-	- When SwapCache is removed, a charge is moved to swap_cgroup.
-	- When swp_entry's refcnt goes down to 0, a charge in swap_cgroup
-	  disappears.
-
-7. Page Migration
-   	One of the most complicated functions is page-migration-handler.
-	Memcg has 2 routines. Assume that we are migrating a page's contents
-	from OLDPAGE to NEWPAGE.
-
-	Usual migration logic is..
-	(a) remove the page from LRU.
-	(b) allocate NEWPAGE (migration target)
-	(c) lock by lock_page().
-	(d) unmap all mappings.
-	(e-1) If necessary, replace entry in radix-tree.
-	(e-2) move contents of a page.
-	(f) map all mappings again.
-	(g) pushback the page to LRU.
-	(-) OLDPAGE will be freed.
-
-	Before (g), memcg should complete all necessary charge/uncharge to
-	NEWPAGE/OLDPAGE.
-
-	The point is....
-	- If OLDPAGE is anonymous, all charges will be dropped at (d) because
-          try_to_unmap() drops all mapcount and the page will not be
-	  SwapCache.
-
-	- If OLDPAGE is SwapCache, charges will be kept at (g) because
-	  __delete_from_swap_cache() isn't called at (e-1)
-
-	- If OLDPAGE is page-cache, charges will be kept at (g) because
-	  remove_from_swap_cache() isn't called at (e-1)
-
-	memcg provides following hooks.
-
-	- mem_cgroup_prepare_migration(OLDPAGE)
-	  Called after (b) to account a charge (usage += PAGE_SIZE) against
-	  memcg which OLDPAGE belongs to.
-
-        - mem_cgroup_end_migration(OLDPAGE, NEWPAGE)
-	  Called after (f) before (g).
-	  If OLDPAGE is used, commit OLDPAGE again. If OLDPAGE is already
-	  charged, a charge by prepare_migration() is automatically canceled.
-	  If NEWPAGE is used, commit NEWPAGE and uncharge OLDPAGE.
-
-	  But zap_pte() (by exit or munmap) can be called while migration,
-	  we have to check if OLDPAGE/NEWPAGE is a valid page after commit().
-
-8. LRU
-        Each memcg has its own private LRU. Now, it's handling is under global
-	VM's control (means that it's handled under global zone->lru_lock).
-	Almost all routines around memcg's LRU is called by global LRU's
-	list management functions under zone->lru_lock().
-
-	A special function is mem_cgroup_isolate_pages(). This scans
-	memcg's private LRU and call __isolate_lru_page() to extract a page
-	from LRU.
-	(By __isolate_lru_page(), the page is removed from both of global and
-	 private LRU.)
-
-
-9. Typical Tests.
-
- Tests for racy cases.
-
- 9.1 Small limit to memcg.
-	When you do test to do racy case, it's good test to set memcg's limit
-	to be very small rather than GB. Many races found in the test under
-	xKB or xxMB limits.
-	(Memory behavior under GB and Memory behavior under MB shows very
-	 different situation.)
-
- 9.2 Shmem
-	Historically, memcg's shmem handling was poor and we saw some amount
-	of troubles here. This is because shmem is page-cache but can be
-	SwapCache. Test with shmem/tmpfs is always good test.
-
- 9.3 Migration
-	For NUMA, migration is an another special case. To do easy test, cpuset
-	is useful. Following is a sample script to do migration.
-
-	mount -t cgroup -o cpuset none /opt/cpuset
-
-	mkdir /opt/cpuset/01
-	echo 1 > /opt/cpuset/01/cpuset.cpus
-	echo 0 > /opt/cpuset/01/cpuset.mems
-	echo 1 > /opt/cpuset/01/cpuset.memory_migrate
-	mkdir /opt/cpuset/02
-	echo 1 > /opt/cpuset/02/cpuset.cpus
-	echo 1 > /opt/cpuset/02/cpuset.mems
-	echo 1 > /opt/cpuset/02/cpuset.memory_migrate
-
-	In above set, when you moves a task from 01 to 02, page migration to
-	node 0 to node 1 will occur. Following is a script to migrate all
-	under cpuset.
-	--
-	move_task()
-	{
-	for pid in $1
-        do
-                /bin/echo $pid >$2/tasks 2>/dev/null
-		echo -n $pid
-		echo -n " "
-        done
-	echo END
-	}
-
-	G1_TASK=`cat ${G1}/tasks`
-	G2_TASK=`cat ${G2}/tasks`
-	move_task "${G1_TASK}" ${G2} &
-	--
- 9.4 Memory hotplug.
-	memory hotplug test is one of good test.
-	to offline memory, do following.
-	# echo offline > /sys/devices/system/memory/memoryXXX/state
-	(XXX is the place of memory)
-	This is an easy way to test page migration, too.
-
- 9.5 mkdir/rmdir
-	When using hierarchy, mkdir/rmdir test should be done.
-	Use tests like the following.
-
-	echo 1 >/opt/cgroup/01/memory/use_hierarchy
-	mkdir /opt/cgroup/01/child_a
-	mkdir /opt/cgroup/01/child_b
-
-	set limit to 01.
-	add limit to 01/child_b
-	run jobs under child_a and child_b
-
-	create/delete following groups at random while jobs are running.
-	/opt/cgroup/01/child_a/child_aa
-	/opt/cgroup/01/child_b/child_bb
-	/opt/cgroup/01/child_c
-
-	running new jobs in new group is also good.
-
- 9.6 Mount with other subsystems.
-	Mounting with other subsystems is a good test because there is a
-	race and lock dependency with other cgroup subsystems.
-
-	example)
-	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
-
-	and do task move, mkdir, rmdir etc...under this.
diff --git a/Documentation/controllers/memory.txt b/Documentation/controllers/memory.txt
deleted file mode 100644
index e150196..0000000
--- a/Documentation/controllers/memory.txt
+++ /dev/null
@@ -1,399 +0,0 @@
-Memory Resource Controller
-
-NOTE: The Memory Resource Controller has been generically been referred
-to as the memory controller in this document. Do not confuse memory controller
-used here with the memory controller that is used in hardware.
-
-Salient features
-
-a. Enable control of both RSS (mapped) and Page Cache (unmapped) pages
-b. The infrastructure allows easy addition of other types of memory to control
-c. Provides *zero overhead* for non memory controller users
-d. Provides a double LRU: global memory pressure causes reclaim from the
-   global LRU; a cgroup on hitting a limit, reclaims from the per
-   cgroup LRU
-
-NOTE: Swap Cache (unmapped) is not accounted now.
-
-Benefits and Purpose of the memory controller
-
-The memory controller isolates the memory behaviour of a group of tasks
-from the rest of the system. The article on LWN [12] mentions some probable
-uses of the memory controller. The memory controller can be used to
-
-a. Isolate an application or a group of applications
-   Memory hungry applications can be isolated and limited to a smaller
-   amount of memory.
-b. Create a cgroup with limited amount of memory, this can be used
-   as a good alternative to booting with mem=XXXX.
-c. Virtualization solutions can control the amount of memory they want
-   to assign to a virtual machine instance.
-d. A CD/DVD burner could control the amount of memory used by the
-   rest of the system to ensure that burning does not fail due to lack
-   of available memory.
-e. There are several other use cases, find one or use the controller just
-   for fun (to learn and hack on the VM subsystem).
-
-1. History
-
-The memory controller has a long history. A request for comments for the memory
-controller was posted by Balbir Singh [1]. At the time the RFC was posted
-there were several implementations for memory control. The goal of the
-RFC was to build consensus and agreement for the minimal features required
-for memory control. The first RSS controller was posted by Balbir Singh[2]
-in Feb 2007. Pavel Emelianov [3][4][5] has since posted three versions of the
-RSS controller. At OLS, at the resource management BoF, everyone suggested
-that we handle both page cache and RSS together. Another request was raised
-to allow user space handling of OOM. The current memory controller is
-at version 6; it combines both mapped (RSS) and unmapped Page
-Cache Control [11].
-
-2. Memory Control
-
-Memory is a unique resource in the sense that it is present in a limited
-amount. If a task requires a lot of CPU processing, the task can spread
-its processing over a period of hours, days, months or years, but with
-memory, the same physical memory needs to be reused to accomplish the task.
-
-The memory controller implementation has been divided into phases. These
-are:
-
-1. Memory controller
-2. mlock(2) controller
-3. Kernel user memory accounting and slab control
-4. user mappings length controller
-
-The memory controller is the first controller developed.
-
-2.1. Design
-
-The core of the design is a counter called the res_counter. The res_counter
-tracks the current memory usage and limit of the group of processes associated
-with the controller. Each cgroup has a memory controller specific data
-structure (mem_cgroup) associated with it.
-
-2.2. Accounting
-
-		+--------------------+
-		|  mem_cgroup     |
-		|  (res_counter)     |
-		+--------------------+
-		 /            ^      \
-		/             |       \
-           +---------------+  |        +---------------+
-           | mm_struct     |  |....    | mm_struct     |
-           |               |  |        |               |
-           +---------------+  |        +---------------+
-                              |
-                              + --------------+
-                                              |
-           +---------------+           +------+--------+
-           | page          +---------->  page_cgroup|
-           |               |           |               |
-           +---------------+           +---------------+
-
-             (Figure 1: Hierarchy of Accounting)
-
-
-Figure 1 shows the important aspects of the controller
-
-1. Accounting happens per cgroup
-2. Each mm_struct knows about which cgroup it belongs to
-3. Each page has a pointer to the page_cgroup, which in turn knows the
-   cgroup it belongs to
-
-The accounting is done as follows: mem_cgroup_charge() is invoked to setup
-the necessary data structures and check if the cgroup that is being charged
-is over its limit. If it is then reclaim is invoked on the cgroup.
-More details can be found in the reclaim section of this document.
-If everything goes well, a page meta-data-structure called page_cgroup is
-allocated and associated with the page.  This routine also adds the page to
-the per cgroup LRU.
-
-2.2.1 Accounting details
-
-All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
-(some pages which never be reclaimable and will not be on global LRU
- are not accounted. we just accounts pages under usual vm management.)
-
-RSS pages are accounted at page_fault unless they've already been accounted
-for earlier. A file page will be accounted for as Page Cache when it's
-inserted into inode (radix-tree). While it's mapped into the page tables of
-processes, duplicate accounting is carefully avoided.
-
-A RSS page is unaccounted when it's fully unmapped. A PageCache page is
-unaccounted when it's removed from radix-tree.
-
-At page migration, accounting information is kept.
-
-Note: we just account pages-on-lru because our purpose is to control amount
-of used pages. not-on-lru pages are tend to be out-of-control from vm view.
-
-2.3 Shared Page Accounting
-
-Shared pages are accounted on the basis of the first touch approach. The
-cgroup that first touches a page is accounted for the page. The principle
-behind this approach is that a cgroup that aggressively uses a shared
-page will eventually get charged for it (once it is uncharged from
-the cgroup that brought it in -- this will happen on memory pressure).
-
-Exception: If CONFIG_CGROUP_CGROUP_MEM_RES_CTLR_SWAP is not used..
-When you do swapoff and make swapped-out pages of shmem(tmpfs) to
-be backed into memory in force, charges for pages are accounted against the
-caller of swapoff rather than the users of shmem.
-
-
-2.4 Swap Extension (CONFIG_CGROUP_MEM_RES_CTLR_SWAP)
-Swap Extension allows you to record charge for swap. A swapped-in page is
-charged back to original page allocator if possible.
-
-When swap is accounted, following files are added.
- - memory.memsw.usage_in_bytes.
- - memory.memsw.limit_in_bytes.
-
-usage of mem+swap is limited by memsw.limit_in_bytes.
-
-Note: why 'mem+swap' rather than swap.
-The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
-to move account from memory to swap...there is no change in usage of
-mem+swap.
-
-In other words, when we want to limit the usage of swap without affecting
-global LRU, mem+swap limit is better than just limiting swap from OS point
-of view.
-
-2.5 Reclaim
-
-Each cgroup maintains a per cgroup LRU that consists of an active
-and inactive list. When a cgroup goes over its limit, we first try
-to reclaim memory from the cgroup so as to make space for the new
-pages that the cgroup has touched. If the reclaim is unsuccessful,
-an OOM routine is invoked to select and kill the bulkiest task in the
-cgroup.
-
-The reclaim algorithm has not been modified for cgroups, except that
-pages that are selected for reclaiming come from the per cgroup LRU
-list.
-
-2. Locking
-
-The memory controller uses the following hierarchy
-
-1. zone->lru_lock is used for selecting pages to be isolated
-2. mem->per_zone->lru_lock protects the per cgroup LRU (per zone)
-3. lock_page_cgroup() is used to protect page->page_cgroup
-
-3. User Interface
-
-0. Configuration
-
-a. Enable CONFIG_CGROUPS
-b. Enable CONFIG_RESOURCE_COUNTERS
-c. Enable CONFIG_CGROUP_MEM_RES_CTLR
-
-1. Prepare the cgroups
-# mkdir -p /cgroups
-# mount -t cgroup none /cgroups -o memory
-
-2. Make the new group and move bash into it
-# mkdir /cgroups/0
-# echo $$ >  /cgroups/0/tasks
-
-Since now we're in the 0 cgroup,
-We can alter the memory limit:
-# echo 4M > /cgroups/0/memory.limit_in_bytes
-
-NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
-mega or gigabytes.
-
-# cat /cgroups/0/memory.limit_in_bytes
-4194304
-
-NOTE: The interface has now changed to display the usage in bytes
-instead of pages
-
-We can check the usage:
-# cat /cgroups/0/memory.usage_in_bytes
-1216512
-
-A successful write to this file does not guarantee a successful set of
-this limit to the value written into the file.  This can be due to a
-number of factors, such as rounding up to page boundaries or the total
-availability of memory on the system.  The user is required to re-read
-this file after a write to guarantee the value committed by the kernel.
-
-# echo 1 > memory.limit_in_bytes
-# cat memory.limit_in_bytes
-4096
-
-The memory.failcnt field gives the number of times that the cgroup limit was
-exceeded.
-
-The memory.stat file gives accounting information. Now, the number of
-caches, RSS and Active pages/Inactive pages are shown.
-
-4. Testing
-
-Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
-Apart from that v6 has been tested with several applications and regular
-daily use. The controller has also been tested on the PPC64, x86_64 and
-UML platforms.
-
-4.1 Troubleshooting
-
-Sometimes a user might find that the application under a cgroup is
-terminated. There are several causes for this:
-
-1. The cgroup limit is too low (just too low to do anything useful)
-2. The user is using anonymous memory and swap is turned off or too low
-
-A sync followed by echo 1 > /proc/sys/vm/drop_caches will help get rid of
-some of the pages cached in the cgroup (page cache pages).
-
-4.2 Task migration
-
-When a task migrates from one cgroup to another, it's charge is not
-carried forward. The pages allocated from the original cgroup still
-remain charged to it, the charge is dropped when the page is freed or
-reclaimed.
-
-4.3 Removing a cgroup
-
-A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
-cgroup might have some charge associated with it, even though all
-tasks have migrated away from it.
-Such charges are freed(at default) or moved to its parent. When moved,
-both of RSS and CACHES are moved to parent.
-If both of them are busy, rmdir() returns -EBUSY. See 5.1 Also.
-
-Charges recorded in swap information is not updated at removal of cgroup.
-Recorded information is discarded and a cgroup which uses swap (swapcache)
-will be charged as a new owner of it.
-
-
-5. Misc. interfaces.
-
-5.1 force_empty
-  memory.force_empty interface is provided to make cgroup's memory usage empty.
-  You can use this interface only when the cgroup has no tasks.
-  When writing anything to this
-
-  # echo 0 > memory.force_empty
-
-  Almost all pages tracked by this memcg will be unmapped and freed. Some of
-  pages cannot be freed because it's locked or in-use. Such pages are moved
-  to parent and this cgroup will be empty. But this may return -EBUSY in
-  some too busy case.
-
-  Typical use case of this interface is that calling this before rmdir().
-  Because rmdir() moves all pages to parent, some out-of-use page caches can be
-  moved to the parent. If you want to avoid that, force_empty will be useful.
-
-5.2 stat file
-  memory.stat file includes following statistics (now)
-	cache			- # of pages from page-cache and shmem.
-	rss			- # of pages from anonymous memory.
-	pgpgin			- # of event of charging
-	pgpgout			- # of event of uncharging
-	active_anon		- # of pages on active lru of anon, shmem.
-	inactive_anon 		- # of pages on active lru of anon, shmem
-	active_file		- # of pages on active lru of file-cache
-	inactive_file		- # of pages on inactive lru of file cache
-	unevictable		- # of pages cannot be reclaimed.(mlocked etc)
-
-	Below is depend on CONFIG_DEBUG_VM.
-	inactive_ratio		- VM inernal parameter. (see mm/page_alloc.c)
-	recent_rotated_anon	- VM internal parameter. (see mm/vmscan.c)
-	recent_rotated_file	- VM internal parameter. (see mm/vmscan.c)
-	recent_scanned_anon 	- VM internal parameter. (see mm/vmscan.c)
-	recent_scanned_file 	- VM internal parameter. (see mm/vmscan.c)
-
-  Memo:
-	recent_rotated means recent frequency of lru rotation.
-	recent_scanned means recent # of scans to lru.
-	showing for better debug please see the code for meanings.
-
-
-5.3 swappiness
-  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
-
-  Following cgroup's swapiness can't be changed.
-  - root cgroup (uses /proc/sys/vm/swappiness).
-  - a cgroup which uses hierarchy and it has child cgroup.
-  - a cgroup which uses hierarchy and not the root of hierarchy.
-
-
-6. Hierarchy support
-
-The memory controller supports a deep hierarchy and hierarchical accounting.
-The hierarchy is created by creating the appropriate cgroups in the
-cgroup filesystem. Consider for example, the following cgroup filesystem
-hierarchy
-
-		root
-	     /  |   \
-           /	|    \
-	  a	b	c
-			| \
-			|  \
-			d   e
-
-In the diagram above, with hierarchical accounting enabled, all memory
-usage of e, is accounted to its ancestors up until the root (i.e, c and root),
-that has memory.use_hierarchy enabled.  If one of the ancestors goes over its
-limit, the reclaim algorithm reclaims from the tasks in the ancestor and the
-children of the ancestor.
-
-6.1 Enabling hierarchical accounting and reclaim
-
-The memory controller by default disables the hierarchy feature. Support
-can be enabled by writing 1 to memory.use_hierarchy file of the root cgroup
-
-# echo 1 > memory.use_hierarchy
-
-The feature can be disabled by
-
-# echo 0 > memory.use_hierarchy
-
-NOTE1: Enabling/disabling will fail if the cgroup already has other
-cgroups created below it.
-
-NOTE2: This feature can be enabled/disabled per subtree.
-
-7. TODO
-
-1. Add support for accounting huge pages (as a separate controller)
-2. Make per-cgroup scanner reclaim not-shared pages first
-3. Teach controller to account for shared-pages
-4. Start reclamation in the background when the limit is
-   not yet hit but the usage is getting closer
-
-Summary
-
-Overall, the memory controller has been a stable controller and has been
-commented and discussed quite extensively in the community.
-
-References
-
-1. Singh, Balbir. RFC: Memory Controller, http://lwn.net/Articles/206697/
-2. Singh, Balbir. Memory Controller (RSS Control),
-   http://lwn.net/Articles/222762/
-3. Emelianov, Pavel. Resource controllers based on process cgroups
-   http://lkml.org/lkml/2007/3/6/198
-4. Emelianov, Pavel. RSS controller based on process cgroups (v2)
-   http://lkml.org/lkml/2007/4/9/78
-5. Emelianov, Pavel. RSS controller based on process cgroups (v3)
-   http://lkml.org/lkml/2007/5/30/244
-6. Menage, Paul. Control Groups v10, http://lwn.net/Articles/236032/
-7. Vaidyanathan, Srinivasan, Control Groups: Pagecache accounting and control
-   subsystem (v3), http://lwn.net/Articles/235534/
-8. Singh, Balbir. RSS controller v2 test results (lmbench),
-   http://lkml.org/lkml/2007/5/17/232
-9. Singh, Balbir. RSS controller v2 AIM9 results
-   http://lkml.org/lkml/2007/5/18/1
-10. Singh, Balbir. Memory controller v6 test results,
-    http://lkml.org/lkml/2007/8/19/36
-11. Singh, Balbir. Memory controller introduction (v6),
-    http://lkml.org/lkml/2007/8/17/69
-12. Corbet, Jonathan, Controlling memory use in cgroups,
-    http://lwn.net/Articles/243795/
diff --git a/Documentation/controllers/resource_counter.txt b/Documentation/controllers/resource_counter.txt
deleted file mode 100644
index f196ac1..0000000
--- a/Documentation/controllers/resource_counter.txt
+++ /dev/null
@@ -1,181 +0,0 @@
-
-		The Resource Counter
-
-The resource counter, declared at include/linux/res_counter.h,
-is supposed to facilitate the resource management by controllers
-by providing common stuff for accounting.
-
-This "stuff" includes the res_counter structure and routines
-to work with it.
-
-
-
-1. Crucial parts of the res_counter structure
-
- a. unsigned long long usage
-
- 	The usage value shows the amount of a resource that is consumed
-	by a group at a given time. The units of measurement should be
-	determined by the controller that uses this counter. E.g. it can
-	be bytes, items or any other unit the controller operates on.
-
- b. unsigned long long max_usage
-
- 	The maximal value of the usage over time.
-
- 	This value is useful when gathering statistical information about
-	the particular group, as it shows the actual resource requirements
-	for a particular group, not just some usage snapshot.
-
- c. unsigned long long limit
-
- 	The maximal allowed amount of resource to consume by the group. In
-	case the group requests for more resources, so that the usage value
-	would exceed the limit, the resource allocation is rejected (see
-	the next section).
-
- d. unsigned long long failcnt
-
- 	The failcnt stands for "failures counter". This is the number of
-	resource allocation attempts that failed.
-
- c. spinlock_t lock
-
- 	Protects changes of the above values.
-
-
-
-2. Basic accounting routines
-
- a. void res_counter_init(struct res_counter *rc)
-
- 	Initializes the resource counter. As usual, should be the first
-	routine called for a new counter.
-
- b. int res_counter_charge[_locked]
-			(struct res_counter *rc, unsigned long val)
-
-	When a resource is about to be allocated it has to be accounted
-	with the appropriate resource counter (controller should determine
-	which one to use on its own). This operation is called "charging".
-
-	This is not very important which operation - resource allocation
-	or charging - is performed first, but
-	  * if the allocation is performed first, this may create a
-	    temporary resource over-usage by the time resource counter is
-	    charged;
-	  * if the charging is performed first, then it should be uncharged
-	    on error path (if the one is called).
-
- c. void res_counter_uncharge[_locked]
-			(struct res_counter *rc, unsigned long val)
-
-	When a resource is released (freed) it should be de-accounted
-	from the resource counter it was accounted to.  This is called
-	"uncharging".
-
-    The _locked routines imply that the res_counter->lock is taken.
-
-
- 2.1 Other accounting routines
-
-    There are more routines that may help you with common needs, like
-    checking whether the limit is reached or resetting the max_usage
-    value. They are all declared in include/linux/res_counter.h.
-
-
-
-3. Analyzing the resource counter registrations
-
- a. If the failcnt value constantly grows, this means that the counter's
-    limit is too tight. Either the group is misbehaving and consumes too
-    many resources, or the configuration is not suitable for the group
-    and the limit should be increased.
-
- b. The max_usage value can be used to quickly tune the group. One may
-    set the limits to maximal values and either load the container with
-    a common pattern or leave one for a while. After this the max_usage
-    value shows the amount of memory the container would require during
-    its common activity.
-
-    Setting the limit a bit above this value gives a pretty good
-    configuration that works in most of the cases.
-
- c. If the max_usage is much less than the limit, but the failcnt value
-    is growing, then the group tries to allocate a big chunk of resource
-    at once.
-
- d. If the max_usage is much less than the limit, but the failcnt value
-    is 0, then this group is given too high limit, that it does not
-    require. It is better to lower the limit a bit leaving more resource
-    for other groups.
-
-
-
-4. Communication with the control groups subsystem (cgroups)
-
-All the resource controllers that are using cgroups and resource counters
-should provide files (in the cgroup filesystem) to work with the resource
-counter fields. They are recommended to adhere to the following rules:
-
- a. File names
-
- 	Field name	File name
-	---------------------------------------------------
-	usage		usage_in_<unit_of_measurement>
-	max_usage	max_usage_in_<unit_of_measurement>
-	limit		limit_in_<unit_of_measurement>
-	failcnt		failcnt
-	lock		no file :)
-
- b. Reading from file should show the corresponding field value in the
-    appropriate format.
-
- c. Writing to file
-
- 	Field		Expected behavior
-	----------------------------------
-	usage		prohibited
-	max_usage	reset to usage
-	limit		set the limit
-	failcnt		reset to zero
-
-
-
-5. Usage example
-
- a. Declare a task group (take a look at cgroups subsystem for this) and
-    fold a res_counter into it
-
-	struct my_group {
-		struct res_counter res;
-
-		<other fields>
-	}
-
- b. Put hooks in resource allocation/release paths
-
- 	int alloc_something(...)
-	{
-		if (res_counter_charge(res_counter_ptr, amount) < 0)
-			return -ENOMEM;
-
-		<allocate the resource and return to the caller>
-	}
-
-	void release_something(...)
-	{
-		res_counter_uncharge(res_counter_ptr, amount);
-
-		<release the resource>
-	}
-
-    In order to keep the usage value self-consistent, both the
-    "res_counter_ptr" and the "amount" in release_something() should be
-    the same as they were in the alloc_something() when the releasing
-    resource was allocated.
-
- c. Provide the way to read res_counter values and set them (the cgroups
-    still can help with it).
-
- c. Compile and run :)
diff --git a/Documentation/cpusets.txt b/Documentation/cpusets.txt
deleted file mode 100644
index 5c86c25..0000000
--- a/Documentation/cpusets.txt
+++ /dev/null
@@ -1,808 +0,0 @@
-				CPUSETS
-				-------
-
-Copyright (C) 2004 BULL SA.
-Written by Simon.Derr-6ktuUTfB/bM@public.gmane.org
-
-Portions Copyright (c) 2004-2006 Silicon Graphics, Inc.
-Modified by Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
-Modified by Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
-Modified by Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
-Modified by Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
-
-CONTENTS:
-=========
-
-1. Cpusets
-  1.1 What are cpusets ?
-  1.2 Why are cpusets needed ?
-  1.3 How are cpusets implemented ?
-  1.4 What are exclusive cpusets ?
-  1.5 What is memory_pressure ?
-  1.6 What is memory spread ?
-  1.7 What is sched_load_balance ?
-  1.8 What is sched_relax_domain_level ?
-  1.9 How do I use cpusets ?
-2. Usage Examples and Syntax
-  2.1 Basic Usage
-  2.2 Adding/removing cpus
-  2.3 Setting flags
-  2.4 Attaching processes
-3. Questions
-4. Contact
-
-1. Cpusets
-==========
-
-1.1 What are cpusets ?
-----------------------
-
-Cpusets provide a mechanism for assigning a set of CPUs and Memory
-Nodes to a set of tasks.   In this document "Memory Node" refers to
-an on-line node that contains memory.
-
-Cpusets constrain the CPU and Memory placement of tasks to only
-the resources within a tasks current cpuset.  They form a nested
-hierarchy visible in a virtual file system.  These are the essential
-hooks, beyond what is already present, required to manage dynamic
-job placement on large systems.
-
-Cpusets use the generic cgroup subsystem described in
-Documentation/cgroups/cgroups.txt.
-
-Requests by a task, using the sched_setaffinity(2) system call to
-include CPUs in its CPU affinity mask, and using the mbind(2) and
-set_mempolicy(2) system calls to include Memory Nodes in its memory
-policy, are both filtered through that tasks cpuset, filtering out any
-CPUs or Memory Nodes not in that cpuset.  The scheduler will not
-schedule a task on a CPU that is not allowed in its cpus_allowed
-vector, and the kernel page allocator will not allocate a page on a
-node that is not allowed in the requesting tasks mems_allowed vector.
-
-User level code may create and destroy cpusets by name in the cgroup
-virtual file system, manage the attributes and permissions of these
-cpusets and which CPUs and Memory Nodes are assigned to each cpuset,
-specify and query to which cpuset a task is assigned, and list the
-task pids assigned to a cpuset.
-
-
-1.2 Why are cpusets needed ?
-----------------------------
-
-The management of large computer systems, with many processors (CPUs),
-complex memory cache hierarchies and multiple Memory Nodes having
-non-uniform access times (NUMA) presents additional challenges for
-the efficient scheduling and memory placement of processes.
-
-Frequently more modest sized systems can be operated with adequate
-efficiency just by letting the operating system automatically share
-the available CPU and Memory resources amongst the requesting tasks.
-
-But larger systems, which benefit more from careful processor and
-memory placement to reduce memory access times and contention,
-and which typically represent a larger investment for the customer,
-can benefit from explicitly placing jobs on properly sized subsets of
-the system.
-
-This can be especially valuable on:
-
-    * Web Servers running multiple instances of the same web application,
-    * Servers running different applications (for instance, a web server
-      and a database), or
-    * NUMA systems running large HPC applications with demanding
-      performance characteristics.
-
-These subsets, or "soft partitions" must be able to be dynamically
-adjusted, as the job mix changes, without impacting other concurrently
-executing jobs. The location of the running jobs pages may also be moved
-when the memory locations are changed.
-
-The kernel cpuset patch provides the minimum essential kernel
-mechanisms required to efficiently implement such subsets.  It
-leverages existing CPU and Memory Placement facilities in the Linux
-kernel to avoid any additional impact on the critical scheduler or
-memory allocator code.
-
-
-1.3 How are cpusets implemented ?
----------------------------------
-
-Cpusets provide a Linux kernel mechanism to constrain which CPUs and
-Memory Nodes are used by a process or set of processes.
-
-The Linux kernel already has a pair of mechanisms to specify on which
-CPUs a task may be scheduled (sched_setaffinity) and on which Memory
-Nodes it may obtain memory (mbind, set_mempolicy).
-
-Cpusets extends these two mechanisms as follows:
-
- - Cpusets are sets of allowed CPUs and Memory Nodes, known to the
-   kernel.
- - Each task in the system is attached to a cpuset, via a pointer
-   in the task structure to a reference counted cgroup structure.
- - Calls to sched_setaffinity are filtered to just those CPUs
-   allowed in that tasks cpuset.
- - Calls to mbind and set_mempolicy are filtered to just
-   those Memory Nodes allowed in that tasks cpuset.
- - The root cpuset contains all the systems CPUs and Memory
-   Nodes.
- - For any cpuset, one can define child cpusets containing a subset
-   of the parents CPU and Memory Node resources.
- - The hierarchy of cpusets can be mounted at /dev/cpuset, for
-   browsing and manipulation from user space.
- - A cpuset may be marked exclusive, which ensures that no other
-   cpuset (except direct ancestors and descendents) may contain
-   any overlapping CPUs or Memory Nodes.
- - You can list all the tasks (by pid) attached to any cpuset.
-
-The implementation of cpusets requires a few, simple hooks
-into the rest of the kernel, none in performance critical paths:
-
- - in init/main.c, to initialize the root cpuset at system boot.
- - in fork and exit, to attach and detach a task from its cpuset.
- - in sched_setaffinity, to mask the requested CPUs by what's
-   allowed in that tasks cpuset.
- - in sched.c migrate_all_tasks(), to keep migrating tasks within
-   the CPUs allowed by their cpuset, if possible.
- - in the mbind and set_mempolicy system calls, to mask the requested
-   Memory Nodes by what's allowed in that tasks cpuset.
- - in page_alloc.c, to restrict memory to allowed nodes.
- - in vmscan.c, to restrict page recovery to the current cpuset.
-
-You should mount the "cgroup" filesystem type in order to enable
-browsing and modifying the cpusets presently known to the kernel.  No
-new system calls are added for cpusets - all support for querying and
-modifying cpusets is via this cpuset file system.
-
-The /proc/<pid>/status file for each task has four added lines,
-displaying the tasks cpus_allowed (on which CPUs it may be scheduled)
-and mems_allowed (on which Memory Nodes it may obtain memory),
-in the two formats seen in the following example:
-
-  Cpus_allowed:   ffffffff,ffffffff,ffffffff,ffffffff
-  Cpus_allowed_list:      0-127
-  Mems_allowed:   ffffffff,ffffffff
-  Mems_allowed_list:      0-63
-
-Each cpuset is represented by a directory in the cgroup file system
-containing (on top of the standard cgroup files) the following
-files describing that cpuset:
-
- - cpus: list of CPUs in that cpuset
- - mems: list of Memory Nodes in that cpuset
- - memory_migrate flag: if set, move pages to cpusets nodes
- - cpu_exclusive flag: is cpu placement exclusive?
- - mem_exclusive flag: is memory placement exclusive?
- - mem_hardwall flag:  is memory allocation hardwalled
- - memory_pressure: measure of how much paging pressure in cpuset
-
-In addition, the root cpuset only has the following file:
- - memory_pressure_enabled flag: compute memory_pressure?
-
-New cpusets are created using the mkdir system call or shell
-command.  The properties of a cpuset, such as its flags, allowed
-CPUs and Memory Nodes, and attached tasks, are modified by writing
-to the appropriate file in that cpusets directory, as listed above.
-
-The named hierarchical structure of nested cpusets allows partitioning
-a large system into nested, dynamically changeable, "soft-partitions".
-
-The attachment of each task, automatically inherited at fork by any
-children of that task, to a cpuset allows organizing the work load
-on a system into related sets of tasks such that each set is constrained
-to using the CPUs and Memory Nodes of a particular cpuset.  A task
-may be re-attached to any other cpuset, if allowed by the permissions
-on the necessary cpuset file system directories.
-
-Such management of a system "in the large" integrates smoothly with
-the detailed placement done on individual tasks and memory regions
-using the sched_setaffinity, mbind and set_mempolicy system calls.
-
-The following rules apply to each cpuset:
-
- - Its CPUs and Memory Nodes must be a subset of its parents.
- - It can't be marked exclusive unless its parent is.
- - If its cpu or memory is exclusive, they may not overlap any sibling.
-
-These rules, and the natural hierarchy of cpusets, enable efficient
-enforcement of the exclusive guarantee, without having to scan all
-cpusets every time any of them change to ensure nothing overlaps a
-exclusive cpuset.  Also, the use of a Linux virtual file system (vfs)
-to represent the cpuset hierarchy provides for a familiar permission
-and name space for cpusets, with a minimum of additional kernel code.
-
-The cpus and mems files in the root (top_cpuset) cpuset are
-read-only.  The cpus file automatically tracks the value of
-cpu_online_map using a CPU hotplug notifier, and the mems file
-automatically tracks the value of node_states[N_HIGH_MEMORY]--i.e.,
-nodes with memory--using the cpuset_track_online_nodes() hook.
-
-
-1.4 What are exclusive cpusets ?
---------------------------------
-
-If a cpuset is cpu or mem exclusive, no other cpuset, other than
-a direct ancestor or descendent, may share any of the same CPUs or
-Memory Nodes.
-
-A cpuset that is mem_exclusive *or* mem_hardwall is "hardwalled",
-i.e. it restricts kernel allocations for page, buffer and other data
-commonly shared by the kernel across multiple users.  All cpusets,
-whether hardwalled or not, restrict allocations of memory for user
-space.  This enables configuring a system so that several independent
-jobs can share common kernel data, such as file system pages, while
-isolating each job's user allocation in its own cpuset.  To do this,
-construct a large mem_exclusive cpuset to hold all the jobs, and
-construct child, non-mem_exclusive cpusets for each individual job.
-Only a small amount of typical kernel memory, such as requests from
-interrupt handlers, is allowed to be taken outside even a
-mem_exclusive cpuset.
-
-
-1.5 What is memory_pressure ?
------------------------------
-The memory_pressure of a cpuset provides a simple per-cpuset metric
-of the rate that the tasks in a cpuset are attempting to free up in
-use memory on the nodes of the cpuset to satisfy additional memory
-requests.
-
-This enables batch managers monitoring jobs running in dedicated
-cpusets to efficiently detect what level of memory pressure that job
-is causing.
-
-This is useful both on tightly managed systems running a wide mix of
-submitted jobs, which may choose to terminate or re-prioritize jobs that
-are trying to use more memory than allowed on the nodes assigned them,
-and with tightly coupled, long running, massively parallel scientific
-computing jobs that will dramatically fail to meet required performance
-goals if they start to use more memory than allowed to them.
-
-This mechanism provides a very economical way for the batch manager
-to monitor a cpuset for signs of memory pressure.  It's up to the
-batch manager or other user code to decide what to do about it and
-take action.
-
-==> Unless this feature is enabled by writing "1" to the special file
-    /dev/cpuset/memory_pressure_enabled, the hook in the rebalance
-    code of __alloc_pages() for this metric reduces to simply noticing
-    that the cpuset_memory_pressure_enabled flag is zero.  So only
-    systems that enable this feature will compute the metric.
-
-Why a per-cpuset, running average:
-
-    Because this meter is per-cpuset, rather than per-task or mm,
-    the system load imposed by a batch scheduler monitoring this
-    metric is sharply reduced on large systems, because a scan of
-    the tasklist can be avoided on each set of queries.
-
-    Because this meter is a running average, instead of an accumulating
-    counter, a batch scheduler can detect memory pressure with a
-    single read, instead of having to read and accumulate results
-    for a period of time.
-
-    Because this meter is per-cpuset rather than per-task or mm,
-    the batch scheduler can obtain the key information, memory
-    pressure in a cpuset, with a single read, rather than having to
-    query and accumulate results over all the (dynamically changing)
-    set of tasks in the cpuset.
-
-A per-cpuset simple digital filter (requires a spinlock and 3 words
-of data per-cpuset) is kept, and updated by any task attached to that
-cpuset, if it enters the synchronous (direct) page reclaim code.
-
-A per-cpuset file provides an integer number representing the recent
-(half-life of 10 seconds) rate of direct page reclaims caused by
-the tasks in the cpuset, in units of reclaims attempted per second,
-times 1000.
-
-
-1.6 What is memory spread ?
----------------------------
-There are two boolean flag files per cpuset that control where the
-kernel allocates pages for the file system buffers and related in
-kernel data structures.  They are called 'memory_spread_page' and
-'memory_spread_slab'.
-
-If the per-cpuset boolean flag file 'memory_spread_page' is set, then
-the kernel will spread the file system buffers (page cache) evenly
-over all the nodes that the faulting task is allowed to use, instead
-of preferring to put those pages on the node where the task is running.
-
-If the per-cpuset boolean flag file 'memory_spread_slab' is set,
-then the kernel will spread some file system related slab caches,
-such as for inodes and dentries evenly over all the nodes that the
-faulting task is allowed to use, instead of preferring to put those
-pages on the node where the task is running.
-
-The setting of these flags does not affect anonymous data segment or
-stack segment pages of a task.
-
-By default, both kinds of memory spreading are off, and memory
-pages are allocated on the node local to where the task is running,
-except perhaps as modified by the tasks NUMA mempolicy or cpuset
-configuration, so long as sufficient free memory pages are available.
-
-When new cpusets are created, they inherit the memory spread settings
-of their parent.
-
-Setting memory spreading causes allocations for the affected page
-or slab caches to ignore the tasks NUMA mempolicy and be spread
-instead.    Tasks using mbind() or set_mempolicy() calls to set NUMA
-mempolicies will not notice any change in these calls as a result of
-their containing tasks memory spread settings.  If memory spreading
-is turned off, then the currently specified NUMA mempolicy once again
-applies to memory page allocations.
-
-Both 'memory_spread_page' and 'memory_spread_slab' are boolean flag
-files.  By default they contain "0", meaning that the feature is off
-for that cpuset.  If a "1" is written to that file, then that turns
-the named feature on.
-
-The implementation is simple.
-
-Setting the flag 'memory_spread_page' turns on a per-process flag
-PF_SPREAD_PAGE for each task that is in that cpuset or subsequently
-joins that cpuset.  The page allocation calls for the page cache
-is modified to perform an inline check for this PF_SPREAD_PAGE task
-flag, and if set, a call to a new routine cpuset_mem_spread_node()
-returns the node to prefer for the allocation.
-
-Similarly, setting 'memory_spread_slab' turns on the flag
-PF_SPREAD_SLAB, and appropriately marked slab caches will allocate
-pages from the node returned by cpuset_mem_spread_node().
-
-The cpuset_mem_spread_node() routine is also simple.  It uses the
-value of a per-task rotor cpuset_mem_spread_rotor to select the next
-node in the current tasks mems_allowed to prefer for the allocation.
-
-This memory placement policy is also known (in other contexts) as
-round-robin or interleave.
-
-This policy can provide substantial improvements for jobs that need
-to place thread local data on the corresponding node, but that need
-to access large file system data sets that need to be spread across
-the several nodes in the jobs cpuset in order to fit.  Without this
-policy, especially for jobs that might have one thread reading in the
-data set, the memory allocation across the nodes in the jobs cpuset
-can become very uneven.
-
-1.7 What is sched_load_balance ?
---------------------------------
-
-The kernel scheduler (kernel/sched.c) automatically load balances
-tasks.  If one CPU is underutilized, kernel code running on that
-CPU will look for tasks on other more overloaded CPUs and move those
-tasks to itself, within the constraints of such placement mechanisms
-as cpusets and sched_setaffinity.
-
-The algorithmic cost of load balancing and its impact on key shared
-kernel data structures such as the task list increases more than
-linearly with the number of CPUs being balanced.  So the scheduler
-has support to  partition the systems CPUs into a number of sched
-domains such that it only load balances within each sched domain.
-Each sched domain covers some subset of the CPUs in the system;
-no two sched domains overlap; some CPUs might not be in any sched
-domain and hence won't be load balanced.
-
-Put simply, it costs less to balance between two smaller sched domains
-than one big one, but doing so means that overloads in one of the
-two domains won't be load balanced to the other one.
-
-By default, there is one sched domain covering all CPUs, except those
-marked isolated using the kernel boot time "isolcpus=" argument.
-
-This default load balancing across all CPUs is not well suited for
-the following two situations:
- 1) On large systems, load balancing across many CPUs is expensive.
-    If the system is managed using cpusets to place independent jobs
-    on separate sets of CPUs, full load balancing is unnecessary.
- 2) Systems supporting realtime on some CPUs need to minimize
-    system overhead on those CPUs, including avoiding task load
-    balancing if that is not needed.
-
-When the per-cpuset flag "sched_load_balance" is enabled (the default
-setting), it requests that all the CPUs in that cpusets allowed 'cpus'
-be contained in a single sched domain, ensuring that load balancing
-can move a task (not otherwised pinned, as by sched_setaffinity)
-from any CPU in that cpuset to any other.
-
-When the per-cpuset flag "sched_load_balance" is disabled, then the
-scheduler will avoid load balancing across the CPUs in that cpuset,
---except-- in so far as is necessary because some overlapping cpuset
-has "sched_load_balance" enabled.
-
-So, for example, if the top cpuset has the flag "sched_load_balance"
-enabled, then the scheduler will have one sched domain covering all
-CPUs, and the setting of the "sched_load_balance" flag in any other
-cpusets won't matter, as we're already fully load balancing.
-
-Therefore in the above two situations, the top cpuset flag
-"sched_load_balance" should be disabled, and only some of the smaller,
-child cpusets have this flag enabled.
-
-When doing this, you don't usually want to leave any unpinned tasks in
-the top cpuset that might use non-trivial amounts of CPU, as such tasks
-may be artificially constrained to some subset of CPUs, depending on
-the particulars of this flag setting in descendent cpusets.  Even if
-such a task could use spare CPU cycles in some other CPUs, the kernel
-scheduler might not consider the possibility of load balancing that
-task to that underused CPU.
-
-Of course, tasks pinned to a particular CPU can be left in a cpuset
-that disables "sched_load_balance" as those tasks aren't going anywhere
-else anyway.
-
-There is an impedance mismatch here, between cpusets and sched domains.
-Cpusets are hierarchical and nest.  Sched domains are flat; they don't
-overlap and each CPU is in at most one sched domain.
-
-It is necessary for sched domains to be flat because load balancing
-across partially overlapping sets of CPUs would risk unstable dynamics
-that would be beyond our understanding.  So if each of two partially
-overlapping cpusets enables the flag 'sched_load_balance', then we
-form a single sched domain that is a superset of both.  We won't move
-a task to a CPU outside it cpuset, but the scheduler load balancing
-code might waste some compute cycles considering that possibility.
-
-This mismatch is why there is not a simple one-to-one relation
-between which cpusets have the flag "sched_load_balance" enabled,
-and the sched domain configuration.  If a cpuset enables the flag, it
-will get balancing across all its CPUs, but if it disables the flag,
-it will only be assured of no load balancing if no other overlapping
-cpuset enables the flag.
-
-If two cpusets have partially overlapping 'cpus' allowed, and only
-one of them has this flag enabled, then the other may find its
-tasks only partially load balanced, just on the overlapping CPUs.
-This is just the general case of the top_cpuset example given a few
-paragraphs above.  In the general case, as in the top cpuset case,
-don't leave tasks that might use non-trivial amounts of CPU in
-such partially load balanced cpusets, as they may be artificially
-constrained to some subset of the CPUs allowed to them, for lack of
-load balancing to the other CPUs.
-
-1.7.1 sched_load_balance implementation details.
-------------------------------------------------
-
-The per-cpuset flag 'sched_load_balance' defaults to enabled (contrary
-to most cpuset flags.)  When enabled for a cpuset, the kernel will
-ensure that it can load balance across all the CPUs in that cpuset
-(makes sure that all the CPUs in the cpus_allowed of that cpuset are
-in the same sched domain.)
-
-If two overlapping cpusets both have 'sched_load_balance' enabled,
-then they will be (must be) both in the same sched domain.
-
-If, as is the default, the top cpuset has 'sched_load_balance' enabled,
-then by the above that means there is a single sched domain covering
-the whole system, regardless of any other cpuset settings.
-
-The kernel commits to user space that it will avoid load balancing
-where it can.  It will pick as fine a granularity partition of sched
-domains as it can while still providing load balancing for any set
-of CPUs allowed to a cpuset having 'sched_load_balance' enabled.
-
-The internal kernel cpuset to scheduler interface passes from the
-cpuset code to the scheduler code a partition of the load balanced
-CPUs in the system. This partition is a set of subsets (represented
-as an array of cpumask_t) of CPUs, pairwise disjoint, that cover all
-the CPUs that must be load balanced.
-
-Whenever the 'sched_load_balance' flag changes, or CPUs come or go
-from a cpuset with this flag enabled, or a cpuset with this flag
-enabled is removed, the cpuset code builds a new such partition and
-passes it to the scheduler sched domain setup code, to have the sched
-domains rebuilt as necessary.
-
-This partition exactly defines what sched domains the scheduler should
-setup - one sched domain for each element (cpumask_t) in the partition.
-
-The scheduler remembers the currently active sched domain partitions.
-When the scheduler routine partition_sched_domains() is invoked from
-the cpuset code to update these sched domains, it compares the new
-partition requested with the current, and updates its sched domains,
-removing the old and adding the new, for each change.
-
-
-1.8 What is sched_relax_domain_level ?
---------------------------------------
-
-In sched domain, the scheduler migrates tasks in 2 ways; periodic load
-balance on tick, and at time of some schedule events.
-
-When a task is woken up, scheduler try to move the task on idle CPU.
-For example, if a task A running on CPU X activates another task B
-on the same CPU X, and if CPU Y is X's sibling and performing idle,
-then scheduler migrate task B to CPU Y so that task B can start on
-CPU Y without waiting task A on CPU X.
-
-And if a CPU run out of tasks in its runqueue, the CPU try to pull
-extra tasks from other busy CPUs to help them before it is going to
-be idle.
-
-Of course it takes some searching cost to find movable tasks and/or
-idle CPUs, the scheduler might not search all CPUs in the domain
-everytime.  In fact, in some architectures, the searching ranges on
-events are limited in the same socket or node where the CPU locates,
-while the load balance on tick searchs all.
-
-For example, assume CPU Z is relatively far from CPU X.  Even if CPU Z
-is idle while CPU X and the siblings are busy, scheduler can't migrate
-woken task B from X to Z since it is out of its searching range.
-As the result, task B on CPU X need to wait task A or wait load balance
-on the next tick.  For some applications in special situation, waiting
-1 tick may be too long.
-
-The 'sched_relax_domain_level' file allows you to request changing
-this searching range as you like.  This file takes int value which
-indicates size of searching range in levels ideally as follows,
-otherwise initial value -1 that indicates the cpuset has no request.
-
-  -1  : no request. use system default or follow request of others.
-   0  : no search.
-   1  : search siblings (hyperthreads in a core).
-   2  : search cores in a package.
-   3  : search cpus in a node [= system wide on non-NUMA system]
- ( 4  : search nodes in a chunk of node [on NUMA system] )
- ( 5  : search system wide [on NUMA system] )
-
-The system default is architecture dependent.  The system default
-can be changed using the relax_domain_level= boot parameter.
-
-This file is per-cpuset and affect the sched domain where the cpuset
-belongs to.  Therefore if the flag 'sched_load_balance' of a cpuset
-is disabled, then 'sched_relax_domain_level' have no effect since
-there is no sched domain belonging the cpuset.
-
-If multiple cpusets are overlapping and hence they form a single sched
-domain, the largest value among those is used.  Be careful, if one
-requests 0 and others are -1 then 0 is used.
-
-Note that modifying this file will have both good and bad effects,
-and whether it is acceptable or not will be depend on your situation.
-Don't modify this file if you are not sure.
-
-If your situation is:
- - The migration costs between each cpu can be assumed considerably
-   small(for you) due to your special application's behavior or
-   special hardware support for CPU cache etc.
- - The searching cost doesn't have impact(for you) or you can make
-   the searching cost enough small by managing cpuset to compact etc.
- - The latency is required even it sacrifices cache hit rate etc.
-then increasing 'sched_relax_domain_level' would benefit you.
-
-
-1.9 How do I use cpusets ?
---------------------------
-
-In order to minimize the impact of cpusets on critical kernel
-code, such as the scheduler, and due to the fact that the kernel
-does not support one task updating the memory placement of another
-task directly, the impact on a task of changing its cpuset CPU
-or Memory Node placement, or of changing to which cpuset a task
-is attached, is subtle.
-
-If a cpuset has its Memory Nodes modified, then for each task attached
-to that cpuset, the next time that the kernel attempts to allocate
-a page of memory for that task, the kernel will notice the change
-in the tasks cpuset, and update its per-task memory placement to
-remain within the new cpusets memory placement.  If the task was using
-mempolicy MPOL_BIND, and the nodes to which it was bound overlap with
-its new cpuset, then the task will continue to use whatever subset
-of MPOL_BIND nodes are still allowed in the new cpuset.  If the task
-was using MPOL_BIND and now none of its MPOL_BIND nodes are allowed
-in the new cpuset, then the task will be essentially treated as if it
-was MPOL_BIND bound to the new cpuset (even though its numa placement,
-as queried by get_mempolicy(), doesn't change).  If a task is moved
-from one cpuset to another, then the kernel will adjust the tasks
-memory placement, as above, the next time that the kernel attempts
-to allocate a page of memory for that task.
-
-If a cpuset has its 'cpus' modified, then each task in that cpuset
-will have its allowed CPU placement changed immediately.  Similarly,
-if a tasks pid is written to a cpusets 'tasks' file, in either its
-current cpuset or another cpuset, then its allowed CPU placement is
-changed immediately.  If such a task had been bound to some subset
-of its cpuset using the sched_setaffinity() call, the task will be
-allowed to run on any CPU allowed in its new cpuset, negating the
-affect of the prior sched_setaffinity() call.
-
-In summary, the memory placement of a task whose cpuset is changed is
-updated by the kernel, on the next allocation of a page for that task,
-but the processor placement is not updated, until that tasks pid is
-rewritten to the 'tasks' file of its cpuset.  This is done to avoid
-impacting the scheduler code in the kernel with a check for changes
-in a tasks processor placement.
-
-Normally, once a page is allocated (given a physical page
-of main memory) then that page stays on whatever node it
-was allocated, so long as it remains allocated, even if the
-cpusets memory placement policy 'mems' subsequently changes.
-If the cpuset flag file 'memory_migrate' is set true, then when
-tasks are attached to that cpuset, any pages that task had
-allocated to it on nodes in its previous cpuset are migrated
-to the tasks new cpuset. The relative placement of the page within
-the cpuset is preserved during these migration operations if possible.
-For example if the page was on the second valid node of the prior cpuset
-then the page will be placed on the second valid node of the new cpuset.
-
-Also if 'memory_migrate' is set true, then if that cpusets
-'mems' file is modified, pages allocated to tasks in that
-cpuset, that were on nodes in the previous setting of 'mems',
-will be moved to nodes in the new setting of 'mems.'
-Pages that were not in the tasks prior cpuset, or in the cpusets
-prior 'mems' setting, will not be moved.
-
-There is an exception to the above.  If hotplug functionality is used
-to remove all the CPUs that are currently assigned to a cpuset,
-then all the tasks in that cpuset will be moved to the nearest ancestor
-with non-empty cpus.  But the moving of some (or all) tasks might fail if
-cpuset is bound with another cgroup subsystem which has some restrictions
-on task attaching.  In this failing case, those tasks will stay
-in the original cpuset, and the kernel will automatically update
-their cpus_allowed to allow all online CPUs.  When memory hotplug
-functionality for removing Memory Nodes is available, a similar exception
-is expected to apply there as well.  In general, the kernel prefers to
-violate cpuset placement, over starving a task that has had all
-its allowed CPUs or Memory Nodes taken offline.
-
-There is a second exception to the above.  GFP_ATOMIC requests are
-kernel internal allocations that must be satisfied, immediately.
-The kernel may drop some request, in rare cases even panic, if a
-GFP_ATOMIC alloc fails.  If the request cannot be satisfied within
-the current tasks cpuset, then we relax the cpuset, and look for
-memory anywhere we can find it.  It's better to violate the cpuset
-than stress the kernel.
-
-To start a new job that is to be contained within a cpuset, the steps are:
-
- 1) mkdir /dev/cpuset
- 2) mount -t cgroup -ocpuset cpuset /dev/cpuset
- 3) Create the new cpuset by doing mkdir's and write's (or echo's) in
-    the /dev/cpuset virtual file system.
- 4) Start a task that will be the "founding father" of the new job.
- 5) Attach that task to the new cpuset by writing its pid to the
-    /dev/cpuset tasks file for that cpuset.
- 6) fork, exec or clone the job tasks from this founding father task.
-
-For example, the following sequence of commands will setup a cpuset
-named "Charlie", containing just CPUs 2 and 3, and Memory Node 1,
-and then start a subshell 'sh' in that cpuset:
-
-  mount -t cgroup -ocpuset cpuset /dev/cpuset
-  cd /dev/cpuset
-  mkdir Charlie
-  cd Charlie
-  /bin/echo 2-3 > cpus
-  /bin/echo 1 > mems
-  /bin/echo $$ > tasks
-  sh
-  # The subshell 'sh' is now running in cpuset Charlie
-  # The next line should display '/Charlie'
-  cat /proc/self/cpuset
-
-In the future, a C library interface to cpusets will likely be
-available.  For now, the only way to query or modify cpusets is
-via the cpuset file system, using the various cd, mkdir, echo, cat,
-rmdir commands from the shell, or their equivalent from C.
-
-The sched_setaffinity calls can also be done at the shell prompt using
-SGI's runon or Robert Love's taskset.  The mbind and set_mempolicy
-calls can be done at the shell prompt using the numactl command
-(part of Andi Kleen's numa package).
-
-2. Usage Examples and Syntax
-============================
-
-2.1 Basic Usage
----------------
-
-Creating, modifying, using the cpusets can be done through the cpuset
-virtual filesystem.
-
-To mount it, type:
-# mount -t cgroup -o cpuset cpuset /dev/cpuset
-
-Then under /dev/cpuset you can find a tree that corresponds to the
-tree of the cpusets in the system. For instance, /dev/cpuset
-is the cpuset that holds the whole system.
-
-If you want to create a new cpuset under /dev/cpuset:
-# cd /dev/cpuset
-# mkdir my_cpuset
-
-Now you want to do something with this cpuset.
-# cd my_cpuset
-
-In this directory you can find several files:
-# ls
-cpu_exclusive  memory_migrate      mems                      tasks
-cpus           memory_pressure     notify_on_release
-mem_exclusive  memory_spread_page  sched_load_balance
-mem_hardwall   memory_spread_slab  sched_relax_domain_level
-
-Reading them will give you information about the state of this cpuset:
-the CPUs and Memory Nodes it can use, the processes that are using
-it, its properties.  By writing to these files you can manipulate
-the cpuset.
-
-Set some flags:
-# /bin/echo 1 > cpu_exclusive
-
-Add some cpus:
-# /bin/echo 0-7 > cpus
-
-Add some mems:
-# /bin/echo 0-7 > mems
-
-Now attach your shell to this cpuset:
-# /bin/echo $$ > tasks
-
-You can also create cpusets inside your cpuset by using mkdir in this
-directory.
-# mkdir my_sub_cs
-
-To remove a cpuset, just use rmdir:
-# rmdir my_sub_cs
-This will fail if the cpuset is in use (has cpusets inside, or has
-processes attached).
-
-Note that for legacy reasons, the "cpuset" filesystem exists as a
-wrapper around the cgroup filesystem.
-
-The command
-
-mount -t cpuset X /dev/cpuset
-
-is equivalent to
-
-mount -t cgroup -ocpuset X /dev/cpuset
-echo "/sbin/cpuset_release_agent" > /dev/cpuset/release_agent
-
-2.2 Adding/removing cpus
-------------------------
-
-This is the syntax to use when writing in the cpus or mems files
-in cpuset directories:
-
-# /bin/echo 1-4 > cpus		-> set cpus list to cpus 1,2,3,4
-# /bin/echo 1,2,3,4 > cpus	-> set cpus list to cpus 1,2,3,4
-
-2.3 Setting flags
------------------
-
-The syntax is very simple:
-
-# /bin/echo 1 > cpu_exclusive 	-> set flag 'cpu_exclusive'
-# /bin/echo 0 > cpu_exclusive 	-> unset flag 'cpu_exclusive'
-
-2.4 Attaching processes
------------------------
-
-# /bin/echo PID > tasks
-
-Note that it is PID, not PIDs. You can only attach ONE task at a time.
-If you have several tasks to attach, you have to do it one after another:
-
-# /bin/echo PID1 > tasks
-# /bin/echo PID2 > tasks
-	...
-# /bin/echo PIDn > tasks
-
-
-3. Questions
-============
-
-Q: what's up with this '/bin/echo' ?
-A: bash's builtin 'echo' command does not check calls to write() against
-   errors. If you use it in the cpuset file system, you won't be
-   able to tell whether a command succeeded or failed.
-
-Q: When I attach processes, only the first of the line gets really attached !
-A: We can only return one error code per call to write(). So you should also
-   put only ONE pid.
-
-4. Contact
-==========
-
-Web: http://www.bullopensource.org/cpuset
diff --git a/Documentation/scheduler/sched-design-CFS.txt b/Documentation/scheduler/sched-design-CFS.txt
index 8398ca4..6f33593 100644
--- a/Documentation/scheduler/sched-design-CFS.txt
+++ b/Documentation/scheduler/sched-design-CFS.txt
@@ -231,7 +231,7 @@ CPU bandwidth control purposes:
 
    This options needs CONFIG_CGROUPS to be defined, and lets the administrator
    create arbitrary groups of tasks, using the "cgroup" pseudo filesystem.  See
-   Documentation/cgroups.txt for more information about this filesystem.
+   Documentation/cgroups/cgroups.txt for more information about this filesystem.
 
 Only one of these options to group tasks can be chosen and not both.
 
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index dede0a2..4c5bcf6 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -9,7 +9,7 @@
  *
  * Author: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
  *
- * See Documentation/controllers/resource_counter.txt for more
+ * See Documentation/cgroups/resource_counter.txt for more
  * info about what this counter is.
  */
 
diff --git a/init/Kconfig b/init/Kconfig
index 56fd93c..2af8382 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -323,8 +323,8 @@ config CGROUP_SCHED
 	  This option allows you to create arbitrary task groups
 	  using the "cgroup" pseudo filesystem and control
 	  the cpu bandwidth allocated to each such task group.
-	  Refer to Documentation/cgroups.txt for more information
-	  on "cgroup" pseudo filesystem.
+	  Refer to Documentation/cgroups/cgroups.txt for more
+	  information on "cgroup" pseudo filesystem.
 
 endchoice
 
@@ -335,10 +335,9 @@ menuconfig CGROUPS
 	  use with process control subsystems such as Cpusets, CFS, memory
 	  controls or device isolation.
 	  See
-		- Documentation/cpusets.txt	(Cpusets)
 		- Documentation/scheduler/sched-design-CFS.txt	(CFS)
-		- Documentation/cgroups/ (features for grouping, isolation)
-		- Documentation/controllers/ (features for resource control)
+		- Documentation/cgroups/ (features for grouping, isolation
+					  and resource control)
 
 	  Say N if unsure.
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 647c77a..a856788 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -568,7 +568,7 @@ update_domain_attr_tree(struct sched_domain_attr *dattr, struct cpuset *c)
  * load balancing domains (sched domains) as specified by that partial
  * partition.
  *
- * See "What is sched_load_balance" in Documentation/cpusets.txt
+ * See "What is sched_load_balance" in Documentation/cgroups/cpusets.txt
  * for a background explanation of this.
  *
  * Does not return errors, on the theory that the callers of this
-- 
1.5.4.rc3


--------------000001060706060400070609
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------000001060706060400070609--
