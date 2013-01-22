From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 09/11] usermod: Add support for subordinate uids and gids.
Date: Tue, 22 Jan 2013 01:18:24 -0800
Message-ID: <87sj5tpodb.fsf@xmission.com>
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
 man/usermod.8.xml |   80 +++++++++++++++++
 src/usermod.c     |  255 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 332 insertions(+), 3 deletions(-)

diff --git a/man/usermod.8.xml b/man/usermod.8.xml
index 322d181..0a23416 100644
--- a/man/usermod.8.xml
+++ b/man/usermod.8.xml
@@ -391,6 +391,86 @@
       </varlistentry>
       <varlistentry>
 	<term>
+	  <option>-v</option>, <option>--add-sub-uids</option>
+	  <replaceable>FIRST</replaceable>-<replaceable>LAST</replaceable>
+	</term>
+	<listitem>
+	  <para>
+	    Add a range of subordinate uids to the users account. 
+	  </para>
+	  <para>
+	    This option may be specified multiple times to add multiple ranges to a users account.
+	  </para>
+	  <para>
+	     No checks will be performed with regard to
+	     <option>SUB_UID_MIN</option>, <option>SUB_UID_MAX</option>, or
+	     <option>SUB_UID_COUNT</option> from /etc/login.defs.
+	  </para>
+	</listitem>
+      </varlistentry>
+      <varlistentry>
+	<term>
+	  <option>-V</option>, <option>--del-sub-uids</option>
+	  <replaceable>FIRST</replaceable>-<replaceable>LAST</replaceable>
+	</term>
+	<listitem>
+	  <para>
+	    Remove a range of subordinate uids from the users account.
+	  </para>
+	  <para>
+	    This option may be specified multiple times to remove multiple ranges to a users account.
+	    When both <option>--del-sub-uids</option> and <option>--add-sub-uids</option> are specified
+	    remove of all subordinate uid ranges happens before any subordinate uid ranges are added.
+	  </para>
+	  <para>
+	     No checks will be performed with regard to
+	     <option>SUB_UID_MIN</option>, <option>SUB_UID_MAX</option>, or
+	     <option>SUB_UID_COUNT</option> from /etc/login.defs.
+	  </para>
+	</listitem>
+      </varlistentry>
+      <varlistentry>
+	<term>
+	  <option>-w</option>, <option>--add-sub-gids</option>
+	  <replaceable>FIRST</replaceable>-<replaceable>LAST</replaceable>
+	</term>
+	<listitem>
+	  <para>
+	    Add a range of subordinate gids to the users account.
+	  </para>
+	  <para>
+	    This option may be specified multiple times to add multiple ranges to a users account.
+	  </para>
+	  <para>
+	     No checks will be performed with regard to
+	     <option>SUB_GID_MIN</option>, <option>SUB_GID_MAX</option>, or
+	     <option>SUB_GID_COUNT</option> from /etc/login.defs.
+	  </para>
+	</listitem>
+      </varlistentry>
+      <varlistentry>
+	<term>
+	  <option>-W</option>, <option>--del-sub-gids</option>
+	  <replaceable>FIRST</replaceable>-<replaceable>LAST</replaceable>
+	</term>
+	<listitem>
+	  <para>
+	    Remove a range of subordinate gids from the users account.
+	  </para>
+	  <para>
+	    This option may be specified multiple times to remove multiple ranges to a users account.
+	    When both <option>--del-sub-gids</option> and <option>--add-sub-gids</option> are specified
+	    remove of all subordinate gid ranges happens before any subordinate gid ranges are added.
+	  </para>
+	  <para>
+	     No checks will be performed with regard to
+	     <option>SUB_GID_MIN</option>, <option>SUB_GID_MAX</option>, or
+	     <option>SUB_GID_COUNT</option> from /etc/login.defs.
+	  </para>
+	</listitem>
+      </varlistentry>
+      <varlistentry>
+	<term>
 	  <option>-Z</option>, <option>--selinux-user</option>
 	  <replaceable>SEUSER</replaceable>
 	</term>
diff --git a/src/usermod.c b/src/usermod.c
index e411a32..448eed0 100644
--- a/src/usermod.c
+++ b/src/usermod.c
@@ -63,6 +63,7 @@
 #include "sgroupio.h"
 #endif
 #include "shadowio.h"
+#include "subordinateio.h"
 #ifdef WITH_TCB
 #include "tcbfuncs.h"
 #endif
@@ -86,6 +87,8 @@
 /* #define E_NOSPACE	11	   insufficient space to move home dir */
 #define E_HOMEDIR	12	/* unable to complete home dir move */
 #define E_SE_UPDATE	13	/* can't update SELinux user mapping */
