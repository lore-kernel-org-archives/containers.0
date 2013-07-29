From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: memcg creates an unkillable task in 3.2-rc2
Date: Mon, 29 Jul 2013 10:03:35 -0700
Message-ID: <87r4eh70yg.fsf@xmission.com>
References: <20130723174711.GE21100@mtj.dyndns.org>
	<8761vui4cr.fsf@xmission.com> <20130729075939.GA4678@dhcp22.suse.cz>
	<87ehahg312.fsf@xmission.com> <20130729095109.GB4678@dhcp22.suse.cz>
	<20130729161026.GD22605@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130729161026.GD22605-9pTldWuhBndy/B6EtB590w@public.gmane.org> (Tejun Heo's message of
	"Mon, 29 Jul 2013 12:10:26 -0400")
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
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> Hello,
>
> On Mon, Jul 29, 2013 at 11:51:09AM +0200, Michal Hocko wrote:
>> Isn't this a bug in freezer then? I am not familiar with the freezer
>> much but memcg oom handling seems correct to me. The task is sleeping
>> KILLABLE and fatal_signal_pending in mem_cgroup_handle_oom will tell us
>> to bypass the charge and let the taks go away.
>
> Is the problem a frozen task not being killed even when SIGKILL is
> received?  If so, it is a known problem and a side-effect of
> cgroup_freezer (ab)using and making the existing power management
> freezer visible to userland without really thinking about the
> implications.  :(

Something like that.  I need to look at it in a little more detail.
The idiom someone adopted to atomically kill all of the tasks in a
cgroup is to.  Freeze all of the tasks.  Send them SIGKILL. unfreeze
all of the tasks.

The freezing actually fails in this case so I don't know what is
happening.

So this is not a simple matter of a frozen task not dying when SIGKILL
is received.  For the most part not dying when SIGKILL is received seems
like correct behavior for a frozne task.  Certainly it is correct
behavior for any other signal.

The issue is that the tasks don't freeze or that when thawed the SIGKILL
is still ignored.  It seems a wake up is being missed in there somewhere.

> So, yeah, if you use cgroup_freezer now, the tasks will get stuck in
> states which aren't well defined when visible from userland and will
> just stay there until unfrozen no matter what.  Yet another reason
> I'll be screaming like a banshee at anyone who says that cgroup is
> built to delegate subtree access rights to !root users.

Yes.  From the looks of the looks of it the cgroup implementation is
rather badly borked right now, and definitely not up to the standards of
the other core pieces of the kernel.  One of the reasons I was rather
apalled when systemd started using them.  Until the code actually works
reliably and the races are removed most people's systems would be much
better off with cgroups compiled out.

A single unified hierarchy is a really nasty idea for the same set of
reasons. You have to recompile to disable a controller to see if it that
controller's bugs are what are causing problems on your production
system.  Compiles or even just a reboot is a very heavy hammer to ask
people to use when they are triaging a problem.

That said semantically having more than single process controls for all
of user space are very desirable.  Until we have code that is safe to
use giving it any additional exposure seems like a bad idea.

> It's on the to-do list but a very long term one.  Right now, if you
> combine userland OOM handling with freezer and whatnot, it'd be pretty
> easy to get into trouble.

Thanks for the heads up.  Right now this is looking like a regression
but it might just be that my test machine has the right combination
of racying pixies to trigger a long standing bug.


I am also seeing what looks like a leak somewhere in the cgroup code as
well.  After some runs of the same reproducer I get into a state where
after everything is clean up.  All of the control groups have been
removed and the cgroup filesystem is unmounted, I can mount a cgroup
filesystem with that same combindation of subsystems, but I can't mount
a cgroup filesystem with any of those subsystems in any other
combination.  So I am guessing that the superblock is from the original
mounting is still lingering for some reason.

Eric
