From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup: replace tasklist_lock with rcu_read_lock
Date: Sat, 24 Dec 2011 03:30:31 +0100
Message-ID: <20111224023028.GD28309__40262.5270690352$1324693853$gmane$org@somewhere.redhat.com>
References: <1324661325-31968-1-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1324661325-31968-1-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 23, 2011 at 09:28:44AM -0800, Mandeep Singh Baines wrote:
> Since cgroup_attach_proc is protected by a threadgroup_lock, we
> can replace the tasklist_lock in cgroup_attach_proc with an
> rcu_read_lock. To keep the complexity of the double-check locking
> in one place, I also moved the thread_group_leader check up into
> attach_task_by_pid. This allows us to use a goto instead of
> returning -EAGAIN.
> 
> While at it, also converted a couple of returns to gotos.
> 
> Changes in V3:
> * https://lkml.org/lkml/2011/12/22/419 (Frederic Weisbecker)
>   * Add an rcu_read_lock to protect against exit
> Changes in V2:
> * https://lkml.org/lkml/2011/12/22/86 (Tejun Heo)
>   * Use a goto instead of returning -EAGAIN
> 
> Suggested-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> ---
>  kernel/cgroup.c |   74 +++++++++++++++++++-----------------------------------
>  1 files changed, 26 insertions(+), 48 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 1042b3c..6ee1438 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2102,21 +2102,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  	if (retval)
>  		goto out_free_group_list;
>  
> -	/* prevent changes to the threadgroup list while we take a snapshot. */
> -	read_lock(&tasklist_lock);
> -	if (!thread_group_leader(leader)) {
> -		/*
> -		 * a race with de_thread from another thread's exec() may strip
> -		 * us of our leadership, making while_each_thread unsafe to use
> -		 * on this task. if this happens, there is no choice but to
> -		 * throw this task away and try again (from cgroup_procs_write);
> -		 * this is "double-double-toil-and-trouble-check locking".
> -		 */
> -		read_unlock(&tasklist_lock);
> -		retval = -EAGAIN;
> -		goto out_free_group_list;
> -	}
> -
> +	rcu_read_lock();

Please add a comment to explain why we need this. This may not be obvious
to other people that are not familiar with that code.

>  	tsk = leader;
>  	i = 0;

Also you can move rcu_read_lock() straight here. The two above operations don't need to
be protected.

>  	do {
> @@ -2145,7 +2131,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  	group_size = i;
>  	tset.tc_array = group;
>  	tset.tc_array_len = group_size;
> -	read_unlock(&tasklist_lock);
> +	rcu_read_unlock();

In a similar way, you can move rcu_read_unlock() right after while_each_thread().

Thanks.
