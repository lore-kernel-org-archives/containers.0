From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 06/11] userdel: Add support for removing subordinate user and
	group ids.
Date: Tue, 22 Jan 2013 01:16:51 -0800
Message-ID: <878v7lr30c.fsf@xmission.com>
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
 src/userdel.c |  115 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 115 insertions(+), 0 deletions(-)

diff --git a/src/userdel.c b/src/userdel.c
index 4439f62..0c9b83d 100644
--- a/src/userdel.c
+++ b/src/userdel.c
@@ -65,6 +65,7 @@
 #endif				/* WITH_TCB */
 /*@-exitarg@*/
 #include "exitcodes.h"
+#include "subordinateio.h"
 
 /*
  * exit status values
@@ -75,6 +76,8 @@
 #define E_GRP_UPDATE	10	/* can't update group file */
 #define E_HOMEDIR	12	/* can't remove home directory */
 #define E_SE_UPDATE	14	/* can't update SELinux user mapping */
+#define E_SUB_UID_UPDATE 16	/* can't update the subordinate uid file */
+#define E_SUB_GID_UPDATE 18	/* can't update the subordinate gid file */
 
 /*
  * Global variables
@@ -96,9 +99,13 @@ static bool is_shadow_pwd;
 static bool is_shadow_grp;
 static bool sgr_locked = false;
 #endif				/* SHADOWGRP */
+static bool is_sub_uid;
+static bool is_sub_gid;
 static bool pw_locked  = false;
 static bool gr_locked   = false;
 static bool spw_locked  = false;
+static bool sub_uid_locked = false;
+static bool sub_gid_locked = false;
 
 /* local function prototypes */
 static void usage (int status);
@@ -437,6 +444,34 @@ static void close_files (void)
 		sgr_locked = false;
 	}
 #endif				/* SHADOWGRP */
+
+	if (is_sub_uid) {
+		if (sub_uid_close () == 0) {
+			fprintf (stderr, _("%s: failure while writing changes to %s\n"), Prog, sub_uid_dbname ());
+			SYSLOG ((LOG_ERR, "failure while writing changes to %s", sub_uid_dbname ()));
+			fail_exit (E_SUB_UID_UPDATE);
+		}
+		if (sub_uid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_uid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_uid_dbname ()));
+			/* continue */
+		}
+		sub_uid_locked = false;
+	}
+
+	if (is_sub_gid) {
+		if (sub_gid_close () == 0) {
+			fprintf (stderr, _("%s: failure while writing changes to %s\n"), Prog, sub_gid_dbname ());
+			SYSLOG ((LOG_ERR, "failure while writing changes to %s", sub_gid_dbname ()));
+			fail_exit (E_SUB_GID_UPDATE);
+		}
+		if (sub_gid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_gid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_gid_dbname ()));
+			/* continue */
+		}
+		sub_gid_locked = false;
+	}
 }
 
 /*
@@ -474,6 +509,20 @@ static void fail_exit (int code)
 		}
 	}
 #endif				/* SHADOWGRP */
+	if (sub_uid_locked) {
+		if (sub_uid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_uid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_uid_dbname ()));
+			/* continue */
+		}
+	}
+	if (sub_gid_locked) {
+		if (sub_gid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_gid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_gid_dbname ()));
+			/* continue */
+		}
+	}
 
 #ifdef WITH_AUDIT
 	audit_logger (AUDIT_DEL_USER, Prog,
@@ -595,6 +644,58 @@ static void open_files (void)
 		}
 	}
 #endif				/* SHADOWGRP */
+	if (is_sub_uid) {
+		if (sub_uid_lock () == 0) {
+			fprintf (stderr,
+				_("%s: cannot lock %s; try again later.\n"),
+				Prog, sub_uid_dbname ());
+#ifdef WITH_AUDIT
+			audit_logger (AUDIT_DEL_USER, Prog,
+				"locking subordinate user file",
+				user_name, (unsigned int) user_id,
+				SHADOW_AUDIT_FAILURE);
+#endif				/* WITH_AUDIT */
+			fail_exit (E_SUB_UID_UPDATE);
+		}
+		sub_uid_locked = true;
+		if (sub_uid_open (O_RDWR) == 0) {
+			fprintf (stderr,
+				_("%s: cannot open %s\n"), Prog, sub_uid_dbname ());
+#ifdef WITH_AUDIT
+			audit_logger (AUDIT_DEL_USER, Prog,
+				"opening subordinate user file",
+				user_name, (unsigned int) user_id,
+				SHADOW_AUDIT_FAILURE);
+#endif				/* WITH_AUDIT */
+			fail_exit (E_SUB_UID_UPDATE);
+		}
+	}
+	if (is_sub_gid) {
+		if (sub_gid_lock () == 0) {
+			fprintf (stderr,
+				_("%s: cannot lock %s; try again later.\n"),
+				Prog, sub_gid_dbname ());
+#ifdef WITH_AUDIT
+			audit_logger (AUDIT_DEL_USER, Prog,
+				"locking subordinate group file",
+				user_name, (unsigned int) user_id,
+				SHADOW_AUDIT_FAILURE);
+#endif				/* WITH_AUDIT */
+			fail_exit (E_SUB_GID_UPDATE);
+		}
+		sub_gid_locked = true;
+		if (sub_gid_open (O_RDWR) == 0) {
+			fprintf (stderr,
+				_("%s: cannot open %s\n"), Prog, sub_gid_dbname ());
+#ifdef WITH_AUDIT
+			audit_logger (AUDIT_DEL_USER, Prog,
+				"opening subordinate group file",
+				user_name, (unsigned int) user_id,
+				SHADOW_AUDIT_FAILURE);
+#endif				/* WITH_AUDIT */
+			fail_exit (E_SUB_GID_UPDATE);
+		}
+	}
 }
 
 /*
@@ -619,6 +720,18 @@ static void update_user (void)
 		         Prog, user_name, spw_dbname ());
 		fail_exit (E_PW_UPDATE);
 	}
+	if (is_sub_uid && sub_uid_remove(user_name, 0, ULONG_MAX) == 0) {
+		fprintf (stderr,
+			_("%s: cannot remove entry %lu from %s\n"),
+			Prog, (unsigned long)user_id, sub_uid_dbname ());
+		fail_exit (E_SUB_UID_UPDATE);
+	}
+	if (is_sub_gid && sub_gid_remove(user_name, 0, ULONG_MAX) == 0) {
+		fprintf (stderr,
+			_("%s: cannot remove entry %lu from %s\n"),
+			Prog, (unsigned long)user_id, sub_gid_dbname ());
+		fail_exit (E_SUB_GID_UPDATE);
+	}
 #ifdef WITH_AUDIT
 	audit_logger (AUDIT_DEL_USER, Prog,
 	              "deleting user entries",
@@ -966,6 +1079,8 @@ int main (int argc, char **argv)
 #ifdef SHADOWGRP
 	is_shadow_grp = sgr_file_present ();
 #endif				/* SHADOWGRP */
+	is_sub_uid = sub_uid_file_present ();
+	is_sub_gid = sub_gid_file_present ();
 
 	/*
 	 * Start with a quick check to see if the user exists.
-- 
1.7.5.4
