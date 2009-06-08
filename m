From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 16/20] io-controller: IO group refcounting support
Date: Mon, 8 Jun 2009 09:53:11 -0400
Message-ID: <20090608135311.GD3652__41019.7105761201$1244469465$gmane$org@redhat.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
	<1243377729-2176-17-git-send-email-vgoyal@redhat.com>
	<4A2C716C.8070808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A2C716C.8070808-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Mon, Jun 08, 2009 at 10:03:24AM +0800, Gui Jianfeng wrote:
> Vivek Goyal wrote:
> ...
> >  
> >  /**
> > @@ -436,7 +443,6 @@ static void bfq_idle_insert(struct io_service_tree *st,
> >  {
> >  	struct io_entity *first_idle = st->first_idle;
> >  	struct io_entity *last_idle = st->last_idle;
> > -	struct io_queue *ioq = io_entity_to_ioq(entity);
> >  
> >  	if (first_idle == NULL || bfq_gt(first_idle->finish, entity->finish))
> >  		st->first_idle = entity;
> > @@ -444,10 +450,6 @@ static void bfq_idle_insert(struct io_service_tree *st,
> >  		st->last_idle = entity;
> >  
> >  	bfq_insert(&st->idle, entity);
> > -
> > -	/* Add this queue to idle list */
> > -	if (ioq)
> > -		list_add(&ioq->queue_list, &ioq->efqd->idle_list);
> >  }
> >  
> >  /**
> > @@ -723,8 +725,26 @@ int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
> >  void bfq_deactivate_entity(struct io_entity *entity, int requeue)
> >  {
> >  	struct io_sched_data *sd;
> > +	struct io_group *iog;
> >  	struct io_entity *parent;
> >  
> > +	iog = container_of(entity->sched_data, struct io_group, sched_data);
> > +
> > +	/*
> > +	 * Hold a reference to entity's iog until we are done. This function
> > +	 * travels the hierarchy and we don't want to free up the group yet
> > +	 * while we are traversing the hiearchy. It is possible that this
> > +	 * group's cgroup has been removed hence cgroup reference is gone.
> > +	 * If this entity was active entity, then its group will not be on
> > +	 * any of the trees and it will be freed up the moment queue is
> > +	 * freed up in __bfq_deactivate_entity().
> > +	 *
> > +	 * Hence, hold a reference, deactivate the hierarhcy of entities and
> > +	 * then drop the reference which should free up the whole chain of
> > +	 * groups.
> > +	 */
> > +	elv_get_iog(iog);
> > +
> >  	for_each_entity_safe(entity, parent) {
> >  		sd = entity->sched_data;
> >  
> > @@ -736,21 +756,28 @@ void bfq_deactivate_entity(struct io_entity *entity, int requeue)
> >  			 */
> >  			break;
> >  
> > -		if (sd->next_active != NULL)
> > +		if (sd->next_active != NULL) {
> >  			/*
> >  			 * The parent entity is still backlogged and
> >  			 * the budgets on the path towards the root
> >  			 * need to be updated.
> >  			 */
> > +			elv_put_iog(iog);
> >  			goto update;
> > +		}
> >  
> >  		/*
> >  		 * If we reach there the parent is no more backlogged and
> >  		 * we want to propagate the dequeue upwards.
> > +		 *
> > +		 * If entity's group has been marked for deletion, don't
> > +		 * requeue the group in idle tree so that it can be freed.
> >  		 */
> > -		requeue = 1;
> > +		if (!iog_deleting(iog))
> > +			requeue = 1;
> 
>   Hi Vivek,
> 
>   IIUC, if the iog is marked deleting, all iogs in the hierarchy don't have a chance 
>   to be requeued into idle trees. So, I wonder why do it like this? Why the upper iogs 
>   can't be requeued to the idle tree?
> 

I think this is a bug Gui. Good catch. I think following should fix it.

Thanks
Vivek



Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: linux16/block/elevator-fq.c
===================================================================
--- linux16.orig/block/elevator-fq.c	2009-06-06 14:21:11.000000000 -0400
+++ linux16/block/elevator-fq.c	2009-06-08 09:40:59.000000000 -0400
@@ -863,7 +863,7 @@ int __bfq_deactivate_entity(struct io_en
 void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 {
 	struct io_sched_data *sd;
-	struct io_group *iog;
+	struct io_group *iog, *__iog;
 	struct io_entity *parent;
 
 	iog = container_of(entity->sched_data, struct io_group, sched_data);
@@ -911,8 +911,11 @@ void bfq_deactivate_entity(struct io_ent
 		 * If entity's group has been marked for deletion, don't
 		 * requeue the group in idle tree so that it can be freed.
 		 */
-		if (!iog_deleting(iog))
-			requeue = 1;
+		if (parent) {
+			__iog = container_of(parent, struct io_group, entity);
+			if (!iog_deleting(__iog))
+				requeue = 1;
+		}
 	}
 
 	elv_put_iog(iog);
