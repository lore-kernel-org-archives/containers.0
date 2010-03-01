From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH user-cr] User can override SUBARCH for cross-compilation
Date: Mon,  1 Mar 2010 10:50:06 -0500
Message-ID: <1267458606-1622-1-git-send-email-orenl@cs.columbia.edu>
References: <1267217669.15300.118.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267217669.15300.118.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Detecting the architecture via uname is fine as long as the user is
able to override it (make SUBARCH=foo).

Signed-of-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 Makefile |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index 60ddccd..64b5f73 100644
--- a/Makefile
+++ b/Makefile
@@ -1,3 +1,11 @@
+# *DOCUMENTATION*
+#
+# List of environment variables that may be set by caller:
+#  KERNELSRC	- path of kernel sources (def: ../linux)
+#  SUBARCH	- sub-architecture (def: extract with 'uname')
+#  PREFIX	- prefix path for installation (def: /usr/local)
+#
+
 KERNELSRC ?= ../linux
 
 CKPT_INCLUDE = -I./include
@@ -6,7 +14,7 @@ CKPT_HEADERS = include/linux/checkpoint.h \
 		include/asm/checkpoint_hdr.h
 
 # detect architecture (for eclone)
-SUBARCH = $(patsubst i%86,x86_32,$(shell uname -m))
+SUBARCH ?= $(patsubst i%86,x86_32,$(shell uname -m))
 
 # compile with debug ?
 DEBUG = -DCHECKPOINT_DEBUG
-- 
1.6.3.3
