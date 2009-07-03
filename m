From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks"
	that  shows only unique tgids
Date: Fri, 3 Jul 2009 09:50:00 -0700
Message-ID: <20090703095000.cf46ad19.akpm__3862.56209244511$1246639852$gmane$org@linux-foundation.org>
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
	<6599ad830907030911m6176dc59id3a7d897b03d2bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907030911m6176dc59id3a7d897b03d2bd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Fri, 3 Jul 2009 09:11:56 -0700 Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> Hmm, I guess we could use a combination of the IDR approach that you
> suggested and the present shared-array approach:
> 
> - when opening a tasks file:
>   - populate an IDR with all the pids/tgids in the cgroup
>   - find any existing IDR open for the cgroup in the list keyed by
> namespace and filetype ("procs"/"tasks")
>   - replace (and free) the existing IDR or extend the list with a new one
>   - bump the refcount
> 
> - when reading:
>   - iterate from the last reported pid/tgid
> 
> - when closing:
>   - drop the refcount, and free the IDR if the count reaches 0
> 
> That maintains the property of preventing userspace from consuming
> arbitrary amounts of memory just by holding an fd open on a large
> cgroup, while also maintaining a consistency guarantee, and we get the
> ordering for free as a side-effect of the IDR, with no large memory
> allocations. It's not hugely different from the current solution - all
> we're doing is replacing the large array in the cgroup_pidlist
> structure with an IDR, and populating/reading it appropriately.

I think you're saying "for each pid N in the cgroup, set the Nth
element in an IDR tree".  That would work.  And it automatically gives
ordered traversal and dupe removal.  

I don't think IDRs permit in-order traversal, whereas radix-trees do
support this.  Unfortunately radix-trees are presented as operating on
void* data, so one would need to do some typecasting when storing
BITS_PER_LONG-sized bitfields inside them.

> The downsides would be a higher fixed cost, I suspect - setting up an
> IDR and populating/scanning it sounds like it has to be more expensive
> than filling/reading a linear buffer. But it's probably not enough
> extra overhead to worry too much about it.

Yes, I expect it'd be fairly modest.  There will be far more calls to
kmalloc() when using a tree, but that's the whole point..
