From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 12 Apr 2012 03:07:45 +0200
Message-ID: <20120412010745.GE1787__41228.0289376669$1334192895$gmane$org@cmpxchg.org>
References: <20120411185715.GA4317@somewhere.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120411185715.GA4317-oHC15RC7JGTpAmv0O++HtFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 11, 2012 at 08:57:20PM +0200, Frederic Weisbecker wrote:
> Hi,
> 
> While talking with Tejun about targetting the cgroup task counter subsystem
> for the next merge window, he suggested to check if this could be merged into
> the memcg subsystem rather than creating a new one cgroup subsystem just
> for task count limit purpose.
> 
> So I'm pinging you guys to seek your insight.

I'm sorry you are given a runaround like this with that code.

> I assume not everybody in the Cc list knows what the task counter subsystem
> is all about. So here is a summary: this is a cgroup subsystem (latest version
> in https://lwn.net/Articles/478631/) that keeps track of the number of tasks
> present in a cgroup. Hooks are set in task fork/exit and cgroup migration to
> maintain this accounting visible to a special tasks.usage file. The user can
> set a limit on the number of tasks by writing on the tasks.limit file.
> Further forks or cgroup migration are then rejected if the limit is exceeded.
> 
> This feature is especially useful to protect against forkbombs in containers.
> Or more generally to limit the resources on the number of tasks on a cgroup
> as it involves some kernel memory allocation.

You could also twist this around and argue the same for cpu usage and
make it part of the cpu cgroup, but it doesn't really fit in either
subsystem, IMO.

> Now the dilemna is how to implement it?
> 
> 1) As a standalone subsystem, as it stands currently (https://lwn.net/Articles/478631/)

What was wrong with that again?

> 2) As a feature in memcg, part of the memory.kmem.* files. This makes sense
> because this is about kernel memory allocation limitation. We could have a
> memory.kmem.tasks.count
> 
> My personal opinion is that the task counter brings some overhead: a charge
> across the whole hierarchy at every fork, and the mirrored uncharge on task exit.
> And this overhead happens even in the off-case (when the task counter susbsystem
> is mounted but the limit is the default: ULLONG_MAX).

3) Make it an integral part of cgroups, because keeping track of tasks
in them already is, so it would be a more natural approach than
bolting it onto the memory controller.

But this has the same overhead.  And even if this would end up being a
better idea, we could still do this after merging it as a separate
controller as long as we maintain the interface.

> So if we choose the second solution, this overhead will be added unconditionally
> to memcg.
> But I don't expect every users of memcg will need the task counter. So perhaps
> the overhead should be kept in its own separate subsystem.
> 
> OTOH memory.kmem.* interface would have be a good fit.
> 
> What do you think?

Instead of integrating it task-wise, could the problem be solved by
accounting the kernel stack to kmem?  And then have a kmem limit,
which we already want anway?

After all, we would only restrict the number of tasks for the
resources they require, not to only allow an arbitrary number of tasks
(unless one wants to sell Windows 7 Starter style containers, in which
case one can go play with oneself out of tree as far as I'm concerned)
