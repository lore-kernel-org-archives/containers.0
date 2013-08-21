From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 11/11] cpuset: export effective masks to userspace
Date: Wed, 21 Aug 2013 18:01:32 +0800
Message-ID: <52148FFC.4080701@huawei.com>
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

cpuset.cpus and cpuset.mems are the configured masks, and we need
to export effective masks to userspace, so users know the real
cpus_allowed and mems_allowed that apply to the tasks in a cpuset.

cpuset.effective_cpus and cpuset.effective_mems will be created for
sane_behavior only.

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cpuset.c | 36 ++++++++++++++++++++++++++++++------
 1 file changed, 30 insertions(+), 6 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index c302979..a4f3483 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1583,6 +1583,8 @@ typedef enum {
 	FILE_MEMORY_MIGRATE,
 	FILE_CPULIST,
 	FILE_MEMLIST,
+	FILE_EFFECTIVE_CPULIST,
+	FILE_EFFECTIVE_MEMLIST,
 	FILE_CPU_EXCLUSIVE,
 	FILE_MEM_EXCLUSIVE,
 	FILE_MEM_HARDWALL,
@@ -1731,23 +1733,23 @@ out_unlock:
  * across a page fault.
  */
 
-static size_t cpuset_sprintf_cpulist(char *page, struct cpuset *cs)
+static size_t cpuset_sprintf_cpulist(char *page, struct cpumask *pmask)
 {
 	size_t count;
 
 	mutex_lock(&callback_mutex);
-	count = cpulist_scnprintf(page, PAGE_SIZE, cs->cpus_allowed);
+	count = cpulist_scnprintf(page, PAGE_SIZE, pmask);
 	mutex_unlock(&callback_mutex);
 
 	return count;
 }
 
-static size_t cpuset_sprintf_memlist(char *page, struct cpuset *cs)
+static size_t cpuset_sprintf_memlist(char *page, nodemask_t mask)
 {
 	size_t count;
 
 	mutex_lock(&callback_mutex);
-	count = nodelist_scnprintf(page, PAGE_SIZE, cs->mems_allowed);
+	count = nodelist_scnprintf(page, PAGE_SIZE, mask);
 	mutex_unlock(&callback_mutex);
 
 	return count;
@@ -1771,10 +1773,16 @@ static ssize_t cpuset_common_file_read(struct cgroup_subsys_state *css,
 
 	switch (type) {
 	case FILE_CPULIST:
-		s += cpuset_sprintf_cpulist(s, cs);
+		s += cpuset_sprintf_cpulist(s, cs->cpus_allowed);
 		break;
 	case FILE_MEMLIST:
-		s += cpuset_sprintf_memlist(s, cs);
+		s += cpuset_sprintf_memlist(s, cs->mems_allowed);
+		break;
+	case FILE_EFFECTIVE_CPULIST:
+		s += cpuset_sprintf_cpulist(s, cs->real_cpus_allowed);
+		break;
+	case FILE_EFFECTIVE_MEMLIST:
+		s += cpuset_sprintf_memlist(s, cs->real_mems_allowed);
 		break;
 	default:
 		retval = -EINVAL;
@@ -1849,6 +1857,14 @@ static struct cftype files[] = {
 	},
 
 	{
+		.name = "effective_cpus",
+		.flags = CFTYPE_SANE,
+		.read = cpuset_common_file_read,
+		.max_write_len = (100U + 6 * NR_CPUS),
+		.private = FILE_EFFECTIVE_CPULIST,
+	},
+
+	{
 		.name = "mems",
 		.read = cpuset_common_file_read,
 		.write_string = cpuset_write_resmask,
@@ -1857,6 +1873,14 @@ static struct cftype files[] = {
 	},
 
 	{
+		.name = "effective_mems",
+		.flags = CFTYPE_SANE,
+		.read = cpuset_common_file_read,
+		.max_write_len = (100U + 6 * MAX_NUMNODES),
+		.private = FILE_EFFECTIVE_MEMLIST,
+	},
+
+	{
 		.name = "cpu_exclusive",
 		.read_u64 = cpuset_read_u64,
 		.write_u64 = cpuset_write_u64,
-- 
1.8.0.2
