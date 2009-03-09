From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] define s390x signalfd for old headers
Date: Mon, 9 Mar 2009 11:35:51 -0500
Message-ID: <20090309163551.GA23210@us.ibm.com>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

define s390x signalfd for systems with headers which are too
old.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 src/lxc/start.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/src/lxc/start.c b/src/lxc/start.c
index 410235c..476d695 100644
--- a/src/lxc/start.c
+++ b/src/lxc/start.c
@@ -51,6 +51,8 @@
 #      define __NR_signalfd4 327
 #    elif __x86_64__
 #      define __NR_signalfd4 289
+#    elif __s390x__
+#      define __NR_signalfd4 322
 #    endif
 #endif
 
@@ -60,6 +62,8 @@
 #      define __NR_signalfd 321
 #    elif __x86_64__
 #      define __NR_signalfd 282
+#    elif __s390x__
+#      define __NR_signalfd 316
 #    endif
 #endif
 
-- 
1.6.1.1
