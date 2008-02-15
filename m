From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 3/7] CGroup API: Use cgroup map for memcontrol stats file
Date: Fri, 15 Feb 2008 12:44:21 -0800
Message-ID: <20080215204821.079806000__33292.8236028694$1203108640$gmane$org@menage.corp.google.com>
References: <20080215204418.535025000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=memcontrol_use_cgroup_map.patch
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

Remove the seq_file boilerplate used to construct the memcontrol stats
map, and instead use the new map representation for cgroup control
files

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 mm/memcontrol.c |   30 ++++++------------------------
 1 file changed, 6 insertions(+), 24 deletions(-)

Index: cgroupmap-2.6.24-mm1/mm/memcontrol.c
===================================================================
--- cgroupmap-2.6.24-mm1.orig/mm/memcontrol.c
+++ cgroupmap-2.6.24-mm1/mm/memcontrol.c
@@ -974,9 +974,9 @@ static const struct mem_cgroup_stat_desc
 	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
 };
 
-static int mem_control_stat_show(struct seq_file *m, void *arg)
+static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
+				 struct cgroup_map_cb *cb)
 {
-	struct cgroup *cont = m->private;
 	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
 	struct mem_cgroup_stat *stat = &mem_cont->stat;
 	int i;
@@ -986,8 +986,7 @@ static int mem_control_stat_show(struct 
 
 		val = mem_cgroup_read_stat(stat, i);
 		val *= mem_cgroup_stat_desc[i].unit;
-		seq_printf(m, "%s %lld\n", mem_cgroup_stat_desc[i].msg,
-				(long long)val);
+		cb->fill(cb, mem_cgroup_stat_desc[i].msg, val);
 	}
 	/* showing # of active pages */
 	{
@@ -997,29 +996,12 @@ static int mem_control_stat_show(struct 
 						MEM_CGROUP_ZSTAT_INACTIVE);
 		active = mem_cgroup_get_all_zonestat(mem_cont,
 						MEM_CGROUP_ZSTAT_ACTIVE);
-		seq_printf(m, "active %ld\n", (active) * PAGE_SIZE);
-		seq_printf(m, "inactive %ld\n", (inactive) * PAGE_SIZE);
+		cb->fill(cb, "active", (active) * PAGE_SIZE);
+		cb->fill(cb, "inactive", (inactive) * PAGE_SIZE);
 	}
 	return 0;
 }
 
-static const struct file_operations mem_control_stat_file_operations = {
-	.read = seq_read,
-	.llseek = seq_lseek,
-	.release = single_release,
-};
-
-static int mem_control_stat_open(struct inode *unused, struct file *file)
-{
-	/* XXX __d_cont */
-	struct cgroup *cont = file->f_dentry->d_parent->d_fsdata;
-
-	file->f_op = &mem_control_stat_file_operations;
-	return single_open(file, mem_control_stat_show, cont);
-}
-
-
-
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1044,7 +1026,7 @@ static struct cftype mem_cgroup_files[] 
 	},
 	{
 		.name = "stat",
-		.open = mem_control_stat_open,
+		.read_map = mem_control_stat_show,
 	},
 };
 

--
