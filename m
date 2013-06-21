From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11] cgroup: disallow rename(2) if
	sane_behavior
Date: Fri, 21 Jun 2013 10:35:20 +0200
Message-ID: <20130621083520.GA12424__30196.2693724365$1371803740$gmane$org@dhcp22.suse.cz>
References: <20130614034717.GA31533@htj.dyndns.org>
	<20130616071648.GA1978@tango.0pointer.de>
	<20130616221556.GC28587@htj.dyndns.org>
	<20130617135122.GD5018@dhcp22.suse.cz>
	<20130617165129.GA32663@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130617165129.GA32663-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon 17-06-13 09:51:29, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Jun 17, 2013 at 03:51:22PM +0200, Michal Hocko wrote:
> > > Some configurations which are legitimate under the current parent
> > > might be invalid when put under a different parent. 
> > 
> > yes, for example all configurations where old parent is more restrictive
> > than the new one. For example. hardlimit in memcg or even more
> 
> I'm not following the hardlimit part.  Shouldn't a given hardlimit
> value have the same meaning regardless of where the node is located?
> Its application will surely be different but its meaning would be the
> same, no?

Yes the hardlimit example was misleading. I was thinking about all the
consequences. Sorry about the confusion.

> > oom_control, swappiness or use_hierarchy which are expected to be
> > consistent down the hierarchy.
> 
> use_hierarchy is going away.  Can you please explain how oom_control
> and swappiness behave?

Both have to be consistent throughout the hierarchy currently. 

The same swappiness is used for hierarchical reclaim at any
level. I plan to remove this restriction because this is really too
restrictive. We should be able to say that some groups in a hierarchy
shouldn't swap etc.

I am not sure about oom_control yet, though. OOM is handled at the first
hierarchy level which cannot be pushed down to its hard limit and the
whole subtree is oom frozen.
It would be little awkward if a group down the hierarchy hit its own
limit as well and fired OOM while the OOM is frozen up the hierarchy
and user space tries to find out the best candidate to kill in that
hierarchy:
A (under_oom=true) - waiting for userspace
 \
  .
  .
  .
   \
    B - hit the limit and call mem_cgroup_out_of_memory

On the other hand the handler should be prepared to handle exiting
tasks (which might change the oom situation) so the under_oom has to be
checked after a victim is selected and before it is killed to prevent
from an excessive killing.

It would be even more interesting if the situation was opposite. Child
has the oom disabled and waits for userspace to handle the situation.
     A (oom_control=0)
    / \___________
   /              \
  B (charge)       C (oom_control=1)

Parent gets under oom as well because a sibling pushes it to the
hard limit. Parent wouldn't be able to oom freeze the hierarchy
(mem_cgroup_oom_lock) because there is an ongoing oom down the hierarchy
so it would be basically waiting for userspace as well. This would be
quite unexpected. While the oom freezing could be tweaked to handle this
it sounds quite messy to me.

> > The biggest problem I can see is how the core cgroup code know when it is
> > OK to migrate. There might be some ongoing operations that depend on the
> > current tree structure. For example the hierarchical reclaim or oom
> > etc..
> 
> Internally, I think it should be implemented as task migrating to
> another cgroup - IOW, to controllers, it'll appear the same as the
> userland echoing the pid to cgroup.procs file on the new cgroup.

OK, that should work. The controller still should have an option to say
that the current configuration is not compatible with its new parent.
E.g. for memcg if parent->oom_control != moving_memcg->oom_control so
the move would fail.

> That's the only sane way to implement it as controllers need to do
> everything which it does for the normal task migration case anyway.
> Matching the impedance would be the responsibility of cgroup core.
> 
> > I do not think that soft reclaim which I was talking about at LSF would
> > change anything here as it would be pretty much the same as the hard
> > limit. But that is not so important.
> 
> I think it's very important to have trivially stackable
> configurations.  Maybe we can make more complex semantics work too but
> it's gonna be confusing like hell when combined with the level of
> automation we're hoping to achieve.
> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs
