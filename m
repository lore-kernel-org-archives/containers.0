From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] cgroups: fix pid namespace bug, fix
Date: Thu, 2 Jul 2009 22:15:47 -0500
Message-ID: <20090703031547.GA28049__36005.1021831625$1246590461$gmane$org@hallyn.com>
References: <4A4D73C5.9000305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A4D73C5.9000305-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Li Zefan (lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> - add get_pid_ns()/put_pid_ns()
> - remove prefix "pids_"
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Reviewed-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks,
-serge

> ---
>  kernel/cgroup.c |   28 +++++++++++++++-------------
>  1 files changed, 15 insertions(+), 13 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 13dddb4..250dac0 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2213,13 +2213,13 @@ struct cgroup_pids {
>  	/* The cgroup those pids belong to */
>  	struct cgroup *cgrp;
>  	/* The namepsace those pids belong to */
> -	struct pid_namespace *pid_ns;
> +	struct pid_namespace *ns;
>  	/* Array of process ids in the cgroup */
>  	pid_t *tasks_pids;
>  	/* How many files are using the this tasks_pids array */
> -	int pids_use_count;
> +	int use_count;
>  	/* Length of the current tasks_pids array */
> -	int pids_length;
> +	int length;
>  };
>  
>  static int cmppid(const void *a, const void *b)
> @@ -2248,7 +2248,7 @@ static void *cgroup_tasks_start(struct seq_file *s, loff_t *pos)
>  
>  	down_read(&cgrp->pids_mutex);
>  	if (pid) {
> -		int end = cp->pids_length;
> +		int end = cp->length;
>  
>  		while (index < end) {
>  			int mid = (index + end) / 2;
> @@ -2262,7 +2262,7 @@ static void *cgroup_tasks_start(struct seq_file *s, loff_t *pos)
>  		}
>  	}
>  	/* If we're off the end of the array, we're done */
> -	if (index >= cp->pids_length)
> +	if (index >= cp->length)
>  		return NULL;
>  	/* Update the abstract position to be the actual pid that we found */
>  	iter = cp->tasks_pids + index;
> @@ -2281,7 +2281,7 @@ static void *cgroup_tasks_next(struct seq_file *s, void *v, loff_t *pos)
>  {
>  	struct cgroup_pids *cp = s->private;
>  	int *p = v;
> -	int *end = cp->tasks_pids + cp->pids_length;
> +	int *end = cp->tasks_pids + cp->length;
>  
>  	/*
>  	 * Advance to the next pid in the array. If this goes off the
> @@ -2313,9 +2313,10 @@ static void release_cgroup_pid_array(struct cgroup_pids *cp)
>  	struct cgroup *cgrp = cp->cgrp;
>  
>  	down_write(&cgrp->pids_mutex);
> -	BUG_ON(!cp->pids_use_count);
> -	if (!--cp->pids_use_count) {
> +	BUG_ON(!cp->use_count);
> +	if (!--cp->use_count) {
>  		list_del(&cp->list);
> +		put_pid_ns(cp->ns);
>  		kfree(cp->tasks_pids);
>  		kfree(cp);
>  	}
> @@ -2352,7 +2353,7 @@ static struct file_operations cgroup_tasks_operations = {
>  static int cgroup_tasks_open(struct inode *unused, struct file *file)
>  {
>  	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
> -	struct pid_namespace *pid_ns = task_active_pid_ns(current);
> +	struct pid_namespace *ns = current->nsproxy->pid_ns;
>  	struct cgroup_pids *cp;
>  	pid_t *pidarray;
>  	int npids;
> @@ -2382,7 +2383,7 @@ static int cgroup_tasks_open(struct inode *unused, struct file *file)
>  	down_write(&cgrp->pids_mutex);
>  
>  	list_for_each_entry(cp, &cgrp->pids_list, list) {
> -		if (pid_ns == cp->pid_ns)
> +		if (ns == cp->ns)
>  			goto found;
>  	}
>  
> @@ -2393,13 +2394,14 @@ static int cgroup_tasks_open(struct inode *unused, struct file *file)
>  		return -ENOMEM;
>  	}
>  	cp->cgrp = cgrp;
> -	cp->pid_ns = pid_ns;
> +	cp->ns = ns;
> +	get_pid_ns(ns);
>  	list_add(&cp->list, &cgrp->pids_list);
>  found:
>  	kfree(cp->tasks_pids);
>  	cp->tasks_pids = pidarray;
> -	cp->pids_length = npids;
> -	cp->pids_use_count++;
> +	cp->length = npids;
> +	cp->use_count++;
>  	up_write(&cgrp->pids_mutex);
>  
>  	file->f_op = &cgroup_tasks_operations;
> -- 
> 1.5.4.rc3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
