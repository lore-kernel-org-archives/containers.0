From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/3] capabilities: define CONFIG_COMMONCAP
Date: Mon, 1 Oct 2007 09:41:20 -0500
Message-ID: <20071001144120.GA25345@sergelap.austin.ibm.com>
References: <20071001144031.GA24683@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071001144031.GA24683@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: containers@lists.osdl.org
Cc: Andrew Morgan <morgan@kernel.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

From 3bba066917dd4a8a7c368ee1d2e163c3d619bb92 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue@us.ibm.com>
Date: Fri, 28 Sep 2007 10:33:33 -0500
Subject: [PATCH 1/3] capabilities: define CONFIG_COMMONCAP

currently the compilation of commoncap.c is determined
through Makefile logic.  So there is no single CONFIG
variable which can be relied upon to know whether it
will be compiled.

Define CONFIG_COMMONCAP to be true when lsm is not
compiled in, or when the capability or rootplug modules
are compiled.  These are thr cases when commoncap is
currently compiled.  Use this variable in security/Makefile
to determinr commoncap.c's compilation.

Apart from being a logic cleanup, this is needed by the
upcoming cap_bset patch so that prctl can know whether
PR_SET_BSET should be allowed.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 security/Kconfig  |    4 ++++
 security/Makefile |    9 +++------
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/security/Kconfig b/security/Kconfig
index 8086e61..02b33fa 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -103,6 +103,10 @@ config SECURITY_ROOTPLUG
 	  
 	  If you are unsure how to answer this question, answer N.
 
+config COMMONCAP
+	bool
+	default !SECURITY || SECURITY_CAPABILITIES || SECURITY_ROOTPLUG
+
 source security/selinux/Kconfig
 
 endmenu
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
1.5.1.6

