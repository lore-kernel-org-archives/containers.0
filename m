From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/11] cpuset: inherite ancestor's masks if real_{cpus,
	mems}_allowed become empty
Date: Wed, 21 Aug 2013 17:59:44 +0800
Message-ID: <52148F90.7070809@huawei.com>
References: <52148F52.0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52148F52.0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

We're going to have separate user-configured masks and effective ones.

At last configured masks can only be changed by writing cpuset.cpus
and cpuset.mems, and they won't be restricted by parent cpuset. While
effective masks reflect cpu/memory hotplug and hierachical restriction.

This is a preparation to make real_{cpus,mems}_allowed to be effective
masks of the cpuset:

- change the effective masks at hotplug: done
- change the effective masks at config change: done
- take on ancestor's mask when the effective mask is empty: done

This won't introduce behavior change.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 72afef4..b7b63dd 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -904,12 +904,14 @@ static void update_cpumasks_hier(struct cpuset *cs, struct cpuset *trialcs,
 			    parent->real_cpus_allowed);
 
 		/*
-		 * Skip the whole subtree if the cpumask is not changed, unless
-		 * it's empty, and in this case we need to update tasks to take
-		 * on an ancestor's cpumask.
+		 * If it becomes empty, inherite the effective mask of the
+		 * parent, which is guarantted to have some CPUs.
 		 */
-		if (cpumask_equal(new_cpus, cp->real_cpus_allowed) &&
-		    ((cp == cs) || !cpumask_empty(new_cpus))) {
+		if (cpumask_empty(new_cpus))
+			cpumask_copy(new_cpus, parent->real_cpus_allowed);
+
+		/* Skip the whole subtree if the cpumask is not changed. */
+		if (cpumask_equal(new_cpus, cp->real_cpus_allowed)) {
 			pos_css = css_rightmost_descendant(pos_css);
 			continue;
 		}
@@ -1168,12 +1170,14 @@ static void update_nodemasks_hier(struct cpuset *cs, struct cpuset *trialcs,
 			  parent->real_mems_allowed);
 
 		/*
-		 * Skip the whole subtree if the nodemask is not changed, unless
-		 * it's empty, and in this case we need to update tasks to take
-		 * on an ancestor's nodemask.
+		 * If it becoms empty, inherite the effective mask of the
+		 * parent, which is guaranteed to have some MEMs.
 		 */
-		if (nodes_equal(*new_mems, cp->real_mems_allowed) &&
-		    ((cp == cs) || !nodes_empty(*new_mems))) {
+		if (nodes_empty(*new_mems))
+			*new_mems = parent->real_mems_allowed;
+
+		/* Skip the whole subtree if the nodemask is not changed. */
+		if (nodes_equal(*new_mems, cp->real_mems_allowed)) {
 			pos_css = css_rightmost_descendant(pos_css);
 			continue;
 		}
@@ -2202,8 +2206,13 @@ retry:
 
 	mutex_lock(&callback_mutex);
 	cpumask_andnot(cs->cpus_allowed, cs->cpus_allowed, &off_cpus);
+
 	cpumask_andnot(cs->real_cpus_allowed, cs->real_cpus_allowed,
 		       &off_cpus);
+	/* Inherite the effective mask of the parent, if it becomes empty */
+	if (cpumask_empty(cs->real_cpus_allowed))
+		cpumask_copy(cs->real_cpus_allowed,
+			     parent_cs(cs)->real_cpus_allowed);
 	mutex_unlock(&callback_mutex);
 
 	/*
@@ -2218,7 +2227,11 @@ retry:
 
 	mutex_lock(&callback_mutex);
 	nodes_andnot(cs->mems_allowed, cs->mems_allowed, off_mems);
+
 	nodes_andnot(cs->real_mems_allowed, cs->real_mems_allowed, off_mems);
+	/* Inherite the effective mask of the parent, if it becomes empty */
+	if (nodes_empty(cs->real_mems_allowed))
+		cs->real_mems_allowed = parent_cs(cs)->real_mems_allowed;
 	mutex_unlock(&callback_mutex);
 
 	/*
-- 
1.8.0.2
