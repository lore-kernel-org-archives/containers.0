From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/9] [RFC] Remove the cgroup_subsys.bind callback
Date: Wed, 01 Jul 2009 19:11:23 -0700
Message-ID: <20090702021123.14469.90837.stgit@menage.mtv.corp.google.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702020624.14469.47066.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

[RFC] Remove the cgroup_subsys.bind callback

In preparation for supporting cgroup subsystems that can be bound to
multiple hierarchies, remove the "bind" callback. It's not currently
used by any in-tree subsystem and its semantics become fuzzy for
multi-bindable subsystems.  It can be re-added with clearer semantics
in the future if necessary.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 Documentation/cgroups/cgroups.txt |    8 --------
 include/linux/cgroup.h            |    1 -
 kernel/cgroup.c                   |    4 ----
 3 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 6eb1a97..d5be8ae 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -544,14 +544,6 @@ initialization which might be required before a task could attach.  For
 example in cpusets, no task may attach before 'cpus' and 'mems' are set
 up.
 
-void bind(struct cgroup_subsys *ss, struct cgroup *root)
-(cgroup_mutex and ss->hierarchy_mutex held by caller)
-
-Called when a cgroup subsystem is rebound to a different hierarchy
-and root cgroup. Currently this will only involve movement between
-the default hierarchy (which never has sub-cgroups) and a hierarchy
-that is being created/destroyed (and hence has no sub-cgroups).
-
 4. Questions
 ============
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index adf6739..a6bb0ca 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -386,7 +386,6 @@ struct cgroup_subsys {
 	int (*populate)(struct cgroup_subsys *ss,
 			struct cgroup *cgrp);
 	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
-	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
 
 	int subsys_id;
 	int active;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 8b1b92f..74840ea 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -897,8 +897,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			mutex_lock(&ss->hierarchy_mutex);
 			cgrp->subsys[i] = dummytop->subsys[i];
 			cgrp->subsys[i]->cgroup = cgrp;
-			if (ss->bind)
-				ss->bind(ss, cgrp);
 			rootnode.subsys_bits &= ~bit;
 			root->subsys_bits |= bit;
 			mutex_unlock(&ss->hierarchy_mutex);
@@ -908,8 +906,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
 			BUG_ON(rootnode.subsys_bits & bit);
 			mutex_lock(&ss->hierarchy_mutex);
-			if (ss->bind)
-				ss->bind(ss, dummytop);
 			dummytop->subsys[i]->cgroup = dummytop;
 			cgrp->subsys[i] = NULL;
 			root->subsys_bits &= ~bit;
