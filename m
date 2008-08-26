From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup(fix critical bug): new handling for tasks file
Date: Mon, 25 Aug 2008 19:29:27 -0700
Message-ID: <6599ad830808251929p10dfc9d2ub11e4db0cd4f9f3__42316.2915082232$1219717964$gmane$org@mail.gmail.com>
References: <48B360CE.2010501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48B360CE.2010501-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 25, 2008 at 6:47 PM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> In original code, we kmalloc a lot of memory when we open cgroup.tasks.
> _This memory is allocated by kmalloc_, So this memory is not statistical
> for this process or this user. This is a critical bug.

It's true that this does represent a way for an untrusted user to
consume a big chunk of memory on a machine. It's been around since
cpusets was introduced. I'm not sure that it's more serious than say,
a fork bomb or allocating lots of memory via lots of sockets with huge
network buffers. I don't see how this can cause an oops - slab.c and
slub.c both appear to just return NULL in that case, from a quick
inspection.

But improving the current code has been on my todo list for a while.
My thought on the best way to fix it is to use a proper seq_file -
that would remove the issues that you have currently with the
"unconsumed" portion of the output.

Using a seq_file iterator with your single pid array per cgroup might
work quite nicely - but isn't there still a problem that with a really
large cgroup we can overflow the kmalloc() limit for a single pid
array?

My original thoughts for solving this involved using a prio_heap to
ensure that every task in the cgroup was seen once:

1) similar to cgroup_scan_tasks, fill a prio_heap with the first N (by
task start time) tasks in the cgroup
2) sort these tasks by pid
3) report these by seq_file
4) once all the pids in the heap have been reported, update the
minimum task start time to be greater than the last task start time in
the reported group, and goto 1

This way we never have to allocate more than a single prio_heap per
open file; the downside is that we have more overhead when reporting
on really large cgroups since we have to make multiple scans of the
cgroup's task list.

Paul
