From: "Michael J. Coss" <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
Subject: [PATCH 3/3] net/udevns: Netlink module to forward uevent to containers
Date: Wed,  9 Sep 2015 14:53:13 -0400
Message-ID: <dba3687ebebd6744710cd9a1d6f39b1fa01dfd87.1441762578.git.michael.coss__39085.5799116709$1441824871$gmane$org@alcatel-lucent.com>
References: <cover.1441762578.git.michael.coss@alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1441762578.git.michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
Cc: "Michael J. Coss" <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

New generic netlink module to provide an interface with the new
forwarding interface for uevent.  The driver allows a user to
direct a uevent as read from the kernel to a specific network
namespace by providing the uevent message, and a target process id.
The uapi header file provides the message format.

Signed-off-by: Michael J. Coss <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
---
 include/uapi/linux/Kbuild   |   1 +
 include/uapi/linux/udevns.h |  19 ++++++++
 net/Kconfig                 |   1 +
 net/Makefile                |   1 +
 net/udevns/Kconfig          |   9 ++++
 net/udevns/Makefile         |   5 ++
 net/udevns/udevns.c         | 112 ++++++++++++++++++++++++++++++++++++++++++++
 net/udevns/udevns.h         |  19 ++++++++
 8 files changed, 167 insertions(+)
 create mode 100644 include/uapi/linux/udevns.h
 create mode 100644 net/udevns/Kconfig
 create mode 100644 net/udevns/Makefile
 create mode 100644 net/udevns/udevns.c
 create mode 100644 net/udevns/udevns.h

diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 1ff9942..9fb9c59 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -404,6 +404,7 @@ header-y += toshiba.h
 header-y += tty_flags.h
 header-y += tty.h
 header-y += types.h
+header-y += udevns.h
 header-y += udf_fs_i.h
 header-y += udp.h
 header-y += uhid.h
diff --git a/include/uapi/linux/udevns.h b/include/uapi/linux/udevns.h
new file mode 100644
index 0000000..f5702f5
--- /dev/null
+++ b/include/uapi/linux/udevns.h
@@ -0,0 +1,19 @@
+#ifndef _UDEVNS_H_
+#define _UDEVNS_H_
+
+enum udevns_msg_types {
+	UDEVNS_FORWARD_MSG = 0x1,
+	UDEVNS_CMD_MAX,
+};
+
+enum udevns_attr {
+	UDEVNS_UNSPEC,
+	UDEVNS_PID,
+	UDEVNS_MSG,
+	__UDEVNS_ATTR_MAX,
+};
+
+#define UDEVNS_ATTR_MAX (__UDEVNS_ATTR_MAX - 1)
+#define UDEVNS_VERSION 0x1
+
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index 57a7c5a..465e288 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -54,6 +54,7 @@ source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
 source "net/iucv/Kconfig"
+source "net/udevns/Kconfig"
 
 config INET
 	bool "TCP/IP networking"
diff --git a/net/Makefile b/net/Makefile
index 3995613..bde7775 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -74,3 +74,4 @@ obj-$(CONFIG_HSR)		+= hsr/
 ifneq ($(CONFIG_NET_SWITCHDEV),)
 obj-y				+= switchdev/
 endif
