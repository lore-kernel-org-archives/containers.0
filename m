From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/3] Use triggers in force_empty and max_usage files
Date: Thu, 13 Mar 2008 14:37:23 +0300
Message-ID: <47D911F3.1050108@openvz.org>
References: <47D9114F.6020301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D9114F.6020301-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 mm/memcontrol.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c27141d..d3ec3e3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -868,27 +868,18 @@ static ssize_t mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 				mem_cgroup_write_strategy);
 }
 
-static ssize_t mem_cgroup_max_reset(struct cgroup *cont, struct cftype *cft,
-				struct file *file, const char __user *userbuf,
-				size_t nbytes, loff_t *ppos)
+static int mem_cgroup_max_reset(struct cgroup *cont, unsigned int event)
 {
 	struct mem_cgroup *mem;
 
 	mem = mem_cgroup_from_cont(cont);
 	res_counter_reset_max(&mem->res);
-	return nbytes;
+	return 0;
 }
 
-static ssize_t mem_force_empty_write(struct cgroup *cont,
-				struct cftype *cft, struct file *file,
-				const char __user *userbuf,
-				size_t nbytes, loff_t *ppos)
+static int mem_force_empty_write(struct cgroup *cont, unsigned int event)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	int ret = mem_cgroup_force_empty(mem);
-	if (!ret)
-		ret = nbytes;
-	return ret;
+	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
 }
 
 static const struct mem_cgroup_stat_desc {
@@ -936,7 +927,7 @@ static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "max_usage_in_bytes",
 		.private = RES_MAX_USAGE,
-		.write = mem_cgroup_max_reset,
+		.trigger = mem_cgroup_max_reset,
 		.read_u64 = mem_cgroup_read,
 	},
 	{
@@ -952,7 +943,7 @@ static struct cftype mem_cgroup_files[] = {
 	},
 	{
 		.name = "force_empty",
-		.write = mem_force_empty_write,
+		.trigger = mem_force_empty_write,
 	},
 	{
 		.name = "stat",
-- 
1.5.3.4
