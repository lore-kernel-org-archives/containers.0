From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/18] user-cr: cross-compile: Enable proper cross compilation
Date: Thu, 17 Mar 2011 10:27:36 -0700
Message-ID: <143894c882d1339322b36ea459531a7debec7f29.1300382276.git.matthltc@us.ibm.com>
References: <1300382870-28486-1-git-send-email-matthltc@us.ibm.com>
	<beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc@us.ibm.com>
	<1525d5365ced342871277f7a94a42bcd960c04a9.1300382276.git.matthltc@us.ibm.com>
	<ccf68c276e54e7cb9dce0df9b8fec8391dd0e349.1300382276.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ccf68c276e54e7cb9dce0df9b8fec8391dd0e349.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile      |    7 +++++++
 test/Makefile |    2 ++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/Makefile b/Makefile
index 0932519..d4558be 100644
--- a/Makefile
+++ b/Makefile
@@ -8,6 +8,13 @@
 
 KERNELSRC ?= ../linux
 
+# Prefix CC, AS, LD, AR for cross compilation
+CROSS_COMPILE ?=
+CC := $(CROSS_COMPILE)gcc
+LD := $(CROSS_COMPILE)ld
+AS := $(CROSS_COMPILE)as
+AR := $(CROSS_COMPILE)ar
+
 CKPT_INCLUDE = -I./include
 CKPT_HEADERS = include/linux/checkpoint.h \
 		include/linux/checkpoint_hdr.h \
diff --git a/test/Makefile b/test/Makefile
index 898e426..92482f2 100644
--- a/test/Makefile
+++ b/test/Makefile
@@ -1,4 +1,6 @@
 # handle cross-compilation
+# Prefix CC, AS, LD, AR for cross compilation
+CROSS_COMPILE ?=
 AR  := ${CROSS_COMPILE}ar
 AS  := ${CROSS_COMPILE}as
 CC  := ${CROSS_COMPILE}gcc
-- 
1.6.3.3
