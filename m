From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Make kernel source path configurable
Date: Wed, 28 Jan 2009 18:15:28 -0800
Message-ID: <20090129021528.22655.32316.stgit@crlf.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Add an optional argument to the user-cs Makefile called KERNELPATH that allows
one to specify the path for kernel sources to use for the build.

Signed-off-by: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---

 Makefile |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Makefile b/Makefile
index 151d006..52cbfee 100644
--- a/Makefile
+++ b/Makefile
@@ -1,13 +1,13 @@
-
+KERNELPATH ?= ../linux
 # compile with debug ?
 DEBUG = -DCHECKPOINT_DEBUG
 
 # find linux architecure
-KERN_ARCH = $(shell readlink ../linux/include/asm | sed 's/^asm-//')
+KERN_ARCH = $(shell readlink $(KERNELPATH)/include/asm | sed 's/^asm-//')
 
 # look for includes
-PATHS = -I../linux/include \
-	-I../linux/arch/$(KERN_ARCH)/include
+PATHS = -I$(KERNELPATH)/include \
+	-I$(KERNELPATH)/arch/$(KERN_ARCH)/include
 
 # extra warnings and fun
 WARNS := -Wall -Wstrict-prototypes -Wno-trigraphs
