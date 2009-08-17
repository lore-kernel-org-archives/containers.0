From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 02/24] io-controller: Core of the elevator fair queuing
Date: Mon, 17 Aug 2009 13:29:48 +0800
Message-ID: <4A88EACC.6010805__36483.4136133597$1250487182$gmane$org@cn.fujitsu.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
	<1250451046-9966-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250451046-9966-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> +static void place_entity(struct io_service_tree *st, struct io_entity *entity,
> +				int add_front)
> +{
> +	u64 vdisktime = st->min_vdisktime;
> +	struct rb_node *parent;
> +	struct io_entity *entry;
> +	int nr_active = st->nr_active - 1;
> +
> +	/*
> +	 * Currently put entity at the end of last entity. This probably will
> +	 * require adjustments as we move along
> +	 */
> +	if (io_entity_class_idle(entity)) {
> +		vdisktime = elv_delta_fair(ELV_IDLE_DELAY, entity);
> +		parent = rb_last(&st->active);
> +		if (parent) {
> +			entry = rb_entry(parent, struct io_entity, rb_node);
> +			vdisktime += entry->vdisktime;
> +		}
> +	} else if (!add_front && nr_active) {
> +		parent = rb_last(&st->active);
> +		if (parent) {
> +			entry = rb_entry(parent, struct io_entity, rb_node);
> +			vdisktime = entry->vdisktime;
> +		}
> +	} else
> +		vdisktime = st->min_vdisktime;

Hi Vivek,

Should we set vdisktime a little small than st->min_vdisktime to ensure putting
this entity at the left-most position when add_front is set?

> +
> +	entity->vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
> +}
> +
> +static inline void io_entity_update_prio(struct io_entity *entity)
> +{
> +	if (unlikely(entity->ioprio_changed)) {
> +		/*
> +		 * Re-initialize the service tree as ioprio class of the
> +		 * entity might have changed.
> +		 */
> +		init_io_entity_service_tree(entity, parent_entity(entity));
> +		entity->ioprio_changed = 0;
> +	}
> +}
> +


-- 
Regards
Gui Jianfeng
