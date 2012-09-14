From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC] cgroup TODOs
Date: Fri, 14 Sep 2012 12:16:31 +0400
Message-ID: <5052E7DF.7040000@parallels.com>
References: <20120913205827.GO7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120913205827.GO7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

First:

Can we please keep some key userspace guys CCd?

> 1. cpu and cpuacct
> 
>   They cover the same resources and the scheduler cgroup code ends up
>   having to traverse two separate cgroup trees to update the stats.
>   With nested cgroups, the overhead isn't insignificant and it
>   generally is silly.
> 
>   While the use cases for having cpuacct on a separate and likely more
>   granular hierarchy, are somewhat valid, the consensus seems that
>   it's just not worth the trouble and cpuacct should be removed in the
>   long term and we shouldn't allow overlapping controllers for the
>   same resource, especially accounting ones.
> 
>   Solution:
> 
>   * Whine if cpuacct is not co-mounted with cpu.
> 
>   * Make sure cpu has all the stats of cpuacct.  If cpu and cpuacct
>     are comounted, don't really mount cpuacct but tell cpu that the
>     user requested it.  cpu is updated to create aliases for cpuacct.*
>     files in such cases.  This involves special casing cpuacct in
>     cgroup core but I much prefer one-off exception case to adding a
>     generic mechanism for this.
> 
>   * After a while, we can just remove cpuacct completely.
> 
>   * Later on, phase out the aliases too.
> 
>   Who:
> 
>   Me, working on it.
I can work on it as well if you want. I dealt with it many times in the
past, and tried some different approaches, so I am familiar. But if
you're already doing it, be my guest...

> 
> 2. memcg's __DEPRECATED_clear_css_refs
> 
>   This is a remnant of another weird design decision of requiring
>   synchronous draining of refcnts on cgroup removal and allowing
>   subsystems to veto cgroup removal - what's the userspace supposed to
>   do afterwards?  Note that this also hinders co-mounting different
>   controllers.
> 
>   The behavior could be useful for development and debugging but it
>   unnecessarily interlocks userland visible behavior with in-kernel
>   implementation details.  To me, it seems outright wrong (either
>   implement proper severing semantics in the controller or do full
>   refcnting) and disallows, for example, lazy drain of caching refs.
>   Also, it complicates the removal path with try / commit / revert
>   logic which has never been fully correct since the beginning.
> 
>   Currently, the only left user is memcg.
> 
>   Solution:
> 
>   * Update memcg->pre_destroy() such that it never fails.
> 
>   * Drop __DEPRECATED_clear_css_refs and all related logic.
>     Convert pre_destroy() to return void.
> 
>   Who:
> 
>   KAMEZAWA, Michal, PLEASE.  I will make __DEPRECATED_clear_css_refs
>   trigger WARN sooner or later.  Let's please get this settled.
> 
> 3. cgroup_mutex usage outside cgroup core
> 
>   This is another thing which is simply broken.  Given the way cgroup
>   is structured and used, nesting cgroup_mutex inside any other
>   commonly used lock simply doesn't work - it's held while invoking
>   controller callbacks which then interact and synchronize with
>   various core subsystems.
> 
>   There are currently three external cgroup_mutex users - cpuset,
>   memcontrol and cgroup_freezer.
> 
>   Solution:
> 
>   Well, we should just stop doing it - use a separate nested lock
>   (which seems possible for cgroup_freezer) or track and mange task
>   in/egress some other way.
> 
>   Who:
> 
>   I'll do the cgroup_freezer.  I'm hoping PeterZ or someone who's
>   familiar with the code base takes care of cpuset.  Michal, can you
>   please take care of memcg?
> 

I think this is a pressing problem, yes, but not the only problem with
cgroup lock. Even if we restrict its usage to cgroup core, we still can
call cgroup functions, which will lock. And then we gain nothing.

And the problem is that people need to lock. cgroup_lock is needed
because the data you are accessing is protected by it. The way I see it,
it is incredible how we were able to revive the BKL in the form of
cgroup_lock after we finally manage to successfully get rid of it!

We should just start to do a more fine grained locking of data, instead
of "stop the world, cgroup just started!". If we do that, the problem
you are trying to address here will even cease to exist.

> 4. Make disabled controllers cheaper
> 
>   Mostly through the use of static_keys, I suppose.  Making this
>   easier AFAICS depends on resolving #2.  The lock dependency loop
>   from #2 makes using static_keys from cgroup callbacks extremely
>   nasty.
> 
>   Solution:
> 
>   Fix #2 and support common pattern from cgroup core.
> 
>   Who:
> 
>   Dunno.  Let's see.

I've been doing it for kmem related controllers, and by trying to do it
with cpu/cpuacct, I became quite familiar with the corner cases, etc. I
can happily tackle it.

