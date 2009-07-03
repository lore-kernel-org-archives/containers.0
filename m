From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks"
	that  shows only unique tgids
Date: Fri, 3 Jul 2009 14:54:41 +0900
Message-ID: <20090703145441.f526793f.kamezawa.hiroyu__13624.3909983479$1246600701$gmane$org@jp.fujitsu.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
	<20090702175341.fd2e26d5.akpm@linux-foundation.org>
	<6599ad830907021808o6f3bb51eh324e4bf13544d83e@mail.gmail.com>
	<20090702183004.1e3f4315.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702183004.1e3f4315.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2 Jul 2009 18:30:04 -0700
Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> On Thu, 2 Jul 2009 18:08:29 -0700 Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > On Thu, Jul 2, 2009 at 5:53 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > >> In the first snippet, count will be at most equal to length. As length
> > >> is determined from cgroup_task_count, it can be no greater than the
> > >> total number of pids on the system.
> > >
> > > Well that's a problem, because there can be tens or hundreds of
> > > thousands of pids, and there's a fairly low maximum size for kmalloc()s
> > > (include/linux/kmalloc_sizes.h).
> > >
> > > And even if this allocation attempt doesn't exceed KMALLOC_MAX_SIZE,
> > > large allocations are less unreliable. __There is a large break point at
> > > 8*PAGE_SIZE (PAGE_ALLOC_COSTLY_ORDER).
> > 
> > This has been a long-standing problem with the tasks file, ever since
> > the cpusets days.
> > 
> > There are ways around it - Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> posted
> > a patch that allocated an array of pages to store pids in, with a
> > custom sorting function that let you specify indirection rather than
> > assuming everything was in one contiguous array. This was technically
> > the right approach in terms of not needing vmalloc and never doing
> > large allocations, but it was very complex; an alternative that was
> > mooted was to use kmalloc for small cgroups and vmalloc for large
> > ones, so the vmalloc penalty wouldn't be paid generally. The thread
> > fizzled AFAICS.
> 
> It's a problem which occurs fairly regularly.  Some sites are fairly
> busted.  Many gave up and used vmalloc().  Others use an open-coded
> array-of-pages thing.
> 
> This happens enough that I expect the kernel would benefit from a
> general dynamic-array library facility.  Something whose interface
> mimics the C-level array operations but which is internally implemented
> via some data structure which uses PAGE_SIZE allocations.  Probably a
> simple two-level thing would suffice.
> 
I think both of kmalloc usage here are very bad.

Why we can't do what readdir(/proc) does ? I'm sorry I misunderstand.
Following is an easy example.


0. at open, inilialize f_pos to 0. f_pos is used as "pid"
   remember "css_set with hole" as template in f_private?(or somewhere) at open
   ...like this.
--
   struct cgroupfs_root *root = cgrp->root;
   struct cgroup *template = kzalloc(sizeof(void*) * CGROUP_SUBSYS_COUNT);

   for (i = 0; i < CGROUP_SUBSYS_COUNT; i++)
	if (root->subsys_bits & (1UL << i))
		template[i] =  cgrp->subsys[i];
--


1. at read(), find task_struct of "pid" in f_pos.
2. look up task_struct of "pid" and compare with f_private
--
   struct cgroup *template = f_private;

   for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
	if (!template[i])
		contiue;
	if (template[i] != task_subsys_state(task, i))
		break;
   }
   if (i == CGROUP_SUBSYS_COUNT)
	print task;
 --
   
4. f_pos++ until filling seq_buffer.


Thanks,
-Kame
