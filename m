From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks"
	that  shows only unique tgids
Date: Thu, 2 Jul 2009 17:53:41 -0700
Message-ID: <20090702175341.fd2e26d5.akpm__30704.60816748$1246582479$gmane$org@linux-foundation.org>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480907021731h13e0bb95q94f06829eded9aa6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2 Jul 2009 17:31:38 -0700 Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Thu, Jul 2, 2009 at 4:46 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> >> +/**
> >> + * pidlist_uniq - given a kmalloc()ed list, strip out all duplicate entries
> >> + * returns -ENOMEM if the malloc fails; 0 on success
> >> + */
> >
> > The comment purports to be kerneldoc ("/**") but didn't document the
> > function's arguments.
> 
> Wasn't aware of that restriction. Recommend making
> scripts/checkpatch.pl look for that sort of thing?

ooh, hard.

Probably the kerneldoc parsing tools are the place to do this checking
- there's no point in duplicating it.  But they might not be smart
enough to detect missing arguments.

> >> + __ __ list = *p;
> >> + __ __ /*
> >> + __ __ __* we presume the 0th element is unique, so i starts at 1. trivial
> >> + __ __ __* edge cases first; no work needs to be done for either
> >> + __ __ __*/
> >> + __ __ if (*length == 0 || *length == 1)
> >> + __ __ __ __ __ __ return 0;
> >> + __ __ for (i = 1; i < *length; i++) {
> >> + __ __ __ __ __ __ BUG_ON(list[i] == PIDLIST_VALUE_NONE);
> >> + __ __ __ __ __ __ if (list[i] == list[last]) {
> >> + __ __ __ __ __ __ __ __ __ __ list[i] = PIDLIST_VALUE_NONE;
> >> + __ __ __ __ __ __ } else {
> >> + __ __ __ __ __ __ __ __ __ __ last = i;
> >> + __ __ __ __ __ __ __ __ __ __ count++;
> >> + __ __ __ __ __ __ }
> >> + __ __ }

Someone's email client is doing s/0x20/0xa0/grr

> >> + __ __ newlist = kmalloc(count * sizeof(pid_t), GFP_KERNEL);
> >
> > What is the maximum possible value of `count' here?
> >
> > Is there any way in which malicious code can exploit the potential
> > multiplicative overflow in this statement? __(kcalloc() checks for
> > this).
> >> + __ __ /*
> >> + __ __ __* If cgroup gets more users after we read count, we won't have
> >> + __ __ __* enough space - tough. __This race is indistinguishable to the
> >> + __ __ __* caller from the case that the additional cgroup users didn't
> >> + __ __ __* show up until sometime later on.
> >> + __ __ __*/
> >> + __ __ length = cgroup_task_count(cgrp);
> >> + __ __ array = kmalloc(length * sizeof(pid_t), GFP_KERNEL);
> >
> > max size?
> >
> > overflowable?
> 
> In the first snippet, count will be at most equal to length. As length
> is determined from cgroup_task_count, it can be no greater than the
> total number of pids on the system.

Well that's a problem, because there can be tens or hundreds of
thousands of pids, and there's a fairly low maximum size for kmalloc()s
(include/linux/kmalloc_sizes.h).

And even if this allocation attempt doesn't exceed KMALLOC_MAX_SIZE,
large allocations are less unreliable.  There is a large break point at
8*PAGE_SIZE (PAGE_ALLOC_COSTLY_ORDER).

It would be really nice if we could avoid "fixing" this via vmalloc(). 
Because vmalloc() causes, and is vulnerable to internal fragmentation
problems.

> (Also, the second snippet of code
> was there before, just relocated, so if there's an overflow bug in
> either it'll have already been there.)
> 
> >> @@ -2389,21 +2457,27 @@ static int cgroup_write_notify_on_release(struct cgroup *cgrp,
> >> __/*
> >> __ * for the common functions, 'private' gives the type of file
> >> __ */
> >> +/* for hysterical reasons, we can't put this on the older files */
> >
> > "raisins" ;)
> 
> They keys are right next to each other, I promise.
> 
> There was a bit of discussion on how to name these files. Paul wanted
> to start naming the generic cgroup files with the "cgroup." prefix,
> but we can't change "tasks" and "notify_on_release" etc. We decided to
> use the new name format but only for the new file - can anything be
> done about the other ones, or do they have to stay as is?

One could perhaps create an alias (symlink?) and leave that in place
for a few kernel releases and then remove the old names.  The trick to
doing this politely is to arrange for a friendly printk to come out
when userspace uses the old filename, so people know to change their
tools.  That printk should come out once-per-boot, not once-per-access.
