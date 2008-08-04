From: "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Subject: [PATCH] CGROUPS:  Group the CGROUPS Kconfig entries to be consecutive.
Date: Mon, 4 Aug 2008 12:16:05 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0808041213540.2600@localhost.localdomain>
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


Move a few CGROUPS-related Kconfig entries so that they appear
consecutively when running "make menuconfig."  This shouldn't affect
the functionality.

Signed-off-by: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>

---

diff --git a/init/Kconfig b/init/Kconfig
index 7e6dae1..b51c133 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -317,6 +317,42 @@ config CPUSETS

 	  Say N if unsure.

+config CGROUP_CPUACCT
+	bool "Simple CPU accounting cgroup subsystem"
+	depends on CGROUPS
+	help
+	  Provides a simple Resource Controller for monitoring the
+	  total CPU consumed by the tasks in a cgroup
+
+config RESOURCE_COUNTERS
+	bool "Resource counters"
+	help
+	  This option enables controller independent resource accounting
+          infrastructure that works with cgroups
+	depends on CGROUPS
+
+config CGROUP_MEM_RES_CTLR
+	bool "Memory Resource Controller for Control Groups"
+	depends on CGROUPS && RESOURCE_COUNTERS
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
