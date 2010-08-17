From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix API thinko
Date: Tue, 17 Aug 2010 15:19:46 +0800
Message-ID: <4C6A3812.1070002__41584.4826646664$1282029350$gmane$org@cn.fujitsu.com>
References: <20100805225914.GA26772@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100805225914.GA26772-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

(Just came back from vacation)

Michael S. Tsirkin wrote:
> cgroup_attach_task_current_cg API that have upstream is backwards: we
> really need an API to attach to the cgroups from another process A to
> the current one.
> 
> In our case (vhost), a priveledged user wants to attach it's task to cgroups
> from a less priveledged one, the API makes us run it in the other
> task's context, and this fails.
> 
> So let's make the API generic and just pass in 'from' and 'to' tasks.
> Add an inline wrapper for cgroup_attach_task_current_cg to avoid
> breaking bisect.
> 
> Signed-off-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

I also don't like the name, but I'm not good at English or naming. ;)

> ---
> 
> Paul, Li, Sridhar, could you please review the following
> patch?
> 
> I only compile-tested it due to travel, but looks
> straight-forward to me.
> Alex Williamson volunteered to test and report the results.
> Sending out now for review as I might be offline for a bit.
> Will only try to merge when done, obviously.
> 
> If OK, I would like to merge this through -net tree,
> together with the patch fixing vhost-net.
> Let me know if that sounds ok.
> 

That's Ok.

...
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 43b2072..b38ec60 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -525,7 +525,11 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
>  void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it);
>  int cgroup_scan_tasks(struct cgroup_scanner *scan);
>  int cgroup_attach_task(struct cgroup *, struct task_struct *);
> -int cgroup_attach_task_current_cg(struct task_struct *);
> +int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);

a nitpick:

better add a blank line here.

> +static inline int cgroup_attach_task_current_cg(struct task_struct *tsk)
> +{
> +	return cgroup_attach_task_all(current, tsk);
> +}
