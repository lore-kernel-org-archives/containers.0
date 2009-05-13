From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IO Controller: Add per-device weight and ioprio_class
	handling
Date: Wed, 13 May 2009 15:09:29 -0400
Message-ID: <20090513190929.GB18371__44580.5280971856$1242242235$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A0A29B5.7030109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A0A29B5.7030109-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 13, 2009 at 10:00:21AM +0800, Gui Jianfeng wrote:
> Hi Vivek,
> 
> This patch enables per-cgroup per-device weight and ioprio_class handling.
> A new cgroup interface "policy" is introduced. You can make use of this 
> file to configure weight and ioprio_class for each device in a given cgroup.
> The original "weight" and "ioprio_class" files are still available. If you
> don't do special configuration for a particular device, "weight" and 
> "ioprio_class" are used as default values in this device.
> 
> You can use the following format to play with the new interface.
> #echo DEV:weight:ioprio_class > /patch/to/cgroup/policy
> weight=0 means removing the policy for DEV.
> 
> Examples:
> Configure weight=300 ioprio_class=2 on /dev/hdb in this cgroup
> # echo /dev/hdb:300:2 > io.policy
> # cat io.policy
> dev weight class
> /dev/hdb 300 2
> 
> Configure weight=500 ioprio_class=1 on /dev/hda in this cgroup
> # echo /dev/hda:500:1 > io.policy
> # cat io.policy
> dev weight class
> /dev/hda 500 1
> /dev/hdb 300 2
> 
> Remove the policy for /dev/hda in this cgroup
> # echo /dev/hda:0:1 > io.policy
> # cat io.policy
> dev weight class
> /dev/hdb 300 2
> 

Hi Gui,

Noticed few things during testing.

1. Writing 0 as weight is not removing the policy for me, if I swich the
   IO scheduler on the device.

	- echo "/dev/sdb:500:2" > io.policy
	- Change elevator on device /sdb
	- echo "/dev/sdb:0:2" > io.policy
	- cat io.policy
	  The old rule is not gone away.

2. One can add same rule twice after chaning elevator. 

	- echo "/dev/sdb:500:2" > io.policy
	- Change elevator on device /sdb
	- echo "/dev/sdb:500:2" > io.policy
	- cat io.policy

	Same rule appears twice

3. If one writes to io.weight, it should not update the weight for a
   device if there is a rule for the device already. For example, if a
   cgroup got io.weight=1000 and later i set the weight on /dev/sdb to
   500 and then change the io.weight=200, it should not be udpated for
   for groups on /dev/sdb. Why?, because I think it will make more sense
   to keep the simple rule that as long there is a rule for device, it 
   always overrides the generic settings of io.weight.

4. Wrong rule should return invalid value instead we see oops.

   - echo "/dev/sdb:0:" > io.policy

