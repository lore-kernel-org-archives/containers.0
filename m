From: Peter Dolding <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: OOM and Cgroups. How Cgroups could help OOM Killer do its job better.
Date: Thu, 7 Apr 2011 10:36:40 +1000
Message-ID: <BANLkTiniMkJkQWk4EK=mGh43aHvyKdgaEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I don't have the skill to implement this.    But I have been thinking about
the problem.  I have come up with a plan that could remove lot of the issues
OOM can cause and how  CGROUPS can stop it.  To me it makes sense.

Memory.oom_control provides
oom_kill_disable
and under_oom already.

Problem is these are really not what you call fine grained enough.

I have not looked at oom_kill_disable but I would hope this would limit
applications using oom_kill_disable only to be able to allocate as much
memory as the computer has.  If not this could be a nasty bug.  Over commit
and a process that cannot be killed by OOM is a really bad thing.

Really oom_control needs a oom selection order.

Basic description
memory.oom_order
This is the order of preference this cgroup will see the oom killer.  0
being default and last to be oom killed.    Highest numbers first.   So a
cgroup marked 2 will be have applications terminated before a cgroup marked
1  and 1 applications will be terminated before those marked 0.   Also I
would restrict oom disable setting only to oom_order number 0.  This allows
users and distributions to have full control over what order application
groups disappear.  This also removes the random shot gun like effect OOM
killer can have without requiring per application tweaking or basically
blocking the OOM Killer from being able to work.  Since less critical
processes should go first less risk of system issues.

Yes I find it strange applications have a preference order to be killed
assigned but cgroup does not have one at this stage.

 Also I would consider making everything at oom_order 0 unable to
over-commit memory since it is what should work no matter what.  This would
be a change from past but no different to if system admin had turned
over-commit off system wide.   So allowing over-commit to be turned on
selectively group by group by raising the groups order.  Effect also putting
the applications using over-commit up to be taken out by the oom killer
first to save the applications that did not over-commit that are critical to
system operations.

This way adding this flag does not cause any backwards compatibility issues
since not changing it the system acts exactly how it use to.

Next is oom termination style. under_oom might be able to take these flags.

Some cases inside a cgroup you will not want the oom cherry picking.  Since
by cherry picking a task oom kills may be just restarted so returning you to
another oom event.  So a flag to say to the oom killer if you need memory
terminate everything in this cgroup at once.  This maybe able to speed up
oom killer getting back memory as well.  That a cgroup has been terminated
this way a message would have to remain for systemd and the like to know
why.  So an attempt at restarting the cgroup is not done while resources are
low.

At this stage as far I know you cannot assign a decanted swapfile to a
cgroup so having the option to suspend a cgroup to disk in case of large
memory pressure or cpu pressure automatically could not be done.

These setting combined with systemd should be able to make unplanned OOM
events less common.  Hopefully a never event.

Peter Dolding
