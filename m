From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/7] [RFC]Move the cgroup debug subsys into cgroup.c to
	access	internal state
Date: Tue, 17 Mar 2009 14:44:32 +0800
Message-ID: <49BF46D0.6000909@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
	<20090312105127.24154.39200.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312105127.24154.39200.stgit-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

> +static u64 current_css_set_refcount_read(struct cgroup *cont,

we can change those 'cont' to 'cgrp' along with this patch

> +					   struct cftype *cft)
> +{
> +	u64 count;
> +
> +	rcu_read_lock();
> +	count = atomic_read(&current->cgroups->refcount);
> +	rcu_read_unlock();
> +	return count;
> +}
> +
> +static u64 releasable_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	return test_bit(CGRP_RELEASABLE, &cgrp->flags);
> +}
> +
> +static struct cftype debug_files[] =  {
> +	{
> +		.name = "cgroup_refcount",
> +		.read_u64 = cgroup_refcount_read,
> +	},

a trivial inconsistency that no blank line here

> +	{
> +		.name = "taskcount",
> +		.read_u64 = taskcount_read,
> +	},
> +
> +	{
> +		.name = "current_css_set",
> +		.read_u64 = current_css_set_read,
> +	},
> +
> +	{
> +		.name = "current_css_set_refcount",
> +		.read_u64 = current_css_set_refcount_read,
> +	},
> +
> +	{
> +		.name = "releasable",
> +		.read_u64 = releasable_read,
> +	},
> +};
