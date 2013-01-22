From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 07/11] useradd: Add support for subordinate user identifiers
Date: Tue, 22 Jan 2013 01:17:30 -0800
Message-ID: <8738xtr2z9.fsf@xmission.com>
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
 src/useradd.c |  141 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 140 insertions(+), 1 deletions(-)

diff --git a/src/useradd.c b/src/useradd.c
index bfddfc6..87ba98d 100644
--- a/src/useradd.c
+++ b/src/useradd.c
@@ -65,6 +65,7 @@
 #include "sgroupio.h"
 #endif
 #include "shadowio.h"
+#include "subordinateio.h"
 #ifdef WITH_TCB
 #include "tcbfuncs.h"
 #endif
@@ -121,12 +122,20 @@ static bool is_shadow_pwd;
 static bool is_shadow_grp;
 static bool sgr_locked = false;
 #endif
+static bool is_sub_uid = false;
+static bool is_sub_gid = false;
 static bool pw_locked = false;
 static bool gr_locked = false;
 static bool spw_locked = false;
+static bool sub_uid_locked = false;
+static bool sub_gid_locked = false;
 static char **user_groups;	/* NULL-terminated list */
 static long sys_ngroups;
 static bool do_grp_update = false;	/* group files need to be updated */
+static uid_t sub_uid_start;	/* New subordinate uid range */
+static unsigned long sub_uid_count;
+static gid_t sub_gid_start;	/* New subordinate gid range */
+static unsigned long sub_gid_count;
 
 static bool
     bflg = false,		/* new default root of home directory */
@@ -168,6 +177,8 @@ static bool home_added = false;
 #define E_GRP_UPDATE	10	/* can't update group file */
 #define E_HOMEDIR	12	/* can't create home directory */
 #define E_SE_UPDATE	14	/* can't update SELinux user mapping */
+#define E_SUB_UID_UPDATE 16	/* can't update the subordinate uid file */
+#define E_SUB_GID_UPDATE 18	/* can't update the subordinate gid file */
 
 #define DGROUP			"GROUP="
 #define DHOME			"HOME="
@@ -268,6 +279,32 @@ static void fail_exit (int code)
 		}
 	}
 #endif
+	if (sub_uid_locked) {
+		if (sub_uid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_uid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_uid_dbname ()));
+#ifdef WITH_AUDIT
+			audit_logger (AUDIT_ADD_USER, Prog,
+			              "unlocking subodinate user file",
+			              user_name, AUDIT_NO_ID,
+			              SHADOW_AUDIT_FAILURE);
+#endif
+			/* continue */
+		}
+	}
+	if (sub_gid_locked) {
+		if (sub_gid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_gid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_gid_dbname ()));
+#ifdef WITH_AUDIT
+			audit_logger (AUDIT_ADD_USER, Prog,
+			              "unlocking subodinate group file",
+			              user_name, AUDIT_NO_ID,
+			              SHADOW_AUDIT_FAILURE);
+#endif
+			/* continue */
+		}
+	}
 
 #ifdef WITH_AUDIT
 	audit_logger (AUDIT_ADD_USER, Prog,
@@ -1378,6 +1415,18 @@ static void close_files (void)
 		}
 #endif
 	}
+	if (is_sub_uid  && (sub_uid_close () == 0)) {
+		fprintf (stderr,
+		         _("%s: failure while writing changes to %s\n"), Prog, sub_uid_dbname ());
+		SYSLOG ((LOG_ERR, "failure while writing changes to %s", sub_uid_dbname ()));
+		fail_exit (E_SUB_UID_UPDATE);
+	}
+	if (is_sub_gid  && (sub_gid_close () == 0)) {
+		fprintf (stderr,
+		         _("%s: failure while writing changes to %s\n"), Prog, sub_gid_dbname ());
+		SYSLOG ((LOG_ERR, "failure while writing changes to %s", sub_gid_dbname ()));
+		fail_exit (E_SUB_GID_UPDATE);
+	}
 	if (is_shadow_pwd) {
 		if (spw_unlock () == 0) {
 			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, spw_dbname ());
@@ -1432,6 +1481,34 @@ static void close_files (void)
 		sgr_locked = false;
 	}
 #endif
