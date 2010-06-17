From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Thu, 17 Jun 2010 13:53:39 +0400
Message-ID: <4C19F0A3.2050707@parallels.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1276706068-18567-1-git-send-email-louis.rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis Rilling <louis.rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/16/2010 08:34 PM, Louis Rilling wrote:
> [ Resending, hopefully with all pieces ]
> 
> Detached tasks are not seen by zap_pid_ns_processes()->sys_wait4(), so
> that release_task()->proc_flush_task() of container init can be called
> before it is for some detached tasks in the namespace.
> 
> Pin proc_mnt's in copy_process(), so that proc_flush_task() becomes safe
> whatever the ordering of tasks.

See one comment below.

> Signed-off-by: Louis Rilling <louis.rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
> ---
>  fs/proc/base.c          |   18 ++++++++++++++++++
>  include/linux/proc_fs.h |    4 ++++
>  kernel/fork.c           |    1 +
>  3 files changed, 23 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index acb7ef8..d6cdd91 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -2663,6 +2663,23 @@ static const struct inode_operations proc_tgid_base_inode_operations = {
>  	.setattr	= proc_setattr,
>  };
>  
> +/*
> + * Pin all proc_mnt so that detached tasks can safely call proc_flush_task()
> + * after container init calls itself proc_flush_task().
> + */
> +void proc_new_task(struct task_struct *task)
> +{
> +	struct pid *pid;
> +	int i;
> +
> +	if (!task->pid)
> +		return;
> +
> +	pid = task_pid(task);
> +	for (i = 0; i <= pid->level; i++)
> +		mntget(pid->numbers[i].ns->proc_mnt);

NAK. Pids live their own lives - task can change one, pid will
become orphan and will be destroyed, so you'll leak.

There's another big problem with proc mount - you can umount proc
and the namespace will have a stale pointer.

I think we should have a kern_mount-ed proc at the namespace createi

> +}
> +
>  static void proc_flush_task_mnt(struct vfsmount *mnt, pid_t pid, pid_t tgid)
>  {
>  	struct dentry *dentry, *leader, *dir;
> @@ -2744,6 +2761,7 @@ void proc_flush_task(struct task_struct *task)
>  		upid = &pid->numbers[i];
>  		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
>  					tgid->numbers[i].nr);
> +		mntput(upid->ns->proc_mnt);
>  	}
>  
>  	upid = &pid->numbers[pid->level];
> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index 379eaed..f24faa1 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -104,6 +104,7 @@ struct vmcore {
>  
>  extern void proc_root_init(void);
>  
> +void proc_new_task(struct task_struct *task);
>  void proc_flush_task(struct task_struct *task);
>  
>  extern struct proc_dir_entry *create_proc_entry(const char *name, mode_t mode,
> @@ -184,6 +185,9 @@ extern void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm);
>  #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
>  static inline void proc_net_remove(struct net *net, const char *name) {}
>  
> +static inline void proc_new_task(struct task_struct *task)
> +{
> +}
>  static inline void proc_flush_task(struct task_struct *task)
>  {
>  }
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b6cce14..c6c2874 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1281,6 +1281,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	total_forks++;
>  	spin_unlock(&current->sighand->siglock);
>  	write_unlock_irq(&tasklist_lock);
> +	proc_new_task(p);
>  	proc_fork_connector(p);
>  	cgroup_post_fork(p);
>  	perf_event_fork(p);
