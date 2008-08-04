From: "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Subject: [PATCH] (Revised) CGROUPS:  Collect CGROUPS-related Kconfig entries
	together.
Date: Mon, 4 Aug 2008 13:20:11 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0808041316130.5120@localhost.localdomain>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Rearrange the CGROUPS-related Kconfig entries in init/Kconfig so that
they're consecutive, and simplify the dependencies by using a
"menuconfig" directive.  This shouldn't affect the underlying
functionality.

Signed-off-by: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>

---

  sorry, i just realized that it would be even cleaner to use a
"menuconfig" directive to reduce the number of repetitive
dependencies.

diff --git a/init/Kconfig b/init/Kconfig
index 7e6dae1..5fe5baf 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -271,7 +271,7 @@ config LOG_BUF_SHIFT
 		     13 =>  8 KB
 		     12 =>  4 KB

-config CGROUPS
+menuconfig CGROUPS
 	bool "Control Group support"
 	help
 	  This option will let you use process cgroup subsystems
@@ -279,9 +279,10 @@ config CGROUPS

 	  Say N if unsure.

+if CGROUPS
+
 config CGROUP_DEBUG
 	bool "Example debug cgroup subsystem"
-	depends on CGROUPS
 	default n
 	help
 	  This option enables a simple cgroup subsystem that
@@ -292,7 +293,6 @@ config CGROUP_DEBUG

 config CGROUP_NS
         bool "Namespace cgroup subsystem"
-        depends on CGROUPS
         help
           Provides a simple namespace cgroup subsystem to
           provide hierarchical naming of sets of namespaces,
@@ -301,14 +301,14 @@ config CGROUP_NS

 config CGROUP_DEVICE
 	bool "Device controller for cgroups"
-	depends on CGROUPS && EXPERIMENTAL
+	depends on EXPERIMENTAL
 	help
 	  Provides a cgroup implementing whitelists for devices which
 	  a process in the cgroup can mknod or open.

 config CPUSETS
 	bool "Cpuset support"
-	depends on SMP && CGROUPS
+	depends on SMP
 	help
 	  This option will let you create and manage CPUSETs which
 	  allow dynamically partitioning a system into sets of CPUs and
@@ -317,6 +317,42 @@ config CPUSETS

 	  Say N if unsure.

+config CGROUP_CPUACCT
+	bool "Simple CPU accounting cgroup subsystem"
+	help
+	  Provides a simple Resource Controller for monitoring the
+	  total CPU consumed by the tasks in a cgroup
+
+config RESOURCE_COUNTERS
+	bool "Resource counters"
+	help
+	  This option enables controller independent resource accounting
+          infrastructure that works with cgroups
+
+config CGROUP_MEM_RES_CTLR
+	bool "Memory Resource Controller for Control Groups"
+	depends on RESOURCE_COUNTERS
+	select MM_OWNER
+	help
+	  Provides a memory resource controller that manages both page cache and
+	  RSS memory.
+
+	  Note that setting this option increases fixed memory overhead
+	  associated with each page of memory in the system by 4/8 bytes
+	  and also increases cache misses because struct page on many 64bit
+	  systems will not fit into a single cache line anymore.
+
+	  Only enable when you're ok with these trade offs and really
+	  sure you need the memory resource controller.
+
+	  This config option also selects MM_OWNER config option, which
+	  could in turn add some fork/exit overhead.
+
+config MM_OWNER
+	bool
+
+endif # CGROUPS
+
 #
 # Architectures with an unreliable sched_clock() should select this:
 #
@@ -372,42 +408,6 @@ config CGROUP_SCHED

 endchoice

-config CGROUP_CPUACCT
-	bool "Simple CPU accounting cgroup subsystem"
-	depends on CGROUPS
-	help
-	  Provides a simple Resource Controller for monitoring the
-	  total CPU consumed by the tasks in a cgroup
-
-config RESOURCE_COUNTERS
-	bool "Resource counters"
-	help
-	  This option enables controller independent resource accounting
-          infrastructure that works with cgroups
-	depends on CGROUPS
-
-config MM_OWNER
-	bool
-
-config CGROUP_MEM_RES_CTLR
-	bool "Memory Resource Controller for Control Groups"
-	depends on CGROUPS && RESOURCE_COUNTERS
-	select MM_OWNER
-	help
-	  Provides a memory resource controller that manages both page cache and
-	  RSS memory.
-
-	  Note that setting this option increases fixed memory overhead
-	  associated with each page of memory in the system by 4/8 bytes
-	  and also increases cache misses because struct page on many 64bit
-	  systems will not fit into a single cache line anymore.
-
-	  Only enable when you're ok with these trade offs and really
-	  sure you need the memory resource controller.
-
-	  This config option also selects MM_OWNER config option, which
-	  could in turn add some fork/exit overhead.
-
 config SYSFS_DEPRECATED
 	bool



========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
