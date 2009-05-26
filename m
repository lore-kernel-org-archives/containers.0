From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 5/8] groups: allow compilation on s390x
Date: Tue, 26 May 2009 12:33:44 -0500
Message-ID: <20090526173344.GE13991@us.ibm.com>
References: <20090526173242.GA13757@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090526173242.GA13757@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 kernel/groups.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/kernel/groups.c b/kernel/groups.c
index 1b95b2f..14ebc6a 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -1,6 +1,7 @@
 /*
  * Supplementary group IDs
  */
+#include <linux/init.h>
 #include <linux/cred.h>
 #include <linux/module.h>
 #include <linux/slab.h>
-- 
1.6.1

