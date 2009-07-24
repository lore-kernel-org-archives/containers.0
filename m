From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by tgid
	at once
Date: Fri, 24 Jul 2009 10:47:21 -0700
Message-ID: <6599ad830907241047w9a9fff9q4dc68f26a9544398__19296.4188209318$1248457690$gmane$org@mail.gmail.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
	<20090724155041.GF5878@count0.beaverton.ibm.com>
	<6599ad830907240901w4fc02097k83d0c1012708e6ee@mail.gmail.com>
	<20090724172320.GH5878@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724172320.GH5878-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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

On Fri, Jul 24, 2009 at 10:23 AM, Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
> Well, I imagine holding tasklist_lock is worse than cgroup_mutex in some
> ways since it's used even more widely. Makes sense not to use it here..

Just to clarify - the new "procs" code doesn't use cgroup_mutex for
its critical section, it uses a new cgroup_fork_mutex, which is only
taken for write during cgroup_proc_attach() (after all setup has been
done, to ensure that no new threads are created while we're updating
all the existing threads). So in general there'll be zero contention
on this lock - the cost will be the cache misses due to the rwlock
bouncing between the different CPUs that are taking it in read mode.

What happened to the big-reader lock concept from 2.4.x? That would be
applicable here - minimizing the overhead on the critical path when
the write operation is expected to be very rare.

Paul
