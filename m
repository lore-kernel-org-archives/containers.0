From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 1/4] cgroups: Fix race between userspace and
	kernelspace
Date: Sat, 20 Feb 2010 13:00:55 +0900
Message-ID: <20100220130055.02bb143a.kamezawa.hiroyu__17259.4186653898$1266638815$gmane$org@jp.fujitsu.com>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, 20 Feb 2010 00:28:16 +0200
"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

> Notify userspace about cgroup removing only after rmdir of cgroup
> directory to avoid race between userspace and kernelspace.
> 
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Hmm, but could you elaborate what is the race in patch description.
I can imagine by reading your patch but please write it in clear way.



> ---
>  kernel/cgroup.c |   32 +++++++++++++++++---------------
>  1 files changed, 17 insertions(+), 15 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index ce9008f..46903cb 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -780,28 +780,15 @@ static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
>  static int cgroup_call_pre_destroy(struct cgroup *cgrp)
>  {
>  	struct cgroup_subsys *ss;
> -	struct cgroup_event *event, *tmp;
>  	int ret = 0;
>  
>  	for_each_subsys(cgrp->root, ss)
>  		if (ss->pre_destroy) {
>  			ret = ss->pre_destroy(ss, cgrp);
>  			if (ret)
> -				goto out;
> +				break;
>  		}
>  
> -	/*
> -	 * Unregister events and notify userspace.
> -	 */
> -	spin_lock(&cgrp->event_list_lock);
> -	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
> -		list_del(&event->list);
> -		eventfd_signal(event->eventfd, 1);
> -		schedule_work(&event->remove);
> -	}
> -	spin_unlock(&cgrp->event_list_lock);
> -
> -out:
>  	return ret;
>  }
>  
> @@ -2991,7 +2978,6 @@ static void cgroup_event_remove(struct work_struct *work)
>  	event->cft->unregister_event(cgrp, event->cft, event->eventfd);
>  
>  	eventfd_ctx_put(event->eventfd);
> -	remove_wait_queue(event->wqh, &event->wait);
>  	kfree(event);
>  }
>  
> @@ -3009,6 +2995,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
>  	unsigned long flags = (unsigned long)key;
>  
>  	if (flags & POLLHUP) {
> +		remove_wait_queue_locked(event->wqh, &event->wait);
>  		spin_lock(&cgrp->event_list_lock);
>  		list_del(&event->list);
>  		spin_unlock(&cgrp->event_list_lock);
> @@ -3457,6 +3444,7 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
>  	struct dentry *d;
>  	struct cgroup *parent;
>  	DEFINE_WAIT(wait);
> +	struct cgroup_event *event, *tmp;
>  	int ret;
>  
>  	/* the vfs holds both inode->i_mutex already */
> @@ -3540,6 +3528,20 @@ again:
>  	set_bit(CGRP_RELEASABLE, &parent->flags);
>  	check_for_release(parent);
>  
> +	/*
> +	 * Unregister events and notify userspace.
> +	 * Notify userspace about cgroup removing only after rmdir of cgroup
> +	 * directory to avoid race between userspace and kernelspace
> +	 */
> +	spin_lock(&cgrp->event_list_lock);
> +	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
> +		list_del(&event->list);
> +		remove_wait_queue(event->wqh, &event->wait);
> +		eventfd_signal(event->eventfd, 1);
> +		schedule_work(&event->remove);
> +	}
> +	spin_unlock(&cgrp->event_list_lock);
> +
>  	mutex_unlock(&cgroup_mutex);
>  	return 0;
>  }
> -- 
> 1.6.6.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
> 
