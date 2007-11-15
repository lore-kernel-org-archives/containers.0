From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [RFC PATCH 1/2] capabilities: define CONFIG_COMMONCAP
Date: Thu, 15 Nov 2007 17:16:15 -0600
Message-ID: <20071115231615.GA3851@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

From 1512a99aedb7a75ac993ccef91a42c97e1baefc5 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue@us.ibm.com>
Date: Fri, 28 Sep 2007 10:33:33 -0500
Subject: [PATCH 1/2] capabilities: define CONFIG_COMMONCAP

currently the compilation of commoncap.c is determined
through Makefile logic.  So there is no single CONFIG
variable which can be relied upon to know whether it
will be compiled.

Define CONFIG_COMMONCAP to be true when lsm is not
compiled in, or when the capability or rootplug modules
are compiled.  These are the cases when commoncap is
currently compiled.  Use this variable in security/Makefile
to determine commoncap.c's compilation.

Apart from being a logic cleanup, this is needed by the
upcoming cap_bset patch so that prctl can know whether
PR_SET_BSET should be supported.

Changelog:
	Nov 15: make CONFIG_FILE_CAPABILITIES just depend on
		COMMONCAP.  Unfortunately since rootplug doesn't
		hook cap_setxattr, it would be not quite right
		to allow CONFIG_FILE_CAPABILITIES with rootplug.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 security/Kconfig  |    6 +++++-
 security/Makefile |    9 +++------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/security/Kconfig b/security/Kconfig
index 8086e61..de7f9fe 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -80,9 +80,13 @@ config SECURITY_CAPABILITIES
 	  This enables the "default" Linux capabilities functionality.
 	  If you are unsure how to answer this question, answer Y.
 
+config COMMONCAP
+	bool
+	default !SECURITY || SECURITY_CAPABILITIES || SECURITY_ROOTPLUG
+
 config SECURITY_FILE_CAPABILITIES
 	bool "File POSIX Capabilities (EXPERIMENTAL)"
-	depends on (SECURITY=n || SECURITY_CAPABILITIES!=n) && EXPERIMENTAL
+	depends on COMMONCAP && !SECURITY_ROOTPLUG && EXPERIMENTAL
 	default n
 	help
 	  This enables filesystem capabilities, allowing you to give
diff --git a/security/Makefile b/security/Makefile
index ef87df2..7cccc81 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -5,14 +5,11 @@
 obj-$(CONFIG_KEYS)			+= keys/
 subdir-$(CONFIG_SECURITY_SELINUX)	+= selinux
 
-# if we don't select a security model, use the default capabilities
-ifneq ($(CONFIG_SECURITY),y)
-obj-y		+= commoncap.o
-endif
+obj-$(CONFIG_COMMONCAP)			+= commoncap.o
 
 # Object file lists
 obj-$(CONFIG_SECURITY)			+= security.o dummy.o inode.o
 # Must precede capability.o in order to stack properly.
 obj-$(CONFIG_SECURITY_SELINUX)		+= selinux/built-in.o
-obj-$(CONFIG_SECURITY_CAPABILITIES)	+= commoncap.o capability.o
-obj-$(CONFIG_SECURITY_ROOTPLUG)		+= commoncap.o root_plug.o
+obj-$(CONFIG_SECURITY_CAPABILITIES)	+= capability.o
+obj-$(CONFIG_SECURITY_ROOTPLUG)		+= root_plug.o
-- 
1.5.1.1.GIT

