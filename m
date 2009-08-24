From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Mon, 24 Aug 2009 16:11:15 +0200
Message-ID: <4A929F83.80207@free.fr>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>	
	<4A924D11.80002@free.fr>	
	<ac1c4bf20908240125q1e126cdq2d2b7659ca167d52@mail.gmail.com>	
	<4A924F5C.1000208@fr.ibm.com>	
	<ac1c4bf20908240138l67cfabfcid2bb7224a1f6ab24@mail.gmail.com>	
	<4A925794.7050808@free.fr>	
	<ac1c4bf20908240245ydbc1b9bxacfcf2398049505c@mail.gmail.com>	
	<4A92676A.1080609@free.fr>	
	<ac1c4bf20908240327u424bd021t8848cf1cafb24ada@mail.gmail.com>	
	<4A9275CB.7030108@free.fr>
	<ac1c4bf20908240431p1fda5a15qd26629618397696@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090605020709040108060009"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20908240431p1fda5a15qd26629618397696-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------090605020709040108060009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



[ snip ]
>>> i think that /proc/meminfo should be mounted after /proc . why? i think
>>> that, because mounting /proc may override /proc/meminfo
>>> Am I right? :)
>>>
>>>
>>>       
>> Ha ! haha ! arrgh ! no way ! You are right :/
>>
>>     
>
> Hehe ;)
>
>   
>> In the case of application container, lxc mounts /proc but in the case of
>> system container it is the system who do that so after the /proc/meminfo has
>> been mounted.
>>
>> Maybe we can look at modifying fs/proc/meminfo.c instead. Let me do a small
>> patch for the kernel...
>>
>>
>>     
> Okey. I am waiting for your patch :)

Quick and dirty patch but at least working. It is no synced on the 
latest kernel version.
I do not really like to touch fs/proc/meminfo.c but it's an example here.

--------------090605020709040108060009
Content-Type: text/x-diff;
 name="enhance-meminfo-with-memcontrol.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="enhance-meminfo-with-memcontrol.patch"

Subject: use memory controller to display meminfo
From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

This patch modify the meminfo code to display informations related to the
memory cgroup controller. The ensure the consistency for the tools running
in the container.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 fs/proc/meminfo.c          |   15 ++++++++-
 include/linux/memcontrol.h |    2 +
 mm/memcontrol.c            |   71 ++++++++++++++++++++++++++++++++-------------
 3 files changed, 67 insertions(+), 21 deletions(-)

Index: linux-2.6/include/linux/memcontrol.h
===================================================================
--- linux-2.6.orig/include/linux/memcontrol.h
+++ linux-2.6/include/linux/memcontrol.h
@@ -117,6 +117,8 @@ static inline bool mem_cgroup_disabled(v
 
 extern bool mem_cgroup_oom_called(struct task_struct *task);
 
+extern int mem_cgroup_info(struct task_struct *task, struct sysinfo *info);
+
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
Index: linux-2.6/mm/memcontrol.c
===================================================================
--- linux-2.6.orig/mm/memcontrol.c
+++ linux-2.6/mm/memcontrol.c
@@ -128,6 +128,29 @@ struct mem_cgroup_lru_info {
 	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
 };
 
+/* For read statistics */
+enum {
+	MCS_CACHE,
+	MCS_RSS,
+	MCS_PGPGIN,
+	MCS_PGPGOUT,
+	MCS_INACTIVE_ANON,
+	MCS_ACTIVE_ANON,
+	MCS_INACTIVE_FILE,
+	MCS_ACTIVE_FILE,
+	MCS_UNEVICTABLE,
+	NR_MCS_STAT,
+};
+
+struct mcs_total_stat {
+	s64 stat[NR_MCS_STAT];
+};
+
+static int mem_cgroup_get_local_stat(struct mem_cgroup *mem, void *data);
+static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
+					 unsigned long long *mem_limit,
+					 unsigned long long *memsw_limit);
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -1794,6 +1817,35 @@ static int mem_cgroup_force_empty_list(s
 	return ret;
 }
 
+int mem_cgroup_info(struct task_struct *task, struct sysinfo *info)
+{
+	struct mem_cgroup *mem_cont = mem_cgroup_from_task(task);
+	struct mcs_total_stat mystat = { };
+	u64 limit, memsw_limit, swap_in_u, m_usage, s_usage;
+
+	s_usage = res_counter_read_u64(&mem_cont->memsw, RES_USAGE);
+	m_usage = res_counter_read_u64(&mem_cont->res, RES_USAGE);
+	swap_in_u = s_usage - m_usage;
+
+	mem_cgroup_get_local_stat(mem_cont, &mystat);
+	memcg_get_hierarchical_limit(mem_cont, &limit, &memsw_limit);
+
+        si_meminfo(info);
+        si_swapinfo(info);
+
+	if (limit != LLONG_MAX) {
+		info->totalram = limit / info->mem_unit;
+		info->freeram = (limit - mystat.stat[MCS_RSS]) / info->mem_unit;
+	}
+
+	if (memsw_limit != LLONG_MAX) {
+		info->totalswap = memsw_limit / info->mem_unit;
+		info->freeswap = (memsw_limit - swap_in_u) / info->mem_unit;
+	}
+
+	return 0;
+}
+
 /*
  * make mem_cgroup's charge to be 0 if there is no task.
  * This enables deleting this mem_cgroup.
@@ -2030,25 +2082,6 @@ static int mem_cgroup_reset(struct cgrou
 	return 0;
 }
 
-
-/* For read statistics */
-enum {
-	MCS_CACHE,
-	MCS_RSS,
-	MCS_PGPGIN,
-	MCS_PGPGOUT,
-	MCS_INACTIVE_ANON,
-	MCS_ACTIVE_ANON,
-	MCS_INACTIVE_FILE,
-	MCS_ACTIVE_FILE,
-	MCS_UNEVICTABLE,
-	NR_MCS_STAT,
-};
-
-struct mcs_total_stat {
-	s64 stat[NR_MCS_STAT];
-};
-
 struct {
 	char *local_name;
 	char *total_name;
Index: linux-2.6/fs/proc/meminfo.c
===================================================================
--- linux-2.6.orig/fs/proc/meminfo.c
+++ linux-2.6/fs/proc/meminfo.c
@@ -10,6 +10,7 @@
 #include <linux/seq_file.h>
 #include <linux/swap.h>
 #include <linux/vmstat.h>
+#include <linux/memcontrol.h>
 #include <asm/atomic.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -19,6 +20,17 @@ void __attribute__((weak)) arch_report_m
 {
 }
 
+static int get_meminfo(struct sysinfo *sysinfo)
+{
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+	mem_cgroup_info(current, sysinfo);
+#else
+	si_meminfo(&i);
+	si_swapinfo(&i);
+#endif
+	return 0;
+}
+
 static int meminfo_proc_show(struct seq_file *m, void *v)
 {
 	struct sysinfo i;
@@ -33,8 +45,7 @@ static int meminfo_proc_show(struct seq_
  * display in kilobytes.
  */
 #define K(x) ((x) << (PAGE_SHIFT - 10))
-	si_meminfo(&i);
-	si_swapinfo(&i);
+	get_meminfo(&i);
 	committed = percpu_counter_read_positive(&vm_committed_as);
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;

--------------090605020709040108060009
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------090605020709040108060009--
