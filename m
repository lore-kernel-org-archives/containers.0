From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add powerpc signalfd syscall numbers
Date: Thu, 19 Mar 2009 22:44:20 -0700
Message-ID: <20090320054420.GB26719@us.ibm.com>
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
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, LXC Tools <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Add signalfd and signalfd4 syscall number definitions for powerpc so
that we may compile even with older platform headers.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

diff --git a/src/lxc/start.c b/src/lxc/start.c
index 476d695..051e70c 100644
--- a/src/lxc/start.c
+++ b/src/lxc/start.c
@@ -51,6 +51,8 @@
 #      define __NR_signalfd4 327
 #    elif __x86_64__
 #      define __NR_signalfd4 289
+#    elif __powerpc__
+#      define __NR_signalfd4 313
 #    elif __s390x__
 #      define __NR_signalfd4 322
 #    endif
@@ -62,6 +64,8 @@
 #      define __NR_signalfd 321
 #    elif __x86_64__
 #      define __NR_signalfd 282
+#    elif __powerpc__
+#      define __NR_signalfd 305
 #    elif __s390x__
 #      define __NR_signalfd 316
 #    endif
