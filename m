From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 03/10] threadgroup: extend threadgroup_lock() to cover
	exit and exec
Date: Mon, 21 Nov 2011 13:58:39 -0800
Message-ID: <20111121215839.GL25776@google.com>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-4-git-send-email-tj@kernel.org>
	<20111113164426.GB9446@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111113164426.GB9446@somewhere>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Frederic.

On Sun, Nov 13, 2011 at 05:44:32PM +0100, Frederic Weisbecker wrote:
> > The next patch will update cgroup so that it can take full advantage
> > of this change.
> 
> I don't want to nitpick really,

Heh, please go ahead and nitpick.  That's one of the main purposes of
LKML after all. :)

> but IMHO the races involved in exit and exec
> are too different, specific and complicated on their own to be solved in a
> single one patch. This should be split in two things.
> 
> The specific problems and their fix need to be described more in detail
> in the changelog because the issues are very tricky.
> 
> The exec case:
> 
> IIUC, the race in exec is about the group leader that can be changed
> to become the exec'ing thread, making while_each_thread() unsafe.

Not only that, pid changes, sighand struct may get swapped, and other
weird things which aren't usually expected for a live task happen.
It's basically semi-killed and then resurrected.

> We also have other things happening there like all the other threads
> in the group that get killed, but that should be handled by the threadgroup_change_begin()
> you put in the exit path.
> The old leader is also killed but release_task() -> __unhash_process() is called
> for it manually from the exec path. However this thread too should be covered by your
> synchronisation in exit().
> 
> So after your protection in the exit path, the only thing to protect against in exec
> is that group_leader that can change concurrently. But I may be missing something in the picture.

Hmm... an exec'ing task goes through transitions which usually aren't
allowed to happen.  It assumes exclusive access to group-shared data
structures and may ditch the current one and create a new one.

Sure, it's possible to make every cgroup method correct w.r.t. all
those via explicit locking or by being more careful but I don't see
much point in such excercise.  If the code is sitting in some hot path
and the added exclusion is gonna add significant amount of contention,
sure, we should trade off easiness for better performance /
scalability but this is for cgroup modifications, a fundamentally cold
path, and the added locking is per-task or per-threadgroup.  I don't
see any reason not to be easy here.

Please read on.

> Also note this is currently protected by the tasklist readlock. Cred
> guard mutex is certainly better, I just don't remember if you remove
> the tasklist lock in a further patch.

I don't remove tasklist_lock.

> The exit case:
> 
> There the issue is about racing against cgroup_exit() where the task can be
> assigned to the root cgroup. Is this really a problem in fact? I don't know
> if subsystems care about that. Perhaps some of them are buggy in that
> regard. At least the task counter handles that and it needs a
> ->cancel_attach_task() for this purpose in the case the migration fails due to exit.
> Not sure about others. A real synchronization against exit is less error prone for sure.
> In the end that's probably a win.

This is the same story.  Yes, we can narrow the locking and try to
make sure everyone handles partially destroyed tasks properly in all
methods, but for what?  If we can give stable threadgroups to all
cgroup methods without introducing performance or scalability
bottleneck, that's the right thing to do.  Please also note that bugs
stemming from failure to handle those corner cases properly will be
subtle, difficult to reproduce and track down.

In general, for any subsystem with pluggable interface, I think it's
best to put as much complexity as possible into the core layer to make
things eaiser for its customers.  It becomes excruciatingly painful if
the API invites subtle corner case bugs and the subsystem grows
several dozen clients down the road.

So, to me, what seems more important is how to make it easier for each
cgroup client instead of what's the minimal that's necessary right
now.

Heh, did I make any sense? :)

Thanks.

-- 
tejun
