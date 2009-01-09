From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: clean up Kconfig
Date: Fri, 09 Jan 2009 10:16:16 +0800
Message-ID: <4966B370.5070707__22376.7707161189$1231467694$gmane$org@cn.fujitsu.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

- move CONFIG_PROC_PID_CPUSET into cgroup menu
- move MM_OWNER to the bottom for better menu indent
- fix typos
- use tabs not spaces

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 init/Kconfig |   56 ++++++++++++++++++++++++++++----------------------------
 1 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index a724a14..56fd93c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -328,11 +328,10 @@ config CGROUP_SCHED
 
 endchoice
 
-menu "Control Group support"
-config CGROUPS
-	bool "Control Group support"
+menuconfig CGROUPS
+	boolean "Control Group support"
 	help
-	  This option add support for grouping sets of processes together, for
+	  This option adds support for grouping sets of processes together, for
 	  use with process control subsystems such as Cpusets, CFS, memory
 	  controls or device isolation.
 	  See
@@ -343,6 +342,8 @@ config CGROUPS
 
 	  Say N if unsure.
 
+if CGROUPS
+
 config CGROUP_DEBUG
 	bool "Example debug cgroup subsystem"
 	depends on CGROUPS
@@ -350,24 +351,24 @@ config CGROUP_DEBUG
 	help
 	  This option enables a simple cgroup subsystem that
 	  exports useful debugging information about the cgroups
-	  framework
+	  framework.
 
-	  Say N if unsure
+	  Say N if unsure.
 
 config CGROUP_NS
-        bool "Namespace cgroup subsystem"
-        depends on CGROUPS
-        help
-          Provides a simple namespace cgroup subsystem to
-          provide hierarchical naming of sets of namespaces,
-          for instance virtual servers and checkpoint/restart
-          jobs.
+	bool "Namespace cgroup subsystem"
+	depends on CGROUPS
+	help
+	  Provides a simple namespace cgroup subsystem to
+	  provide hierarchical naming of sets of namespaces,
+	  for instance virtual servers and checkpoint/restart
+	  jobs.
 
 config CGROUP_FREEZER
-        bool "control group freezer subsystem"
-        depends on CGROUPS
-        help
-          Provides a way to freeze and unfreeze all tasks in a
+	bool "Freezer cgroup subsystem"
+	depends on CGROUPS
+	help
+	  Provides a way to freeze and unfreeze all tasks in a
 	  cgroup.
 
 config CGROUP_DEVICE
@@ -388,18 +389,23 @@ config CPUSETS
 
 	  Say N if unsure.
 
+config PROC_PID_CPUSET
+	bool "Include legacy /proc/<pid>/cpuset file"
+	depends on CPUSETS
+	default y
+
 config CGROUP_CPUACCT
 	bool "Simple CPU accounting cgroup subsystem"
 	depends on CGROUPS
 	help
 	  Provides a simple Resource Controller for monitoring the
-	  total CPU consumed by the tasks in a cgroup
+	  total CPU consumed by the tasks in a cgroup.
 
 config RESOURCE_COUNTERS
 	bool "Resource counters"
 	help
 	  This option enables controller independent resource accounting
-          infrastructure that works with cgroups
+	  infrastructure that works with cgroups.
 	depends on CGROUPS
 
 config CGROUP_MEM_RES_CTLR
@@ -425,9 +431,6 @@ config CGROUP_MEM_RES_CTLR
 	  This config option also selects MM_OWNER config option, which
 	  could in turn add some fork/exit overhead.
 
-config MM_OWNER
-	bool
-
 config CGROUP_MEM_RES_CTLR_SWAP
 	bool "Memory Resource Controller Swap Extension(EXPERIMENTAL)"
 	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
@@ -444,8 +447,10 @@ config CGROUP_MEM_RES_CTLR_SWAP
 	  there will be no overhead from this. Even when you set this config=y,
 	  if boot option "noswapaccount" is set, swap will not be accounted.
 
+endif # CGROUPS
 
-endmenu
+config MM_OWNER
+	bool
 
 config SYSFS_DEPRECATED
 	bool
@@ -483,11 +488,6 @@ config SYSFS_DEPRECATED_V2
 	  if the original kernel, that came with your distribution, has
 	  this option set to N.
 
-config PROC_PID_CPUSET
-	bool "Include legacy /proc/<pid>/cpuset file"
-	depends on CPUSETS
-	default y
-
 config RELAY
 	bool "Kernel->user space relay support (formerly relayfs)"
 	help
-- 
1.5.4.rc3
