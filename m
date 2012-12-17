From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] block: implement blkcg hierarchy support in cfq
Date: Mon, 17 Dec 2012 13:50:14 -0500
Message-ID: <20121217185014.GC7235@redhat.com>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
	<20121217165228.GB7235@redhat.com>
	<20121217173800.GB2592@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121217173800.GB2592-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Peter Zijlstra <pzijlstr-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Dec 17, 2012 at 09:38:00AM -0800, Tejun Heo wrote:

[..]
> > >   Treating cfqqs and cfqgs as equals doesn't make much sense to me and
> > >   is hairy - we need to establish ioprio to weight mapping and the
> > >   weights fluctuate as processes fork and exit.
> > 
> > So weights of task (io_context) or blkcg weights don't fluctuate with
> > task fork/exit. It is just the weight on service tree, which fluctuates.
> 
> Why would the weight on service tree fluctuate?

Because tasks come and go and get queued on service tree. I am referring
to total_weight on service tree and not weight of individual entity. That
will change only if ioprio of task changes or blkio.weight is updated.

[..]
> > I think we first need to have some kind of buy-in from cpu controller
> > guys that yes in long term they will change it. Otherwise we don't want
> > to be stuck in a situation where cpu and blkio behave entirely
> > differently.
> 
> Sure, I was planning to work on that once blkio is in place but it's
> not like we can be consistent in any other way and I don't think
> making cpu support this behavior would be too difficult.  It's just
> dealing with an extra leaf node after all.  Peter?

I am not concerned about implementation. I am only worried about having
agreement that having a hidden group is a better thing to do as compared
to what we have now.

[..]
> > So though I don't mind the notion of this hidden cgroups but given
> > the fact that we have implemented things other way and left it to
> > user space to manage it based on their needs, I am not sure what's
> > that fundamental reason that we should change that assumption now.
> 
> Hmmm?  blkio doesn't work like that *at all*.  Currently, it basically
> treats the root cgroup as a leaf group, so I'm kinda lost why you're
> talking about "changing the assumption" because the proposed patchset
> maintains the existing behavior (at least for 1-level hierarchy) while
> what you're suggesting would change the behavior fundamentally.

I am comparing the change of behavior w.r.t cpu controller. Initially
we had implemented a full hierarchical controller (cpu like). It was
lot of code and never went any where so we ended up writing flat
controller. 

> 
> So, in terms of compatibility, I don't think there's a clear better
> way here.  cpu and blkio are already doing things differently and we
> need to pick one to unify the behavior and I think having separate
> weight for tasks in internal node is a better one because
> 
> * Configuration lives in cgroup proper.  No need to somehow map
>   per-schedule-entity attribute to cgroup weight, which is hairy and
>   non-obvious.
> 
> * Different controllers deal with different scheduling-entities and it
>   becomes very difficult to tell how the weight is actually being
>   distributed.  It's just nasty.
> 

Ok, so you want more preditability and don't want to rely on task
prio or ioprio so that when you co-mount cpu and blkio, you don't
have to worry about different behaviors and just by looking at cgroup
configuration you can tell what % of resoruce a group will get. Makes
sense.

[..]
> > I think we will have similar issues with others components too. In blkio
> > throttling support, we will have to put some kind of throttling limits
> > on internal group too. I guess one can raise similar concerns for memory
> > controller too where there are no internal limits on child task of a
> > cgroup but there are limits on child group.
> 
> I don't think so.  We need some way of assigning weights between tasks
> of an internal cgroup and children.  No such issue exists for
> non-weight based controllers.  I don't see any reason to change that.

I am not sure about that. So the general idea is that how resources of
a group are distributed among its children. I am not sure why are you
dismissing this notion in max limit controllers.

For example, if parent has 100MB/limit and it has 4 childs (T1, T2, T3 and G1),
then either all children can get 25MB/s or T1/T2/T3 colectively get
50MB/s and G1 gets 50MB/s. So to me question of hidden group and
its share w,r.t sibling entities is very much valid here too.

Having said that, what you are doing for CFQ, should make blk-throttle
hierachical easier. We just need to queue all IO from all tasks of
a group in a single entity and just round robin between this entity
and sibling groups. Otherwise making throttling hierarchical will become
tricky as we shall have to maintain per task queues in block throttling
layer too.

Well, I don't mind treating all tasks as a sub-group and let that sub-group
compete with sibling groups. Just want to make sure cpu controller guys
are on-board.

Thanks
Vivek
