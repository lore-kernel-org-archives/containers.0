From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 2/4] containers: add CAP_NS_OVERRIDE capability
Date: Mon, 28 Jan 2008 13:09:40 -0600
Message-ID: <20080128190940.GC8909@sergelap.austin.ibm.com>
References: <20080128190828.GA8909@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080128190828.GA8909@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

From ce1cf14000860f82ab59a5253bbe468da767e77f Mon Sep 17 00:00:00 2001
From: sergeh@us.ibm.com <sergeh@us.ibm.com>
Date: Wed, 28 Nov 2007 18:52:28 -0800
Subject: [PATCH 2/4] containers: add CAP_NS_OVERRIDE capability

containers: add CAP_NS_OVERRIDE capability

Signed-off-by: sergeh@us.ibm.com <hallyn@kernel.(none)>
---
 include/linux/capability.h |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 7d50ff6..58bc24e 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -332,7 +332,14 @@ typedef struct kernel_cap_struct {
 
 #define CAP_MAC_ADMIN        33
 
-#define CAP_LAST_CAP         CAP_MAC_ADMIN
+/* Allow acting on resources in another namespace.  In
+   particular:
+      1. when combined with CAP_KILL, kill users in another
+         user namespace
+ */
+#define CAP_NS_OVERRIDE      34
+
+#define CAP_LAST_CAP         CAP_NS_OVERRIDE
 
 #define cap_valid(x) ((x) >= 0 && (x) <= CAP_LAST_CAP)
 
-- 
1.5.1

