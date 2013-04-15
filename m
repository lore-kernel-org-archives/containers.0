From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] cgroup: implement task_cgroup_path_from_hierarchy()
Date: Mon, 15 Apr 2013 11:43:15 +0800
Message-ID: <516B7753.9060503__25490.6619237319$1365997416$gmane$org@huawei.com>
References: <1365964619-14762-1-git-send-email-tj@kernel.org>
	<1365964619-14762-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365964619-14762-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

> +int task_cgroup_path_from_hierarchy(struct task_struct *task, int hierarchy_id,
> +				    char *buf, size_t buflen)
> +{
> +	struct cgroupfs_root *root;
> +	struct cgroup *cgrp = NULL;
> +	int ret = -ENOENT;
> +
> +	mutex_lock(&cgroup_mutex);
> +
> +	root = idr_find(&cgroup_hierarchy_idr, hierarchy_id);
> +	if (root) {
> +		cgrp = task_cgroup_from_root(task, root);

task_cgroup_from_root() will never return NULL, and there's a BUG_ON(!res) in it.

> +		if (cgrp)
> +			ret = cgroup_path(cgrp, buf, buflen);
> +	}
> +
> +	mutex_unlock(&cgroup_mutex);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(task_cgroup_path_from_hierarchy);
