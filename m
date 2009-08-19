From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/24] io-controller: Core of the elevator fair queuing
Date: Wed, 19 Aug 2009 14:41:42 -0400
Message-ID: <20090819184142.GD4391__48345.2736902565$1250707495$gmane$org@redhat.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
	<1250451046-9966-3-git-send-email-vgoyal@redhat.com>
	<4A8C21DE.1080001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A8C21DE.1080001-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 19, 2009 at 06:01:34PM +0200, Jerome Marchand wrote:
> Hi Vivek,
> 
> Vivek Goyal wrote:
> > o This is core of the io scheduler implemented at elevator layer. This is a mix
> >   of cpu CFS scheduler and CFQ IO scheduler. Some of the bits from CFS have
> >   to be derived so that we can support hierarchical scheduling. Without
> >   cgroups or with-in group, we should essentially get same behavior as CFQ.
> > 
> > o This patch only shows non-hierarchical bits. Hierarhical code comes in later
> >   patches.
> > 
> > o This code is the building base of introducing fair queuing logic in common
> >   elevator layer so that it can be used by all the four IO schedulers.
> 
> > +static void enqueue_io_entity(struct io_entity *entity)
> > +{
> > +	struct io_service_tree *st = entity->st;
> > +	struct io_sched_data *sd = io_entity_sched_data(entity);
> > +
> > +	/* In case task ioprio class changed while entity was off tree */
> > +	io_entity_update_prio(entity);
> > +	st->nr_active++;
> > +	sd->nr_active++;
> > +	entity->on_st = 1;
> > +	place_entity(st, entity, 0);
> > +	__enqueue_io_entity(st, entity);
> > +}
> 
> > +static void put_prev_io_entity(struct io_entity *entity)
> > +{
> > +	struct io_service_tree *st = entity->st;
> > +	struct io_sched_data *sd = io_entity_sched_data(entity);
> > +
> > +	st->active_entity = NULL;
> > +	sd->active_entity = NULL;
> > +
> > +	if (unlikely(entity->ioprio_changed)) {
> > +		dequeue_io_entity(entity);
> > +		io_entity_update_prio(entity);
> 
> That call to io_entity_update_prio() looks redundant with the one in
> enqueue_io_entity().
> 

thanks Jerome. Yes it does look like a redundant call. Will get rid of it
in next posting.

Vivek

> > +		enqueue_io_entity(entity);
> > +	} else
> > +		__enqueue_io_entity(st, entity);
> > +}
> 
> Jerome
