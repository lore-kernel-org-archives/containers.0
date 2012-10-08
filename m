From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is not locking task_lock in cgroup_fork() safe?
Date: Mon, 8 Oct 2012 14:48:58 +0200
Message-ID: <CAFTL4hzXWtzp7megsCAEuak5=_2SWmp9age-+wrpyQAU4BRZ0w__49151.0012922392$1349700561$gmane$org@mail.gmail.com>
References: <20121008020000.GB2575@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121008020000.GB2575@localhost>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

2012/10/8 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>:
> Hello, Frederic.
>
> 7e381b0eb1 ("cgroup: Drop task_lock(parent) on cgroup_fork()") removed
> task_lock from cgroup_fork citing that current->cgroups can't change
> due to threadgroup_change locking; however, threadgroup_change locking
> is used only during CLONE_THREAD forking.  If @current is forking a
> new process, there's nothing preventing someone else to migrate the
> parent while forking is in progress and delete the css_set it
> currently is using.  Am I confused somewhere?

Yeah I missed this one.
Now the whole cgroup_attach_task() is clusteracy without the
threadgroup lock anyway:

* The PF_EXITING check is racy (we are neither holding tsk->flags nor
threagroup lock).
* The cgrp == oldcgrp is racy (exit() can change the oldcgrp anytime.
* can_attach / attach / cancel_attach can race against fork/exit (and
post_fork if you consider those interested in cgroup task link like
the freezer. But that is racy in any case already even with
threadgroup lock)

It has been designed to be called under that lock. So I suspect the
best, at least for now, is to threadgroup lock from
cgroup_attach_task_all(). And also make cgroup_attach_task() static to
avoid future unsafe callers.
There is no harm yet because the only user of it calls that with
current as the "task" parameter, in a place that is
not in the middle of a fork. So no need to worry about some stable backport.

Also, looking at cgroup_attach_task_all(), what guarantee do we have
that "from" is not concurrently exiting and removing its cgrp. Which
is a separate problem. But we probably need to do some css_set_get()
before playing with it.
