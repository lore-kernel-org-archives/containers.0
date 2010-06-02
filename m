From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 2/2] cgroups: make procs file writable
Date: Wed, 2 Jun 2010 12:53:33 -0700
Message-ID: <AANLkTin-T6ij3xf0ceGoCamwcoayxyf0GdAKY6yXDMVl__45084.9447436214$1275508586$gmane$org@mail.gmail.com>
References: <20100530013002.GA762@ghc01.ghc.andrew.cmu.edu>
	<20100530013303.GC762@ghc01.ghc.andrew.cmu.edu>
	<20100531175242.GA14691@redhat.com>
	<20100531180446.GA16249@redhat.com>
	<AANLkTimcrX0TjzDMNJdubR92pAO4IPATbVpyvvVt0qIV@mail.gmail.com>
	<20100602140659.GA5324@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100602140659.GA5324-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jun 2, 2010 at 7:06 AM, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>
> Yes sure, I understand this part. cgroup_attach_task() correctly checks
> PF_EXITING under task_lock(), this protects from the case when this
> task has already passed cgroup_exit() which takes this lock too.

Right.

>
> But. This exactly means that the PF_EXITING check in attach_task_by_pid()
> is not necessary from the correctness pov (while probably can be considered
> as optimization), right?

For the value of correctness that was relevant when writing that code
originally, I think it's fine. But ...

> I am not sure. It doesn't hurt when we try to move a thread. But if
> we want to move the whole thread group, we should proceed even if the
> group leader has already exited and thus has PF_EXITING bit set.

Hmm, maybe. I could see this being argued both ways. Can the process
hang around indefinitely with the leader as a zombie and the other
threads still running?

It wouldn't be that hard to make it possible to avoid relying on
PF_EXITING as the check - instead we'd have an exiting_css_set object
that have the same pointer set as init_css_set, but would be
distinguishable from it as a task->cgroups pointer by virtue of being
a different object. Then cgroup_exit() can reassign tasks to point to
exiting_css_set rather than init_css_set, and the various checks that
are currently made for (task->flags & PF_EXITING) could check for
(task->cgroups == exiting_css_set) instead. This would allow task
movement further into the exit process.

Paul
