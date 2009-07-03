From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Fri, 3 Jul 2009 09:11:56 -0700
Message-ID: <6599ad830907030911m6176dc59id3a7d897b03d2bd__23862.2540412054$1246637695$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
	<20090702175341.fd2e26d5.akpm@linux-foundation.org>
	<6599ad830907021808o6f3bb51eh324e4bf13544d83e@mail.gmail.com>
	<2f86c2480907021817o79fce75yd9785aab682f7bb4@mail.gmail.com>
	<20090702190845.0cafc46a.akpm@linux-foundation.org>
	<6599ad830907022116n7a711c7fs52ff9b400ec8797f@mail.gmail.com>
	<20090702235527.7ddc873c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702235527.7ddc873c.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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

On Thu, Jul 2, 2009 at 11:55 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> w=
rote:
>> The seq_file iterator for these files relies on them being sorted so
>> that it can pick up where it left off even in the event of the pid set
>> changing between reads - it does a binary search to find the first pid
>> greater than the last one that was returned, so as to guarantee that
>> we return every pid that was in the cgroup before the scan started and
>> remained in the cgroup until after the scan finished; there are no
>> guarantees about pids that enter/leave the cgroup during the scan.
>
> OIC. =A0Gee we made it hard for ourselves. =A0That tears it.

Without a guarantee like that, the file becomes much less useful - it
would just be "a random subset of the pids that were in the cgroup at
some time during the read".

>
> Was it a mistake to try to present an ordered, dupes-removed view of a
> large amount of data from the kernel?

The dupe-removal is a red-herring in this argument - that's only added
by this patch, and doesn't affect the existing "tasks" file. I think
we could even change it into a "mostly dupe-removed" view very cheaply
by simply ignoring a tgid when building the array if it's the same as
the previous one we just saw, and leaving userspace to deal with any
remaining dupes.

The ordered semantics of the tasks file comes from cpusets and I
maintained the API (which actually allocated a potentially even larger
array containing the pre-formatted data).

I'd be surprised if removing the ordering constraint broke anything in
userspace, but the more important part about the ordering is to allow
the kernel to present a consistent view in the presence of changing
pids.

Hmm, I guess we could use a combination of the IDR approach that you
suggested and the present shared-array approach:

- when opening a tasks file:
  - populate an IDR with all the pids/tgids in the cgroup
  - find any existing IDR open for the cgroup in the list keyed by
namespace and filetype ("procs"/"tasks")
  - replace (and free) the existing IDR or extend the list with a new one
  - bump the refcount

- when reading:
  - iterate from the last reported pid/tgid

- when closing:
  - drop the refcount, and free the IDR if the count reaches 0

That maintains the property of preventing userspace from consuming
arbitrary amounts of memory just by holding an fd open on a large
cgroup, while also maintaining a consistency guarantee, and we get the
ordering for free as a side-effect of the IDR, with no large memory
allocations. It's not hugely different from the current solution - all
we're doing is replacing the large array in the cgroup_pidlist
structure with an IDR, and populating/reading it appropriately.

The downsides would be a higher fixed cost, I suspect - setting up an
IDR and populating/scanning it sounds like it has to be more expensive
than filling/reading a linear buffer. But it's probably not enough
extra overhead to worry too much about it.

Paul
