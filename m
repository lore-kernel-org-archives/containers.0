From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 2/3][V2] cgroup : make the mount options parsing more accurate
Date: Mon, 27 Sep 2010 12:14:12 +0200
Message-ID: <1285582453-6127-3-git-send-email-daniel.lezcano@free.fr>
References: <1285582453-6127-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285582453-6127-1-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Current behavior:
=================

(1) When we mount a cgroup, we can specify the 'all' option which means
to enable all the cgroup subsystems. This is the default option when
no option is specified.

(2) If we want to mount a cgroup with a subset of the supported cgroup
subsystems, we have to specify a subsystems name list for the mount
option.

(3) If we specify another option like 'noprefix' or 'release_agent', the
actual code wants the 'all' or a subsystem name option specified also.
Not critical but a bit not friendly as we should assume (1) in this case.

(4) Logically, the 'all' option is mutually exclusive with a subsystem
name, but this is not detected.

In other words:
 succeed : mount -t cgroup -o all,freezer cgroup /cgroup
	=> is it 'all' or 'freezer' ?
 fails : mount -t cgroup -o noprefix cgroup /cgroup
	=> succeed if we do '-o noprefix,all'

The following patches consolidate a bit the mount options check.

New behavior:
=============

(1) untouched
(2) untouched
(3) the 'all' option will be by default when specifying other than
    a subsystem name option
(4) raises an error

In other words:
 fails   : mount -t cgroup -o all,freezer cgroup /cgroup
 succeed : mount -t cgroup -o noprefix cgroup /cgroup

For the sake of lisibility, the if ... then ... else ... if ...
indentation when parsing the options has been changed to:
if ... then
	...
	continue
fi

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |   90 ++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 60 insertions(+), 30 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7b17c3e..9eace43 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1073,7 +1073,8 @@ struct cgroup_sb_opts {
  */
 static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 {
-	char *token, *o = data ?: "all";
+	char *token, *o = data;
+	bool all_ss = false, one_ss = false;
 	unsigned long mask = (unsigned long)-1;
 	int i;
 	bool module_pin_failed = false;
@@ -1089,24 +1090,27 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	while ((token = strsep(&o, ",")) != NULL) {
 		if (!*token)
 			return -EINVAL;
-		if (!strcmp(token, "all")) {
-			/* Add all non-disabled subsystems */
-			opts->subsys_bits = 0;
-			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-				struct cgroup_subsys *ss = subsys[i];
-				if (ss == NULL)
-					continue;
-				if (!ss->disabled)
-					opts->subsys_bits |= 1ul << i;
-			}
-		} else if (!strcmp(token, "none")) {
+		if (!strcmp(token, "none")) {
 			/* Explicitly have no subsystems */
 			opts->none = true;
-		} else if (!strcmp(token, "noprefix")) {
+			continue;
+		}
+		if (!strcmp(token, "all")) {
+			/* Mutually exclusive option 'all' + subsystem name */
+			if (one_ss)
+				return -EINVAL;
+			all_ss = true;
+			continue;
+		}
+		if (!strcmp(token, "noprefix")) {
 			set_bit(ROOT_NOPREFIX, &opts->flags);
-		} else if (!strcmp(token, "clone_children")) {
+			continue;
+		}
+		if (!strcmp(token, "clone_children")) {
 			opts->clone_children = true;
-		} else if (!strncmp(token, "release_agent=", 14)) {
+			continue;
+		}
+		if (!strncmp(token, "release_agent=", 14)) {
 			/* Specifying two release agents is forbidden */
 			if (opts->release_agent)
 				return -EINVAL;
@@ -1114,7 +1118,9 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 				kstrndup(token + 14, PATH_MAX - 1, GFP_KERNEL);
 			if (!opts->release_agent)
 				return -ENOMEM;
-		} else if (!strncmp(token, "name=", 5)) {
+			continue;
+		}
+		if (!strncmp(token, "name=", 5)) {
 			const char *name = token + 5;
 			/* Can't specify an empty name */
 			if (!strlen(name))
@@ -1136,20 +1142,44 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 					      GFP_KERNEL);
 			if (!opts->name)
 				return -ENOMEM;
-		} else {
-			struct cgroup_subsys *ss;
-			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-				ss = subsys[i];
-				if (ss == NULL)
-					continue;
-				if (!strcmp(token, ss->name)) {
-					if (!ss->disabled)
-						set_bit(i, &opts->subsys_bits);
-					break;
-				}
-			}
-			if (i == CGROUP_SUBSYS_COUNT)
-				return -ENOENT;
+
+			continue;
+		}
+
+		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+			struct cgroup_subsys *ss = subsys[i];
+			if (ss == NULL)
+				continue;
+			if (strcmp(token, ss->name))
+				continue;
+			if (ss->disabled)
+				continue;
+
+			/* Mutually exclusive option 'all' + subsystem name */
+			if (all_ss)
+				return -EINVAL;
+			set_bit(i, &opts->subsys_bits);
+			one_ss = true;
+
+			break;
+		}
+		if (i == CGROUP_SUBSYS_COUNT)
+			return -ENOENT;
+	}
+
+	/*
+	 * If the 'all' option was specified select all the subsystems,
+	 * otherwise 'all, 'none' and a subsystem name options were not
+	 * specified, let's default to 'all'
+	 */
+	if (all_ss || (!all_ss && !one_ss && !opts->none)) {
+		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+			struct cgroup_subsys *ss = subsys[i];
+			if (ss == NULL)
+				continue;
+			if (ss->disabled)
+				continue;
+			set_bit(i, &opts->subsys_bits);
 		}
 	}
 
-- 
1.7.0.4
