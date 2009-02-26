From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] liblxc: Add username and uid lookup/check.
Date: Wed, 25 Feb 2009 20:21:57 -0800
Message-ID: <20090226042157.GC11052@us.ibm.com>
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
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Add the ability to lookup usernames and check uids. Bails out early if the given
uid/name does not exist and avoids using atoi() (which is bad because we can't
tell if it parsed an int or a pumpkin).

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
Also gets rid of a bogus "maybe used uninitialized" warning.

 src/lxc/lxc_unshare.c |   32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

Index: lxc/src/lxc/lxc_unshare.c
===================================================================
--- lxc.orig/src/lxc/lxc_unshare.c
+++ lxc/src/lxc/lxc_unshare.c
@@ -30,6 +30,7 @@
 #include <errno.h>
 #include <sys/types.h>
 #include <sys/wait.h>
+#include <pwd.h>
 
 #include "lxc_namespace.h"
 
@@ -48,12 +49,37 @@ void usage(char *cmd)
 	_exit(1);
 }
 
+static uid_t lookup_user(const char *optarg)
+{
+	char name[sysconf(_SC_LOGIN_NAME_MAX)];
+	uid_t uid = -1;
+
+	if (!optarg || (optarg[0] == '\0'))
+		return uid;
+	if (sscanf(optarg, "%u", &uid) < 1) {
+		struct passwd pwent; /* not a uid -- perhaps a username */
+		struct passwd *pent;
+
+		if (sscanf(optarg, "%s", name) < 1)
+			return uid;
+		if (getpwnam_r(name, &pwent, NULL, 0, &pent) || !pent)
+			return uid;
+		uid = pent->pw_uid;
+	} else {
+		if (getpwuid_r(uid, NULL, NULL, 0, NULL)) {
+			uid = -1;
+			return uid;
+		}
+	}
+	return uid;
+}
+
 int main(int argc, char *argv[])
 {
 	int opt, nbargs = 0, status = 1, hastofork = 0;
 	char **args;
 	long flags = 0;
-	uid_t uid = 0;
+ 	uid_t uid = -1; /* valid only if (flags & CLONE_NEWUSER) */
 	pid_t pid;
 
 	while ((opt = getopt(argc, argv, "fmphiu:n")) != -1) {
@@ -71,8 +97,10 @@ int main(int argc, char *argv[])
 			flags |= CLONE_NEWIPC;
 			break;
 		case 'u':
+			uid = lookup_user(optarg);
+			if (uid == -1)
+				break;
 			flags |= CLONE_NEWUSER;
-			uid = atoi(optarg);
 			break;
 		case 'n':
 			flags |= CLONE_NEWNET;
