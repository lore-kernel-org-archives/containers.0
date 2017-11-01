From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [GIT PULL] signal bug fix for v4.14-rc8
Date: Wed, 01 Nov 2017 17:22:25 -0500
Message-ID: <87o9olfxlq.fsf__46642.6387698904$1509574962$gmane$org@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Linus,

Please pull the for-linus branch from the git tree:

   git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus

   HEAD: c3aff086ea11f17f5c0bec77bdbf4365ba6b41fc signal: Fix name of SIGEMT in #if defined() check

When making the generic support for SIGEMT conditional on the presence
of SIGEMT I made a typo that causes it to fail to activate.  It was
noticed comparatively quickly but the bug report just made it to me
today.

From: Andrew Clayton <andrew-gyMb1R/nBgN3uBD2Ct+Y/qxOck334EZe@public.gmane.org>
Date: Wed, 1 Nov 2017 15:49:59 +0000
Subject: [PATCH] signal: Fix name of SIGEMT in #if defined() check

Commit cc731525f26a ("signal: Remove kernel interal si_code magic")
added a check for SIGMET and NSIGEMT being defined. That SIGMET should
in fact be SIGEMT, with SIGEMT being defined in
arch/{alpha,mips,sparc}/include/uapi/asm/signal.h

This was actually pointed out by BenHutchings in a lwn.net comment
here https://lwn.net/Comments/734608/

Fixes: cc731525f26a ("signal: Remove kernel interal si_code magic")
Signed-off-by: Andrew Clayton <andrew-gyMb1R/nBgN3uBD2Ct+Y/qxOck334EZe@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/signal.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 800a18f77732..8dcd8825b2de 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2698,7 +2698,7 @@ enum siginfo_layout siginfo_layout(int sig, int si_code)
 			[SIGSEGV] = { NSIGSEGV, SIL_FAULT },
 			[SIGBUS]  = { NSIGBUS,  SIL_FAULT },
 			[SIGTRAP] = { NSIGTRAP, SIL_FAULT },
-#if defined(SIGMET) && defined(NSIGEMT)
+#if defined(SIGEMT) && defined(NSIGEMT)
 			[SIGEMT]  = { NSIGEMT,  SIL_FAULT },
 #endif
 			[SIGCHLD] = { NSIGCHLD, SIL_CHLD },
-- 
2.14.1
