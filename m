From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 2/3] cgroup: fix RCU accesses around
	task->cgroups
Date: Tue, 25 Jun 2013 10:02:38 +0800
Message-ID: <51C8FA3E.9020104@huawei.com>
References: <20130621225116.GC3949@htj.dyndns.org>
	<20130621225204.GD3949@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130621225204.GD3949-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <theo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

> @@ -5046,8 +5049,8 @@ static const struct file_operations proc
>  void cgroup_fork(struct task_struct *child)
>  {
>  	task_lock(current);
> +	get_css_set(task_css_set(current));
>  	child->cgroups = current->cgroups;

While we use RCU_INIT_POINTER() in cgroup_exit(), we don't need to use it here?

> -	get_css_set(child->cgroups);
>  	task_unlock(current);
>  	INIT_LIST_HEAD(&child->cg_list);
>  }
> @@ -5081,7 +5084,7 @@ void cgroup_post_fork(struct task_struct
>  		write_lock(&css_set_lock);
>  		task_lock(child);
>  		if (list_empty(&child->cg_list))
> -			list_add(&child->cg_list, &child->cgroups->tasks);
> +			list_add(&child->cg_list, &task_css_set(child)->tasks);
>  		task_unlock(child);
>  		write_unlock(&css_set_lock);
>  	}
> @@ -5163,8 +5166,8 @@ void cgroup_exit(struct task_struct *tsk
>  
>  	/* Reassign the task to the init_css_set. */
>  	task_lock(tsk);
> -	cset = tsk->cgroups;
> -	tsk->cgroups = &init_css_set;
> +	cset = task_css_set(tsk);
> +	RCU_INIT_POINTER(tsk->cgroups, &init_css_set);
>  
>  	if (run_callbacks && need_forkexit_callback) {
>  		/*
