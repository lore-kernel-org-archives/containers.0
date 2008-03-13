From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] Implement failcounter reset
Date: Thu, 13 Mar 2008 14:39:55 +0300
Message-ID: <47D9128B.6010906@openvz.org>
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

Merge two resets into one mem_cgroup_reset() function to
demonstrate how multiplexing work.

Besides, I have plans to move the files, that correspond to
res_counter to the res_counter.c file and somehow "import" 
them into controller. I don't know how to make it gracefully
yet, but merging resets of max_usage and failcnt in one function 
will be there for sure.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 include/linux/res_counter.h |    8 ++++++++
 mm/memcontrol.c             |   14 +++++++++++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index df8085a..3c05d6d 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -141,4 +141,12 @@ static inline void res_counter_reset_max(struct res_counter *cnt)
 	spin_unlock_irqrestore(&cnt->lock, flags);
 }
 
+static inline void res_counter_reset_failcnt(struct res_counter *cnt)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->failcnt = 0;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+}
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d3ec3e3..5852b23 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -868,12 +868,19 @@ static ssize_t mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 				mem_cgroup_write_strategy);
 }
 
-static int mem_cgroup_max_reset(struct cgroup *cont, unsigned int event)
+static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 {
 	struct mem_cgroup *mem;
 
 	mem = mem_cgroup_from_cont(cont);
-	res_counter_reset_max(&mem->res);
+	switch (event) {
+		case RES_MAX_USAGE:
+			res_counter_reset_max(&mem->res);
+			break;
+		case RES_FAILCNT:
+			res_counter_reset_failcnt(&mem->res);
+			break;
+	}
 	return 0;
 }
 
@@ -927,7 +934,7 @@ static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "max_usage_in_bytes",
 		.private = RES_MAX_USAGE,
-		.trigger = mem_cgroup_max_reset,
+		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
 	{
@@ -939,6 +946,7 @@ static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "failcnt",
 		.private = RES_FAILCNT,
+		.trigger = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read,
 	},
 	{
-- 
1.5.3.4
