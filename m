From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC v2][PATCH 2/9] Remove CAP_SYS_ADMIN for checkpoint/restart
Date: Wed, 20 Aug 2008 12:25:59 -0700
Message-ID: <20080820192559.32C52EA3__9949.43511109359$1219260601$gmane$org@nimitz>
References: <20080820192557.98788FAB@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820192557.98788FAB@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


We need to do this so that we think about the security concerns
as we add each and every bit of c/r functionality.  There's
nothing that we need privileges for, yet.  Let's keep it that
way as long as possible.

---

 oren-cr.git-dave/checkpoint/sys.c |    6 ------
 1 file changed, 6 deletions(-)

diff -puN checkpoint/sys.c~0003-Remove-CAP_SYS_ADMIN-for-checkpoint-restart checkpoint/sys.c
--- oren-cr.git/checkpoint/sys.c~0003-Remove-CAP_SYS_ADMIN-for-checkpoint-restart	2008-08-20 12:12:49.000000000 -0700
+++ oren-cr.git-dave/checkpoint/sys.c	2008-08-20 12:12:49.000000000 -0700
@@ -169,9 +169,6 @@ asmlinkage long sys_checkpoint(pid_t pid
 	int fput_needed;
 	int ret;
 
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
 	file = fget_light(fd, &fput_needed);
 	if (!file)
 		return -EBADF;
@@ -207,9 +204,6 @@ asmlinkage long sys_restart(int crid, in
 	int fput_needed;
 	int ret;
 
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
 	file = fget_light(fd, &fput_needed);
 	if (!file)
 		return -EBADF;
_
