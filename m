From: Pekka Enberg <penberg-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 3/4] limit nr_dentries per superblock
Date: Mon, 15 Aug 2011 13:58:01 +0300
Message-ID: <CAOJsxLGFJmqO-W=itQbO4Mh4DxSD4wrHOC8gQ5bWL5aE1YYeQw__13321.6201131747$1313405962$gmane$org@mail.gmail.com>
References: <1313334832-1150-1-git-send-email-glommer@parallels.com>
	<1313334832-1150-4-git-send-email-glommer@parallels.com>
	<CAOJsxLFYD9DkEU5R+9fZr-uaznteP8-BUC_Ti+FnNFqtbOCHSw@mail.gmail.com>
	<20110815104656.GG26978@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110815104656.GG26978@dastard>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Dave,

On Mon, Aug 15, 2011 at 1:46 PM, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org> wrote:
> That's usage for the entire slab, though, and we don't have a dentry
> slab per superblock so I don't think that helps us. And with slab
> merging, I think that even if we did have a slab per superblock,
> they'd end up in the same slab context anyway, right?

You could add a flag to disable slab merging but there's no sane way
to fix the per-superblock thing in slab.

On Mon, Aug 15, 2011 at 1:46 PM, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org> wrote:
> Ideally what we need is a slab, LRU and shrinkers all rolled into a
> single infrastructure handle so we can simply set them up per
> object, per context etc and not have to re-invent the wheel for
> every single slab cache/LRU/shrinker setup we have in the kernel.
>
> I've got a rough node-aware generic LRU/shrinker infrastructure
> prototype that is generic enough for most of the existing slab
> caches with shrinkers, but I haven't looked at what is needed to
> integrate it with the slab cache code. That's mainly because I don't
> like the idea of having to implement the same thing 3 times in 3
> different ways and debug them all before anyone would consider it
> for inclusion in the kernel.
>
> Once I've sorted out the select_parent() use-the-LRU-for-disposal
> abuse and have a patch set that survives a 'rm -rf *' operation,
> maybe we can then talk about what is needed to integrate stuff into
> the slab caches....

Well, now that I really understand what you're trying to do here, it's
probably best to keep slab as-is and implement "slab accounting" on
top of it.

You'd have something like you do now but in slightly more generic form:

  struct kmem_accounted_cache {
                  struct kmem_cache *cache;
                  /* ... statistics... */
  }

  void *kmem_accounted_alloc(struct kmem_accounted_cache *c)
  {
          if (/* within limits */)
                  return kmem_cache_alloc(c->cache);

          return NULL;
  }

Does something like that make sense to you?

                        Pekka
