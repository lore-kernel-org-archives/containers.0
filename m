From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/9] cgroup: introduce struct cgroup_pidlist_open_file
Date: Fri, 29 Nov 2013 09:03:01 +0800
Message-ID: <5297E7C5.5000505@huawei.com>
References: <1385331096-7918-1-git-send-email-tj@kernel.org>
	<1385331096-7918-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385331096-7918-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

> @@ -3841,6 +3851,7 @@ static const struct file_operations cgroup_pidlist_operations = {
>  static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
>  {
>  	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
> +	struct cgroup_pidlist_open_file *of;
>  	struct cgroup_pidlist *l;
>  	int retval;
>  
> @@ -3851,12 +3862,17 @@ static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
>  	/* configure file information */
>  	file->f_op = &cgroup_pidlist_operations;
>  
> -	retval = seq_open(file, &cgroup_pidlist_seq_operations);
> +	retval = seq_open_private(file, &cgroup_pidlist_seq_operations,
> +				  sizeof(*of));

should be a bit simpler to use __seq_open_private():

	of = __seq_open_private(...);
	if (!of) {
		...
		return -ENOMEM;
	}

and then @retval can be removed in 6/7.

>  	if (retval) {
>  		cgroup_release_pid_array(l);
>  		return retval;
>  	}
> -	((struct seq_file *)file->private_data)->private = l;
> +
> +	of = ((struct seq_file *)file->private_data)->private;
> +	of->type = type;
> +	of->cgrp = cgrp;
> +	of->pidlist = l;
>  	return 0;
>  }
>  static int cgroup_tasks_open(struct inode *unused, struct file *file)
> 
