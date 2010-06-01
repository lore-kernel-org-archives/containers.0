From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 2/2] cgroups: make procs file writable
Date: Tue, 1 Jun 2010 11:57:08 -0700
Message-ID: <AANLkTimcrX0TjzDMNJdubR92pAO4IPATbVpyvvVt0qIV__21864.7973765203$1275418687$gmane$org@mail.gmail.com>
References: <20100530013002.GA762@ghc01.ghc.andrew.cmu.edu>
	<20100530013303.GC762@ghc01.ghc.andrew.cmu.edu>
	<20100531175242.GA14691@redhat.com>
	<20100531180446.GA16249@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100531180446.GA16249-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Mon, May 31, 2010 at 11:04 AM, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>
> And, forgot to mention, I do not understand the PF_EXITING check in
> attach_task_by_pid() (and some others).
>
> At first glance, it buys nothing. PF_EXITING can be set right after
> the check.

It can, but it's a benign race.

Moving a non-current thread into a cgroup takes task->alloc_lock and
checks for PF_EXITING before manipulating that thread's cgroup links.
The exit procedure sets PF_EXITING and then (somewhat later, but
guaranteed) moves current to the root cgroups while holding
alloc_lock. If a task hasn't set PF_EXITING by the time we check for
it, while holding alloc_lock, it can't enter the cgroup cleanup code
until we've finished moving it to its new cgroup. If it has set
PF_EXITING by that point, it's guaranteed to be moving itself to the
root cgroups and disconnecting from various cgroups structures in the
very near future, so it's fine to refuse to move it to a new cgroup.

Paul
