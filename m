From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 9/9 v2] cgroup_freezer: implement proper hierarchy support
Date: Thu, 8 Nov 2012 16:57:48 +0100
Message-ID: <20121108155748.GO31821__10167.4079466195$1352390288$gmane$org@dhcp22.suse.cz>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-10-git-send-email-tj@kernel.org>
	<20121107163919.GC2660@mtj.dyndns.org>
	<20121108140852.GI31821@dhcp22.suse.cz>
	<20121108141848.GA12973@htj.dyndns.org>
	<20121108152039.GL31821@dhcp22.suse.cz>
	<20121108152923.GG12973@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121108152923.GG12973-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu 08-11-12 07:29:23, Tejun Heo wrote:
> Hey, Michal.
> 
> On Thu, Nov 08, 2012 at 04:20:39PM +0100, Michal Hocko wrote:
> > > So, in the above example in CPU2, (B->state & FREEZING) test and
> > > freezer_apply_state(C, false) can't be interleaved with the same
> > > inheritance operation from CPU1.  They either happen before or after.
> > 
> > I am not sure I understand what you mean by inheritance operation but
> 
> The operation of looking at one's parent and inherting the state.
> Here, checking parent->state and calling apply_state accordingly.
> 
> > you are right that the race is not possible because spin_lock makes
> > sure that Foo->state is done after the lock(Foo->child) and spin_unlock
> > then serves as a leave barrier so the other CPUs will see the correctly
> > updated value. The rest is handled by the fixed ordered tree walk. So
> > there is really no interleaving going on here.
> 
> I'm worried that this is a bit too subtle.

Dunno, it looks obvious now, I just missed the entry&leave implicit
barriers by spinlocks and again sorry about the confusion.

> This will work fine with a single hierarchy mutex protecting hierarchy
> updates and state propagations through it and that should work for
> most controllers too.

But single mutex is just ugly.

> I want to have at least one example of finer grained locking for
> future reference and cgroup_freezer happened to be the one I started
> working on.

I think this is a good example because it shows how to share the state
without too many implementation details.

> So, it is more complicated (not necessarily in written code but the
> sync rules) than necessary.  I'm still not sure whether to keep it or
> not.

I think the locking is fine and I would keep it this way rather than a
big lock.

> I'll add more documentation about synchronization in
> cgroup_for_each_descendant_pre() either way.

more doc cannot hurt ;)

Thanks
-- 
Michal Hocko
SUSE Labs
