From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 2/3] cgroup : make the mount options parsing more accurate
Date: Thu, 29 Jul 2010 14:57:36 -0500
Message-ID: <20100729195736.GA19015__40927.3966019557$1280433878$gmane$org@hallyn.com>
References: <20100729195629.GA13378@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100729195629.GA13378-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

The actual code does not detect 'all' with one subsystem name, which
is IMHO mutually exclusive and when an option is specified even if it
is not a subsystem name, we have to specify the 'all' option with the
other option.
eg:
 not detected : mount -t cgroup -o all,freezer cgroup /cgroup
 not flexible : mount -t cgroup -o noprefix,all cgroup /cgroup

This patch fix this and makes the code a bit more clear by replacing
'else if' indentation by 'continue' blocks in the loop.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |   91 +++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 61 insertions(+), 30 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index dfbff78..09fb6f9 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1074,7 +1074,8 @@ struct cgroup_sb_opts {
  */
 static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 {
-	char *token, *o = data ?: "all";
+	char *token, *o = data;
+	bool all_ss = false, one_ss = false;
 	unsigned long mask = (unsigned long)-1;
 	int i;
 	bool module_pin_failed = false;
@@ -1088,26 +1089,30 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	memset(opts, 0, sizeof(*opts));
 
 	while ((token = strsep(&o, ",")) != NULL) {
+
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
 			set_bit(ROOT_CLONE_CHILDREN, &opts->flags);
-		} else if (!strncmp(token, "release_agent=", 14)) {
+			continue;
+		}
+		if (!strncmp(token, "release_agent=", 14)) {
 			/* Specifying two release agents is forbidden */
 			if (opts->release_agent)
 				return -EINVAL;
@@ -1115,7 +1120,9 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 				kstrndup(token + 14, PATH_MAX, GFP_KERNEL);
 			if (!opts->release_agent)
 				return -ENOMEM;
-		} else if (!strncmp(token, "name=", 5)) {
+			continue;
+		}
+		if (!strncmp(token, "name=", 5)) {
 			const char *name = token + 5;
 			/* Can't specify an empty name */
 			if (!strlen(name))
@@ -1137,20 +1144,44 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
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
