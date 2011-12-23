From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] cgroup: remove tasklist_lock from cgroup_attach_proc
Date: Fri, 23 Dec 2011 03:27:45 +0100
Message-ID: <20111223022742.GA28309__1973.99586109004$1324607288$gmane$org@somewhere.redhat.com>
References: <1324601873-20773-1-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1324601873-20773-1-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
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

On Thu, Dec 22, 2011 at 04:57:51PM -0800, Mandeep Singh Baines wrote:
> Since cgroup_attach_proc is protected by a threadgroup_lock, we
> no longer need a tasklist_lock to protect while_each_thread.
> To keep the complexity of the double-check locking in one place,
> I also moved the thread_group_leader check up into
> attach_task_by_pid.
> 
> While at it, also converted a couple of returns to gotos.
> 
> The suggestion was made here:
> 
> https://lkml.org/lkml/2011/12/22/86
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
>  kernel/cgroup.c |   52 +++++++++++++++++++++-------------------------------
>  1 files changed, 21 insertions(+), 31 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 1042b3c..032139d 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2102,21 +2102,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
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
>  	tsk = leader;
>  	i = 0;
>  	do {
> @@ -2145,7 +2130,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
>  	group_size = i;
>  	tset.tc_array = group;
>  	tset.tc_array_len = group_size;
> -	read_unlock(&tasklist_lock);

You still need rcu_read_lock()/rcu_read_unlock() around
	do {

	} while_each_thread()

because threadgroup_lock() doesn't lock the part that remove a thread from
its group on exit.
