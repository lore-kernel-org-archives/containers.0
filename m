From: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] c/r:  Fix no-dot-config-targets pattern in linux/Makefile
Date: Mon, 03 Aug 2009 19:43:30 +0000
Message-ID: <1249328610.7138.23.camel@Maple>
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
To: oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Oren, I'm not sure who you're accepting patches from, but...

--
Kernel builds that specify targets in the checkpoint/ directory will
fail or be incorrect because the autoconfig files were not included.
One way to reproduce the problem is:

	make checkpoint/sys.s

The problem is that this pattern in linux/Makefile matches files in the
checkpoint/ directory:

no-dot-config-targets := clean mrproper distclean \
                         cscope TAGS tags help %docs check% \
                         include/linux/version.h headers_% \
                         kernelrelease kernelversion

Make the pattern more exact, per the current set of linux build targets.

Signed-off-by: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index cf631d7..17445a6 100644
--- a/Makefile
+++ b/Makefile
@@ -400,7 +400,7 @@ endif
 # of make so .config is not included in this case either (for *config).
 
 no-dot-config-targets := clean mrproper distclean \
-			 cscope TAGS tags help %docs check% \
+			 cscope TAGS tags help %docs checkstack \
 			 include/linux/version.h headers_% \
 			 kernelrelease kernelversion
 
-- 
1.5.4.3
