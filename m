From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Fri, 29 May 2009 12:06:10 -0400
Message-ID: <20090529160610.GC26962__38599.0539020442$1243613318$gmane$org@redhat.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
	<1243377729-2176-3-git-send-email-vgoyal@redhat.com>
	<e98e18940905271353kc6890dbxa1ea63026c8faec1@mail.gmail.com>
	<20090528160003.GA4335@redhat.com>
	<e98e18940905281241v4aa24716j91f351a828af604a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940905281241v4aa24716j91f351a828af604a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jbaron-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, May 28, 2009 at 12:41:27PM -0700, Nauman Rafique wrote:
> On Thu, May 28, 2009 at 9:00 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Wed, May 27, 2009 at 01:53:59PM -0700, Nauman Rafique wrote:
> >
> > [..]
> >> > +/**
> >> > + * __bfq_lookup_next_entity - return the first eligible entity in @=
st.
> >> > + * @st: the service tree.
> >> > + *
> >> > + * Update the virtual time in @st and return the first eligible ent=
ity
> >> > + * it contains.
> >> > + */
> >> > +static struct io_entity *__bfq_lookup_next_entity(struct io_service=
_tree *st)
> >> > +{
> >> > + =A0 =A0 =A0 struct io_entity *entity;
> >> > +
> >> > + =A0 =A0 =A0 if (RB_EMPTY_ROOT(&st->active))
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> >> > +
> >> > + =A0 =A0 =A0 bfq_update_vtime(st);
> >>
> >> Vivek, Paolo, Fabio,
> >> Over here we call bfq_update_vtime(), and this function could have
> >> been called even when we are just doing a lookup (and not an extract).
> >> So vtime is updated while we are not really selecting the next queue
> >> for service (for an example, see elv_preempt_queue()). This can result
> >> in a call to update_vtime when only an entity with small weight (say
> >> weight=3D1) is backlogged and another entity with bigger weight (say 1=
0)
> >> is getting serviced so it is not in the tree (we extract the entity
> >> which is getting service). This results in a big vtime jump to the
> >> start time of the entity with weight 1 (entity of weight 1 would have
> >> big start times, as it has small weight). Now when another entity with
> >> bigger weight (say 90) gets backlogged, it is assigned a new vtime
> >> from service tree's vtime, causing it to get a big value. In the
> >> meanwhile, iog for weight 10 keeps getting service for many quantums,
> >> as it was continuously backlogged.
> >>
> >> The problem happens because we extract an entity (removing it from the
> >> tree) while it is getting service, and do vtime jumps based on what is
> >> still in the tree. I think we need to add an extra check on the vtime
> >> of the entity in service, before we take a vtime jump.
> >>
> >> I have actually seen this happening when trying to debug on of my
> >> tests. Please let me know what you think.
> >>
> >
> > Hi Nauman,
> >
> > This sounds like a problem but apart from elv_preempt_queue(), in which=
 path
> > do you see it?
> >
> > Initially fabio posted the patches where preemption was allowed only if
> > the preempting queue is the next one to be served. To keep the behavior
> > same as CFQ, I have changed that logic and if we decide to preempt the
> > current queue (based on many checks like sync or async), I expire the
> > current queue and add the new queue to the front of the service tree so
> > that it is selected next. It does impact the fairness a bit but that's =
how
> > cfq does it today and concept of preemption with-in same prio class is
> > somewhat peculiar.
> >
> > So in latest patches preemption path is covered. There does not seem to=
 be
> > other paths where we do lookups while and active entity is being served.
> > For example, update_next_active() does not continue with lookup if there
> > is an active entity. So with this version of patch, you should not face
> > the issue.
> >
> > In general, I think it is a good idea to fix it in update_vtime() so
> > that not to udpate vtime if there is an active entity and not rely on
> > caller who makes sure that update_vtime() is not called when there is
> > an active entity. Do you have a quick patch for that?
> =

> Adding this extra check in update_vtime() is tricky. If we don't
> update vtime, then its possible that lookup would return no entity,
> even though there are backlogged queues, as all backlogged entities
> might be not eligible (i.e have start times bigger than vtime).
> When an entity is currently under service, we don't know what would be
> the next entity really, as it could be the current entity under
> service, depending on the actual time slice used by under service
> entity.
> =

> You are right that the lookup (without extract) was done only in
> preemption path. And with your latest changes, even that is removed.
> In this case, just having a BUG_ON() to ensure this does not happen
> should suffice.
> =

> commit dc54ad458b907db5523e8a088786014da8c4b3b2
> Author: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Date:   Thu May 28 12:27:00 2009 -0700
> =

>     Add a BUG_ON() that should fire when we can update vtime while just
>     doing a lookup for next entity (and not extraction).
> =

> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index f1179aa..d512c1b 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -1036,8 +1036,11 @@ struct io_entity *bfq_lookup_next_entity(struct
> io_sched_data *sd,
>         /*
>          * One can check for which will be next selected entity without
>          * expiring the current one.
> +        * Also, we should not call lookup when an entity is active, as
> +        * we extract an active entity from tree, and doing lookup can re=
sult
> +        * in an erroneous vtime jump when active entity is extacted from=
 tree.
>          */
> -       BUG_ON(extract && sd->active_entity !=3D NULL);
> +       BUG_ON(sd->active_entity !=3D NULL);

I think this should be good. I had added this "extract" in the past, because
preemption logic could do lookup which an entity was active.

> =

>         for (i =3D 0; i < IO_IOPRIO_CLASSES; i++, st++) {
>                 entity =3D __bfq_lookup_next_entity(st);
> =

> =

> I have some concerns about the new preemption logic.

Actually we need a more proper definition of in-class preemption. Across
class preemption means that RT class always gets to run first.

What does in-class preemption mean? If I look at the current CFQ code,
it does look like that preempting process will gain share. It is always
added to the front of the tree with "rb_key=3D0" and that means, this new
queue will get fresh time slice (even if it got time slice very recently).

Currently I have just tried to make the behavior same as CFQ to reduce
the possiblility of regressions. That's a different thing that we can
discuss what should be the exact behavior in case of in-class preemption
and first it needs to be fixed in CFQ, if current behavior is an issue.

On the other hand, I am not sure if previous bfq preemption logic was
working. We were checking if the new request belonged to the queue which
will be served next, then preempt the existing queue. While looking
for the next queue, I think we did not consider the current active
entity (as it was not on the tree). So after expiry of the current
queue, it might get selected next if it has not got its share. So there
was no point in preempting the queue. If queue already got its share, then
anyway the next queue will be selected next and there is no point in
preempting the current queue.

I am not sure why reads should preempt writes in CFQ. We are already giving
preference to reads by giving these bigger time slice as compared to
writes and that should take care of read being preferred over writes?
 =

Thanks
Vivek
  =

> We modify the
> start and finish time to make sure the entity gets selected next. So
> the entity which preempts others can eventually get more service than
> others (specially if it keeps preempting others). It seems that we can
> fix that by temporarily pushing the entity to the front, without
> modifying start/finish times. One way to do that is to add an extra
> flag to an entity. When the flag is set, we can ignore finish times
> and prefer the entity (in bfq_first_active_entity()). This has the
> advantage that since we are preserving start/finish times, over time,
> such an entity will be de-prioritized over others. In order to ensure
> that actually does happen, we can introduce a threshold (call it
> preempt_threshold). Then the entity with the flag set would jump to
> the front only if the difference between 'its finish time' and 'the
> finish time of other entities' is within this threshold. Let me know
> if it makes sense.
> =

> >
> > Thanks
> > Vivek
> >
