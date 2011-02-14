From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v8 0/3] cgroups: implement moving a threadgroup's threads
	atomically with cgroup.procs
Date: Sun, 13 Feb 2011 22:12:19 -0800
Message-ID: <AANLkTikD6YKO4C-uOHtsUWk1XMr5yXozvHL2BgbwSVAX__2755.78715741194$1297664094$gmane$org@mail.gmail.com>
References: <20101226120919.GA28529@ghc17.ghc.andrew.cmu.edu>
	<20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110209151046.89e03dcd.akpm@linux-foundation.org>
	<20110210100210.adf09c49.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110210100210.adf09c49.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 9, 2011 at 5:02 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>
> So, I think it's ok to have 'procs' interface for cgroup if
> overhead/impact of patch is not heavy.
>

Agreed - it's definitely an operation that comes up as either
confusing or annoying for users, depending on whether or not they
understand how threads and cgroups interact. (We've been getting
people wanting to do this internally at Google, and I'm guessing that
we're one of the bigger users of cgroups.)

In theory it's something that could be handled in userspace, in one of two ways:

- repeatedly scan the old cgroup's tasks file and sweep any threads
from the given process into the destination cgroup, until you complete
a clean sweep finding none. (Possibly even this is racy if a thread is
being slow to fork)

- use a process event notifier to catch thread fork events and keep
track of any newly created threads that appear after your first sweep
of threads, and be prepared to handle them for some reasonable length
of time (tens of milliseconds?) after the last thread has been
apparently moved.

(The alternative approach, of course, is to give up and never try to
move a process into a cgroup except right when you're in the middle of
forking it, before the exec(), when you know that it has only a single
thread and you're in control of it.)

These are both painful procedures, compared to the very simple
approach of letting the kernel move the entire process atomically.

It's true that it's a pretty heavyweight operation, but that weight is
only paid when you actually use it on a very large process (and which
would be even more expensive to do in userspace). For the rest of the
kernel, it's just an extra read lock in the fork path on a semaphore
in a structure that's pretty much guaranteed to be in cache.

Paul
