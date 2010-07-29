From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH 1/3] cgroup : add clone_children control file
Date: Thu, 29 Jul 2010 14:56:29 -0500
Message-ID: <20100729195629.GA13378__14199.494632385$1280433670$gmane$org@hallyn.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch is sent as an answer to a previous thread around the ns_cgroup.

https://lists.linux-foundation.org/pipermail/containers/2009-June/018627.html

It adds a control file 'clone_children' for a cgroup.
This control file is a boolean specifying if the child cgroup should
be a clone of the parent cgroup or not. The default value is 'false'.

This flag makes the child cgroup to call the post_clone callback of all
the subsystem, if it is available.

At present, the cpuset is the only one which had implemented the post_clone
callback.

The option can be set at mount time by specifying the 'clone_children' mount
option.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   14 +++++++++++-
 include/linux/cgroup.h            |    4 +++
 kernel/cgroup.c                   |   39 +++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index b34823f..190018b 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -18,7 +18,8 @@ CONTENTS:
   1.2 Why are cgroups needed ?
   1.3 How are cgroups implemented ?
   1.4 What does notify_on_release do ?
-  1.5 How do I use cgroups ?
+  1.5 What does clone_children do ?
+  1.6 How do I use cgroups ?
 2. Usage Examples and Syntax
   2.1 Basic Usage
   2.2 Attaching processes
@@ -293,7 +294,16 @@ notify_on_release in the root cgroup at system boot is disabled
 value of their parents notify_on_release setting. The default value of
 a cgroup hierarchy's release_agent path is empty.
 
-1.5 How do I use cgroups ?
+1.5 What does clone_children do ?
+---------------------------------
+
+If the clone_children flag is enabled (1) in a cgroup, then all
+cgroups created beneath will call the post_clone callbacks for each
+subsystem of the newly created cgroup. Usually when this callback is
+implemented for a subsystem, it copies the values of the parent
+subsystem, this is the case for the cpuset.
+
+1.6 How do I use cgroups ?
 --------------------------
 
 To start a new job that is to be contained within a cgroup, using
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index e3d00fd..f3cbd73 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -154,6 +154,10 @@ enum {
 	 * A thread in rmdir() is wating for this cgroup.
 	 */
 	CGRP_WAIT_ON_RMDIR,
+	/*
+	 * Clone cgroup values when creating a new child cgroup
+	 */
+	CGRP_CLONE_CHILDREN,
 };
 
 /* which pidlist file are we talking about? */
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3ac6f5b..dfbff78 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -229,6 +229,7 @@ inline int cgroup_is_removed(const struct cgroup *cgrp)
 /* bits in struct cgroupfs_root flags field */
 enum {
 	ROOT_NOPREFIX, /* mounted subsystems have no named prefix */
+	ROOT_CLONE_CHILDREN, /* mounted subsystems will inherit from parent */
 };
 
 static int cgroup_is_releasable(const struct cgroup *cgrp)
@@ -244,6 +245,11 @@ static int notify_on_release(const struct cgroup *cgrp)
 	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
 }
 
+static int clone_children(const struct cgroup *cgrp)
+{
+	return test_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
+}
+
 /*
  * for_each_subsys() allows you to iterate on each subsystem attached to
  * an active hierarchy
@@ -1038,6 +1044,8 @@ static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
 		seq_printf(seq, ",%s", ss->name);
 	if (test_bit(ROOT_NOPREFIX, &root->flags))
 		seq_puts(seq, ",noprefix");
+	if (test_bit(ROOT_CLONE_CHILDREN, &root->flags))
+		seq_puts(seq, ",clone_children");
 	if (strlen(root->release_agent_path))
 		seq_printf(seq, ",release_agent=%s", root->release_agent_path);
 	if (strlen(root->name))
@@ -1097,6 +1105,8 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 			opts->none = true;
 		} else if (!strcmp(token, "noprefix")) {
 			set_bit(ROOT_NOPREFIX, &opts->flags);
+		} else if (!strcmp(token, "clone_children")) {
+			set_bit(ROOT_CLONE_CHILDREN, &opts->flags);
 		} else if (!strncmp(token, "release_agent=", 14)) {
 			/* Specifying two release agents is forbidden */
 			if (opts->release_agent)
@@ -1357,6 +1367,8 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 		strcpy(root->release_agent_path, opts->release_agent);
 	if (opts->name)
 		strcpy(root->name, opts->name);
+	if (test_bit(ROOT_CLONE_CHILDREN, &opts->flags))
+		set_bit(CGRP_CLONE_CHILDREN, &root->top_cgroup.flags);
 	return root;
 }
 
@@ -3150,6 +3162,23 @@ fail:
 	return ret;
 }
 
+static u64 cgroup_clone_children_read(struct cgroup *cgrp,
+				    struct cftype *cft)
+{
+	return clone_children(cgrp);
+}
+
+static int cgroup_clone_children_write(struct cgroup *cgrp,
+				     struct cftype *cft,
+				     u64 val)
+{
+	if (val)
+		set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
+	else
+		clear_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
+	return 0;
+}
+
 /*
  * for the common functions, 'private' gives the type of file
  */
@@ -3180,6 +3209,11 @@ static struct cftype files[] = {
 		.write_string = cgroup_write_event_control,
 		.mode = S_IWUGO,
 	},
+	{
+		.name = "cgroup.clone_children",
+		.read_u64 = cgroup_clone_children_read,
+		.write_u64 = cgroup_clone_children_write,
+	},
 };
 
 static struct cftype cft_release_agent = {
@@ -3309,6 +3343,9 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (notify_on_release(parent))
 		set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
 
+	if (clone_children(parent))
+		set_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
+
 	for_each_subsys(root, ss) {
 		struct cgroup_subsys_state *css = ss->create(ss, cgrp);
 
@@ -3323,6 +3360,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 				goto err_destroy;
 		}
 		/* At error, ->destroy() callback has to free assigned ID. */
+		if (clone_children(parent) && ss->post_clone)
+			ss->post_clone(ss, cgrp);
 	}
 
 	cgroup_lock_hierarchy(root);
-- 
1.7.0.4
