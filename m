From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Thu, 28 May 2009 10:52:07 +0200
Message-ID: <20090528085207.GA18909__10634.790096856$1243500891$gmane$org@gandalf.sssup.it>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
	<1243377729-2176-3-git-send-email-vgoyal@redhat.com>
	<e98e18940905271353kc6890dbxa1ea63026c8faec1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jbaron-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

> From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Date: Wed, May 27, 2009 01:53:59PM -0700
>
> On Tue, May 26, 2009 at 3:41 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > This is common fair queuing code in elevator layer. This is controlled by
...
> > +/**
> > + * __bfq_lookup_next_entity - return the first eligible entity in @st.
> > + * @st: the service tree.
> > + *
> > + * Update the virtual time in @st and return the first eligible entity
> > + * it contains.
> > + */
> > +static struct io_entity *__bfq_lookup_next_entity(struct io_service_tree *st)
> > +{
> > +	struct io_entity *entity;
> > +
> > +	if (RB_EMPTY_ROOT(&st->active))
> > +		return NULL;
> > +
> > +	bfq_update_vtime(st);
> 
> Vivek, Paolo, Fabio,
> Over here we call bfq_update_vtime(), and this function could have
> been called even when we are just doing a lookup (and not an extract).
> So vtime is updated while we are not really selecting the next queue
> for service (for an example, see elv_preempt_queue()). This can result
> in a call to update_vtime when only an entity with small weight (say
> weight=1) is backlogged and another entity with bigger weight (say 10)
> is getting serviced so it is not in the tree (we extract the entity
> which is getting service). This results in a big vtime jump to the
> start time of the entity with weight 1 (entity of weight 1 would have
> big start times, as it has small weight). Now when another entity with
> bigger weight (say 90) gets backlogged, it is assigned a new vtime
> from service tree's vtime, causing it to get a big value. In the
> meanwhile, iog for weight 10 keeps getting service for many quantums,
> as it was continuously backlogged.
> 
> The problem happens because we extract an entity (removing it from the
> tree) while it is getting service, and do vtime jumps based on what is
> still in the tree. I think we need to add an extra check on the vtime
> of the entity in service, before we take a vtime jump.
> 
> I have actually seen this happening when trying to debug on of my
> tests. Please let me know what you think.
> 

IIRC this behavior is not coming from bfq, as the original code
called __bfq_lookup_next_entity() without extraction only if there
was no entity under service (in bfq_update_next_active() it checked
for sd->active_entity != NULL).

I've not looked at the details of what changed, thus I don't know
why the old behavior cannot be maintained, but the virtual time jump
should be avoided in this case (and it is not specified by the wf2q+
algorithm).

[ sorry for the excessive trimming, but due to some charset problems
  the quotations were unreadable ]
