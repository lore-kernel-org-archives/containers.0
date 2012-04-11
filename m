From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFD] Merge task counter into memcg
Date: Wed, 11 Apr 2012 20:57:20 +0200
Message-ID: <20120411185715.GA4317__45079.1203686551$1334170656$gmane$org@somewhere.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

While talking with Tejun about targetting the cgroup task counter subsystem
for the next merge window, he suggested to check if this could be merged into
the memcg subsystem rather than creating a new one cgroup subsystem just
for task count limit purpose.

So I'm pinging you guys to seek your insight.

I assume not everybody in the Cc list knows what the task counter subsystem
is all about. So here is a summary: this is a cgroup subsystem (latest version
in https://lwn.net/Articles/478631/) that keeps track of the number of tasks
present in a cgroup. Hooks are set in task fork/exit and cgroup migration to
maintain this accounting visible to a special tasks.usage file. The user can
set a limit on the number of tasks by writing on the tasks.limit file.
Further forks or cgroup migration are then rejected if the limit is exceeded.

This feature is especially useful to protect against forkbombs in containers.
Or more generally to limit the resources on the number of tasks on a cgroup
as it involves some kernel memory allocation.

Now the dilemna is how to implement it?

1) As a standalone subsystem, as it stands currently (https://lwn.net/Articles/478631/)

2) As a feature in memcg, part of the memory.kmem.* files. This makes sense
because this is about kernel memory allocation limitation. We could have a
memory.kmem.tasks.count

My personal opinion is that the task counter brings some overhead: a charge
across the whole hierarchy at every fork, and the mirrored uncharge on task exit.
And this overhead happens even in the off-case (when the task counter susbsystem
is mounted but the limit is the default: ULLONG_MAX).

So if we choose the second solution, this overhead will be added unconditionally
to memcg.
But I don't expect every users of memcg will need the task counter. So perhaps
the overhead should be kept in its own separate subsystem.

OTOH memory.kmem.* interface would have be a good fit.

What do you think?
