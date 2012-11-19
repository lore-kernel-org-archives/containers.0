From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] pidns: remove the useless function is_container_init
Date: Mon, 19 Nov 2012 14:12:24 +0000
Message-ID: <20121119141224.GA4321@mail.hallyn.com>
References: <1353321882-30491-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1353321882-30491-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> since commit 1cdcbec1a3372c0c49c59d292e708fd07b509f18,
> is_container_init has no used for a long time.
> 
> just remove it.

Only thing is it's being exported, so I think it needs to go through
deprecation.

> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  include/linux/sched.h |    6 ------
>  kernel/pid.c          |   15 ---------------
>  2 files changed, 0 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 0dd42a0..3fadd26 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1710,12 +1710,6 @@ static inline int is_global_init(struct task_struct *tsk)
>  	return tsk->pid == 1;
>  }
>  
> -/*
> - * is_container_init:
> - * check whether in the task is init in its own pid namespace.
> - */
> -extern int is_container_init(struct task_struct *tsk);
> -
>  extern struct pid *cad_pid;
>  
>  extern void free_task(struct task_struct *tsk);
> diff --git a/kernel/pid.c b/kernel/pid.c
> index aebd4f5..8ccdf0e 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -81,21 +81,6 @@ struct pid_namespace init_pid_ns = {
>  };
>  EXPORT_SYMBOL_GPL(init_pid_ns);
>  
> -int is_container_init(struct task_struct *tsk)
> -{
> -	int ret = 0;
> -	struct pid *pid;
> -
> -	rcu_read_lock();
> -	pid = task_pid(tsk);
> -	if (pid != NULL && pid->numbers[pid->level].nr == 1)
> -		ret = 1;
> -	rcu_read_unlock();
> -
> -	return ret;
> -}
> -EXPORT_SYMBOL(is_container_init);
> -
>  /*
>   * Note: disable interrupts while the pidmap_lock is held as an
>   * interrupt might come in and do read_lock(&tasklist_lock).
> -- 
> 1.7.7.6
