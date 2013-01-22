From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 10/11] newusers: Add support for assiging subordinate uids and
	gids.
Date: Tue, 22 Jan 2013 01:19:28 -0800
Message-ID: <87k3r5pobj.fsf@xmission.com>
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
 src/newusers.c |  124 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 124 insertions(+), 0 deletions(-)

diff --git a/src/newusers.c b/src/newusers.c
index c25f40e..e5e832c 100644
--- a/src/newusers.c
+++ b/src/newusers.c
@@ -65,6 +65,7 @@
 #include "pwio.h"
 #include "sgroupio.h"
 #include "shadowio.h"
+#include "subordinateio.h"
 #include "chkname.h"
 
 /*
@@ -82,6 +83,8 @@ static long sha_rounds = 5000;
 #endif				/* USE_SHA_CRYPT */
 #endif				/* !USE_PAM */
 
+static bool is_sub_uid = false;
+static bool is_sub_gid = false;
 static bool is_shadow;
 #ifdef SHADOWGRP
 static bool is_shadow_grp;
@@ -90,6 +93,8 @@ static bool sgr_locked = false;
 static bool pw_locked = false;
 static bool gr_locked = false;
 static bool spw_locked = false;
+static bool sub_uid_locked = false;
+static bool sub_gid_locked = false;
 
 /* local function prototypes */
 static void usage (int status);
@@ -178,6 +183,20 @@ static void fail_exit (int code)
 		}
 	}
 #endif
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
 
 	exit (code);
 }
@@ -732,6 +751,24 @@ static void open_files (void)
 		sgr_locked = true;
 	}
 #endif
+	if (is_sub_uid) {
+		if (sub_uid_lock () == 0) {
+			fprintf (stderr,
+			         _("%s: cannot lock %s; try again later.\n"),
+			         Prog, sub_uid_dbname ());
+			fail_exit (EXIT_FAILURE);
+		}
+		sub_uid_locked = true;
+	}
+	if (is_sub_gid) {
+		if (sub_gid_lock () == 0) {
+			fprintf (stderr,
+			         _("%s: cannot lock %s; try again later.\n"),
+			         Prog, sub_gid_dbname ());
+			fail_exit (EXIT_FAILURE);
+		}
+		sub_gid_locked = true;
+	}
 
 	if (pw_open (O_RDWR) == 0) {
 		fprintf (stderr, _("%s: cannot open %s\n"), Prog, pw_dbname ());
@@ -751,6 +788,22 @@ static void open_files (void)
 		fail_exit (EXIT_FAILURE);
 	}
 #endif
+	if (is_sub_uid) {
+		if (sub_uid_open (O_RDWR) == 0) {
+			fprintf (stderr,
+			         _("%s: cannot open %s\n"),
+			         Prog, sub_uid_dbname ());
+			fail_exit (EXIT_FAILURE);
+		}
+	}
+	if (is_sub_gid) {
+		if (sub_gid_open (O_RDWR) == 0) {
+			fprintf (stderr,
+			         _("%s: cannot open %s\n"),
+			         Prog, sub_gid_dbname ());
+			fail_exit (EXIT_FAILURE);
+		}
+	}
 }
 
 /*
@@ -795,6 +848,19 @@ static void close_files (void)
 		SYSLOG ((LOG_ERR, "failure while writing changes to %s", gr_dbname ()));
 		fail_exit (EXIT_FAILURE);
 	}
+	if (is_sub_uid  && (sub_uid_close () == 0)) {
+		fprintf (stderr,
+		         _("%s: failure while writing changes to %s\n"), Prog, sub_uid_dbname ());
+		SYSLOG ((LOG_ERR, "failure while writing changes to %s", sub_uid_dbname ()));
+		fail_exit (EXIT_FAILURE);
+	}
+	if (is_sub_gid  && (sub_gid_close () == 0)) {
+		fprintf (stderr,
+		         _("%s: failure while writing changes to %s\n"), Prog, sub_gid_dbname ());
+		SYSLOG ((LOG_ERR, "failure while writing changes to %s", sub_gid_dbname ()));
+		fail_exit (EXIT_FAILURE);
+	}
+
 	if (gr_unlock () == 0) {
 		fprintf (stderr,
 		         _("%s: failed to unlock %s\n"),
@@ -823,6 +889,22 @@ static void close_files (void)
 		sgr_locked = false;
 	}
 #endif
+	if (is_sub_uid) {
+		if (sub_uid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_uid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_uid_dbname ()));
+			/* continue */
+		}
+		sub_uid_locked = false;
+	}
+	if (is_sub_gid) {
+		if (sub_gid_unlock () == 0) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_gid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_gid_dbname ()));
+			/* continue */
+		}
+		sub_gid_locked = false;
+	}
 }
 
 int main (int argc, char **argv)
@@ -864,6 +946,8 @@ int main (int argc, char **argv)
 #ifdef SHADOWGRP
 	is_shadow_grp = sgr_file_present ();
 #endif
+	is_sub_uid = sub_uid_file_present ();
+	is_sub_gid = sub_gid_file_present ();
 
 	open_files ();
 
@@ -1044,6 +1128,46 @@ int main (int argc, char **argv)
 			errors++;
 			continue;
 		}
+
+		/*
+		 * Add subordinate uids if the user does not have them.
+		 */
+		if (is_sub_uid && !sub_uid_assigned(fields[0])) {
+			uid_t sub_uid_start = 0;
+			unsigned long sub_uid_count = 0;
+			if (find_new_sub_uids(fields[0], &sub_uid_start, &sub_uid_count) == 0) {
+				if (sub_uid_add(fields[0], sub_uid_start, sub_uid_count) == 0) {
+					fprintf (stderr,
+						_("%s: failed to prepare new %s entry\n"),
+						Prog, sub_uid_dbname ());
+				}
+			} else {
+				fprintf (stderr,
+					_("%s: can't find subordinate user range\n"),
+					Prog);
+				errors++;
+			}
+		}
+	
+		/*
+		 * Add subordinate gids if the user does not have them.
+		 */
+		if (is_sub_gid && !sub_gid_assigned(fields[0])) {
+			gid_t sub_gid_start = 0;
+			unsigned long sub_gid_count = 0;
+			if (find_new_sub_gids(fields[0], &sub_gid_start, &sub_gid_count) == 0) {
+				if (sub_gid_add(fields[0], sub_gid_start, sub_gid_count) == 0) {
+					fprintf (stderr,
+						_("%s: failed to prepare new %s entry\n"),
+						Prog, sub_uid_dbname ());
+				}
+			} else {
+				fprintf (stderr,
+					_("%s: can't find subordinate group range\n"),
+					Prog);
+				errors++;
+			}
+		}
 	}
 
 	/*
-- 
1.7.5.4
