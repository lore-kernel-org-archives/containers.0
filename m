From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] user-cr: Makefile: Use standard variables
Date: Fri, 26 Feb 2010 11:44:52 -0800
Message-ID: <92a207e405307fe1dc528f59e08782985830d5e9.1267213393.git.matthltc@us.ibm.com>
References: <1267210602-11444-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267210602-11444-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <1267210602-11444-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux-Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

[Based on the previous series of Makefile patches]

These are standard variables which many cross compiler systems will setup.
I believe they are also variables Make sets up with default values.
Make also sets $(MAKE) so you don't accidentally mix make binaries in the
same build -- let's use that too.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Makefile |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Makefile b/Makefile
index a4a1a8a..60ddccd 100644
--- a/Makefile
+++ b/Makefile
@@ -34,10 +34,10 @@ LDLIBS = -lm
 .PHONY: all distclean clean headers install
 
 all: $(PROGS)
-	@make -C test
+	@$(MAKE) -C test
 
 $(LIB_ECLONE):
-	ar ruv $(LIB_ECLONE) $^
+	$(AR) ruv $(LIB_ECLONE) $^
 
 # restart needs to be thread-safe
 restart: CFLAGS += -D__REENTRANT -pthread
@@ -82,4 +82,4 @@ distclean: clean
 
 clean:
 	@rm -f $(PROGS) $(LIB_ECLONE) $(OTHER) *~ *.o headers.h
-	@make -C test clean
+	@$(MAKE) -C test clean
-- 
1.6.3.3
