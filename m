From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks"
	that  shows only unique tgids
Date: Thu, 2 Jul 2009 23:55:27 -0700
Message-ID: <20090702235527.7ddc873c.akpm__23752.5345678025$1246604189$gmane$org@linux-foundation.org>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
	<20090702175341.fd2e26d5.akpm@linux-foundation.org>
	<6599ad830907021808o6f3bb51eh324e4bf13544d83e@mail.gmail.com>
	<2f86c2480907021817o79fce75yd9785aab682f7bb4@mail.gmail.com>
	<20090702190845.0cafc46a.akpm@linux-foundation.org>
	<6599ad830907022116n7a711c7fs52ff9b400ec8797f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907022116n7a711c7fs52ff9b400ec8797f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2 Jul 2009 21:16:15 -0700 Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Thu, Jul 2, 2009 at 7:08 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> >
> > Why are we doing all this anyway? __To avoid presenting duplicated pids
> > to userspace? __Nothing else?
> 
> To present the pids or tgids in sorted order. Removing duplicates is
> only for the case of the "procs" file; that could certainly be left to
> userspace, but it wouldn't by itself remove the existing requirement
> for a contiguous array.
> 
> The seq_file iterator for these files relies on them being sorted so
> that it can pick up where it left off even in the event of the pid set
> changing between reads - it does a binary search to find the first pid
> greater than the last one that was returned, so as to guarantee that
> we return every pid that was in the cgroup before the scan started and
> remained in the cgroup until after the scan finished; there are no
> guarantees about pids that enter/leave the cgroup during the scan.

OIC.  Gee we made it hard for ourselves.  That tears it.

> > Or we can do it the other way? __Create an initially-empty local IDR
> > tree or radix tree and, within that, mark off any pids which we've
> > already emitted? __That'll have a worst-case memory consumption of
> > approximately PID_MAX_LIMIT bits -- presently that's half a megabyte.
> > With no large allocations needed?
> >
> 
> But that would be half a megabyte per open fd?

worst-case, assuming that there are 4,000,000/64 pids, spread evenly
across the pid space.

> That's a lot of memory
> that userspace can pin down by opening fds.

yup.

> The reason for the current
> pid array approach is to mean that there's only ever one pid array
> allocated at a time per cgroup, rather than per open fd.

Oh.  Didn't know that.  That would have been an interesting thing to
have documeted, but the sorry little comment which tried to explain
this got deleted by this patch :(

> There's actually a structure already for doing that - cgroup_scanner,
> which uses a high-watermark and a priority heap to provide a similar
> guarantee, with a constant memory size overhead (typically one page).
> But it can take O(n^2) time to scan a large cgroup, as would, I
> suspect, using an IDR, so it's only used for cases where we really
> can't avoid it due to locking reasons. I'd rather have something that
> accumulates unsorted pids in page-size chunks as we iterate through
> the cgroup, and then sorts them using something like Lai Jiangshan's
> patch did.

Was it a mistake to try to present an ordered, dupes-removed view of a
large amount of data from the kernel?
 
> >
> > btw, did pidlist_uniq() actually needs to allocate new memory for the
> > output array? __Could it have done the filtering in-place?
> 
> Yes - or just omit duplicates in the seq_file iterator, I guess

OK.


So now what?  lib/dynarray.c?