+#define E_SUB_UID_UPDATE 16	/* can't update the subordinate uid file */
+#define E_SUB_GID_UPDATE 18	/* can't update the subordinate gid file */
 #define	VALID(s)	(strcspn (s, ":\n") == strlen (s))
 /*
  * Global variables
@@ -133,7 +136,11 @@ static bool
     Zflg = false,		/* new selinux user */
 #endif
     uflg = false,		/* specify new user ID */
-    Uflg = false;		/* unlock the password */
+    Uflg = false,		/* unlock the password */
+    vflg = false,		/*    add subordinate uids */
+    Vflg = false,		/* delete subordinate uids */
+    wflg = false,		/*    add subordinate gids */
+    Wflg = false;		/* delete subordinate gids */
 
 static bool is_shadow_pwd;
 
@@ -141,12 +148,17 @@ static bool is_shadow_pwd;
 static bool is_shadow_grp;
 #endif
 
+static bool is_sub_uid = false;
+static bool is_sub_gid = false;
+
 static bool pw_locked  = false;
 static bool spw_locked = false;
 static bool gr_locked  = false;
 #ifdef SHADOWGRP
 static bool sgr_locked = false;
 #endif
+static bool sub_uid_locked = false;
+static bool sub_gid_locked = false;
 
 
 /* local function prototypes */
@@ -302,6 +314,69 @@ static int get_groups (char *list)
 	return 0;
 }
 
+struct ulong_range
+{
+	unsigned long first;
+	unsigned long last;
+};
+
+static struct ulong_range getulong_range(const char *str)
+{
+	struct ulong_range result = { .first = ULONG_MAX, .last = 0 };
+	unsigned long long first, last;
+	char *pos;
+
+	errno = 0;
+	first = strtoll(str, &pos, 10);
+	if (('\0' == *str) || ('-' != *pos ) || (ERANGE == errno) ||
+	    (first != (unsigned long int)first))
+		goto out;
+
+	errno = 0;
+	last = strtoul(pos + 1, &pos, 10);
+	if (('\0' != *pos ) || (ERANGE == errno) ||
+	    (last != (unsigned long int)last))
+		goto out;
+
+	if (first > last)
+		goto out;
+
+	result.first = (unsigned long int)first;
+	result.last = (unsigned long int)last;
+out:
+	return result;
+	
+}
+
+struct ulong_range_list_entry {
+	struct ulong_range_list_entry *next;
+	struct ulong_range range;
+};
+
+static struct ulong_range_list_entry *add_sub_uids = NULL, *del_sub_uids = NULL;
+static struct ulong_range_list_entry *add_sub_gids = NULL, *del_sub_gids = NULL;
+
+static int prepend_range(const char *str, struct ulong_range_list_entry **head)
+{
+	struct ulong_range range;
+	struct ulong_range_list_entry *entry;
+	range = getulong_range(str);
+	if (range.first > range.last)
+		return 0;
+
+	entry = malloc(sizeof(*entry));
+	if (!entry) {
+		fprintf (stderr,
+			_("%s: failed to allocate memory: %s\n"),
+			Prog, strerror (errno));
+		return 0;
+	}
+	entry->next = *head;
+	entry->range = range;
+	*head = entry;
+	return 1;
+}
+
 /*
  * usage - display usage message and exit
  */
@@ -334,6 +409,10 @@ static /*@noreturn@*/void usage (int status)
 	(void) fputs (_("  -s, --shell SHELL             new login shell for the user account\n"), usageout);
 	(void) fputs (_("  -u, --uid UID                 new UID for the user account\n"), usageout);
 	(void) fputs (_("  -U, --unlock                  unlock the user account\n"), usageout);
+	(void) fputs (_("  -v, --add-subuids FIRST-LAST  add range of subordinate uids\n"), usageout);
+	(void) fputs (_("  -V, --del-subuids FIRST-LAST  remvoe range of subordinate uids\n"), usageout);
+	(void) fputs (_("  -w, --add-subgids FIRST-LAST  add range of subordinate gids\n"), usageout);
+	(void) fputs (_("  -W, --del-subgids FIRST-LAST  remvoe range of subordinate gids\n"), usageout);
 #ifdef WITH_SELINUX
 	(void) fputs (_("  -Z, --selinux-user SEUSER     new SELinux user mapping for the user account\n"), usageout);
 #endif				/* WITH_SELINUX */
