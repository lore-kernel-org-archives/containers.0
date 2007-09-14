From: benjamin.thery-6ktuUTfB/bM@public.gmane.org
Subject: [NETNS45][PATCH 1/1] Fix network namespace unshare support.
Date: Fri, 14 Sep 2007 18:26:38 +0200
Message-ID: <20070914162735.674439633@frecb000701.frec.bull.fr>
References: <20070914162637.429733612@frecb000701.frec.bull.fr>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=Fix-netns-unshare-support.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Add CLONE_NEWNET flag in sys_unshare() test.

This patch should be merged with commit: 
"net: Add network namespace clone & unshare support."

Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 kernel/fork.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6-netns/kernel/fork.c
===================================================================
--- linux-2.6-netns.orig/kernel/fork.c
+++ linux-2.6-netns/kernel/fork.c
@@ -1608,7 +1608,8 @@ asmlinkage long sys_unshare(unsigned lon
 	err = -EINVAL;
 	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
 				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER))
+				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWUSER|
+				CLONE_NEWNET))
 		goto bad_unshare_out;
 
 	if ((err = unshare_thread(unshare_flags)))

-- 
