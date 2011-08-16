From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH v3 3/4] limit nr_dentries per superblock
Date: Tue, 16 Aug 2011 12:11:54 +1000
Message-ID: <20110816021154.GI26978__10798.9780408845$1313460947$gmane$org@dastard>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-4-git-send-email-glommer@parallels.com>
	<CAOJsxLFYD9DkEU5R+9fZr-uaznteP8-BUC_Ti+FnNFqtbOCHSw@mail.gmail.com>
	<20110815104656.GG26978@dastard>
	<CAOJsxLGFJmqO-W=itQbO4Mh4DxSD4wrHOC8gQ5bWL5aE1YYeQw@mail.gmail.com>
	<4E48FD8A.90401@parallels.com>
	<CAOJsxLFjZffC9i5kQsBWjGy3eWdj3VMB5awz=yPcwgeKb5BG0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOJsxLFjZffC9i5kQsBWjGy3eWdj3VMB5awz=yPcwgeKb5BG0Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pekka Enberg <penberg-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 15, 2011 at 02:14:39PM +0300, Pekka Enberg wrote:
> Hi Pavel,
> 
> On Mon, Aug 15, 2011 at 2:05 PM, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> > This will make sense, since the kernel memory management per-cgroup is one of the
> > things we'd live to have, but this particular idea will definitely not work in case
> > we keep the containers' files on one partition keeping each container in its own
> > chroot environment.
> 
> And you want a per-container dcache limit? Will the containers share
> the same superblock?

Yes, and that's one of the problems with the "arbitrary container"
approach to controlling the dentry cache size. Arbitrary containers
don't map easily to predictable and scalable LRU and reclaim
implementations. Hence right now the container scope is limited to
per-superblock.

> Couldn't you simply do per-container "struct
> kmem_accounted_cache" in struct superblock?

Probably could do it that way, but it's still not really and
integrated solution. What we'll end up with is this LRU structure:

struct lru_node {
	struct list_head		lru;
	spinlock_t			lock;
	long				nr_items;
} ____cacheline_aligned_in_smp;

struct lru {
	struct kmem_accounted_cache	*cache;
	struct lru_node			lru_node[MAX_NUMNODES];
	nodemask_t			active_nodes;
	int (*isolate_item)(struct list_head *item);
	int (*dispose)(struct list_head *list);
}

Where the only thing that the lru->cache is used for is getting the
number of items allocated to the cache. Seems relatively pointless
to make that statistic abstraction for just a single value that we
can get via a simple per-cpu counter...

Then, when you consider SLUB has this structure for every individual
slab cache:

struct kmem_cache_node {
        spinlock_t list_lock;   /* Protect partial list and nr_partial */
        unsigned long nr_partial;
        struct list_head partial;
#ifdef CONFIG_SLUB_DEBUG
        atomic_long_t nr_slabs;
        atomic_long_t total_objects;
        struct list_head full;
#endif
};

you can see why tight integration of the per-node LRU infrastructure
is appealing - there's no unnecessary duplication and the accounting
is done in the right spot. It also means there is only one shrinker
implmentation for all slabs, with a couple of simple per-slab
callbacks for isolating objects for disposal and then to dispose of
them. This would mean that most slab caches that use shrinkers would
no longer need to implement their own LRU, get LRU scalability and
node-aware reclaim for free, have built in size limits, etc.

And FWIW, integrating the LRU shrinker mechanism into the slab cache
also provides the mechanisms needed for capping the size of the
cache as well as slab defragmentation.  Much smarter things can be
done when you know both the age and the locality of objects. e.g.
there's no point preventing allocation from a slab due to maximum
object count limitations if there are partial pages in the slab
cache because the allocation can be done without increasing memory
footprint.....

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
