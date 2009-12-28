From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [patch 1/2] Add clone_child control file
Date: Tue, 29 Dec 2009 00:04:55 +0100
Message-ID: <20091228230620.494084022@mai.lab.toulouse-stg.fr.ibm.com>
References: <20091228230454.000895089@mai.lab.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=cgroup-clone-parent.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |   14 ++++++++++++--
 include/linux/cgroup.h            |    4 ++++
 kernel/cgroup.c                   |   26 ++++++++++++++++++++++++++
 3 files changed, 42 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/cgroup.h
===================================================================
--- linux-2.6.orig/include/linux/cgroup.h
+++ linux-2.6/include/linux/cgroup.h
@@ -139,6 +139,10 @@ enum {
 	 * A thread in rmdir() is wating for this cgroup.
 	 */
 	CGRP_WAIT_ON_RMDIR,
+	/*
+	 * Clone cgroup values when creating a new child cgroup
+	 */
+	CGRP_CLONE_CHILDREN,
 };
 
 /* which pidlist file are we talking about? */
Index: linux-2.6/kernel/cgroup.c
===================================================================
--- linux-2.6.orig/kernel/cgroup.c
+++ linux-2.6/kernel/cgroup.c
@@ -2789,6 +2789,23 @@ static int cgroup_write_notify_on_releas
 	return 0;
 }
 
+static u64 cgroup_clone_children_read(struct cgroup *cgrp,
+				    struct cftype *cft)
+{
+	return test_bit(CGRP_CLONE_CHILDREN, &cgrp->flags);
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
@@ -2814,6 +2831,11 @@ static struct cftype files[] = {
 		.read_u64 = cgroup_read_notify_on_release,
 		.write_u64 = cgroup_write_notify_on_release,
 	},
+	{
+		.name = "clone_children",
+		.read_u64 = cgroup_clone_children_read,
+		.write_u64 = cgroup_clone_children_write,
+	},
 };
 
 static struct cftype cft_release_agent = {
@@ -2946,6 +2968,10 @@ static long cgroup_create(struct cgroup 
 			if (alloc_css_id(ss, parent, cgrp))
 				goto err_destroy;
 		/* At error, ->destroy() callback has to free assigned ID. */
+
+		if (test_bit(CGRP_CLONE_CHILDREN, &parent->flags))
+			if (ss->post_clone)
+				ss->post_clone(ss, cgrp);
 	}
 
 	cgroup_lock_hierarchy(root);
Index: linux-2.6/Documentation/cgroups/cgroups.txt
===================================================================
--- linux-2.6.orig/Documentation/cgroups/cgroups.txt
+++ linux-2.6/Documentation/cgroups/cgroups.txt
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
@@ -292,7 +293,16 @@ notify_on_release in the root cgroup at 
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
