From: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 2/7] Have alloc_pidmap() return actual error code
Date: Mon, 1 Jun 2009 16:17:26 +0800
Message-ID: <20090601081726.GB4381@cr0.nay.redhat.com>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000115.GA4191@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090531000115.GA4191-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, May 30, 2009 at 05:01:15PM -0700, Sukadev Bhattiprolu wrote:
>
>From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>Date: Mon, 4 May 2009 01:17:40 -0700
>Subject: [RFC][v3][PATCH 2/7] Have alloc_pidmap() return actual error code
>
>alloc_pidmap() can fail either because all pid numbers are in use or
>because memory allocation failed.  With support for setting a specific
>pid number, alloc_pidmap() would also fail if either the given pid
>number is invalid or in use.
>
>Rather than have callers assume -ENOMEM, have alloc_pidmap() return
>the actual error.
>
>Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Reviewed-by: WANG Cong <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>



>---
> kernel/fork.c |    5 +++--
> kernel/pid.c  |    9 ++++++---
> 2 files changed, 9 insertions(+), 5 deletions(-)
>
>diff --git a/kernel/fork.c b/kernel/fork.c
>index b9e2edd..f8411a8 100644
>--- a/kernel/fork.c
>+++ b/kernel/fork.c
>@@ -1119,10 +1119,11 @@ static struct task_struct *copy_process(unsigned long clone_flags,
> 		goto bad_fork_cleanup_io;
> 
> 	if (pid != &init_struct_pid) {
>-		retval = -ENOMEM;
> 		pid = alloc_pid(p->nsproxy->pid_ns);
>-		if (!pid)
>+		if (IS_ERR(pid)) {
>+			retval = PTR_ERR(pid);
> 			goto bad_fork_cleanup_io;
>+		}
> 
> 		if (clone_flags & CLONE_NEWPID) {
> 			retval = pid_ns_prepare_proc(p->nsproxy->pid_ns);
>diff --git a/kernel/pid.c b/kernel/pid.c
>index 9ff33cc..b2d6a19 100644
>--- a/kernel/pid.c
>+++ b/kernel/pid.c
>@@ -158,6 +158,7 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
> 	offset = pid & BITS_PER_PAGE_MASK;
> 	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
> 	max_scan = (pid_max + BITS_PER_PAGE - 1)/BITS_PER_PAGE - !offset;
>+	rc = -EAGAIN;
> 	for (i = 0; i <= max_scan; ++i) {
> 		rc = alloc_pidmap_page(map);
> 		if (rc)
>@@ -188,12 +189,14 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
> 		} else {
> 			map = &pid_ns->pidmap[0];
> 			offset = RESERVED_PIDS;
>-			if (unlikely(last == offset))
>+			if (unlikely(last == offset)) {
>+				rc = -EAGAIN;
> 				break;
>+			}
> 		}
> 		pid = mk_pid(pid_ns, map, offset);
> 	}
>-	return -1;
>+	return rc;
> }
> 
> int next_pidmap(struct pid_namespace *pid_ns, int last)
>@@ -298,7 +301,7 @@ out_free:
> 		free_pidmap(pid->numbers + i);
> 
> 	kmem_cache_free(ns->pid_cachep, pid);
>-	pid = NULL;
>+	pid = ERR_PTR(nr);
> 	goto out;
> }
> 
>-- 
>1.5.2.5
>
>_______________________________________________
>Containers mailing list
>Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>https://lists.linux-foundation.org/mailman/listinfo/containers
