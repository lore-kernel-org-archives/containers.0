From: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 17/29] containers implement namespace tracking subsystem fix
	order of container subsystems in init kconfig
Date: Tue, 11 Sep 2007 12:52:56 -0700
Message-ID: <20070911200147.417900000@menage.corp.google.com>
References: <20070911195239.997111000@menage.corp.google.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=containers-implement-namespace-tracking-subsystem-fix-order-of-container-subsystems-in-init-kconfig.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

some cosmetic changes to init/Kconfig to make the subsystem list
under cgroups look nicer when CONFIG_CGROUPS=y.

also changed the 'select' to 'depends on' for the namespace
subsystem.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---

 init/Kconfig |   32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff -puN init/Kconfig~cgroups-implement-namespace-tracking-subsystem-fix-order-of-cgroup-subsystems-in-init-kconfig init/Kconfig
--- a/init/Kconfig~cgroups-implement-namespace-tracking-subsystem-fix-order-of-cgroup-subsystems-in-init-kconfig
+++ a/init/Kconfig
@@ -292,6 +292,22 @@ config CGROUP_DEBUG
 
 	  Say N if unsure
 
+config CGROUP_NS
+        bool "Namespace cgroup subsystem"
+        depends on CGROUPS
+        help
+          Provides a simple namespace cgroup subsystem to
+          provide hierarchical naming of sets of namespaces,
+          for instance virtual servers and checkpoint/restart
+          jobs.
+
+config CGROUP_CPUACCT
+	bool "Simple CPU accounting cgroup subsystem"
+	depends on CGROUPS
+	help
+	  Provides a simple Resource Controller for monitoring the
+	  total CPU consumed by the tasks in a cgroup
+
 config CPUSETS
 	bool "Cpuset support"
 	depends on SMP && CGROUPS
@@ -323,27 +339,11 @@ config SYSFS_DEPRECATED
 	  If you are using a distro that was released in 2006 or later,
 	  it should be safe to say N here.
 
-config CGROUP_NS
-        bool "Namespace cgroup subsystem"
-        select CGROUPS
-        help
-          Provides a simple namespace cgroup subsystem to
-          provide hierarchical naming of sets of namespaces,
-          for instance virtual servers and checkpoint/restart
-          jobs.
-
 config PROC_PID_CPUSET
 	bool "Include legacy /proc/<pid>/cpuset file"
 	depends on CPUSETS
 	default y
 
-config CGROUP_CPUACCT
-	bool "Simple CPU accounting cgroup subsystem"
-	depends on CGROUPS
-	help
-	  Provides a simple Resource Controller for monitoring the
-	  total CPU consumed by the tasks in a cgroup
-
 config RELAY
 	bool "Kernel->user space relay support (formerly relayfs)"
 	help
_

--
