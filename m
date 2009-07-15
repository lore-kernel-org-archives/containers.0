From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Wed, 15 Jul 2009 09:18:33 -0700
Message-ID: <6599ad830907150918r5ed6f2cevde9dbc9ef304fb2b__46743.1948207833$1247674906$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<2f86c2480907021817o79fce75yd9785aab682f7bb4@mail.gmail.com>
	<20090702190845.0cafc46a.akpm@linux-foundation.org>
	<6599ad830907022116n7a711c7fs52ff9b400ec8797f@mail.gmail.com>
	<20090702235527.7ddc873c.akpm@linux-foundation.org>
	<6599ad830907030911m6176dc59id3a7d897b03d2bd@mail.gmail.com>
	<20090703095000.cf46ad19.akpm@linux-foundation.org>
	<6599ad830907031054x74d90149y38aae60afa403d58@mail.gmail.com>
	<20090703111016.ceb28541.akpm@linux-foundation.org>
	<m1ocrm73cu.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ocrm73cu.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 15, 2009 at 1:33 AM, Eric W. Biederman<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> w=
rote:
>
> I think guaranteeing a truly atomic snapshot is likely to be a
> horrible idea requiring all kinds of nasty locking,

We don't guarantee a truly atomic snapshot unless you manage to read
the entire file with a single read() call.

> and smp
> scalability issues. =A0So please walk the list of pids and
> just return those that belong to your cgroup.

The downside with that is that scanning any cgroup takes O(n) in the
number of threads on the machine, so scanning them all becomes O(n^2).
We've definitely seen problems (on older kernels using cpusets, which
did something similar, i.e. walking the tasklist) where we have lots
of small cpusets and a few huge ones, and this blew up the cost of
accessing any of them.

But having said that, the idea of being able to maintain just a cursor
is something that would definitely be nice.

Here's another idea that might work:

Currently, each cgroup has a list running through the attached css_set
objects, and each css_set has a list running through its tasks; we
iterate through these lists of lists to produce the cgroup's task list

Since this list isn't sorted in any way, there's no convenient way to
save/restore your position between seq_file invocations; this is why
we currently generate a sorted snapshot, so that even if the snapshot
is updated by someone else before our next read, we know where to pick
up from (the next pid above the last one that we returned).

Instead, we could actually store cursor objects in the list itself
whenever we need to pause/resume iterating through a large cgroup (due
to hitting the limits of a single seq_file read, i.e. probably after
every 700 threads).

Then we'd just need to teach cgroup_iter_next() to distinguish between
real tasks and cursors, and skip the latter. Simple way to do that
would be to change the existing declarations in task_struct:

#ifdef CONFIG_CGROUPS
        /* Control Group info protected by css_set_lock */
        struct css_set *cgroups;
        /* cg_list protected by css_set_lock and tsk->alloc_lock */
        struct list_head cg_list;
#endif

and instead define these two fields together as a struct
cgroup_css_list_elem. A cursor can just be a cgroup_css_list_elem
whose cgroups field points to a distinguishing address that identifies
it as a cursor.

So we're guaranteed to hit all threads that are in the cgroup before
we start, and stay there until we finish; there are no guarantees
about threads that move into or out of the cgroup while we're
iterating

It's a bit more complex than just iterating over the machine's entire
pid list, but I think it scales better.

Paul
