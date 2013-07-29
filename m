From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: memcg creates an unkillable task in 3.2-rc2
Date: Mon, 29 Jul 2013 13:20:46 -0400
Message-ID: <20130729172046.GI22605__41443.0043813356$1375118468$gmane$org@mtj.dyndns.org>
References: <20130723174711.GE21100@mtj.dyndns.org>
	<8761vui4cr.fsf@xmission.com>
	<20130729075939.GA4678@dhcp22.suse.cz>
	<87ehahg312.fsf@xmission.com>
	<20130729095109.GB4678@dhcp22.suse.cz>
	<20130729161026.GD22605@mtj.dyndns.org>
	<87r4eh70yg.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87r4eh70yg.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Eric.

On Mon, Jul 29, 2013 at 10:03:35AM -0700, Eric W. Biederman wrote:
> So this is not a simple matter of a frozen task not dying when SIGKILL
> is received.  For the most part not dying when SIGKILL is received seems
> like correct behavior for a frozne task.  Certainly it is correct
> behavior for any other signal.
> 
> The issue is that the tasks don't freeze or that when thawed the SIGKILL
> is still ignored.  It seems a wake up is being missed in there somewhere.

That's actually interesting and shouldn't be happening.  Can you
please provide more data as to what's going on while freezing?  It's
likely that the problem is not caused by freezer per-se, the task
might be stuck elsewhere and just fails to reach the freezing point.

Would it be possible for memcg and freezer to deadlock?  Note that
while freezing is in progress, some tasks will enter freezer earlier
than others (of course) and won't respond to anything.  If memcg adds
wait dependency among the tasks being frozen, it'll surely deadlock.

> A single unified hierarchy is a really nasty idea for the same set of
> reasons. You have to recompile to disable a controller to see if it that
> controller's bugs are what are causing problems on your production
> system.  Compiles or even just a reboot is a very heavy hammer to ask
> people to use when they are triaging a problem.

For Nth time, unified hierarchy doesn't mean all controllers are
enabled on all hierarchies or that controllers can't be bound and
unbound dynamically.  Except for the removal of orthogonal
hierarchies, things actually become a lot more dynamic.

> I am also seeing what looks like a leak somewhere in the cgroup code as
> well.  After some runs of the same reproducer I get into a state where
> after everything is clean up.  All of the control groups have been
> removed and the cgroup filesystem is unmounted, I can mount a cgroup
> filesystem with that same combindation of subsystems, but I can't mount
> a cgroup filesystem with any of those subsystems in any other
> combination.  So I am guessing that the superblock is from the original
> mounting is still lingering for some reason.

Hmmm... yeah, if there are cgroups with refs remaining, that'd happen.
Note that AFAIU memcg keeps the cgroups hangling around until all the
pages are gone from it, so it could just be that it's still draining
which may take a long time.  Maybe dropping cache would work?

Thanks.

-- 
tejun