@@ -590,6 +669,20 @@ static /*@noreturn@*/void fail_exit (int code)
 			/* continue */
 		}
 	}
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
 	audit_logger (AUDIT_USER_CHAUTHTOK, Prog,
@@ -889,6 +982,10 @@ static void process_flags (int argc, char **argv)
 			{"shell",        required_argument, NULL, 's'},
 			{"uid",          required_argument, NULL, 'u'},
 			{"unlock",       no_argument,       NULL, 'U'},
+			{"add-subuids",  required_argument, NULL, 'v'},
+			{"del-subuids",  required_argument, NULL, 'V'},
+ 			{"add-subgids",  required_argument, NULL, 'w'},
+ 			{"del-subgids",  required_argument, NULL, 'W'},
 #ifdef WITH_SELINUX
 			{"selinux-user", required_argument, NULL, 'Z'},
 #endif				/* WITH_SELINUX */
@@ -1018,6 +1115,41 @@ static void process_flags (int argc, char **argv)
 			case 'U':
 				Uflg = true;
 				break;
+			case 'v':
+				if (prepend_range (optarg, &add_sub_uids) == 0) {
+					fprintf (stderr,
+						_("%s: invalid subordinate uid range '%s'\n"),
+						Prog, optarg);
+					exit(E_BAD_ARG);
+				}
+				vflg = true;
+				break;
+			case 'V':
+				if (prepend_range (optarg, &del_sub_uids) == 0) {
+					fprintf (stderr,
+						_("%s: invalid subordinate uid range '%s'\n"),
+						Prog, optarg);
+					exit(E_BAD_ARG);
+				}
+				Vflg = true;
+				break;
+			case 'w':
+				if (prepend_range (optarg, &add_sub_gids) == 0) {
+					fprintf (stderr,
+						_("%s: invalid subordinate gid range '%s'\n"),
+						Prog, optarg);
+					exit(E_BAD_ARG);
+				}
+				wflg = true;
+			case 'W':
+				if (prepend_range (optarg, &del_sub_gids) == 0) {
+					fprintf (stderr,
+						_("%s: invalid subordinate gid range '%s'\n"),
+						Prog, optarg);
+					exit(E_BAD_ARG);
+				}
+				Wflg = true;
+				break;
 #ifdef WITH_SELINUX
 			case 'Z':
 				if (is_selinux_enabled () > 0) {
@@ -1170,6 +1302,7 @@ static void process_flags (int argc, char **argv)
 
 	if (!(Uflg || uflg || sflg || pflg || mflg || Lflg ||
 	      lflg || Gflg || gflg || fflg || eflg || dflg || cflg
+	      || vflg || Vflg || wflg || Wflg
 #ifdef WITH_SELINUX
 	      || Zflg
 #endif				/* WITH_SELINUX */
@@ -1200,6 +1333,7 @@ static void process_flags (int argc, char **argv)
 		         Prog, (unsigned long) user_newid);
 		exit (E_UID_IN_USE);
 	}
+
 }
 
 /*
@@ -1248,6 +1382,10 @@ static void close_files (void)
 				         sgr_dbname ()));
 				fail_exit (E_GRP_UPDATE);
 			}
+		}
+#endif
+#ifdef SHADOWGRP
+		if (is_shadow_grp) {
 			if (sgr_unlock () == 0) {
 				fprintf (stderr,
 				         _("%s: failed to unlock %s\n"),
@@ -1296,6 +1434,33 @@ static void close_files (void)
 	sgr_locked = false;
 #endif
 
+	if (vflg || Vflg) {
+		if (!is_sub_uid || (sub_uid_close () == 0)) {
+			fprintf (stderr, _("%s: failure while writing changes to %s\n"), Prog, sub_uid_dbname ());
+			SYSLOG ((LOG_ERR, "failure while writing changes to %s", sub_uid_dbname ()));
+			fail_exit (E_SUB_UID_UPDATE);
+		}
+		if (!is_sub_uid || (sub_uid_unlock () == 0)) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_uid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_uid_dbname ()));
+			/* continue */
+		}
+		sub_uid_locked = false;
+	}
+	if (wflg || Wflg) {
+		if (!is_sub_gid || (sub_gid_close () == 0)) {
+			fprintf (stderr, _("%s: failure while writing changes to %s\n"), Prog, sub_gid_dbname ());
+			SYSLOG ((LOG_ERR, "failure while writing changes to %s", sub_gid_dbname ()));
+			fail_exit (E_SUB_GID_UPDATE);
+		}
+		if (!is_sub_gid || (sub_gid_unlock () == 0)) {
+			fprintf (stderr, _("%s: failed to unlock %s\n"), Prog, sub_gid_dbname ());
+			SYSLOG ((LOG_ERR, "failed to unlock %s", sub_gid_dbname ()));
+			/* continue */
+		}
+		sub_gid_locked = false;
+	}
+
 	/*
 	 * Close the DBM and/or flat files
 	 */
@@ -1375,6 +1540,36 @@ static void open_files (void)
 		}
 #endif
 	}