+obj-$(CONFIG_UDEVNS)	+= udevns/
diff --git a/net/udevns/Kconfig b/net/udevns/Kconfig
new file mode 100644
index 0000000..367e650
--- /dev/null
+++ b/net/udevns/Kconfig
@@ -0,0 +1,9 @@
+config UDEVNS
+	tristate "UDEV namespace bridge"
+	depends on SYSFS
+	default n
+	help
+		This option enables support for explicit forwarding of UDEV events to
+		other network namespaces
+
+		If unsure, say N.
diff --git a/net/udevns/Makefile b/net/udevns/Makefile
new file mode 100644
index 0000000..44c6b12
--- /dev/null
+++ b/net/udevns/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the uevent namespace aware forwarder
+#
+#
+obj-$(CONFIG_UDEVNS) += udevns.o
diff --git a/net/udevns/udevns.c b/net/udevns/udevns.c
new file mode 100644
index 0000000..8b23751
--- /dev/null
+++ b/net/udevns/udevns.c
@@ -0,0 +1,112 @@
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <net/sock.h>
+#include <net/genetlink.h>
+#include <linux/netlink.h>
+#include <linux/skbuff.h>
+#include <linux/fs.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
+
+#include "udevns.h"
+
+#define DRIVER_AUTHOR "Michael J Coss <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>"
+#define DRIVER_DESC   "new udev namespace bridge"
+#define DEVICE_NAME   "udevns"
+
+#ifdef MODULE
+#define UDEVNS_NAME (THIS_MODULE->name)
+#else
+#define UDEVNS_NAME "udevns"
+#endif
+
+#define UDEVNS_INFO(fmt, args...)                                       \
+	pr_info("[%s] " fmt, UDEVNS_NAME, ## args)
+
+#define UDEVNS_ERROR(fmt, args...)                                      \
+	pr_err("[ERROR:%s:%s] " fmt, UDEVNS_NAME, __func__, ## args)
+
+#define UDEVNS_WARNING(fmt, args...)                                    \
+	pr_warn("[WARNING:%s:%s] " fmt, UDEVNS_NAME, __func__, ## args)
+
+static struct genl_family udevns_genl_family = {
+	.id      = GENL_ID_GENERATE,
+	.name    = DEVICE_NAME,
+	.hdrsize = 0,
+	.version = UDEVNS_VERSION,
+	.maxattr = UDEVNS_ATTR_MAX,
+};
+
+static const struct nla_policy udevns_fmsgpolicy[UDEVNS_ATTR_MAX + 1] = {
+	[UDEVNS_PID] = { .type = NLA_U32 },
+	[UDEVNS_MSG] = { .type = NLA_STRING, .len =  UEVENT_BUFFER_SIZE},
+};
+
+static int udevns_forwardmsg(struct sk_buff *skb, struct genl_info *info)
+{
+	pid_t pid;
+	char *msg;
+	int msglen;
+	int err;
+
+	if (!info->attrs[UDEVNS_PID]) {
+		UDEVNS_WARNING("missing PID from UDEVNS_FORWARD_MSG.\n");
+		return -EINVAL;
+	}
+
+	if (!info->attrs[UDEVNS_MSG]) {
+		UDEVNS_WARNING("missing uevent from UDEVNS_FORWARD_MSG.\n");
+		return -EINVAL;
+	}
+
+	pid = nla_get_u32(info->attrs[UDEVNS_PID]);
+	msg = nla_data(info->attrs[UDEVNS_MSG]);
+	msglen = nla_len(info->attrs[UDEVNS_MSG]);
+
+	if (msglen < 0) {
+		UDEVNS_ERROR("Malformed uevent from UDEVNS_FORWARD_MSG.\n");
+		return -EINVAL;
+	}
+
+	err = kobject_uevent_forward(msg, msglen, pid);
+	return err;
+}
+
+static struct genl_ops udevns_genl_ops[] = {
+	{
+		.cmd    = UDEVNS_FORWARD_MSG,
+		.flags  = GENL_ADMIN_PERM,
+		.doit   = udevns_forwardmsg,
+		.policy = udevns_fmsgpolicy,
+	},
+};
+
+static int __init udevns_init(void)
+{
+	int rc;
+
+	UDEVNS_INFO("Starting udevns module\n");
+	rc = genl_register_family_with_ops(&udevns_genl_family,
+					   udevns_genl_ops);
+	if (rc) {
+		UDEVNS_ERROR("Failed to register netlink interface\n");
+		return rc;
+	}
+	return 0;
+}
+
+static void __exit udevns_exit(void)
+{
+	UDEVNS_INFO("Exiting udevns module\n");
+	genl_unregister_family(&udevns_genl_family);
+}
+
+module_init(udevns_init);
+module_exit(udevns_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION(DRIVER_DESC);
+MODULE_AUTHOR(DRIVER_AUTHOR);
diff --git a/net/udevns/udevns.h b/net/udevns/udevns.h
new file mode 100644
index 0000000..f5702f5
--- /dev/null
+++ b/net/udevns/udevns.h
@@ -0,0 +1,19 @@
+#ifndef _UDEVNS_H_
+#define _UDEVNS_H_
+
+enum udevns_msg_types {
+	UDEVNS_FORWARD_MSG = 0x1,
+	UDEVNS_CMD_MAX,
+};
+
+enum udevns_attr {
+	UDEVNS_UNSPEC,
+	UDEVNS_PID,
+	UDEVNS_MSG,
+	__UDEVNS_ATTR_MAX,
+};
+
+#define UDEVNS_ATTR_MAX (__UDEVNS_ATTR_MAX - 1)
+#define UDEVNS_VERSION 0x1
+
+#endif
-- 
2.4.6
