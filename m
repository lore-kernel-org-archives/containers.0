From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 07/20] io-controller: Export disk time used and nr
	sectors dipatched through cgroups
Date: Tue, 23 Jun 2009 10:38:56 -0400
Message-ID: <20090623143856.GB4262__15735.5646173984$1245768180$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-8-git-send-email-vgoyal@redhat.com>
	<4A40C64E.8040305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A40C64E.8040305-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 23, 2009 at 08:10:54PM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> > +
> > +static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
> > +				struct cftype *cftype, struct seq_file *m)
> > +{
> > +	struct io_cgroup *iocg;
> > +	struct io_group *iog;
> > +	struct hlist_node *n;
> > +
> > +	if (!cgroup_lock_live_group(cgroup))
> > +		return -ENODEV;
> > +
> > +	iocg = cgroup_to_io_cgroup(cgroup);
> > +
> > +	spin_lock_irq(&iocg->lock);
> 
> It's better to make use of rcu_read_lock instead since it's
> a read action.
> 

Thanks Gui. Queued for next posting.

Vivek

> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index 2ad40eb..d779282 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -1418,7 +1418,7 @@ static int io_cgroup_disk_time_read(struct cgroup *cgroup,
>  
>  	iocg = cgroup_to_io_cgroup(cgroup);
>  
> -	spin_lock_irq(&iocg->lock);
> +	rcu_read_lock();
>  	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
>  		/*
>  		 * There might be groups which are not functional and
> @@ -1430,7 +1430,7 @@ static int io_cgroup_disk_time_read(struct cgroup *cgroup,
>  					iog->entity.total_service);
>  		}
>  	}
> -	spin_unlock_irq(&iocg->lock);
> +	rcu_read_unlock();
>  	cgroup_unlock();
>  
>  	return 0;
> @@ -1448,7 +1448,7 @@ static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
>  
>  	iocg = cgroup_to_io_cgroup(cgroup);
>  
> -	spin_lock_irq(&iocg->lock);
> +	rcu_read_lock();
>  	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
>  		/*
>  		 * There might be groups which are not functional and
> @@ -1460,7 +1460,7 @@ static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
>  					iog->entity.total_sector_service);
>  		}
>  	}
> -	spin_unlock_irq(&iocg->lock);
> +	rcu_read_unlock();
>  	cgroup_unlock();
>  
>  	return 0;
> @@ -1478,7 +1478,7 @@ static int io_cgroup_disk_queue_read(struct cgroup *cgroup,
>  		return -ENODEV;
>  
>  	iocg = cgroup_to_io_cgroup(cgroup);
> -	spin_lock_irq(&iocg->lock);
> +	rcu_read_lock();
>  	/* Loop through all the io groups and print statistics */
>  	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
>  		/*
> @@ -1491,7 +1491,7 @@ static int io_cgroup_disk_queue_read(struct cgroup *cgroup,
>  					iog->queue_duration);
>  		}
>  	}
> -	spin_unlock_irq(&iocg->lock);
> +	rcu_read_unlock();
>  	cgroup_unlock();
>  
>  	return 0;
> -- 
> 1.5.4.rc3
> 
> 
> 
> > +	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
> > +		/*
> > +		 * There might be groups which are not functional and
> > +		 * waiting to be reclaimed upon cgoup deletion.
> > +		 */
> > +		if (iog->key) {
> > +			seq_printf(m, "%u %u %lu\n", MAJOR(iog->dev),
> > +					MINOR(iog->dev),
> > +					iog->entity.total_sector_service);
> > +		}
> > +	}
> > +	spin_unlock_irq(&iocg->lock);
> > +	cgroup_unlock();
> > +
> > +	return 0;
> > +}
> > +
> >