[ 2651.587533] BUG: unable to handle kernel NULL pointer dereference at
(null)
[ 2651.588301] IP: [<ffffffff811f035c>] strict_strtoul+0x24/0x79
[ 2651.588301] PGD 38c33067 PUD 38d67067 PMD 0 
[ 2651.588301] Oops: 0000 [#2] SMP 
[ 2651.588301] last sysfs file:
/sys/devices/pci0000:00/0000:00:1c.0/0000:0e:00.0/irq
[ 2651.588301] CPU 2 
[ 2651.588301] Modules linked in:
[ 2651.588301] Pid: 4538, comm: bash Tainted: G      D    2.6.30-rc4-ioc
#52 HP xw6600 Workstation
[ 2651.588301] RIP: 0010:[<ffffffff811f035c>]  [<ffffffff811f035c>]
strict_strtoul+0x24/0x79
[ 2651.588301] RSP: 0018:ffff88003dd73dc0  EFLAGS: 00010286
[ 2651.588301] RAX: 0000000000000000 RBX: 0000000000000000 RCX:
ffffffffffffffff
[ 2651.588301] RDX: ffff88003e9ffca0 RSI: 000000000000000a RDI:
0000000000000000
[ 2651.588301] RBP: ffff88003dd73de8 R08: 000000000000000a R09:
ffff88003dd73cf8
[ 2651.588301] R10: ffff88003dcd2300 R11: ffffffff8178aa00 R12:
ffff88003f4a1e00
[ 2651.588301] R13: ffff88003e9ffca0 R14: ffff88003ac5f200 R15:
ffff88003fa7ed40
[ 2651.588301] FS:  00007ff971c466f0(0000) GS:ffff88000209c000(0000)
knlGS:0000000000000000
[ 2651.588301] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2651.588301] CR2: 0000000000000000 CR3: 000000003ad0d000 CR4:
00000000000006e0
[ 2651.588301] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[ 2651.588301] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[ 2651.588301] Process bash (pid: 4538, threadinfo ffff88003dd72000, task
ffff880038d98000)
[ 2651.588301] Stack:
[ 2651.588301]  ffffffff810d8f23 ffff88003fa7ed4a ffff88003dcdeee0
ffff88003f4a1e00
[ 2651.588301]  ffff88003e9ffc60 ffff88003dd73e68 ffffffff811e8097
ffff880038dd2780
[ 2651.588301]  ffff88003dd73e48 ffff88003fa7ed40 ffff88003fa7ed49
0000000000000000
[ 2651.588301] Call Trace:
[ 2651.588301]  [<ffffffff810d8f23>] ? iput+0x2f/0x65
[ 2651.588301]  [<ffffffff811e8097>] io_cgroup_policy_write+0x11d/0x2ac
[ 2651.588301]  [<ffffffff81072dee>] cgroup_file_write+0x1ec/0x254
[ 2651.588301]  [<ffffffff811afce8>] ? security_file_permission+0x11/0x13
[ 2651.588301]  [<ffffffff810c8394>] vfs_write+0xab/0x105
[ 2651.588301]  [<ffffffff810c84a8>] sys_write+0x47/0x6c
[ 2651.588301]  [<ffffffff8100bb2b>] system_call_fastpath+0x16/0x1b
[ 2651.588301] Code: 65 ff ff ff 5b c9 c3 55 48 83 c9 ff 31 c0 fc 48 89 e5
41 55 41 89 f0 49 89 d5 41 54 53 48 89 fb 48 83 ec 10 48 c7 02 00 00 00 00
<f2> ae 48 f7 d1 49 89 cc 49 ff cc 74 39 48 8d 75 e0 44 89 c2 48 
[ 2651.588301] RIP  [<ffffffff811f035c>] strict_strtoul+0x24/0x79
[ 2651.588301]  RSP <ffff88003dd73dc0>
[ 2651.588301] CR2: 0000000000000000
[ 2651.828110] ---[ end trace 537b9a98ce297f01 ]---

Thanks
Vivek

> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.c |  239 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  block/elevator-fq.h |   11 +++
>  2 files changed, 245 insertions(+), 5 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index 69435ab..7c95d55 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -12,6 +12,9 @@
>  #include "elevator-fq.h"
>  #include <linux/blktrace_api.h>
>  #include <linux/biotrack.h>
> +#include <linux/seq_file.h>
> +#include <linux/genhd.h>
> +
>  
>  /* Values taken from cfq */
>  const int elv_slice_sync = HZ / 10;
> @@ -1045,12 +1048,30 @@ struct io_group *io_lookup_io_group_current(struct request_queue *q)
>  }
>  EXPORT_SYMBOL(io_lookup_io_group_current);
>  
> -void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
> +static struct policy_node *policy_search_node(const struct io_cgroup *iocg,
> +					      void *key);
> +
> +void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog,
> +			  void *key)
>  {
>  	struct io_entity *entity = &iog->entity;
> +	struct policy_node *pn;
> +
> +	spin_lock_irq(&iocg->lock);
> +	pn = policy_search_node(iocg, key);
> +	if (pn) {
> +		entity->weight = pn->weight;
> +		entity->new_weight = pn->weight;
> +		entity->ioprio_class = pn->ioprio_class;
> +		entity->new_ioprio_class = pn->ioprio_class;
> +	} else {
> +		entity->weight = iocg->weight;
> +		entity->new_weight = iocg->weight;
> +		entity->ioprio_class = iocg->ioprio_class;
> +		entity->new_ioprio_class = iocg->ioprio_class;
> +	}
> +	spin_unlock_irq(&iocg->lock);
>  
> -	entity->weight = entity->new_weight = iocg->weight;
> -	entity->ioprio_class = entity->new_ioprio_class = iocg->ioprio_class;
>  	entity->ioprio_changed = 1;
>  	entity->my_sched_data = &iog->sched_data;
>  }
> @@ -1263,7 +1284,7 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
>  		atomic_set(&iog->ref, 0);
>  		iog->deleting = 0;
>  
> -		io_group_init_entity(iocg, iog);
> +		io_group_init_entity(iocg, iog, key);
>  		iog->my_entity = &iog->entity;
>  #ifdef CONFIG_DEBUG_GROUP_IOSCHED
>  		iog->iocg_id = css_id(&iocg->css);
> @@ -1549,8 +1570,208 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
>  	return iog;
>  }
>  
> +static int io_cgroup_policy_read(struct cgroup *cgrp, struct cftype *cft,
> +				  struct seq_file *m)
> +{
> +	struct io_cgroup *iocg;
> +	struct policy_node *pn;
> +
> +	iocg = cgroup_to_io_cgroup(cgrp);
> +
> +	if (list_empty(&iocg->list))
> +		goto out;
> +
> +	seq_printf(m, "dev weight class\n");
> +
> +	spin_lock_irq(&iocg->lock);
> +	list_for_each_entry(pn, &iocg->list, node) {
> +		seq_printf(m, "%s %lu %lu\n", pn->dev_name,
> +			   pn->weight, pn->ioprio_class);
> +	}
> +	spin_unlock_irq(&iocg->lock);
> +out:
> +	return 0;
> +}
> +
> +static inline void policy_insert_node(struct io_cgroup *iocg,
> +					  struct policy_node *pn)
> +{
> +	list_add(&pn->node, &iocg->list);
> +}
> +
> +/* Must be called with iocg->lock held */
> +static inline void policy_delete_node(struct policy_node *pn)
> +{
> +	list_del(&pn->node);
> +}
> +
> +/* Must be called with iocg->lock held */
> +static struct policy_node *policy_search_node(const struct io_cgroup *iocg,
> +					      void *key)
> +{
> +	struct policy_node *pn;
> +
> +	if (list_empty(&iocg->list))
> +		return NULL;
> +
> +	list_for_each_entry(pn, &iocg->list, node) {
> +		if (pn->key == key)
> +			return pn;
> +	}
> +
> +	return NULL;
> +}
> +
> +static void *devname_to_efqd(const char *buf)
> +{
> +	struct block_device *bdev;
> +	void *key = NULL;
> +	struct gendisk *disk;
> +	int part;
> +
> +	bdev = lookup_bdev(buf);
> +	if (IS_ERR(bdev))
> +		return NULL;
> +
> +	disk = get_gendisk(bdev->bd_dev, &part);
> +	key = (void *)&disk->queue->elevator->efqd;
> +	bdput(bdev);
> +
> +	return key;
> +}
> +
> +static int policy_parse_and_set(char *buf, struct policy_node *newpn)
> +{
> +	char *s[3];
> +	char *p;
> +	int ret;
> +	int i = 0;
> +
> +	memset(s, 0, sizeof(s));
> +	while (i < ARRAY_SIZE(s)) {
> +		p = strsep(&buf, ":");
> +		if (!p)
> +			break;
> +		if (!*p)
> +			continue;
> +		s[i++] = p;
> +	}
> +
> +	newpn->key = devname_to_efqd(s[0]);
> +	if (!newpn->key)
> +		return -EINVAL;
> +
> +	strcpy(newpn->dev_name, s[0]);
> +
> +	ret = strict_strtoul(s[1], 10, &newpn->weight);
> +	if (ret || newpn->weight > WEIGHT_MAX)
> +		return -EINVAL;
> +
> +	ret = strict_strtoul(s[2], 10, &newpn->ioprio_class);
> +	if (ret || newpn->ioprio_class < IOPRIO_CLASS_RT ||
> +	    newpn->ioprio_class > IOPRIO_CLASS_IDLE)
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
> +static int io_cgroup_policy_write(struct cgroup *cgrp, struct cftype *cft,
> +			    const char *buffer)
> +{
> +	struct io_cgroup *iocg;
> +	struct policy_node *newpn, *pn;
> +	char *buf;
> +	int ret = 0;
> +	int keep_newpn = 0;
> +	struct hlist_node *n;
> +	struct io_group *iog;
> +
> +	buf = kstrdup(buffer, GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	newpn = kzalloc(sizeof(*newpn), GFP_KERNEL);
> +	if (!newpn) {
> +		ret = -ENOMEM;
> +		goto free_buf;
> +	}
> +
> +	ret = policy_parse_and_set(buf, newpn);
> +	if (ret)
> +		goto free_newpn;
> +
> +	if (!cgroup_lock_live_group(cgrp)) {
> +		ret = -ENODEV;
> +		goto free_newpn;
> +	}
> +
> +	iocg = cgroup_to_io_cgroup(cgrp);
> +	spin_lock_irq(&iocg->lock);
> +
> +	pn = policy_search_node(iocg, newpn->key);
> +	if (!pn) {
> +		if (newpn->weight != 0) {
> +			policy_insert_node(iocg, newpn);
> +			keep_newpn = 1;
> +		}
> +		goto update_io_group;
> +	}
> +
> +	if (newpn->weight == 0) {
> +		/* weight == 0 means deleteing a policy */
> +		policy_delete_node(pn);
> +		goto update_io_group;
> +	}
> +
> +	pn->weight = newpn->weight;
> +	pn->ioprio_class = newpn->ioprio_class;
> +
> +update_io_group:
> +	hlist_for_each_entry(iog, n, &iocg->group_data, group_node) {
> +		if (iog->key == newpn->key) {
> +			if (newpn->weight) {
> +				iog->entity.new_weight = newpn->weight;
> +				iog->entity.new_ioprio_class =
> +					newpn->ioprio_class;
> +				/*
> +				 * iog weight and ioprio_class updating
> +				 * actually happens if ioprio_changed is set.
> +				 * So ensure ioprio_changed is not set until
> +				 * new weight and new ioprio_class are updated.
> +				 */
> +				smp_wmb();
> +				iog->entity.ioprio_changed = 1;
> +			} else {
> +				iog->entity.new_weight = iocg->weight;
> +				iog->entity.new_ioprio_class =
> +					iocg->ioprio_class;
> +
> +				/* The same as above */
> +				smp_wmb();
> +				iog->entity.ioprio_changed = 1;
> +			}
> +		}
> +	}
> +	spin_unlock_irq(&iocg->lock);
> +
> +	cgroup_unlock();
> +
> +free_newpn:
> +	if (!keep_newpn)
> +		kfree(newpn);
> +free_buf:
> +	kfree(buf);
> +	return ret;
> +}
> +
>  struct cftype bfqio_files[] = {
>  	{
> +		.name = "policy",
> +		.read_seq_string = io_cgroup_policy_read,
> +		.write_string = io_cgroup_policy_write,
> +		.max_write_len = 256,
> +	},
> +	{
>  		.name = "weight",
>  		.read_u64 = io_cgroup_weight_read,
>  		.write_u64 = io_cgroup_weight_write,
> @@ -1592,6 +1813,7 @@ struct cgroup_subsys_state *iocg_create(struct cgroup_subsys *subsys,
>  	INIT_HLIST_HEAD(&iocg->group_data);
>  	iocg->weight = IO_DEFAULT_GRP_WEIGHT;
>  	iocg->ioprio_class = IO_DEFAULT_GRP_CLASS;
> +	INIT_LIST_HEAD(&iocg->list);
>  
>  	return &iocg->css;
>  }
> @@ -1750,6 +1972,7 @@ void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
>  	unsigned long flags, flags1;
>  	int queue_lock_held = 0;
>  	struct elv_fq_data *efqd;
> +	struct policy_node *pn, *pntmp;
>  
>  	/*
>  	 * io groups are linked in two lists. One list is maintained
> @@ -1823,6 +2046,12 @@ locked:
>  	BUG_ON(!hlist_empty(&iocg->group_data));
>  
>  	free_css_id(&io_subsys, &iocg->css);
> +
> +	list_for_each_entry_safe(pn, pntmp, &iocg->list, node) {
> +		policy_delete_node(pn);
> +		kfree(pn);
> +	}
> +
>  	kfree(iocg);
>  }
>  
> @@ -2137,7 +2366,7 @@ void elv_fq_unset_request_ioq(struct request_queue *q, struct request *rq)
>  void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
>  {
>  	entity->ioprio = entity->new_ioprio;
> -	entity->weight = entity->new_weight;
> +	entity->weight = entity->new_weigh;
>  	entity->ioprio_class = entity->new_ioprio_class;
>  	entity->sched_data = &iog->sched_data;
>  }
> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> index db3a347..0407633 100644
> --- a/block/elevator-fq.h
> +++ b/block/elevator-fq.h
> @@ -253,6 +253,14 @@ struct io_group {
>  #endif
>  };
>  
> +struct policy_node {
> +	struct list_head node;
> +	char dev_name[32];
> +	void *key;
> +	unsigned long weight;
> +	unsigned long ioprio_class;
> +};
> +
>  /**
>   * struct bfqio_cgroup - bfq cgroup data structure.
>   * @css: subsystem state for bfq in the containing cgroup.
> @@ -269,6 +277,9 @@ struct io_cgroup {
>  
>  	unsigned long weight, ioprio_class;
>  
> +	/* list of policy_node */
> +	struct list_head list;
> +
>  	spinlock_t lock;
>  	struct hlist_head group_data;
>  };
> -- 
> 1.5.4.rc3
> 
> 
