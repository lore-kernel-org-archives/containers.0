From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH][RFC] fs/exec.c: provide the correct process pid to the pipe
	helper
Date: Thu, 16 Sep 2010 13:59:59 -0500
Message-ID: <1284663599-3549-1-git-send-email-wad__23263.012225698$1284663780$gmane$org@chromium.org>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

format_corename uses task_tgid_vnr to provide the numeric pid of a
core-dumping process.  For file-based coredumps, this is perfectly
satisfactory.  However, when the core_pattern contains a pipe, the
substituted PID is invalid in the namespace of the core_pattern pipe
helper, the init namespace.

By changing this, any core collector may now find the process in the
init namespace /proc.  This helps with VFS namespacing too since the
mount root is available via /proc.  Unfortunately, it does not help in
cases of more complex namespacing, like net namespaces.  For that, the
helper thread will need to be migrated to the core-dump namespaces.

I have a separate patch series which implements migrating the
____call_usermodehelper thread to the coredump namespace, but it adds a
fair amount of complexity which might be better handled by someone who
understands that code.  I'm happy to mail it out as well though (it
works, but I don't assign a namespaced pid which may open up issues on
its own).

Any and all comments, feedback will be appreciated!

Signed-off-by: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 fs/exec.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 828dd24..0b8a874 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1467,6 +1467,13 @@ static int format_corename(char *corename, long signr)
 	char *const out_end = corename + CORENAME_MAX_SIZE;
 	int rc;
 	int pid_in_pattern = 0;
+	pid_t pid = task_tgid_vnr(current);
+
+	/* The pipe helper runs in the init namespace and should
+	 * receive the matching pid until that changes.
+	 */
+	if (ispipe)
+		pid = task_tgid_nr(current);
 
 	/* Repeat as long as we have more pattern to process and more output
 	   space */
@@ -1489,7 +1496,7 @@ static int format_corename(char *corename, long signr)
 			case 'p':
 				pid_in_pattern = 1;
 				rc = snprintf(out_ptr, out_end - out_ptr,
-					      "%d", task_tgid_vnr(current));
+					      "%d", pid);
 				if (rc > out_end - out_ptr)
 					goto out;
 				out_ptr += rc;
@@ -1568,7 +1575,7 @@ static int format_corename(char *corename, long signr)
 	 * the filename. Do not do this for piped commands. */
 	if (!ispipe && !pid_in_pattern && core_uses_pid) {
 		rc = snprintf(out_ptr, out_end - out_ptr,
-			      ".%d", task_tgid_vnr(current));
+			      ".%d", pid);
 		if (rc > out_end - out_ptr)
 			goto out;
 		out_ptr += rc;
-- 
1.7.0.4
