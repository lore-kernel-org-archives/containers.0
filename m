From: Paul Menage <menage@google.com>
Subject: [PATCH 19/33] containers implement namespace tracking subsystem fix order of container subsystems in init kconfig
Date: Mon, 17 Sep 2007 14:03:26 -0700
Message-ID: <20070917210429.199259000@menage.corp.google.com>
References: <20070917210307.116234000@menage.corp.google.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760872AbXIQVPs@vger.kernel.org>
Content-Disposition: inline; filename=containers-implement-namespace-tracking-subsystem-fix-order-of-container-subsystems-in-init-kconfig.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linuxfoundation.org, balbir@linux.vnet.ibm.com, "Serge E. Hallyn" <serue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, pj@sgi.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

From: Cedric Le Goater <clg@fr.ibm.com>
(container->cgroup renaming by Paul Menage <menage@google.com>)

some cosmetic changes to init/Kconfig to make the subsystem list
under cgroups look nicer when CONFIG_CGROUPS=y.

also changed the 'select' to 'depends on' for the namespace
subsystem.

Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
Signed-off-by: Paul Menage <menage@google.com>
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
