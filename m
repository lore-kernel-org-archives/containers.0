From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 1/4] Add notification about some major slab events
Date: Tue, 18 Sep 2007 12:35:07 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709181231050.3714@schroedinger.engr.sgi.com>
References: <46EE70B4.6060902@openvz.org> <46EE726F.1010707@openvz.org>
	<Pine.LNX.4.64.0709171122150.27057@schroedinger.engr.sgi.com>
	<46EF865F.4050409@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46EF865F.4050409-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 18 Sep 2007, Pavel Emelyanov wrote:

> > Please stay completely out of the fast path. No modifications to 
> > slab_alloc or slab_free please. It is possible to force all allocations of 
> > a particular slab of interest to use the slow path in __slab_alloc (maybe 
> > as a result of the slab page allocation hook returning a certain result 
> > code). See how the SLAB_DEBUG handling does it. You can adapt that and then do the 
> > object checks in __slab_alloc.
> 
> That's true, but:
> 1. we perform only a flag check on a fast path

This is still going to slow down everyone else and I still think there is 
no need to do that.

> 2. currently we cannot force the freeing of an object to go _always_ 
>    through the slow __slab_free(), and thus the following situation is 
>    possible:
>      a. container A allocates an object and this object is 
>         accounted to it

At that point you could mark the slab as a slow slab by setting 
SLAB_DEBUG() so we always take the slow path for this slab.

>      b. the object is freed and gets into lockless freelist (but 
>         stays accounted to A)

B wont work if SLAB_DEBUG() is set. The fastpath is then disabled.

>      c. container C allocates this object from the freelist 
>         and thus get unaccounted amount of memory

>   this discrepancy can grow up infinitely. Sure, we can mark some caches to
>   go through the slow path even on freeing the objects, but isn't it the
>   same as checking for SLAB_NOTIFY on fast paths?

The other caches will then still perform up to speed.
 
> Maybe it's worth having the notifiers under config option, so that those
> who don't need this won't suffer at all?

I think you would want the container functionality to be available in 
distros. They may make the choice whether to enable the container 
functionality based on its impact. It is good if we can stash it away so 
that there is a negligible performance impact if its compiled in but off.
