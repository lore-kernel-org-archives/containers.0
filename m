From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] user-cr: Support kernel builds done with O=
Date: Sun, 12 Jul 2009 20:04:01 -0700
Message-ID: <20090713030401.GB5213@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

Support kernel builds such as:

	make O=../kbuild bzImage

The Makefile must differentiate between where the kernel source is and where
the build output is. The readlink test to determine KERN_ARCH is the only
part of the Makefile that relies on kernel build output at the moment.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/Makefile b/Makefile
index 0ae5fe0..f0439d4 100644
--- a/Makefile
+++ b/Makefile
@@ -1,19 +1,20 @@
 
-KERNELPATH ?= ../linux
+KERNELSRC ?= ../linux
+KERNELBUILD ?= ../linux
 
 # compile with debug ?
 DEBUG = -DCHECKPOINT_DEBUG
 
 # find linux architecure
-KERN_ARCH = $(shell readlink $(KERNELPATH)/include/asm | sed 's/^asm-//')
+KERN_ARCH = $(shell readlink $(KERNELBUILD)/include/asm | sed 's/^asm-//')
 
 # look for includes
-PATHS = -I$(KERNELPATH)/include \
-	-I$(KERNELPATH)/arch/$(KERN_ARCH)/include
+PATHS = -I$(KERNELSRC)/include \
+	-I$(KERNELSRC)/arch/$(KERN_ARCH)/include
 
 # checkpoint_hdr files
-CKPT_HDR = $(KERNELPATH)/include/linux/checkpoint_hdr.h \
-	   $(KERNELPATH)/arch/$(KERN_ARCH)/include/asm/checkpoint_hdr.h
+CKPT_HDR = $(KERNELSRC)/include/linux/checkpoint_hdr.h \
+	   $(KERNELSRC)/arch/$(KERN_ARCH)/include/asm/checkpoint_hdr.h
 
 # extra warnings and fun
 WARNS := -Wall -Wstrict-prototypes -Wno-trigraphs
-- 
1.5.6.3
