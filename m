From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks"
	that shows only unique tgids
Date: Thu, 2 Jul 2009 16:46:49 -0700
Message-ID: <20090702164649.303c4952.akpm@linux-foundation.org>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702232620.3969.16680.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 02 Jul 2009 16:26:20 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> Adds a read-only "procs" file similar to "tasks" that shows only unique tgids
> 
> struct cgroup used to have a bunch of fields for keeping track of the pidlist
> for the tasks file. Those are now separated into a new struct cgroup_pidlist,
> of which two are had, one for procs and one for tasks. The way the seq_file
> operations are set up is changed so that just the pidlist struct gets passed
> around as the private data.
> 
> Possible future functionality is making the procs file writable for purposes
> of adding all threads with the same tgid at once.
> 

It'd be nice were the changelog to spell out the contents of this file
(via an example) so we can review the proposed userspace interface
change.

> ---
> 
>  include/linux/cgroup.h |   23 +++-
>  kernel/cgroup.c        |  287 ++++++++++++++++++++++++++++++------------------

It'd be nice if the proposed userspace interface were documented too.

> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 665fa70..3b937c3 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
>
> ...
>
> -/*
> - * Load into 'pidarray' up to 'npids' of the tasks using cgroup
> - * 'cgrp'.  Return actual number of pids loaded.  No need to
> - * task_lock(p) when reading out p->cgroup, since we're in an RCU
> - * read section, so the css_set can't go away, and is
> - * immutable after creation.
> +/**
> + * pidlist_uniq - given a kmalloc()ed list, strip out all duplicate entries
> + * returns -ENOMEM if the malloc fails; 0 on success
> + */

The comment purports to be kerneldoc ("/**") but didn't document the
function's arguments.

