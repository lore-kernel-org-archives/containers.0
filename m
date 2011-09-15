From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 00/11 v5] cgroups: Task counter subsystem
Date: Thu, 15 Sep 2011 15:56:54 +0200
Message-ID: <20110915135650.GA31630@somewhere.redhat.com>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
 <20110913152302.6c33ea6d.akpm@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110913152302.6c33ea6d.akpm@google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>, Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Tue, Sep 13, 2011 at 03:23:02PM -0700, Andrew Morton wrote:
> On Tue, 13 Sep 2011 01:11:20 +0200
> Frederic Weisbecker <fweisbec@gmail.com> wrote:
> 
> > No functional changes. Only documentation and comments added.
> > Checkpatch.pl fixes, etc...
> > 
> 
> What is the actual rationale for merging all of this?  For this amount
> of complexity I do think we need to see significant end-user benefits. 
> But all I'm seeing in this patchset is
> 
>        This is a step to be able to isolate a bit more a cgroup
>        against the rest of the system and limit the global impact of a
>        fork bomb inside a given cgroup.
> 
> which is really very thin.

Yeah I should have detailed more the goal of this subsystem in the
changelog.

The thing is better described in the documentation.
Quote:

"""
It has two typical usecases, although more can probably be found:

- Protect against forkbombs that explode inside a container when
that container is implemented using a cgroup. The NR_PROC rlimit
is not efficient for that because if we have several containers
running in parallel under the same user, one container could starve
all the others by spawning a high number of tasks close to the
rlimit boundary. So in this case we need this limitation to be
done in a per cgroup granularity.

- Kill all tasks inside a cgroup without races. By setting the limit
of running tasks to 0, one can prevent from any further fork inside a
cgroup and then kill all of its tasks without the need to retry an
unbound amount of time due to races between kills and forks running
in parallel (more details in "Kill a cgroup safely" paragraph).
"""

May be I can refine the changelog to explain the point there?
 
> Also, the changelogs don't appear to mention any testing results for
> the fork-bomb-killer feature.

Yeah I posted a test tool to the thread: https://lkml.org/lkml/2011/9/13/193

Among other things it includes a forkbomb that gets stopped and killed.
The limit I set is of 128 tasks but I tested it succefully with 4000 as
well.

Now it's actually hard to post the result of such a test because there
is no really useful numbers: either the machine hangs (without that
feature or other appropriate protection like rlimit) or we keep
control of it and we kill the forkbomb.

> Is the fork-bomb-killer feature realistically useful?  As I understand
> it, the problem with a fork-bomb is that it causes a huge swapstorm
> while creating tasks very quickly.  The latency impact of the swapping
> makes it very hard to regain control of the system so you can stop the
> forking.  So to be effective, this feature would need to limit the
> swapping?  Or something.  More substantiation, please.

I don't pretend to know well the internals of what happens when a forkbomb
spread far enough that you can't control the machine anymore. But what
you describe above is not surprising.

Now the goal of this subsystem is to prevent from even reaching that point
of running severely out of memory.

Setting a limit of 1024 should be enough for most processes, and if that limit
is joined, you should still be far from a swapstorm while the forkbomb
can't spread further.

People need to find the right leverage between the limit they set and
the possible resources their containers may need.

> Also, what is the relationship between this and RLIMIT_NPROC?  Given
> that we have user namespaces, does that give us per-user,
> per-namespace, per-container rlimits?  If it doesn't, should it?  Will
> it?  If it does/will, how duplicative will that be?

That too is on the doc but I can remind it in the changelog.
That subsystem is deemed for having per containers limit, where containers
are implemented by way of cgroups. RLIMIT doesn't work in that scope because
a single cgroup could starve all the others by using a huge number of tasks
if the limit is per user.

So it's not a duplication. They have no relation with each other. When a new
task is coming, if it reaches either the rlimit or the cgroup task limit, it's
refused, otherwise it increase both counters.

They are rather complementary, just not in the same scope.
