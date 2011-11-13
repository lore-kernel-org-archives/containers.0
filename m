From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 03/10] threadgroup: extend threadgroup_lock() to cover
	exit and exec
Date: Sun, 13 Nov 2011 19:20:34 +0100
Message-ID: <20111113182029.GC9446__7577.06195950067$1321208456$gmane$org@somewhere>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1320191193-8110-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 01, 2011 at 04:46:26PM -0700, Tejun Heo wrote:
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index aa47d0f..6fb546e 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2377,13 +2377,37 @@ static inline void threadgroup_change_done(struct task_struct *tsk)
>  {
>  	up_read(&tsk->signal->group_rwsem);
>  }
> +
> +/**
> + * threadgroup_lock - lock threadgroup
> + * @tsk: member task of the threadgroup to lock
> + *
> + * Lock the threadgroup @tsk belongs to.  No new task is allowed to enter
> + * and member tasks aren't allowed to exit (as indicated by PF_EXITING) or
> + * perform exec.  This is useful for cases where the threadgroup needs to
> + * stay stable across blockable operations.
> + *
> + * fork and exit explicitly call threadgroup_change_{begin|end}() for
> + * synchronization.  exec is already synchronized with cread_guard_mutex
> + * which we grab here.
> + */
>  static inline void threadgroup_lock(struct task_struct *tsk)
>  {
> +	/* exec uses exit for de-threading, grab cred_guard_mutex first */
> +	mutex_lock(&tsk->signal->cred_guard_mutex);

May be worth explaining what in exec is synchronized through this. ie the leader.

>  	down_write(&tsk->signal->group_rwsem);
>  }
> +
> +/**
> + * threadgroup_unlock - unlock threadgroup
> + * @tsk: member task of the threadgroup to unlock
> + *
> + * Reverse threadgroup_lock().
> + */
>  static inline void threadgroup_unlock(struct task_struct *tsk)
>  {
>  	up_write(&tsk->signal->group_rwsem);
> +	mutex_unlock(&tsk->signal->cred_guard_mutex);
>  }
>  #else
>  static inline void threadgroup_change_begin(struct task_struct *tsk) {}
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 2913b35..3565f00 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -938,6 +938,12 @@ NORET_TYPE void do_exit(long code)
>  		schedule();
>  	}
>  
> +	/*
> +	 * @tsk's threadgroup is going through changes - lock out users
> +	 * which expect stable threadgroup.
> +	 */
> +	threadgroup_change_begin(tsk);

Why so early? You actually want to synchronize against cgroup_exit(). Or
am I missing something?

Yeah there may be a problem with reading PF_EXITING inside the lock if it
is updated outside the lock, may be we need a pair of memory barriers. But
other than that, this should be enough to lock around cgroup_exit().
