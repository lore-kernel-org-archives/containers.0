From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH v3 0/4] Per-container dcache limitation
Date: Wed, 17 Aug 2011 15:43:43 +1000
Message-ID: <20110817054343.GM26978__9316.50470379299$1313560007$gmane$org@dastard>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1313334832-1150-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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

On Sun, Aug 14, 2011 at 07:13:48PM +0400, Glauber Costa wrote:
> Hello,
> 
> This series is just like v2, except it addresses
> Eric's comments regarding percpu variables.
> 
> Let me know if there are further comments, and
> I'll promply address them as well. Otherwise,
> I feel this is ready for inclusion

Just out of couriousity, one thing I've noticed about dentries is
that in general at any given point in time most dentries are unused.
Under the workloads I'm testing, even when I have a million cached
dentries, I only have roughly 7,000 accounted as used.  That is, most
of the dentries in the system are on a LRU and accounted in
sb->s_nr_dentry_unused of their owner superblock.

So rather than introduce a bunch of new infrastructure to track the
number of dentries allocated, why not simply limit the number of
dentries allowed on the LRU? We already track that, and the shrinker
already operates on the LRU, so we don't really need any new
infrastructure.

The limiting can be lazily - we don't need to limit the growth of
dentries until we start to run out of memory. If the superblock
shrinker is aware of the limits, then when it gets called by memory
reclaim it can do all the work of reducing the number of items on
the LRU down to the threshold at that time.

IOWs, the limit has no impact on performance until memory is scarce,
at which time memory reclaim enforces the limits on LRU size and
clean up happens automatically.

This also avoids all the problems of setting a limit lower than the
number of active dentries required for the workload (i.e. avoids
spurious ENOMEM errors trying to allocate dentries), allows
overcommitment when memory is plentiful (which will benefit
performance) but it brings the caches back to defined limits when
memory is not plentiful (which solves the problem you are having).

That seems like a much better solution to me, because it doesn't
impact the normal working of workloads in the containers and avoids
having to work out what the correct minimum size of the cache for
each workload is. It's much easier to work out how many extra cached
dentries you want the container to be able to have when memory is
scarce...

What do you think?

Cheers,

Dave.

-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
