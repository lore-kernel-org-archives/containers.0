From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH -mm] memrlimit: fix task_lock() recursive locking
Date: Thu, 18 Sep 2008 11:46:54 -0700
Message-ID: <48D2A21E.7050806__15691.0347323448$1221763955$gmane$org@linux.vnet.ibm.com>
References: <48D29485.5010900@gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48D29485.5010900-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> cgroup_mm_owner_callbacks() can be called with task_lock() held in
> mm_update_next_owner(), and all the .mm_owner_changed callbacks seem to
> be *always* called with task_lock() held.
> 
> Actually, memrlimit is using task_lock() via get_task_mm() in
> memrlimit_cgroup_mm_owner_changed(), raising the following recursive locking
> trace:

[snip]

Thanks for the BUG report()

[snip]

>  static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct cgroup *old_cgrp,
> @@ -246,7 +246,7 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct task_struct *p)
>  {
>  	struct memrlimit_cgroup *memrcg, *old_memrcg;
> -	struct mm_struct *mm = get_task_mm(p);
> +	struct mm_struct *mm = get_task_mm_task_locked(p);
> 

Since we hold task_lock(), we know that p->mm cannot change and we don't have to
worry about incrementing mm_users. I think using just p->mm will work, we do
have checks to make sure we don't pick a kernel thread. I vote for going down
that road.


-- 
	Balbir
