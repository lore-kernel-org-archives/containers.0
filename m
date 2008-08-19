From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/1] mm_owner: fix cgroup null dereference
Date: Tue, 19 Aug 2008 19:43:45 +0530
Message-ID: <20080819141344.GF25239__21897.7629593157$1219156459$gmane$org@balbir.in.ibm.com>
References: <1218745013-9537-1-git-send-email-jirislaby@gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1218745013-9537-1-git-send-email-jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

* Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2008-08-14 22:16:53]:

> Hi,
> 
> found this in mmotm, a fix for
> mm-owner-fix-race-between-swap-and-exit.patch
>

Does the patch below fix your problem, it's against mmotm 19th August
2008.

 
Reported-by: jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org

Jiri reported a problem and saw an oops when the memrlimit-fix-race-with-swap
patch is applied. He sent his patch on top to fix the problem, but ran into
another issue. The root cause of the problem is that we are not suppose
to call task_cgroup on NULL tasks. This patch reverts Jiri's patch and
does not call task_cgroup if the passed task_struct (old) is NULL.


Signed-off-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 kernel/cgroup.c |    5 +++--
 kernel/exit.c   |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff -puN kernel/exit.c~memrlimit-fix-race-with-swap-oops kernel/exit.c
--- linux-2.6.27-rc3/kernel/exit.c~memrlimit-fix-race-with-swap-oops	2008-08-19 18:50:39.000000000 +0530
+++ linux-2.6.27-rc3-balbir/kernel/exit.c	2008-08-19 18:51:05.000000000 +0530
@@ -641,8 +641,8 @@ retry:
 	 * the callback and take action
 	 */
 	down_write(&mm->mmap_sem);
-	cgroup_mm_owner_callbacks(mm->owner, NULL);
 	mm->owner = NULL;
+	cgroup_mm_owner_callbacks(mm->owner, NULL);
 	up_write(&mm->mmap_sem);
 	return;
 
diff -puN kernel/cgroup.c~memrlimit-fix-race-with-swap-oops kernel/cgroup.c
--- linux-2.6.27-rc3/kernel/cgroup.c~memrlimit-fix-race-with-swap-oops	2008-08-19 18:50:39.000000000 +0530
+++ linux-2.6.27-rc3-balbir/kernel/cgroup.c	2008-08-19 18:55:38.000000000 +0530
@@ -2743,13 +2743,14 @@ void cgroup_fork_callbacks(struct task_s
  */
 void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
 {
-	struct cgroup *oldcgrp, *newcgrp = NULL;
+	struct cgroup *oldcgrp = NULL, *newcgrp = NULL;
 
 	if (need_mm_owner_callback) {
 		int i;
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
-			oldcgrp = task_cgroup(old, ss->subsys_id);
+			if (old)
+				oldcgrp = task_cgroup(old, ss->subsys_id);
 			if (new)
 				newcgrp = task_cgroup(new, ss->subsys_id);
 			if (oldcgrp == newcgrp)
diff -puN mm/memrlimitcgroup.c~memrlimit-fix-race-with-swap-oops mm/memrlimitcgroup.c
_

-- 
	Balbir
