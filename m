From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/6] Container Freezer: Fix freezer Kconfig
Date: Tue, 19 Aug 2008 16:22:33 -0700
Message-ID: <20080819232233.028111599__9201.77729935876$1219188569$gmane$org@us.ibm.com>
References: <20080819232232.432973784@us.ibm.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

kernel/power/Kconfig is not sourced from all architectures but the freezer code
should be available to all architectures for the cgroup freezer subsystem.
Sourcing a new kernel/Kconfig.freezer has the added advantage of keeping the
config definition close to its use in the kernel/Makefile.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
---
This patch should probably be merged with the patch that put:
config FREEZER
in kernel/power/Kconfig

 arch/alpha/Kconfig     |    1 +
 arch/arm/Kconfig       |    2 ++
 arch/avr32/Kconfig     |    2 ++
 arch/blackfin/Kconfig  |    3 +++
 arch/cris/Kconfig      |    2 ++
 arch/frv/Kconfig       |    2 ++
 arch/h8300/Kconfig     |    2 ++
 arch/ia64/Kconfig      |    2 ++
 arch/m32r/Kconfig      |    2 ++
 arch/m68k/Kconfig      |    2 ++
 arch/m68knommu/Kconfig |    2 ++
 arch/mips/Kconfig      |    2 ++
 arch/mn10300/Kconfig   |    2 ++
 arch/parisc/Kconfig    |    2 ++
 arch/powerpc/Kconfig   |    2 ++
 arch/s390/Kconfig      |    2 ++
 arch/sh/Kconfig        |    2 ++
 arch/sparc/Kconfig     |    2 ++
 arch/sparc64/Kconfig   |    1 +
 arch/um/Kconfig        |    2 ++
 arch/x86/Kconfig       |    1 +
 arch/xtensa/Kconfig    |    1 +
 kernel/Kconfig.freezer |    2 ++
 kernel/power/Kconfig   |    3 ---
 24 files changed, 43 insertions(+), 3 deletions(-)

Index: linux-2.6.27-rc1-mm1/kernel/Kconfig.freezer
===================================================================
--- /dev/null
+++ linux-2.6.27-rc1-mm1/kernel/Kconfig.freezer
@@ -0,0 +1,2 @@
+config FREEZER
+	def_bool PM_SLEEP || CGROUP_FREEZER
Index: linux-2.6.27-rc1-mm1/kernel/power/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/kernel/power/Kconfig
+++ linux-2.6.27-rc1-mm1/kernel/power/Kconfig
@@ -85,9 +85,6 @@ config PM_SLEEP
 	depends on SUSPEND || HIBERNATION || XEN_SAVE_RESTORE
 	default y
 
-config FREEZER
-	def_bool PM_SLEEP || CGROUP_FREEZER
-
 config SUSPEND
 	bool "Suspend to RAM and standby"
 	depends on PM && ARCH_SUSPEND_POSSIBLE
Index: linux-2.6.27-rc1-mm1/arch/x86/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/x86/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/x86/Kconfig
@@ -206,6 +206,7 @@ config X86_TRAMPOLINE
 config KTIME_SCALAR
 	def_bool X86_32
 source "init/Kconfig"
+source "kernel/Kconfig.freezer"
 
 menu "Processor type and features"
 
Index: linux-2.6.27-rc1-mm1/arch/alpha/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/alpha/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/alpha/Kconfig
@@ -72,6 +72,7 @@ config ARCH_SUPPORTS_AOUT
 	def_bool y
 
 source "init/Kconfig"
+source "kernel/Kconfig.freezer"
 
 
 menu "System setup"
Index: linux-2.6.27-rc1-mm1/arch/arm/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/arm/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/arm/Kconfig
@@ -190,6 +190,8 @@ config VECTORS_BASE
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "System Type"
 
 choice
Index: linux-2.6.27-rc1-mm1/arch/avr32/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/avr32/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/avr32/Kconfig
@@ -72,6 +72,8 @@ config GENERIC_BUG
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "System Type and features"
 
 source "kernel/time/Kconfig"
Index: linux-2.6.27-rc1-mm1/arch/blackfin/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/blackfin/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/blackfin/Kconfig
@@ -64,8 +64,11 @@ config HARDWARE_PM
 	depends on OPROFILE
 
 source "init/Kconfig"
+
 source "kernel/Kconfig.preempt"
 
+source "kernel/Kconfig.freezer"
+
 menu "Blackfin Processor Options"
 
 comment "Processor and Board Settings"
