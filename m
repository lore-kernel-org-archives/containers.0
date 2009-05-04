From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: [RFC][PATCH 2/7] Have alloc_pidmap() return actual error code
Date: Mon,  4 May 2009 01:17:40 -0700
Message-ID: <1241425065670-git-send-email-sukadev@linux.vnet.ibm.com>
References: <12414250653025-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Resent-Message-ID: <20090504165840.GB31285-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Resent-To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <12414250653025-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

alloc_pidmap() can fail either because all pid numbers are in use or
we can't allocate memory. With support for setting a specific pid
number, alloc_pidmap() would also fail if either the given pid
number is invalid or in use.

Rather than have caller assume -ENOMEM, have alloc_pidmap() return
the actual error.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 kernel/fork.c |    5 +++--
 kernel/pid.c  |    9 ++++++---
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index b9e2edd..f8411a8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1119,10 +1119,11 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		goto bad_fork_cleanup_io;

 	if (pid != &init_struct_pid) {
-		retval = -ENOMEM;
 		pid = alloc_pid(p->nsproxy->pid_ns);
-		if (!pid)
+		if (IS_ERR(pid)) {
+			retval = PTR_ERR(pid);
 			goto bad_fork_cleanup_io;
+		}

 		if (clone_flags & CLONE_NEWPID) {
 			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
diff --git a/kernel/pid.c b/kernel/pid.c
index c0aaebe..fd72ad9 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -151,6 +151,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 {
 	int i, offset, max_scan, pid, last = pid_ns->last_pid;
 	struct pidmap *map;
+	int rc = -EAGAIN;

 	pid = last + 1;
 	if (pid >= pid_max)
@@ -159,8 +160,10 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
 	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
 	for (i = 0; i <= max_scan; ++i) {
-		if (alloc_pidmap_page(map))
+		if (alloc_pidmap_page(map)) {
+			rc = -ENOMEM;
 			break;
+		}

 		if (likely(atomic_read(&map->nr_free))) {
 			do {
@@ -192,7 +195,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 		}
 		pid = mk_pid(pid_ns, map, offset);
 	}
-	return -1;
+	return rc;
 }

 int next_pidmap(struct pid_namespace *pid_ns, int last)
@@ -297,7 +300,7 @@ out_free:
 		free_pidmap(pid->numbers + i);

 	kmem_cache_free(ns->pid_cachep, pid);
-	pid = NULL;
+	pid = ERR_PTR(nr);
 	goto out;
 }

-- 
1.5.2.5
