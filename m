From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 05/18] io-controller: Common hierarchical fair queuing
	code in elevaotor layer
Date: Thu, 07 May 2009 15:42:37 +0800
Message-ID: <4A0290ED.7080506__6197.90985151685$1241682293$gmane$org@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<1241553525-28095-6-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241553525-28095-6-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> This patch enables hierarchical fair queuing in common layer. It is
> controlled by config option CONFIG_GROUP_IOSCHED.
...
> +}
> +
> +void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
> +{
> +	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
> +	struct hlist_node *n, *tmp;
> +	struct io_group *iog;
> +
> +	/*
> +	 * Since we are destroying the cgroup, there are no more tasks
> +	 * referencing it, and all the RCU grace periods that may have
> +	 * referenced it are ended (as the destruction of the parent
> +	 * cgroup is RCU-safe); bgrp->group_data will not be accessed by
> +	 * anything else and we don't need any synchronization.
> +	 */
> +	hlist_for_each_entry_safe(iog, n, tmp, &iocg->group_data, group_node)
> +		io_destroy_group(iocg, iog);
> +
> +	BUG_ON(!hlist_empty(&iocg->group_data));
> +

    Hi Vivek,

    IMHO, free_css_id() needs to be called here.

> +	kfree(iocg);
> +}
> +
> +void io_disconnect_groups(struct elevator_queue *e)
> +{
> +	struct hlist_node *pos, *n;
> +	struct io_group *iog;
> +	struct elv_fq_data *efqd = &e->efqd;
> +
> +	hlist_for_each_entry_safe(iog, pos, n, &efqd->group_list,
> +					elv_data_node) {
> +		hlist_del(&iog->elv_data_node);
> +

-- 
Regards
Gui Jianfeng
