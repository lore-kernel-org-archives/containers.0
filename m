From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] [PATCH 0/5] Kernel memory accounting container (v5)
Date: Tue, 02 Oct 2007 16:51:10 +0400
Message-ID: <47023EBE.7000708@openvz.org>
References: <46F91841.9070708@openvz.org>
	<6599ad830710010932t150aba2eid18864a90f169c64@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830710010932t150aba2eid18864a90f169c64-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Hi Pavel,
> 
> One question about the general design of this - have you tested an
> approach where rather than tagging each object within the cache with
> the cgroup that allocated it, you instead have (inside the cache code)
> a separate cache structure for each cgroup? So the space overheads
> would go from having a per-object overhead (one pointer per object?)
> to having a "wastage" overhead (on average half a slab per cgroup).
> And the time overhead would be the time required to lookup the
> relevant cache for a cgroup at the start of the allocation operation,
> and the relevant cache for an object (from its struct page) at
> deallocation, rather then the time required to update the per-object
> housekeeping pointer.

Such a lookup would require a hastable or something similar. We already
have such a bad experience (with OpenVZ RSS fractions accounting for
example). Hash lookups imply the CPU caches screwup and hurt the performance.
See also the comment below.

> Each cache would need to be assigned a unique ID, used as an index
> into a per-cgroup lookup table of localized caches. (This could almost
> be regarded as a form of kmem_cache namespace).
> 
> It seems to me that this alternative approach would be a lower memory
> overhead for people who have the kernel memory controller compiled in
> but aren't using it, or are only using a few groups.

I thought the same some time ago and tried to make a per-beancounter kmem
caches. The result was awful - the memory waste was much larger than in the
case of pointer-per-object approach. Let alone the performance questions -
each kmalloc required a synchronized hash table lookup that was too bad.

If you insist I can try to repeat the experiment, but I'm afraid the result
would be the same.

> Paul
> 
