From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: reduce size of per-cpu-stat to be appropriate
 size.(v2)
Date: Fri, 14 Nov 2008 16:18:36 +0900
Message-ID: <20081114161836.6f8f609e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081113164201.GV29067@bolzano.suse.de>
	<20081113191837.18ed2ade.akpm@linux-foundation.org>
	<491CF609.3050203@cn.fujitsu.com>
	<20081114132840.98d38f12.kamezawa.hiroyu@jp.fujitsu.com>
	<20081114144926.d91f36fd.kamezawa.hiroyu@jp.fujitsu.com>
	<491D1A17.2060404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751982AbYKNHTb@vger.kernel.org>
In-Reply-To: <491D1A17.2060404@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Blunck <jblunck@suse.de>, containers@lists.osdl.org, Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Fri, 14 Nov 2008 14:26:31 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:
> free_out:
> 	for_each_node_state(node, N_POSSIBLE)
> 		free_mem_cgroup_per_zone_info(mem, node);
> 	if (cont->parent != NULL)       <---- this check should be removed
> 		mem_cgroup_free(mem);
> 
> 
Exactrly. fixed one is here.
-Kame
==
As  Jan Blunck <jblunck@suse.de> pointed out, allocating
per-cpu stat for memcg to the size of NR_CPUS is not good.

This patch changes mem_cgroup's cpustat allocation not based
on NR_CPUS but based on nr_cpu_ids.

Changelog:
 - fixed lack of logic in error path.

From: Jan Blunck <jblunck@suse.de>
Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

Index: mmotm-2.6.28-Nov10/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov10.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov10/mm/memcontrol.c
@@ -60,7 +60,7 @@ struct mem_cgroup_stat_cpu {
 } ____cacheline_aligned_in_smp;
 
 struct mem_cgroup_stat {
-	struct mem_cgroup_stat_cpu cpustat[NR_CPUS];
+	struct mem_cgroup_stat_cpu cpustat[0];
 };
 
 /*
@@ -129,11 +129,10 @@ struct mem_cgroup {
 
 	int	prev_priority;	/* for recording reclaim priority */
 	/*
-	 * statistics.
+	 * statistics. This must be placed at the end of memcg.
 	 */
 	struct mem_cgroup_stat stat;
 };
-static struct mem_cgroup init_mem_cgroup;
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -1292,23 +1291,30 @@ static void free_mem_cgroup_per_zone_inf
 	kfree(mem->info.nodeinfo[node]);
 }
 
+static int mem_cgroup_size(void)
+{
+	int cpustat_size = nr_cpu_ids * sizeof(struct mem_cgroup_stat_cpu);
+	return sizeof(struct mem_cgroup) + cpustat_size;
+}
+
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
 	struct mem_cgroup *mem;
+	int size = mem_cgroup_size();
 
-	if (sizeof(*mem) < PAGE_SIZE)
-		mem = kmalloc(sizeof(*mem), GFP_KERNEL);
+	if (size < PAGE_SIZE)
+		mem = kmalloc(size, GFP_KERNEL);
 	else
-		mem = vmalloc(sizeof(*mem));
+		mem = vmalloc(size);
 
 	if (mem)
-		memset(mem, 0, sizeof(*mem));
+		memset(mem, 0, size);
 	return mem;
 }
 
 static void mem_cgroup_free(struct mem_cgroup *mem)
 {
-	if (sizeof(*mem) < PAGE_SIZE)
+	if (mem_cgroup_size() < PAGE_SIZE)
 		kfree(mem);
 	else
 		vfree(mem);
@@ -1321,13 +1327,9 @@ mem_cgroup_create(struct cgroup_subsys *
 	struct mem_cgroup *mem;
 	int node;
 
-	if (unlikely((cont->parent) == NULL)) {
-		mem = &init_mem_cgroup;
-	} else {
-		mem = mem_cgroup_alloc();
-		if (!mem)
-			return ERR_PTR(-ENOMEM);
-	}
+	mem = mem_cgroup_alloc();
+	if (!mem)
+		return ERR_PTR(-ENOMEM);
 
 	res_counter_init(&mem->res);
 
@@ -1339,8 +1341,7 @@ mem_cgroup_create(struct cgroup_subsys *
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
-	if (cont->parent != NULL)
-		mem_cgroup_free(mem);
+	mem_cgroup_free(mem);
 	return ERR_PTR(-ENOMEM);
 }
 
