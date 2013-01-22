From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 08/11] Add support for detecting busy subordinate user ids
Date: Tue, 22 Jan 2013 01:17:50 -0800
Message-ID: <87y5flpoe9.fsf@xmission.com>
References: <87d2wxshu0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d2wxshu0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Tue, 22 Jan 2013 01:11:19 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nicolas =?utf-8?Q?Fran=C3=A7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 libmisc/user_busy.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/libmisc/user_busy.c b/libmisc/user_busy.c
index 168f9d5..04cfc31 100644
--- a/libmisc/user_busy.c
+++ b/libmisc/user_busy.c
@@ -38,11 +38,13 @@
 #include <stdio.h>
 #include <sys/types.h>
 #include <dirent.h>
+#include <fcntl.h>
 #include "defines.h"
 #include "prototypes.h"
+#include "subordinateio.h"
 
 #ifdef __linux__
-static int check_status (const char *sname, uid_t uid);
+static int check_status (const char *name, const char *sname, uid_t uid);
 static int user_busy_processes (const char *name, uid_t uid);
 #else				/* !__linux__ */
 static int user_busy_utmp (const char *name);
@@ -102,7 +104,7 @@ static int user_busy_utmp (const char *name)
 #endif				/* !__linux__ */
 
 #ifdef __linux__
-static int check_status (const char *sname, uid_t uid)
+static int check_status (const char *name, const char *sname, uid_t uid)
 {
 	/* 40: /proc/xxxxxxxxxx/task/xxxxxxxxxx/status + \0 */
 	char status[40];
@@ -125,7 +127,10 @@ static int check_status (const char *sname, uid_t uid)
 			            &ruid, &euid, &suid) == 3) {
 				if (   (ruid == (unsigned long) uid)
 				    || (euid == (unsigned long) uid)
-				    || (suid == (unsigned long) uid)) {
+				    || (suid == (unsigned long) uid)
+				    || have_sub_uids(name, ruid, 1)
+				    || have_sub_uids(name, euid, 1)
+				    || have_sub_uids(name, suid, 1)) {
 					(void) fclose (sfile);
 					return 1;
 				}
@@ -153,6 +158,8 @@ static int user_busy_processes (const char *name, uid_t uid)
 	struct stat sbroot;
 	struct stat sbroot_process;
 
+	sub_uid_open (O_RDONLY);
+
 	proc = opendir ("/proc");
 	if (proc == NULL) {
 		perror ("opendir /proc");
@@ -196,7 +203,7 @@ static int user_busy_processes (const char *name, uid_t uid)
 			continue;
 		}
 
-		if (check_status (tmp_d_name, uid) != 0) {
+		if (check_status (name, tmp_d_name, uid) != 0) {
 			(void) closedir (proc);
 			fprintf (stderr,
 			         _("%s: user %s is currently used by process %d\n"),
@@ -216,7 +223,7 @@ static int user_busy_processes (const char *name, uid_t uid)
 				if (tid == pid) {
 					continue;
 				}
-				if (check_status (task_path+6, uid) != 0) {
+				if (check_status (name, task_path+6, uid) != 0) {
 					(void) closedir (proc);
 					fprintf (stderr,
 					         _("%s: user %s is currently used by process %d\n"),
@@ -231,6 +238,7 @@ static int user_busy_processes (const char *name, uid_t uid)
 	}
 
 	(void) closedir (proc);
+	sub_uid_close();
 	return 0;
 }
 #endif				/* __linux__ */
-- 
1.7.5.4