+	if (is_sub_uid) {
+		if (sub_uid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_uid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_uid_dbname ()));
+#ifdef WITH_AUDIT
+			audit_logger (AUDIT_ADD_USER, Prog,
+				"unlocking subordinate user file",
+				user_name, AUDIT_NO_ID,
+				SHADOW_AUDIT_FAILURE);
+#endif
+			/* continue */
+		}
+		sub_uid_locked = false;
+	}
+	if (is_sub_gid) {
+		if (sub_gid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_gid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_gid_dbname ()));
+#ifdef WITH_AUDIT
+			audit_logger (AUDIT_ADD_USER, Prog,
+				"unlocking subordinate group file",
+				user_name, AUDIT_NO_ID,
+				SHADOW_AUDIT_FAILURE);
+#endif
+			/* continue */
+		}
+		sub_gid_locked = false;
+	}
 }
 
 /*
@@ -1486,6 +1563,36 @@ static void open_files (void)
 		}
 	}
 #endif
+	if (is_sub_uid) {
+		if (sub_uid_lock () == 0) {
+			fprintf (stderr,
+			         _("%s: cannot lock %s; try again later.\n"),
+			         Prog, sub_uid_dbname ());
+			fail_exit (E_SUB_UID_UPDATE);
+		}
+		sub_uid_locked = true;
+		if (sub_uid_open (O_RDWR) == 0) {
+			fprintf (stderr,
+			         _("%s: cannot open %s\n"),
+			         Prog, sub_uid_dbname ());
+			fail_exit (E_SUB_UID_UPDATE);
+		}
+	}
+	if (is_sub_gid) {
+		if (sub_gid_lock () == 0) {
+			fprintf (stderr,
+			         _("%s: cannot lock %s; try again later.\n"),
+			         Prog, sub_gid_dbname ());
+			fail_exit (E_SUB_GID_UPDATE);
+		}
+		sub_gid_locked = true;
+		if (sub_gid_open (O_RDWR) == 0) {
+			fprintf (stderr,
+			         _("%s: cannot open %s\n"),
+			         Prog, sub_gid_dbname ());
+			fail_exit (E_SUB_GID_UPDATE);
+		}
+	}
 }
 
 static void open_shadow (void)
@@ -1732,13 +1839,27 @@ static void usr_update (void)
 #endif
 		fail_exit (E_PW_UPDATE);
 	}
+	if (is_sub_uid &&
+	    (sub_uid_add(user_name, sub_uid_start, sub_uid_count) == 0)) {
+		fprintf (stderr,
+		         _("%s: failed to prepare the new %s entry\n"),
+		         Prog, sub_uid_dbname ());
+		fail_exit (E_SUB_UID_UPDATE);
+	}
+	if (is_sub_gid &&
+	    (sub_gid_add(user_name, sub_gid_start, sub_gid_count) == 0)) {
+		fprintf (stderr,
+		         _("%s: failed to prepare the new %s entry\n"),
+		         Prog, sub_uid_dbname ());
+		fail_exit (E_SUB_GID_UPDATE);
+	}
+
 #ifdef WITH_AUDIT
 	audit_logger (AUDIT_ADD_USER, Prog,
 	              "adding user",
 	              user_name, (unsigned int) user_id,
 	              SHADOW_AUDIT_SUCCESS);
 #endif
-
 	/*
 	 * Do any group file updates for this user.
 	 */
@@ -1884,6 +2005,8 @@ int main (int argc, char **argv)
 #ifdef SHADOWGRP
 	is_shadow_grp = sgr_file_present ();
 #endif
+	is_sub_uid = sub_uid_file_present ();
+	is_sub_gid = sub_gid_file_present ();
 
 	get_defaults ();
 
@@ -2034,6 +2157,22 @@ int main (int argc, char **argv)
 		grp_add ();
 	}
 
+	if (is_sub_uid) {
+		if (find_new_sub_uids(user_name, &sub_uid_start, &sub_uid_count) < 0) {
+			fprintf (stderr,
+				_("%s: can't find subordinate user range\n"),
+				Prog);
+			fail_exit(E_SUB_UID_UPDATE);
+		}
+	}
+	if (is_sub_gid) {
+		if (find_new_sub_gids(user_name, &sub_gid_start, &sub_gid_count) < 0) {
+			fprintf (stderr,
+				_("%s: can't find subordinate group range\n"),
+				Prog);
+			fail_exit(E_SUB_GID_UPDATE);
+		}
+	}
 	usr_update ();
 
 	if (mflg) {
-- 
1.7.5.4
