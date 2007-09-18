From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/4] Kernel memory accounting container (v3)
Date: Tue, 18 Sep 2007 10:25:48 +0400
Message-ID: <46EF6F6C.60702@openvz.org>
References: <46EE70B4.6060902@openvz.org>
	<Pine.LNX.4.64.0709171126330.27057@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0709171126330.27057-RYO/mD75kfhx2SFC9UQUAuF7EQX82lMiAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Christoph Lameter wrote:
> On Mon, 17 Sep 2007, Pavel Emelyanov wrote:
> 
>> As I have already told kmalloc caches cannot be accounted easily
>> so turning the accounting on for them will fail with -EINVAL.
>> Turning the accounting off is possible only if the cache has
>> no objects. This is done so because turning accounting off
>> implies unaccounting of all the objects in the cache, but due
>> to full-pages in slub are not stored in any lists (usually)
>> this is impossible to do so, however I'm open for discussion
>> of how to make this work.
> 
> Where can I find more information why is would not be possible to 
> account kmalloc caches?

It is possible, but the problem is that we want to account only
allocations explicitly caused by the user request. E.g. the
vfsmount name is kmalloc-ed by explicit user request, but such
things as buffer heads are not.

So we have to explicitly specify which calls to kmalloc() do we
wand to be accounted and which we do not by passing additional
flag (GFP_ACCT?) to kmalloc, but this is another patch.

Yet again - as soon as we agree on the implementation of kmem
caches accounting, I will proceed with working on kmalloc, vmalloc
and buddy allocator.

> 

Thanks,
Pavel
