From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH] cgroup: notify ns_cgroup deprecated
Date: Wed, 29 Sep 2010 23:21:41 +0200
Message-ID: <1285795301-2684-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

The ns_cgroup will be removed very soon. Let's warn, for this
version, ns_cgroup is deprecated.

Make ns_cgroup and clone_children exclusive. If the clone_children
is set and the ns_cgroup is mounted, let's fail with EINVAL when
the ns_cgroup subsys is created (a printk will help the user to
understand why the creation fails).

Update the feature remove schedule file with the deprecated ns_cgroup.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 Documentation/feature-removal-schedule.txt |   17 +++++++++++++++++
 kernel/ns_cgroup.c                         |    8 ++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index b32911b..a39e2f3 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -545,4 +545,21 @@ Why:    This is a legacy interface which have been replaced by a more
 Who:    NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
 
 ----------------------------
+
+What:   namespace cgroup (ns_cgroup)
+When:   2.6.38
+Why:    The ns_cgroup leads to some problems:
+	* cgroup creation is out-of-control
+	* cgroup name can conflict when pids are looping
+	* it is not possible to have a single process handling
+	a lot of namespaces without falling in a exponential creation time
+	* we may want to create a namespace without creating a cgroup
+
+	The ns_cgroup is replaced by a compatibility flag 'clone_children',
+	where a newly created cgroup will copy the parent cgroup values.
+	The userspace has to manually create a cgroup and add a task to
+	the 'tasks' file.
+Who:    Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
+
+----------------------------
 	
diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
index 2a5dfec..2c98ad9 100644
--- a/kernel/ns_cgroup.c
+++ b/kernel/ns_cgroup.c
@@ -85,6 +85,14 @@ static struct cgroup_subsys_state *ns_create(struct cgroup_subsys *ss,
 		return ERR_PTR(-EPERM);
 	if (!cgroup_is_descendant(cgroup, current))
 		return ERR_PTR(-EPERM);
+	if (test_bit(CGRP_CLONE_CHILDREN, &cgroup->flags)) {
+		printk("ns_cgroup can't be created with parent "
+		       "'clone_children' set.\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	printk_once("ns_cgroup deprecated: consider using the "
+		    "'clone_children' flag without the ns_cgroup.\n");
 
 	ns_cgroup = kzalloc(sizeof(*ns_cgroup), GFP_KERNEL);
 	if (!ns_cgroup)
-- 
1.7.0.4