+	if (vflg || Vflg) {
+		if (!is_sub_uid || (sub_uid_lock () == 0)) {
+			fprintf (stderr,
+			         _("%s: cannot lock %s; try again later.\n"),
+			         Prog, sub_uid_dbname ());
+			fail_exit (E_SUB_UID_UPDATE);
+		}
+		sub_uid_locked = true;
+		if (!is_sub_uid || (sub_uid_open (O_RDWR) == 0)) {
+			fprintf (stderr,
+			         _("%s: cannot open %s\n"),
+			         Prog, sub_uid_dbname ());
+			fail_exit (E_SUB_UID_UPDATE);
+		}
+	}
+	if (wflg || Wflg) {
+		if (!is_sub_gid || (sub_gid_lock () == 0)) {
+			fprintf (stderr,
+			         _("%s: cannot lock %s; try again later.\n"),
+			         Prog, sub_gid_dbname ());
+			fail_exit (E_SUB_GID_UPDATE);
+		}
+		sub_gid_locked = true;
+		if (!is_sub_gid || (sub_gid_open (O_RDWR) == 0)) {
+			fprintf (stderr,
+			         _("%s: cannot open %s\n"),
+			         Prog, sub_gid_dbname ());
+			fail_exit (E_SUB_GID_UPDATE);
+		}
+	}
 }
 
 /*
@@ -1476,6 +1671,58 @@ static void usr_update (void)
 			fail_exit (E_PW_UPDATE);
 		}
 	}
+	if (Vflg) {
+		struct ulong_range_list_entry *ptr;
+		for (ptr = del_sub_uids; ptr != NULL; ptr = ptr->next) {
+			unsigned long count = ptr->range.last - ptr->range.first + 1;
+			if (sub_uid_remove(user_name, ptr->range.first, count) == 0) {
+				fprintf (stderr,
+					_("%s: failed to remove uid range %lu-%lu from '%s'\n"),
+					Prog, ptr->range.first, ptr->range.last, 
+					sub_uid_dbname ());
+				fail_exit (E_SUB_UID_UPDATE);
+			}
+		}
+	}
+	if (vflg) {
+		struct ulong_range_list_entry *ptr;
+		for (ptr = add_sub_uids; ptr != NULL; ptr = ptr->next) {
+			unsigned long count = ptr->range.last - ptr->range.first + 1;
+			if (sub_uid_add(user_name, ptr->range.first, count) == 0) {
+				fprintf (stderr,
+					_("%s: failed to add uid range %lu-%lu from '%s'\n"),
+					Prog, ptr->range.first, ptr->range.last, 
+					sub_uid_dbname ());
+				fail_exit (E_SUB_UID_UPDATE);
+			}
+		}
+	}
+	if (Wflg) {
+		struct ulong_range_list_entry *ptr;
+		for (ptr = del_sub_gids; ptr != NULL; ptr = ptr->next) {
+			unsigned long count = ptr->range.last - ptr->range.first + 1;
+			if (sub_gid_remove(user_name, ptr->range.first, count) == 0) {
+				fprintf (stderr,
+					_("%s: failed to remove gid range %lu-%lu from '%s'\n"),
+					Prog, ptr->range.first, ptr->range.last, 
+					sub_gid_dbname ());
+				fail_exit (E_SUB_GID_UPDATE);
+			}
+		}
+	}
+	if (wflg) {
+		struct ulong_range_list_entry *ptr;
+		for (ptr = add_sub_gids; ptr != NULL; ptr = ptr->next) {
+			unsigned long count = ptr->range.last - ptr->range.first + 1;
+			if (sub_gid_add(user_name, ptr->range.first, count) == 0) {
+				fprintf (stderr,
+					_("%s: failed to add gid range %lu-%lu from '%s'\n"),
+					Prog, ptr->range.first, ptr->range.last, 
+					sub_gid_dbname ());
+				fail_exit (E_SUB_GID_UPDATE);
+			}
+		}
+	}
 }
 
 /*
@@ -1811,6 +2058,8 @@ int main (int argc, char **argv)
 #ifdef SHADOWGRP
 	is_shadow_grp = sgr_file_present ();
 #endif
+	is_sub_uid = sub_uid_file_present ();
+	is_sub_gid = sub_gid_file_present ();
 
 	process_flags (argc, argv);
 
@@ -1818,7 +2067,7 @@ int main (int argc, char **argv)
 	 * The home directory, the username and the user's UID should not
 	 * be changed while the user is logged in.
 	 */
-	if (   (uflg || lflg || dflg)
+	if (   (uflg || lflg || dflg || Vflg || Wflg)
 	    && (user_busy (user_name, user_id) != 0)) {
 		exit (E_USER_BUSY);
 	}
@@ -1871,7 +2120,7 @@ int main (int argc, char **argv)
 	 */
 	open_files ();
 	if (   cflg || dflg || eflg || fflg || gflg || Lflg || lflg || pflg
-	    || sflg || uflg || Uflg) {
+	    || sflg || uflg || Uflg || vflg || Vflg || wflg || Wflg) {
 		usr_update ();
 	}
 	if (Gflg || lflg) {
-- 
1.7.5.4
