From: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH v3 3/4] limit nr_dentries per superblock
Date: Mon, 15 Aug 2011 20:46:56 +1000
Message-ID: <20110815104656.GG26978__4245.24011691592$1313405314$gmane$org@dastard>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-4-git-send-email-glommer@parallels.com>
	<CAOJsxLFYD9DkEU5R+9fZr-uaznteP8-BUC_Ti+FnNFqtbOCHSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAOJsxLFYD9DkEU5R+9fZr-uaznteP8-BUC_Ti+FnNFqtbOCHSw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 15, 2011 at 10:12:06AM +0300, Pekka Enberg wrote:
> On Sun, Aug 14, 2011 at 6:13 PM, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> > This patch lays the foundation for us to limit the dcache size.
> > Each super block can have only a maximum amount of dentries under its
> > sub-tree. Allocation fails if we we're over limit and the cache
> > can't be pruned to free up space for the newcomers.
.....
> We track the total number of objects in mm/slub.c when
> CONFIG_SLUB_DEBUG is enabled (look for n->total_objects in the code).
> Have you considered extending that for this purpose?

That's usage for the entire slab, though, and we don't have a dentry
slab per superblock so I don't think that helps us. And with slab
merging, I think that even if we did have a slab per superblock,
they'd end up in the same slab context anyway, right?

Ideally what we need is a slab, LRU and shrinkers all rolled into a
single infrastructure handle so we can simply set them up per
object, per context etc and not have to re-invent the wheel for
every single slab cache/LRU/shrinker setup we have in the kernel.

I've got a rough node-aware generic LRU/shrinker infrastructure
prototype that is generic enough for most of the existing slab
caches with shrinkers, but I haven't looked at what is needed to
integrate it with the slab cache code. That's mainly because I don't
like the idea of having to implement the same thing 3 times in 3
different ways and debug them all before anyone would consider it
for inclusion in the kernel.

Once I've sorted out the select_parent() use-the-LRU-for-disposal
abuse and have a patch set that survives a 'rm -rf *' operation,
maybe we can then talk about what is needed to integrate stuff into
the slab caches....

Cheers,

Dave.
-- 
Dave Chinner
david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
