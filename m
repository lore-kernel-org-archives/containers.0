From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/9] cred: #include init.h in cred.h
Date: Fri, 29 May 2009 17:32:48 -0500
Message-ID: <20090529223248.GA14602@us.ibm.com>
References: <20090529223229.GA14536@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090529223229.GA14536@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morgan <morgan@kernel.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

cred.h can't be included as first header because it uses __init and
doesn't include init.h which is enough to break compilation on at least
ia64.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/cred.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 3282ee4..4fa9996 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -13,6 +13,7 @@
 #define _LINUX_CRED_H
 
 #include <linux/capability.h>
+#include <linux/init.h>
 #include <linux/key.h>
 #include <asm/atomic.h>
 
-- 
1.6.1

