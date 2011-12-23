From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/3] cgroup: remove double-checking locking from
	attach_task_by_pid
Date: Thu, 22 Dec 2011 18:13:33 -0800
Message-ID: <20111223021333.GM13529__436.454316559498$1324606802$gmane$org@google.com>
References: <1324601873-20773-1-git-send-email-msb@chromium.org>
	<1324601873-20773-2-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1324601873-20773-2-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is not going to work. Will fix up and resend. Need to goto
the top as suggested by Tejun.

Mandeep Singh Baines (msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org) wrote:
> By reading group_leader after taking the threadgroup_lock, we can
> avoid the double-check locking. This removes the return of
> -EAGAIN so we can cleanup cgroup_procs_write at the same time.
> 
> The suggestion was made here:
> 
> https://lkml.org/lkml/2011/12/22/371
> 
> Suggested-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Signed-off-by: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> ---
>  kernel/cgroup.c |   40 ++++++----------------------------------
>  1 files changed, 6 insertions(+), 34 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 032139d..a5f7d1b 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2234,9 +2234,6 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
>  			ret= -ESRCH;
>  			goto out_unlock_cgroup;
>  		}
> -		/* we check later for a group_leader race with de_thread */
> -		if (threadgroup)
> -			tsk = tsk->group_leader;
>  		/*
>  		 * even if we're attaching all tasks in the thread group, we
>  		 * only need to check permissions on one of them.
> @@ -2252,33 +2249,17 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
>  		get_task_struct(tsk);
>  		rcu_read_unlock();
>  	} else {
> -		if (threadgroup)
> -			tsk = current->group_leader;
> -		else
> -			tsk = current;
> +		tsk = current;
>  		get_task_struct(tsk);
>  	}
>  
>  	threadgroup_lock(tsk);
> -
> -	if (threadgroup) {
> -		if (!thread_group_leader(tsk)) {
> -			/*
> -			 * a race with de_thread from another thread's exec()
> -			 * may strip us of our leadership, if this happens,
> -			 * there is no choice but to throw this task away and
> -			 * try again (from cgroup_procs_write); this is
> -			 * "double-double-toil-and-trouble-check locking".
> -			 */
> -			ret = -EAGAIN;
> -			goto out_unlock_threadgroup;
> -		}
> -		ret = cgroup_attach_proc(cgrp, tsk);
> -	} else
> +	if (threadgroup)
> +		ret = cgroup_attach_proc(cgrp, tsk->group_leader);
> +	else
>  		ret = cgroup_attach_task(cgrp, tsk);
> -
> -out_unlock_threadgroup:
>  	threadgroup_unlock(tsk);
> +
>  	put_task_struct(tsk);
>  out_unlock_cgroup:
>  	cgroup_unlock();
> @@ -2292,16 +2273,7 @@ static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft, u64 pid)
>  
>  static int cgroup_procs_write(struct cgroup *cgrp, struct cftype *cft, u64 tgid)
>  {
> -	int ret;
> -	do {
> -		/*
> -		 * attach_proc fails with -EAGAIN if threadgroup leadership
> -		 * changes in the middle of the operation, in which case we need
> -		 * to find the task_struct for the new leader and start over.
> -		 */
> -		ret = attach_task_by_pid(cgrp, tgid, true);
> -	} while (ret == -EAGAIN);
> -	return ret;
> +	return attach_task_by_pid(cgrp, tgid, true);
>  }
>  
>  /**
> -- 
> 1.7.3.1
> 
