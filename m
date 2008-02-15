From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 6/7] CGroup API: Use descriptions for memory controller
	API files
Date: Fri, 15 Feb 2008 12:44:24 -0800
Message-ID: <20080215204821.606063000__22936.9652145126$1203108877$gmane$org@menage.corp.google.com>
References: <20080215204418.535025000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=memcontrol-use-api.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, pj-sJ/iWh9BUns@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds descriptions to the memory controller API files to
indicate that the usage/limit are in bytes; the names of the control
files can then be simplified to usage/limit.

Also removes the unnecessary mem_force_empty_read() function

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 mm/memcontrol.c |   21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

Index: cgroupmap-2.6.24-mm1/mm/memcontrol.c
===================================================================
--- cgroupmap-2.6.24-mm1.orig/mm/memcontrol.c
+++ cgroupmap-2.6.24-mm1/mm/memcontrol.c
@@ -950,19 +950,6 @@ static ssize_t mem_force_empty_write(str
 	return ret;
 }
 
-/*
- * Note: This should be removed if cgroup supports write-only file.
- */
-
-static ssize_t mem_force_empty_read(struct cgroup *cont,
-				struct cftype *cft,
-				struct file *file, char __user *userbuf,
-				size_t nbytes, loff_t *ppos)
-{
-	return -EINVAL;
-}
-
-
 static const struct mem_cgroup_stat_desc {
 	const char *msg;
 	u64 unit;
@@ -1001,15 +988,17 @@ static int mem_control_stat_show(struct 
 
 static struct cftype mem_cgroup_files[] = {
 	{
-		.name = "usage_in_bytes",
+		.name = "usage",
 		.private = RES_USAGE,
 		.read_uint = mem_cgroup_read,
+		.desc = "Memory usage in bytes",
 	},
 	{
-		.name = "limit_in_bytes",
+		.name = "limit",
 		.private = RES_LIMIT,
 		.write = mem_cgroup_write,
 		.read_uint = mem_cgroup_read,
+		.desc = "Memory limit in bytes",
 	},
 	{
 		.name = "failcnt",
@@ -1019,7 +1008,7 @@ static struct cftype mem_cgroup_files[] 
 	{
 		.name = "force_empty",
 		.write = mem_force_empty_write,
-		.read = mem_force_empty_read,
+		.desc = "Write to this file to forget all memory charges"
 	},
 	{
 		.name = "stat",

--
