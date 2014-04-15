From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] cgroup: print pretty format in /proc/cgroups
Date: Tue, 15 Apr 2014 20:47:45 +0800
Message-ID: <1397566065-3028-1-git-send-email-nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

I found that /proc/cgroups printed format has ugly alignment(see below).

This patch confines every field in fixed-width(16 actually) range.
Though MAX_CGROUP_TYPE_NAMELEN is 32, but currently no subsystem
has name width more than 10, so 16 is a moderate width; besides, 16
figures could accomandate enormous huge number, so no need to worry
that these fields would clobber each other.

Before:
  #subsys_name     hierarchy       num_cgroups     enabled
  cpuset	2	1	1
  cpu	3	1	1
  cpuacct	3	1	1
  memory	4	1	1
  devices	5	1	1
  freezer 6	1	1
  net_cls	7	1	1
  blkio	8	1	1
  perf_event	9	1	1
  hugetlb	10	1	1

Patch applied:
  #subsys_name     hierarchy       num_cgroups     enabled
  cpuset          2               1               1
  cpu             3               1               1
  cpuacct         3               1               1
  memory          4               1               1
  devices         5               1               1
  freezer         6               1               1
  net_cls         7               1               1
  blkio           8               1               1
  perf_event      9               1               1
  hugetlb         10              1               1

Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9fcdaa7..d981697 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4347,7 +4347,7 @@ static int proc_cgroupstats_show(struct seq_file *m, void *v)
 	mutex_lock(&cgroup_mutex);
 
 	for_each_subsys(ss, i)
-		seq_printf(m, "%s\t%d\t%d\t%d\n",
+		seq_printf(m, "%-16s%-16d%-16d%-16d\n",
 			   ss->name, ss->root->hierarchy_id,
 			   atomic_read(&ss->root->nr_cgrps), !ss->disabled);
 
-- 
1.9.0.GIT
