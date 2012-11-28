From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix lockdep warning for event_control
Date: Wed, 28 Nov 2012 13:07:19 -0800
Message-ID: <20121128210719.GB24683__4222.20413242957$1354136869$gmane$org@htj.dyndns.org>
References: <1354133742-22175-1-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1354133742-22175-1-git-send-email-gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Aaron Durbin <adurbin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Greg.

On Wed, Nov 28, 2012 at 12:15:42PM -0800, Greg Thelen wrote:
> @@ -4276,6 +4276,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
>  	DEFINE_WAIT(wait);
>  	struct cgroup_event *event, *tmp;
>  	struct cgroup_subsys *ss;
> +	struct list_head tmp_list;

LIST_HEAD(tmp_list);

>  
>  	lockdep_assert_held(&d->d_inode->i_mutex);
>  	lockdep_assert_held(&cgroup_mutex);
> @@ -4330,16 +4331,20 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
>  	/*
>  	 * Unregister events and notify userspace.
>  	 * Notify userspace about cgroup removing only after rmdir of cgroup
> -	 * directory to avoid race between userspace and kernelspace
> +	 * directory to avoid race between userspace and kernelspace. Use
> +	 * a temporary list to avoid a deadlock with cgroup_event_wake(). Since
> +	 * cgroup_event_wake() is called with the wait queue head locked,
> +	 * remove_wait_queue() cannot be called while holding event_list_lock.
>  	 */
>  	spin_lock(&cgrp->event_list_lock);
> -	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
> +	list_replace_init(&cgrp->event_list, &tmp_list);

list_splice_init();

would be more conventional, I think.

> +	spin_unlock(&cgrp->event_list_lock);
> +	list_for_each_entry_safe(event, tmp, &tmp_list, list) {
>  		list_del(&event->list);

Maybe convert this to list_del_init() while at it?

>  		remove_wait_queue(event->wqh, &event->wait);
>  		eventfd_signal(event->eventfd, 1);
>  		schedule_work(&event->remove);
>  	}
> -	spin_unlock(&cgrp->event_list_lock);

Thanks.

-- 
tejun
