From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] cgroup: remove orphaned cgroup_pidlist_seq_operations
Date: Thu, 17 Apr 2014 23:29:04 +0800
Message-ID: <1397748544-6570-1-git-send-email-nasa4836@gmail.com>
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

Commit 6612f05b88fa309c9(cgroup: unify pidlist and other file handling)
has removed the only user of cgroup_pidlist_seq_operations :
cgroup_pidlist_open().

This patch removes it.

Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b261798..38a9cd0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3883,17 +3883,6 @@ static int cgroup_pidlist_show(struct seq_file *s, void *v)
 	return seq_printf(s, "%d\n", *(int *)v);
 }
 
-/*
- * seq_operations functions for iterating on pidlists through seq_file -
- * independent of whether it's tasks or procs
- */
-static const struct seq_operations cgroup_pidlist_seq_operations = {
-	.start = cgroup_pidlist_start,
-	.stop = cgroup_pidlist_stop,
-	.next = cgroup_pidlist_next,
-	.show = cgroup_pidlist_show,
-};
-
 static u64 cgroup_read_notify_on_release(struct cgroup_subsys_state *css,
 					 struct cftype *cft)
 {
-- 
1.9.0.GIT
