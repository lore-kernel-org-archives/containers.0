From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] cgroups: skip processes from other namespaces when
	listing a cgroup
Date: Mon, 8 Dec 2008 16:19:46 -0800
Message-ID: <20081208161946.f250f68b.akpm@linux-foundation.org>
References: <493CCB28.7000005@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <493CCB28.7000005-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: gowrishankar <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 08 Dec 2008 12:52:16 +0530
gowrishankar <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 35eebd5..25fdd2c 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2011,14 +2011,15 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
>   */
>  static int pid_array_load(pid_t *pidarray, int npids, struct cgroup *cgrp)
>  {
> -    int n = 0;
> +    int n = 0, pid;

Your email client is replacing tabs with spaces.

>      struct cgroup_iter it;
>      struct task_struct *tsk;
>      cgroup_iter_start(cgrp, &it);
>      while ((tsk = cgroup_iter_next(cgrp, &it))) {
>          if (unlikely(n == npids))
>              break;
> -        pidarray[n++] = task_pid_vnr(tsk);
> +        if ((pid = task_pid_vnr(tsk)) > 0)
> +            pidarray[n++] = pid;

Please avoid the assignment-in-an-if shorthand.  We prefer to avoid
tricky C idioms like this keep the code super-simple:


	pid = task_pid_vnr(tsk);
	if (pid > 0)

scripts/checkpatch.pl can/should be used to detect this, and many
other little things.