> +/* this implementation relies on the fact that pids will never be -1 */
> +#define PIDLIST_VALUE_NONE ((pid_t)(-1))
> +static int pidlist_uniq(pid_t **p, int *length)
> +{
> +	int i, j = 0; /* array index */
> +	int last = 0; /* index of last unique entry */
> +	int count = 1; /* count of total unique entries */
> +	pid_t *list, *newlist;

a newline here is conventional.

> +	BUG_ON(p == NULL || *p == NULL || length == NULL);

Unneeded, really.  The kernel will reliably oops if any of these are
true, which provides us with the same info.

In fact debuggability would be enhanced were this assertion to be
removed, because if this goes blam then it will be very hard to work
out which of these three tests went wrong.

> +	list = *p;
> +	/*
> +	 * we presume the 0th element is unique, so i starts at 1. trivial
> +	 * edge cases first; no work needs to be done for either
> +	 */
> +	if (*length == 0 || *length == 1)
> +		return 0;
> +	for (i = 1; i < *length; i++) {
> +		BUG_ON(list[i] == PIDLIST_VALUE_NONE);
> +		if (list[i] == list[last]) {
> +			list[i] = PIDLIST_VALUE_NONE;
> +		} else {
> +			last = i;
> +			count++;
> +		}
> +	}
> +	newlist = kmalloc(count * sizeof(pid_t), GFP_KERNEL);

What is the maximum possible value of `count' here?

Is there any way in which malicious code can exploit the potential
multiplicative overflow in this statement?  (kcalloc() checks for
this).

> +	if (!newlist)
> +		return -ENOMEM;
> +	/* copy to new array */
> +	for (i = 0; i < *length; i++) {
> +		if (list[i] != PIDLIST_VALUE_NONE) {
> +			newlist[j] = list[i];
> +			j++;
> +		}
> +	}
> +	BUG_ON(j != count); /* this would fail on a zero-length array */
> +	kfree(list);
> +	*p = newlist;
> +	*length = count;
> +	return 0;
> +}
> +
> +static int cmppid(const void *a, const void *b)
> +{
> +	return *(pid_t *)a - *(pid_t *)b;
> +}
> +
> +/**
> + * Load a cgroup's pidarray with either procs' tgids or tasks' pids
>   */

again, that ain't kerneldoc.

> -static int pid_array_load(pid_t *pidarray, int npids, struct cgroup *cgrp)
> +static int pidlist_array_load(struct cgroup *cgrp, bool procs)
>  {
> -	int n = 0, pid;
> +	pid_t *array;
> +	int length;
> +	int retval;
> +	int pid, n = 0; /* used for populating the array */
>  	struct cgroup_iter it;
>  	struct task_struct *tsk;
> +	struct cgroup_pidlist *l;
> +
> +	/*
> +	 * If cgroup gets more users after we read count, we won't have
> +	 * enough space - tough.  This race is indistinguishable to the
> +	 * caller from the case that the additional cgroup users didn't
> +	 * show up until sometime later on.
> +	 */
> +	length = cgroup_task_count(cgrp);
> +	array = kmalloc(length * sizeof(pid_t), GFP_KERNEL);

max size?

overflowable?

> +	if (!array)
> +		return -ENOMEM;
> +	/* now, populate the array */
>  	cgroup_iter_start(cgrp, &it);
>  	while ((tsk = cgroup_iter_next(cgrp, &it))) {
> -		if (unlikely(n == npids))
> +		if (unlikely(n == length))
>  			break;
> -		pid = task_pid_vnr(tsk);
> -		if (pid > 0)
> -			pidarray[n++] = pid;
> +		/* get tgid or pid for procs or tasks file respectively */
> +		pid = (procs ? task_tgid_vnr(tsk) : task_pid_vnr(tsk));
> +		if (pid > 0) /* make sure to only use valid results */
> +			array[n++] = pid;
>  	}
>  	cgroup_iter_end(cgrp, &it);
> -	return n;
> +	length = n;
> +	/* now sort & (if procs) strip out duplicates */
> +	sort(array, length, sizeof(pid_t), cmppid, NULL);
> +	if (procs) {
> +		retval = pidlist_uniq(&array, &length);
> +		if (retval) { /* the malloc inside uniq can fail */
> +			kfree(array);
> +			return retval;
> +		}
> +		l = &(cgrp->procs);
> +	} else {
> +		l = &(cgrp->tasks);
> +	}
> +	/* store array in cgroup, freeing old if necessary */
> +	down_write(&l->mutex);
> +	kfree(l->list);
> +	l->list = array;
> +	l->length = length;
> +	l->use_count++;
> +	up_write(&l->mutex);
> +	return 0;
>  }
>  
> +
>  /**
>   * cgroupstats_build - build and fill cgroupstats
>   * @stats: cgroupstats to fill information into
>
> ...
>
> -static int cgroup_tasks_release(struct inode *inode, struct file *file)
> +static int cgroup_pidlist_release(struct inode *inode, struct file *file)
>  {
> -	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
> -
> +	struct cgroup_pidlist *l;
>  	if (!(file->f_mode & FMODE_READ))
>  		return 0;
> -
> -	release_cgroup_pid_array(cgrp);
> +	/*
> +	 * the seq_file will only be initialized if the file was opened for
> +	 * reading; hence we check if it's not null only in that case.
> +	 */
> +	BUG_ON(!file->private_data);

Unneeded assertion for reasons described above.

> +	l = ((struct seq_file *)file->private_data)->private;
> +	cgroup_release_pid_array(l);
>  	return seq_release(inode, file);
>  }
>  
>
> ...
>
> @@ -2389,21 +2457,27 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
>  /*
>   * for the common functions, 'private' gives the type of file
>   */
> +/* for hysterical reasons, we can't put this on the older files */

"raisins" ;)

> +#define CGROUP_FILE_GENERIC_PREFIX "cgroup."
>  static struct cftype files[] = {
>  	{
>  		.name = "tasks",
>  		.open = cgroup_tasks_open,
>  		.write_u64 = cgroup_tasks_write,
> -		.release = cgroup_tasks_release,
> -		.private = FILE_TASKLIST,
> +		.release = cgroup_pidlist_release,
>  		.mode = S_IRUGO | S_IWUSR,
>  	},
> -
> +	{
> +		.name = CGROUP_FILE_GENERIC_PREFIX "procs",
> +		.open = cgroup_procs_open,
> +		/* .write_u64 = cgroup_procs_write, TODO */
> +		.release = cgroup_pidlist_release,
> +		.mode = S_IRUGO,
> +	},
>  	{
>  		.name = "notify_on_release",
>  		.read_u64 = cgroup_read_notify_on_release,
>  		.write_u64 = cgroup_write_notify_on_release,
> -		.private = FILE_NOTIFY_ON_RELEASE,
>  	},
>  };
>  
>
> ...
>
