From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Thu, 28 May 2009 12:00:03 -0400
Message-ID: <20090528160003.GA4335__7999.45615367523$1243526600$gmane$org@redhat.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
	<1243377729-2176-3-git-send-email-vgoyal@redhat.com>
	<e98e18940905271353kc6890dbxa1ea63026c8faec1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940905271353kc6890dbxa1ea63026c8faec1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Wed, May 27, 2009 at 01:53:59PM -0700, Nauman Rafique wrote:

[..]
> > +/**
> > + * __bfq_lookup_next_entity - return the first eligible entity in @st.
> > + * @st: the service tree.
> > + *
> > + * Update the virtual time in @st and return the first eligible entity
> > + * it contains.
> > + */
> > +static struct io_entity *__bfq_lookup_next_entity(struct io_service_tr=
ee *st)
> > +{
> > + =A0 =A0 =A0 struct io_entity *entity;
> > +
> > + =A0 =A0 =A0 if (RB_EMPTY_ROOT(&st->active))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> > +
> > + =A0 =A0 =A0 bfq_update_vtime(st);
> =

> Vivek, Paolo, Fabio,
> Over here we call bfq_update_vtime(), and this function could have
> been called even when we are just doing a lookup (and not an extract).
> So vtime is updated while we are not really selecting the next queue
> for service (for an example, see elv_preempt_queue()). This can result
> in a call to update_vtime when only an entity with small weight (say
> weight=3D1) is backlogged and another entity with bigger weight (say 10)
> is getting serviced so it is not in the tree (we extract the entity
> which is getting service). This results in a big vtime jump to the
> start time of the entity with weight 1 (entity of weight 1 would have
> big start times, as it has small weight). Now when another entity with
> bigger weight (say 90) gets backlogged, it is assigned a new vtime
> from service tree's vtime, causing it to get a big value. In the
> meanwhile, iog for weight 10 keeps getting service for many quantums,
> as it was continuously backlogged.
> =

> The problem happens because we extract an entity (removing it from the
> tree) while it is getting service, and do vtime jumps based on what is
> still in the tree. I think we need to add an extra check on the vtime
> of the entity in service, before we take a vtime jump.
> =

> I have actually seen this happening when trying to debug on of my
> tests. Please let me know what you think.
> =


Hi Nauman,

This sounds like a problem but apart from elv_preempt_queue(), in which path
do you see it?

Initially fabio posted the patches where preemption was allowed only if
the preempting queue is the next one to be served. To keep the behavior
same as CFQ, I have changed that logic and if we decide to preempt the
current queue (based on many checks like sync or async), I expire the
current queue and add the new queue to the front of the service tree so
that it is selected next. It does impact the fairness a bit but that's how
cfq does it today and concept of preemption with-in same prio class is
somewhat peculiar.

So in latest patches preemption path is covered. There does not seem to be
other paths where we do lookups while and active entity is being served.
For example, update_next_active() does not continue with lookup if there
is an active entity. So with this version of patch, you should not face
the issue.

In general, I think it is a good idea to fix it in update_vtime() so
that not to udpate vtime if there is an active entity and not rely on =

caller who makes sure that update_vtime() is not called when there is
an active entity. Do you have a quick patch for that?

Thanks
Vivek
