From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by tgid
	at once
Date: Fri, 24 Jul 2009 09:01:46 -0700
Message-ID: <6599ad830907240901w4fc02097k83d0c1012708e6ee__46794.1530318514$1248451352$gmane$org@mail.gmail.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
	<20090724155041.GF5878@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724155041.GF5878-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 24, 2009 at 8:50 AM, Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
> There is much ado about not taking additional "global locks" in fork()
> paths.
>
> * The fork and exit callbacks cgroup_fork() and cgroup_exit(), don't
> * (usually) take cgroup_mutex. =A0These are the two most performance
> * critical pieces of code here.
> ...
>
> and as I recall cgroup_fork() doesn't ever take cgroup_mutex because it is
> so performance critical.

cgroup_mutex is a much bigger and heavier mutex than the new rwsem
being introduced in this patch. It's sort of the BKL of cgroups,
although where possible I'm encouraging use of finer-grained
alternatives (such as subsystem-specific locks, the per-hierarchy
lock, etc).

> Assuming the above comments in kernel/cgroup.c
> are correct then this patch adds a performance regression by introducing a
> global mutex in the fork path, doesn't it?

Yes, although to what magnitude isn't clear.

Alternatives that we looked at were:

- add a clone_rwsem to task_struct, and require that a clone operation
that's adding to the same thread group take a read lock on the
leader's clone_rwsem; then the effect would be localised to a single
process; but for a system that has one big multi-threaded server on
it, the effect would still be similar to a global lock

- move the housekeeping done by cgroup_fork() inside the tasklist_lock
critical section in do_fork(); then cgroup_attach_proc() can rely on
the existing global tasklist_lock to provide the necessary
synchronization, rather than introducing a second global lock; the
downside is that it slightly increases the size of the section where
tasklist_lock is held for write.

Paul
