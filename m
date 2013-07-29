From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: memcg creates an unkillable task in 3.2-rc2
Date: Mon, 29 Jul 2013 20:17:11 +0200
Message-ID: <20130729181711.GA6174__32652.6538389318$1375121846$gmane$org@dhcp22.suse.cz>
References: <20130723174711.GE21100@mtj.dyndns.org>
	<8761vui4cr.fsf@xmission.com>
	<20130729075939.GA4678@dhcp22.suse.cz>
	<87ehahg312.fsf@xmission.com>
	<20130729095109.GB4678@dhcp22.suse.cz>
	<20130729161026.GD22605@mtj.dyndns.org>
	<87r4eh70yg.fsf@xmission.com>
	<20130729172046.GI22605@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130729172046.GI22605-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon 29-07-13 13:20:46, Tejun Heo wrote:
> Hey, Eric.
> 
> On Mon, Jul 29, 2013 at 10:03:35AM -0700, Eric W. Biederman wrote:
> > So this is not a simple matter of a frozen task not dying when SIGKILL
> > is received.  For the most part not dying when SIGKILL is received seems
> > like correct behavior for a frozne task.  Certainly it is correct
> > behavior for any other signal.
> > 
> > The issue is that the tasks don't freeze or that when thawed the SIGKILL
> > is still ignored.  It seems a wake up is being missed in there somewhere.
> 
> That's actually interesting and shouldn't be happening.  Can you
> please provide more data as to what's going on while freezing?  It's
> likely that the problem is not caused by freezer per-se, the task
> might be stuck elsewhere and just fails to reach the freezing point.
> 
> Would it be possible for memcg and freezer to deadlock?

Hmm, all that memcg cares about is to have only one task to call oom
handler and put other tasks on the wait queue. If the memcg oom is
disabled, and supposed to be handled from the userspace, then all of
them are sitting on the wait queue.
All the waiters are woken up when there is an uncharge and/or after
mem_cgroup_out_of_memory has been called.

> Note that while freezing is in progress, some tasks will enter freezer
> earlier than others (of course) and won't respond to anything.  If
> memcg adds wait dependency among the tasks being frozen, it'll surely
> deadlock.

If memcg oom is enabled and the killed task is frozen then we might end
up with one task looping there until the oom victim is unfrozen. There
is no entry point to the fridge from the charging path so I believe that
memcg under oom might be unfreezable under certain conditions.

If the memcg is disabled, like in this case, then there shouldn't be any
way to deadlock or prevent from freezing unless there is an issue with
freezer vs. wait queue.

[...]
> > I am also seeing what looks like a leak somewhere in the cgroup code as
> > well.  After some runs of the same reproducer I get into a state where
> > after everything is clean up.  All of the control groups have been
> > removed and the cgroup filesystem is unmounted, I can mount a cgroup
> > filesystem with that same combindation of subsystems, but I can't mount
> > a cgroup filesystem with any of those subsystems in any other
> > combination.  So I am guessing that the superblock is from the original
> > mounting is still lingering for some reason.
> 
> Hmmm... yeah, if there are cgroups with refs remaining, that'd happen.
> Note that AFAIU memcg keeps the cgroups hangling around until all the
> pages are gone from it, so it could just be that it's still draining
> which may take a long time.

If the KMEM accounting is not enabled then all the charges will be gone
during offlining. Otherwise yes, it might take really long until slab
page will be freed.

> Maybe dropping cache would work?

KMEM is not used here so I do not think this would help.

-- 
Michal Hocko
SUSE Labs
