From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH v3 0/4] Per-container dcache limitation
Date: Thu, 18 Aug 2011 11:27:00 +1000
Message-ID: <20110818012700.GN26978__26348.1258800768$1313631299$gmane$org@dastard>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<20110817054343.GM26978@dastard> <4E4C0C25.3@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E4C0C25.3-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 17, 2011 at 11:44:53AM -0700, Glauber Costa wrote:
> On 08/16/2011 10:43 PM, Dave Chinner wrote:
> >On Sun, Aug 14, 2011 at 07:13:48PM +0400, Glauber Costa wrote:
> >>Hello,
> >>
> >>This series is just like v2, except it addresses
> >>Eric's comments regarding percpu variables.
> >>
> >>Let me know if there are further comments, and
> >>I'll promply address them as well. Otherwise,
> >>I feel this is ready for inclusion
> 
> Hi David,
> 
> I am not answering everything now, since I'm travelling, but let me
> get to this one:
> 
> >Just out of couriousity, one thing I've noticed about dentries is
> >that in general at any given point in time most dentries are unused.
> >Under the workloads I'm testing, even when I have a million cached
> >dentries, I only have roughly 7,000 accounted as used.  That is, most
> >of the dentries in the system are on a LRU and accounted in
> >sb->s_nr_dentry_unused of their owner superblock.
> >
> >So rather than introduce a bunch of new infrastructure to track the
> >number of dentries allocated, why not simply limit the number of
> >dentries allowed on the LRU? We already track that, and the shrinker
> >already operates on the LRU, so we don't really need any new
> >infrastructure.
> Because this only works well for cooperative workloads. And we can't
> really assume that in the virtualization world. One container can
> come up with a bogus workload - not even hard to write - that has
> the sole purpose of punishing every resource sharer of him.

Sure, but as I've said before you can prevent the container from
consuming too many dentries (via a hard limit) simply by adding a
inode quota per container.  This is exactly the sort of
uncooperative behaviour filesystem quotas were invented to
prevent.

Perhaps we should separate the DOS case from the normal
(co-operative) use case.

As i mentioned previously, your inode allocation based DOS (while
(1); mkdir x; cd x; done type cases) example is trivial to prevent
with quotas. It was claimed that is was not possible to prevent with
filesystem quotas, I left proving that as an exercise for the
reader,but I feel I need to re-iterate my point with an example.

That is, if you can't create a million inodes in the container, you
can't instantiate a million dentries in the container.  For example,
use project quotas on XFS to create directory tree containers with
hard limits on the number of inodes:

$ cat /etc/projects 
12345:/mnt/scratch/projects/foo
$ cat /etc/projid 
foo:12345
$ sudo mount -o prjquota,delaylog,nobarrier,logbsize=262144,inode64 /dev/vda /mnt/scratch
$ mkdir -p /mnt/scratch/projects/foo
$ sudo xfs_quota -x -c "project -s foo" /mnt/scratch
Setting up project foo (path /mnt/scratch/projects/foo)...
Setting up project foo (path /mnt/scratch/projects/foo)...
Processed 2 (/etc/projects and cmdline) paths for project foo with recursion depth infinite (-1).
$ sudo xfs_quota -x -c "limit -p ihard=1436 foo" /mnt/scratch
$ sudo xfs_quota -c "quota -p foo" /mnt/scratch
$ cd /mnt/scratch/projects/foo/
$ ~/src/fs_mark-3.3/dir-depth 
count 1435, err -1, err Disk quota exceeded pwd /mnt/scratch/projects/foo/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/
 x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x!
 /x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/
 x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x!
 /x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/
 x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x/x
$ 

It stopped at 1435 directories because the container
(/mnt/scratch/project/foo) ran out of inodes in it's quota. No DOS
there. And rather than a ENOMEM error (could be caused by
anything) the error is EDQUOT which is a clear indication that a
resource limit has been hit. That's a far better failure from a user
perspective because they know -exactly- why their application
failed - the container resource limits are too low....

IOWs, you don't need to touch the dentry cache -at all- to provide
the per-subtree hard resource limiting you are trying to acheive -
filesystem quotas can already acheive that for you. Project quotas
used in this manner (as directory tree quotas) provide exactly the
"per-subtree" hard resource limiting that you were trying to acheive
with your original dentry mobs proposal.

