From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Thu, 2 Jul 2009 18:08:29 -0700
Message-ID: <6599ad830907021808o6f3bb51eh324e4bf13544d83e__46904.2273391553$1246583376$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
	<20090702175341.fd2e26d5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702175341.fd2e26d5.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 2, 2009 at 5:53 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wr=
ote:
>> In the first snippet, count will be at most equal to length. As length
>> is determined from cgroup_task_count, it can be no greater than the
>> total number of pids on the system.
>
> Well that's a problem, because there can be tens or hundreds of
> thousands of pids, and there's a fairly low maximum size for kmalloc()s
> (include/linux/kmalloc_sizes.h).
>
> And even if this allocation attempt doesn't exceed KMALLOC_MAX_SIZE,
> large allocations are less unreliable. =A0There is a large break point at
> 8*PAGE_SIZE (PAGE_ALLOC_COSTLY_ORDER).

This has been a long-standing problem with the tasks file, ever since
the cpusets days.

There are ways around it - Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> posted
a patch that allocated an array of pages to store pids in, with a
custom sorting function that let you specify indirection rather than
assuming everything was in one contiguous array. This was technically
the right approach in terms of not needing vmalloc and never doing
large allocations, but it was very complex; an alternative that was
mooted was to use kmalloc for small cgroups and vmalloc for large
ones, so the vmalloc penalty wouldn't be paid generally. The thread
fizzled AFAICS.

>
> One could perhaps create an alias (symlink?) and leave that in place
> for a few kernel releases and then remove the old names. =A0The trick to
> doing this politely is to arrange for a friendly printk to come out
> when userspace uses the old filename, so people know to change their
> tools. =A0That printk should come out once-per-boot, not once-per-access.

Personally, I feel that a bit of ugliness in the naming inconsistency
is less painful than trying to deprecate something that people might
be using. If we could just flip the names without breaking anyone,
that would be great, but this is just a style issue rather than a
functional issue. My experience of such printk() statements scattered
around in code is that no-one takes much notice of them.

Paul
