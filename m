From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 4/4] Kconfig: move namespace menu location after the cgroup
Date: Wed, 13 Oct 2010 11:28:45 +0200
Message-ID: <1286962125-23871-4-git-send-email-daniel.lezcano@free.fr>
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

We have the namespaces as a menuconfig like the cgroup.
The cgroup and the namespace are two base bricks for the containers.

It is more logical to put the namespace menu right after the cgroup menu.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 init/Kconfig |  104 +++++++++++++++++++++++++++++-----------------------------
 1 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 806f7d9..3445d11 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -668,58 +668,6 @@ config DEBUG_BLK_CGROUP
 
 endif # CGROUPS
 
-config MM_OWNER
-	bool
-
-config SYSFS_DEPRECATED
-	bool "enable deprecated sysfs features to support old userspace tools"
-	depends on SYSFS
-	default n
-	help
-	  This option adds code that switches the layout of the "block" class
-	  devices, to not show up in /sys/class/block/, but only in
-	  /sys/block/.
-
-	  This switch is only active when the sysfs.deprecated=1 boot option is
-	  passed or the SYSFS_DEPRECATED_V2 option is set.
-
-	  This option allows new kernels to run on old distributions and tools,
-	  which might get confused by /sys/class/block/. Since 2007/2008 all
-	  major distributions and tools handle this just fine.
-
-	  Recent distributions and userspace tools after 2009/2010 depend on
-	  the existence of /sys/class/block/, and will not work with this
-	  option enabled.
-
-	  Only if you are using a new kernel on an old distribution, you might
-	  need to say Y here.
-
-config SYSFS_DEPRECATED_V2
-	bool "enabled deprecated sysfs features by default"
-	default n
-	depends on SYSFS
-	depends on SYSFS_DEPRECATED
-	help
-	  Enable deprecated sysfs by default.
-
-	  See the CONFIG_SYSFS_DEPRECATED option for more details about this
-	  option.
-
-	  Only if you are using a new kernel on an old distribution, you might
-	  need to say Y here. Even then, odds are you would not need it
-	  enabled, you can always pass the boot option if absolutely necessary.
-
-config RELAY
-	bool "Kernel->user space relay support (formerly relayfs)"
-	help
-	  This option enables support for relay interface support in
-	  certain file systems (such as debugfs).
-	  It is designed to provide an efficient mechanism for tools and
-	  facilities to relay large amounts of data from kernel space to
-	  user space.
-
-	  If unsure, say N.
-
 menuconfig NAMESPACES
 	bool "Namespaces support" if EMBEDDED
 	default !EMBEDDED
@@ -773,6 +721,58 @@ config NET_NS
 
 endif # NAMESPACES
 
+config MM_OWNER
+	bool
+
+config SYSFS_DEPRECATED
+	bool "enable deprecated sysfs features to support old userspace tools"
+	depends on SYSFS
+	default n
+	help
+	  This option adds code that switches the layout of the "block" class
+	  devices, to not show up in /sys/class/block/, but only in
+	  /sys/block/.
+
+	  This switch is only active when the sysfs.deprecated=1 boot option is
+	  passed or the SYSFS_DEPRECATED_V2 option is set.
+
+	  This option allows new kernels to run on old distributions and tools,
+	  which might get confused by /sys/class/block/. Since 2007/2008 all
+	  major distributions and tools handle this just fine.
+
+	  Recent distributions and userspace tools after 2009/2010 depend on
+	  the existence of /sys/class/block/, and will not work with this
+	  option enabled.
+
+	  Only if you are using a new kernel on an old distribution, you might
+	  need to say Y here.
+
+config SYSFS_DEPRECATED_V2
+	bool "enabled deprecated sysfs features by default"
+	default n
+	depends on SYSFS
+	depends on SYSFS_DEPRECATED
+	help
+	  Enable deprecated sysfs by default.
+
+	  See the CONFIG_SYSFS_DEPRECATED option for more details about this
+	  option.
+
+	  Only if you are using a new kernel on an old distribution, you might
+	  need to say Y here. Even then, odds are you would not need it
+	  enabled, you can always pass the boot option if absolutely necessary.
+
+config RELAY
+	bool "Kernel->user space relay support (formerly relayfs)"
+	help
+	  This option enables support for relay interface support in
+	  certain file systems (such as debugfs).
+	  It is designed to provide an efficient mechanism for tools and
+	  facilities to relay large amounts of data from kernel space to
+	  user space.
+
+	  If unsure, say N.
+
 config BLK_DEV_INITRD
 	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
 	depends on BROKEN || !FRV
-- 
1.7.0.4