> >The limiting can be lazily - we don't need to limit the growth of
> >dentries until we start to run out of memory. If the superblock
> >shrinker is aware of the limits, then when it gets called by memory
> >reclaim it can do all the work of reducing the number of items on
> >the LRU down to the threshold at that time.
> 
> Well, this idea itself can be considered, independent of which path
> we're taking. We can, if we want, allow the dentry cache to grow
> indefinitely if we're out of memory pressure. But it kinda defies
> the
> purpose of a hard limit...

See my comments above about filesystem quotas providing hard limits.

> >IOWs, the limit has no impact on performance until memory is scarce,
> >at which time memory reclaim enforces the limits on LRU size and
> >clean up happens automatically.
> >
> >This also avoids all the problems of setting a limit lower than the
> >number of active dentries required for the workload (i.e. avoids
> >spurious ENOMEM errors trying to allocate dentries), allows
> >overcommitment when memory is plentiful (which will benefit
> >performance) but it brings the caches back to defined limits when
> >memory is not plentiful (which solves the problem you are having).
> No, this is not really the problem we're having.
> See above.
> 
> About ENOMEM, I don't really see what's wrong with them here.

Your backup program runs inside the container. Filesystem traversal
balloons the dentry cache footprint, and so it is likely to trigger
spurious ENOMEM when trying to read files in the container because
it can't allocate a dentry for random files as it traverses. That'll
be fun when it comes to restoring backups and discovering they
aren't complete....

There's also the "WTF caused the ENOMEM error" problem I mentioned
earlier....

> For a
> container, running out of his assigned kernel memory, should be
> exactly the same as running out of real physical memory. I do agree
> that it changes the feeling of the system a little bit, because it
> then happens more often. But it is still right in principle.

The difference is the degree - when the system runs out of memory,
it tries -really hard- before failing the allocation. Indeed, it'll
swap, it'll free memory in other subsystems, it'll back off on disk
congestion, it will try multiple times to free memory, escalation
priority each time it retries. IOws, it jumps through all sorts of
hoops to free memory before it finally fails. And then the memory,
more often than not, comes from some subsystem other than the dentry
cache, so it is rare that a dentry allocation actually relies on the
dentry cache (and only the dentry cache) being shrunk to provide
memory for the new dentry.

Your dentry hard limit is has no fallback or other mechanisms to try
- if the VFS caches cannot be shrunk immediately, then ENOMEM will
occur.  There's no retries, there's no waiting for disk congestion
to clear, there's no backoff, there's no increase in reclaim
desparation as previous attempts to free dentries fail. This greatly
increases the chances of ENOMEM from _d_alloc() way above when a
normal machine would see because it doesn't have any of the
functionality that memory reclaim has. And, fundamentally, that sort
of complexity doesn't belong in the dentry cache...

Another interesting case to consider is internally fragmented dentry
cache slabs, where the active population of the pages is sparse.
This sort of population density is quite common on machines with
sustained long term multiple workload usage (exactly what you'd
expect on a containerised system). Hence dentry allocation can be
done without increasing memory footprint at all. Likewise, freeing
dentries won't free any memory at all. In this case, what has your
hard limit bought you? An ENOMEM error in a situation where memory
allocation is actually free from a resource consumption perspective.

These are the sorts of corner case problems that hard limits on
cache sizes have. That's the  problem I see with the hard limit
approach: it looks simple, but it is full of corner cases when you
look more deeply. Users are going to hit these corner cases and
want to fix those "problems". We'll have to try to fix them without
really even being able to reproduce them reliably. We'll end up
growing heurisitics to try to detect when problems are about to
happen, and complexity to try to avoid those corner case problems.
We'll muddle along with something that sort of works for the cases
we can reproduce, but ultimately is untestable and unverifiable. In
contrast, a lazy lru limiting solution is simple to implement and
verify and has none of the warts that hard limiting exposes to user
applications.

Hence I'd prefer to avoid all the warts of hard limiting by ignoring
the DOS case that leads to requiring a hard limit as it can be
solved by other existing means. Limiting the size of the inactive
cache (generally dominates cache usage) seems like a much lower
impact manner of acheiving the same thing.

Like I said previously - I've had people asking me whether limiting
the size of the inode cache is possible for the past 5 years, and
all their use cases are solved by the lazy mechanism I described. I
think that most of the OpenVZ dcache size problems will also go away
with the lazy solution as well, as most workloads with a large
dentry cache footprint don't actively reference (and therefore pin)
the entire working set at the same time....

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
