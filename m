From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 2/2] Ensures correct concurrent opening/reading of
	pidlists across pid namespaces
Date: Thu, 2 Jul 2009 16:54:13 -0700
Message-ID: <20090702165413.f4a21471.akpm@linux-foundation.org>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232625.3969.54444.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702232625.3969.54444.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
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

On Thu, 02 Jul 2009 16:26:25 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> Ensures correct concurrent opening/reading of pidlists across pid namespaces
> 
> Previously there was the problem in which two processes from different pid
> namespaces reading the tasks or procs file could result in one process seeing
> results from the other's namespace. Rather than one pidlist for each file in a
> cgroup, we now keep a list of pidlists keyed by namespace and file type (tasks
> versus procs) in which entries are placed on demand. Each pidlist has its own
> lock, and that the pidlists themselves are passed around in the seq_file's
> private pointer means we don't have to touch the cgroup or its master list
> except when creating and destroying entries.
> 
> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

The way these patches were sent states that you were their primary
author.  Is that accurate?  If not, they should have had

From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

at the very top of the changelog.

>
> ...
>
>  /**
> + * find the appropriate pidlist for our purpose (given procs vs tasks)
> + * returns with the lock on that pidlist already held, and takes care
> + * of the use count, or returns NULL with no locks held if we're out of
> + * memory.
> + */

Comment purports to be kerneldoc, but isn't.

> +static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
> +						  enum cgroup_filetype type)
> +{
> +	struct cgroup_pidlist *l;
> +	/* don't need task_nsproxy() if we're looking at ourself */
> +	struct pid_namespace *ns = get_pid_ns(current->nsproxy->pid_ns);
> +	mutex_lock(&cgrp->pidlist_mutex);
> +	list_for_each_entry(l, &cgrp->pidlists, links) {
> +		if (l->key.type == type && l->key.ns == ns) {
> +			/* found a matching list - drop the extra refcount */
> +			put_pid_ns(ns);
> +			/* make sure l doesn't vanish out from under us */

This looks fishy.

> +			down_write(&l->mutex);
> +			mutex_unlock(&cgrp->pidlist_mutex);
> +			l->use_count++;
> +			return l;

The caller of cgroup_pidlist_find() must ensure that l->use_count > 0,
otherwise cgroup_pidlist_find() cannot safely use `l' - it could be
freed at any time.  But if l->use_count > 0, there is no risk of `l'
"vanishing out from under us".

I'm probably wrong there, but that's the usual pattern and this code
looks like it's doing something different.  Please check?

> +		}
> +	}
> +	/* entry not found; create a new one */
> +	l = kmalloc(sizeof(struct cgroup_pidlist), GFP_KERNEL);
> +	if (!l) {
> +		mutex_unlock(&cgrp->pidlist_mutex);
> +		return l;
> +	}
> +	init_rwsem(&l->mutex);
> +	down_write(&l->mutex);
> +	l->key.type = type;
> +	l->key.ns = ns;
> +	l->use_count = 0; /* don't increment here */
> +	l->list = NULL;
> +	l->owner = cgrp;
> +	list_add(&l->links, &cgrp->pidlists);
> +	mutex_unlock(&cgrp->pidlist_mutex);
> +	return l;
> +}
> +
>
> ...
>
