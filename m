From: Balaji Rao <balajirrao@gmail.com>
Subject: [RFC][-mm] [2/2] Simple stats for memory resource controller
Date: Wed, 26 Mar 2008 23:48:59 +0530
Message-ID: <200803262348.59785.balajirrao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762101AbYCZSZl@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: containers@lists.osdl.org, menage@google.com, balbir@in.ibm.com, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

This patch implements trivial statistics for the memory resource controller.

Signed-off-by: Balaji Rao <balajirrao@gmail.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: Dhaval Giani <dhaval@linux.vnet.ibm.com>


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index eb681a6..84f3fe5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -45,6 +45,8 @@ enum mem_cgroup_stat_index {
 	 */
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
+	MEM_CGROUP_STAT_PGIN_COUNT,	/* # of pages paged in */
+	MEM_CGROUP_STAT_PGOUT_COUNT,	/* # of pages paged out */
 
 	MEM_CGROUP_STAT_NSTATS,
 };
@@ -196,6 +198,13 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem, int flags,
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
 	else
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
+
+	if (charge)
+		__mem_cgroup_stat_add_safe(stat,
+				MEM_CGROUP_STAT_PGIN_COUNT, 1);
+	else
+		__mem_cgroup_stat_add_safe(stat,
+				MEM_CGROUP_STAT_PGOUT_COUNT, 1);
 }
 
 static struct mem_cgroup_per_zone *
@@ -886,6 +895,8 @@ static const struct mem_cgroup_stat_desc {
 } mem_cgroup_stat_desc[] = {
 	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
 	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
+	[MEM_CGROUP_STAT_PGIN_COUNT] = {"page_in_count", 1, },
+	[MEM_CGROUP_STAT_PGOUT_COUNT] = {"page_out_count", 1, },
 };
 
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
