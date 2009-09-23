From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v18 12/80] pids 2/7: Have alloc_pidmap() return actual error
	code
Date: Wed, 23 Sep 2009 19:50:52 -0400
Message-ID: <1253749920-18673-13-git-send-email-orenl__9741.86259923062$1253750661$gmane$org@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

alloc_pidmap() can fail either because all pid numbers are in use or
because memory allocation failed.  With support for setting a specific
pid number, alloc_pidmap() would also fail if either the given pid
number is invalid or in use.

Rather than have callers assume -ENOMEM, have alloc_pidmap() return
the actual error.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 kernel/fork.c |    5 +++--
 kernel/pid.c  |    9 ++++++---
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index e6c04d4..851ccd1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1110,10 +1110,11 @@ static struct task_struct *copy_process(unsigned long clone_flags,
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
index f618096..9c678ce 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -158,6 +158,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	offset = pid & BITS_PER_PAGE_MASK;
 	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
 	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
+	rc = -EAGAIN;
 	for (i = 0; i <= max_scan; ++i) {
 		rc = alloc_pidmap_page(map);
 		if (rc)
@@ -188,12 +189,14 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 		} else {
 			map = &pid_ns->pidmap[0];
 			offset = RESERVED_PIDS;
-			if (unlikely(last == offset))
+			if (unlikely(last == offset)) {
+				rc = -EAGAIN;
 				break;
+			}
 		}
 		pid = mk_pid(pid_ns, map, offset);
 	}
-	return -1;
+	return rc;
 }
 
 int next_pidmap(struct pid_namespace *pid_ns, int last)
@@ -298,7 +301,7 @@ out_free:
 		free_pidmap(pid->numbers + i);
 
 	kmem_cache_free(ns->pid_cachep, pid);
-	pid = NULL;
+	pid = ERR_PTR(nr);
 	goto out;
 }
 
-- 
1.6.0.4
