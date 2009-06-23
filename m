From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Mon, 22 Jun 2009 22:43:37 -0400
Message-ID: <20090623024337.GC3620__47611.7191523828$1245725079$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-3-git-send-email-vgoyal@redhat.com>
	<20090622084612.GD3728@balbir.in.ibm.com>
	<20090622124313.GF28770@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090622124313.GF28770-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 22, 2009 at 02:43:13PM +0200, Fabio Checconi wrote:

[..]
> > > +/**
> > > + * bfq_first_active - find the eligible entity with the smallest finish time
> > > + * @st: the service tree to select from.
> > > + *
> > > + * This function searches the first schedulable entity, starting from the
> > > + * root of the tree and going on the left every time on this side there is
> > > + * a subtree with at least one eligible (start <= vtime) entity.  The path
> > > + * on the right is followed only if a) the left subtree contains no eligible
> > > + * entities and b) no eligible entity has been found yet.
> > > + */
> > > +static struct io_entity *bfq_first_active_entity(struct io_service_tree *st)
> > > +{
> > > +	struct io_entity *entry, *first = NULL;
> > > +	struct rb_node *node = st->active.rb_node;
> > > +
> > > +	while (node != NULL) {
> > > +		entry = rb_entry(node, struct io_entity, rb_node);
> > > +left:
> > > +		if (!bfq_gt(entry->start, st->vtime))
> > > +			first = entry;
> > > +
> > > +		BUG_ON(bfq_gt(entry->min_start, st->vtime));
> > > +
> > > +		if (node->rb_left != NULL) {
> > > +			entry = rb_entry(node->rb_left,
> > > +					 struct io_entity, rb_node);
> > > +			if (!bfq_gt(entry->min_start, st->vtime)) {
> > > +				node = node->rb_left;
> > > +				goto left;
> > > +			}
> > > +		}
> > > +		if (first != NULL)
> > > +			break;
> > > +		node = node->rb_right;
> > 
> > Please help me understand this, we sort the tree by finish time, but
> > search by vtime, start_time. The worst case could easily be O(N),
> > right?
> > 
> 
> no, (again, the full answer is in the paper); the nice property of
> min_start is that it partitions the tree in two regions, one with
> eligible entities and one without any of them.  once we know that
> there is one eligible entity (checking the min_start at the root)
> we can find the node i with min(F_i) subject to S_i < V walking down
> a single path from the root to the leftmost eligible entity.  (we
> need to go to the right only if the subtree on the left contains 
> no eligible entities at all.)  since the RB tree is balanced this
> can be done in O(log N).
> 

Hi Fabio,

When I go thorough the paper you mentioned above, they seem to have
sorted the tree based on eligible time (looks like equivalent of start
time) and then keep track of minimum deadline on each node (equivalnet of
finish time).

We seem to be doing reverse in BFQ where we sort tree on finish time
and keep track of minimum start time on each node. Is there any specific
reason behind that?

Thanks
Vivek
