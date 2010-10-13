From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 2/4] Kconfig: remove pointless cgroup dependency
Date: Wed, 13 Oct 2010 11:28:43 +0200
Message-ID: <1286962125-23871-2-git-send-email-daniel.lezcano@free.fr>
References: <1286962125-23871-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1286962125-23871-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

The different cgroup subsystems are under the cgroup submenu.
The dependency between the cgroups and the menu subsystems is
pointless.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 init/Kconfig |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 14c84e7..335ce89 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -511,7 +511,6 @@ if CGROUPS
 
 config CGROUP_DEBUG
 	bool "Example debug cgroup subsystem"
-	depends on CGROUPS
 	default n
 	help
 	  This option enables a simple cgroup subsystem that
@@ -522,7 +521,6 @@ config CGROUP_DEBUG
 
 config CGROUP_NS
 	bool "Namespace cgroup subsystem"
-	depends on CGROUPS
 	help
 	  Provides a simple namespace cgroup subsystem to
 	  provide hierarchical naming of sets of namespaces,
@@ -531,21 +529,19 @@ config CGROUP_NS
 
 config CGROUP_FREEZER
 	bool "Freezer cgroup subsystem"
-	depends on CGROUPS
 	help
 	  Provides a way to freeze and unfreeze all tasks in a
 	  cgroup.
 
 config CGROUP_DEVICE
 	bool "Device controller for cgroups"
-	depends on CGROUPS && EXPERIMENTAL
+	depends on EXPERIMENTAL
 	help
 	  Provides a cgroup implementing whitelists for devices which
 	  a process in the cgroup can mknod or open.
 
 config CPUSETS
 	bool "Cpuset support"
-	depends on CGROUPS
 	help
 	  This option will let you create and manage CPUSETs which
 	  allow dynamically partitioning a system into sets of CPUs and
@@ -561,7 +557,6 @@ config PROC_PID_CPUSET
 
 config CGROUP_CPUACCT
 	bool "Simple CPU accounting cgroup subsystem"
-	depends on CGROUPS
 	help
 	  Provides a simple Resource Controller for monitoring the
 	  total CPU consumed by the tasks in a cgroup.
@@ -571,11 +566,10 @@ config RESOURCE_COUNTERS
 	help
 	  This option enables controller independent resource accounting
 	  infrastructure that works with cgroups.
-	depends on CGROUPS
 
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
-	depends on CGROUPS && RESOURCE_COUNTERS
+	depends on RESOURCE_COUNTERS
 	select MM_OWNER
 	help
 	  Provides a memory resource controller that manages both anonymous
@@ -616,7 +610,7 @@ config CGROUP_MEM_RES_CTLR_SWAP
 
 menuconfig CGROUP_SCHED
 	bool "Group CPU scheduler"
-	depends on EXPERIMENTAL && CGROUPS
+	depends on EXPERIMENTAL
 	default n
 	help
 	  This feature lets CPU scheduler recognize task groups and control CPU
@@ -645,7 +639,7 @@ endif #CGROUP_SCHED
 
 config BLK_CGROUP
 	tristate "Block IO controller"
-	depends on CGROUPS && BLOCK
+	depends on BLOCK
 	default n
 	---help---
 	Generic block IO controller cgroup interface. This is the common
-- 
1.7.0.4
