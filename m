From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 02/10] cpuset: cleanup guarantee_online_{cpus|mems}()
Date: Wed, 5 Jun 2013 17:15:23 +0800
Message-ID: <51AF01AB.2070405__36483.9613474489$1370423755$gmane$org@huawei.com>
References: <51AF0183.8070602@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51AF0183.8070602-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

- We never pass a NULL @cs to these functions.
- The top cpuset always has some online cpus/mems.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f0c884a..d753837 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -304,53 +304,38 @@ static struct file_system_type cpuset_fs_type = {
 /*
  * Return in pmask the portion of a cpusets's cpus_allowed that
  * are online.  If none are online, walk up the cpuset hierarchy
- * until we find one that does have some online cpus.  If we get
- * all the way to the top and still haven't found any online cpus,
- * return cpu_online_mask.  Or if passed a NULL cs from an exit'ing
- * task, return cpu_online_mask.
+ * until we find one that does have some online cpus.  The top
+ * cpuset always has some cpus online.
  *
  * One way or another, we guarantee to return some non-empty subset
  * of cpu_online_mask.
  *
  * Call with callback_mutex held.
  */
-
 static void guarantee_online_cpus(const struct cpuset *cs,
 				  struct cpumask *pmask)
 {
-	while (cs && !cpumask_intersects(cs->cpus_allowed, cpu_online_mask))
+	while (!cpumask_intersects(cs->cpus_allowed, cpu_online_mask))
 		cs = parent_cs(cs);
-	if (cs)
-		cpumask_and(pmask, cs->cpus_allowed, cpu_online_mask);
-	else
-		cpumask_copy(pmask, cpu_online_mask);
-	BUG_ON(!cpumask_intersects(pmask, cpu_online_mask));
+	cpumask_and(pmask, cs->cpus_allowed, cpu_online_mask);
 }
 
 /*
  * Return in *pmask the portion of a cpusets's mems_allowed that
  * are online, with memory.  If none are online with memory, walk
  * up the cpuset hierarchy until we find one that does have some
- * online mems.  If we get all the way to the top and still haven't
- * found any online mems, return node_states[N_MEMORY].
+ * online mems.  The top cpuset always has some mems online.
  *
  * One way or another, we guarantee to return some non-empty subset
  * of node_states[N_MEMORY].
  *
  * Call with callback_mutex held.
  */
-
 static void guarantee_online_mems(const struct cpuset *cs, nodemask_t *pmask)
 {
-	while (cs && !nodes_intersects(cs->mems_allowed,
-					node_states[N_MEMORY]))
+	while (!nodes_intersects(cs->mems_allowed, node_states[N_MEMORY]))
 		cs = parent_cs(cs);
-	if (cs)
-		nodes_and(*pmask, cs->mems_allowed,
-					node_states[N_MEMORY]);
-	else
-		*pmask = node_states[N_MEMORY];
-	BUG_ON(!nodes_intersects(*pmask, node_states[N_MEMORY]));
+	nodes_and(*pmask, cs->mems_allowed, node_states[N_MEMORY]);
 }
 
 /*
-- 
1.8.0.2