> 
> 5. I CAN HAZ HIERARCHIES?
> 
>   The cpu ones handle nesting correctly - parent's accounting includes
>   children's, parent's configuration affects children's unless
>   explicitly overridden, and children's limits nest inside parent's.
> 
>   memcg asked itself the existential question of to be hierarchical or
>   not and then got confused and decided to become both.
> 
>   When faced with the same question, blkio and cgroup_freezer just
>   gave up and decided to allow nesting and then ignore it - brilliant.
> 
>   And there are others which kinda sorta try to handle hierarchy but
>   only goes way-half.
> 
>   This one is screwed up embarrassingly badly.  We failed to establish
>   one of the most basic semantics and can't even define what a cgroup
>   hierarchy is - it depends on each controller and they're mostly
>   wacky!
> 
>   Fortunately, I don't think it will be prohibitively difficult to dig
>   ourselves out of this hole.
> 
>   Solution:
> 
>   * cpu ones seem fine.
> 
>   * For broken controllers, cgroup core will be generating warning
>     messages if the user tries to nest cgroups so that the user at
>     least can know that the behavior may change underneath them later
>     on.  For more details,
> 
>     http://thread.gmane.org/gmane.linux.kernel/1356264/focus=3902
> 
>   * memcg can be fully hierarchical but we need to phase out the flat
>     hierarchy support.  Unfortunately, this involves flipping the
>     behavior for the existing users.  Upstream will try to nudge users
>     with warning messages.  Most burden would be on the distros and at
>     least SUSE seems to be on board with it.  Needs coordination with
>     other distros.
> 
>   * blkio is the most problematic.  It has two sub-controllers - cfq
>     and blk-throttle.  Both are utterly broken in terms of hierarchy
>     support and the former is known to have pretty hairy code base.  I
>     don't see any other way than just biting the bullet and fixing it.
> 
>   * cgroup_freezer and others shouldn't be too difficult to fix.
> 
>   Who:
> 
>   memcg can be handled by memcg people and I can handle cgroup_freezer
>   and others with help from the authors.  The problematic one is
>   blkio.  If anyone is interested in working on blkio, please be my
>   guest.  Vivek?  Glauber?

I am happy to help where manpower is needed, but I must node I am a bit
ignorant of block in general.

> 
> 6. Multiple hierarchies
> 
>   Apart from the apparent wheeeeeeeeness of it (I think I talked about
>   that enough the last time[1]), there's a basic problem when more
>   than one controllers interact - it's impossible to define a resource
>   group when more than two controllers are involved because the
>   intersection of different controllers is only defined in terms of
>   tasks.
> 
>   IOW, if an entity X is of interest to two controllers, there's no
>   way to map X to the cgroups of the two controllers.  X may belong to
>   A and B when viewed by one task but A' and B when viewed by another.
>   This already is a head scratcher in writeback where blkcg and memcg
>   have to interact.
> 
>   While I am pushing for unified hierarchy, I think it's necessary to
>   have different levels of granularities depending on controllers
>   given that nesting involves significant overhead and noticeable
>   controller-dependent behavior changes.
> 
>   Solution:
> 
>   I think a unified hierarchy with the ability to ignore subtrees
>   depending on controllers should work.  For example, let's assume the
>   following hierarchy.
> 
>           R
> 	/   \
>        A     B
>       / \
>      AA AB
> 
>   All controllers are co-mounted.  There is per-cgroup knob which
>   controls which controllers nest beyond it.  If blkio doesn't want to
>   distinguish AA and AB, the user can specify that blkio doesn't nest
>   beyond A and blkio would see the tree as,
> 
>           R
> 	/   \
>        A     B
> 
>   While other controllers keep seeing the original tree.  The exact
>   form of interface, I don't know yet.  It could be a single file
>   which the user echoes [-]controller name into it or per-controller
>   boolean file.
> 
>   I think this level of flexibility should be enough for most use
>   cases.  If someone disagrees, please voice your objections now.
> 

Do you realize this is the exact same thing I proposed in our last
round, and you keep screaming saying you wanted something else, right?

The only difference is that the discussion at the time started by a
forced-comount patch, but that is not the core of the question. For that
you are proposing to make sense, the controllers need to be comounted,
and at some point we'll have to enforce it. Be it now or in the future.
But what to do when they are in fact comounted, I see no difference from
what you are saying, and what I said.

>   I *think* this can be achieved by changing where css_set is bound.
>   Currently, a css_set is (conceptually) owned by a task.  After the
>   change, a cgroup in the unified hierarchy has its own css_set which
>   tasks point to and can also be used to tag resources as necessary.
>   This way, it should be achieveable without introducing a lot of new
>   code or affecting individual controllers too much.
> 
>   The headache will be the transition period where we'll probably have
>   to support both modes of operation.  Oh well....
> 
>   Who:
> 
>   Li, Glauber and me, I guess?
> 
> 7. Misc issues
> 
>   * Sort & unique when listing tasks.  Even the documentation says it
>     doesn't happen but we have a good hunk of code doing it in
>     cgroup.c.  I'm gonna rip it out at some point.  Again, if you
>     don't like it, scream.
> 
In all honesty, I never noticed that. ugh