Index: linux-2.6.27-rc1-mm1/arch/cris/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/cris/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/cris/Kconfig
@@ -62,6 +62,8 @@ config HZ
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "General setup"
 
 source "fs/Kconfig.binfmt"
Index: linux-2.6.27-rc1-mm1/arch/frv/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/frv/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/frv/Kconfig
@@ -66,6 +66,8 @@ mainmenu "Fujitsu FR-V Kernel Configurat
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 
 menu "Fujitsu FR-V system setup"
 
Index: linux-2.6.27-rc1-mm1/arch/h8300/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/h8300/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/h8300/Kconfig
@@ -89,6 +89,8 @@ config HZ
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 source "arch/h8300/Kconfig.cpu"
 
 menu "Executable file formats"
Index: linux-2.6.27-rc1-mm1/arch/ia64/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/ia64/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/ia64/Kconfig
@@ -7,6 +7,8 @@ mainmenu "IA-64 Linux Kernel Configurati
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "Processor type and features"
 
 config IA64
Index: linux-2.6.27-rc1-mm1/arch/m32r/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/m32r/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/m32r/Kconfig
@@ -45,6 +45,8 @@ config HZ
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 
 menu "Processor type and features"
 
Index: linux-2.6.27-rc1-mm1/arch/m68k/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/m68k/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/m68k/Kconfig
@@ -64,6 +64,8 @@ mainmenu "Linux/68k Kernel Configuration
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "Platform dependent setup"
 
 config EISA
Index: linux-2.6.27-rc1-mm1/arch/m68knommu/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/m68knommu/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/m68knommu/Kconfig
@@ -78,6 +78,8 @@ config ARCH_SUPPORTS_AOUT
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "Processor type and features"
 
 choice
Index: linux-2.6.27-rc1-mm1/arch/mips/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/mips/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/mips/Kconfig
@@ -1886,6 +1886,8 @@ config STACKTRACE_SUPPORT
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "Bus options (PCI, PCMCIA, EISA, ISA, TC)"
 
 config HW_HAS_EISA
Index: linux-2.6.27-rc1-mm1/arch/mn10300/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/mn10300/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/mn10300/Kconfig
@@ -71,6 +71,8 @@ mainmenu "Matsushita MN10300/AM33 Kernel
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 
 menu "Matsushita MN10300 system setup"
 
Index: linux-2.6.27-rc1-mm1/arch/parisc/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/parisc/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/parisc/Kconfig
@@ -93,6 +93,8 @@ config ARCH_MAY_HAVE_PC_FDC
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 
 menu "Processor type and features"
 
Index: linux-2.6.27-rc1-mm1/arch/powerpc/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/powerpc/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/powerpc/Kconfig
@@ -230,6 +230,8 @@ config PPC_OF_PLATFORM_PCI
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 source "arch/powerpc/sysdev/Kconfig"
 source "arch/powerpc/platforms/Kconfig"
 
Index: linux-2.6.27-rc1-mm1/arch/s390/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/s390/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/s390/Kconfig
@@ -77,6 +77,8 @@ config S390
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "Base setup"
 
 comment "Processor type and features"
Index: linux-2.6.27-rc1-mm1/arch/sh/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/sh/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/sh/Kconfig
@@ -102,6 +102,8 @@ config IO_TRAPPED
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "System type"
 
 #
Index: linux-2.6.27-rc1-mm1/arch/sparc/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/sparc/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/sparc/Kconfig
@@ -32,6 +32,8 @@ config HZ
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 menu "General machine setup"
 
 config SMP
Index: linux-2.6.27-rc1-mm1/arch/sparc64/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/sparc64/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/sparc64/Kconfig
@@ -84,6 +84,7 @@ config GENERIC_HARDIRQS_NO__DO_IRQ
 	def_bool y
 
 source "init/Kconfig"
+source "kernel/Kconfig.freezer"
 
 menu "Processor type and features"
 
Index: linux-2.6.27-rc1-mm1/arch/um/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/um/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/um/Kconfig
@@ -229,6 +229,8 @@ endmenu
 
 source "init/Kconfig"
 
+source "kernel/Kconfig.freezer"
+
 source "drivers/block/Kconfig"
 
 source "arch/um/Kconfig.char"
Index: linux-2.6.27-rc1-mm1/arch/xtensa/Kconfig
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/xtensa/Kconfig
+++ linux-2.6.27-rc1-mm1/arch/xtensa/Kconfig
@@ -55,6 +55,7 @@ config HZ
 	default 100
 
 source "init/Kconfig"
+source "kernel/Kconfig.freezer"
 
 menu "Processor type and features"
 

-- 
