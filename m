From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/5] Switch caches notification dynamically
Date: Tue, 25 Sep 2007 11:46:44 +0400
Message-ID: <46F8BCE4.4010302@openvz.org>
References: <46F38B67.3020609@openvz.org> <46F38D3B.2050608@openvz.org>
	<Pine.LNX.4.64.0709241406280.30982@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0709241406280.30982-RYO/mD75kfhx2SFC9UQUAuF7EQX82lMiAL8bYrjMMd8@public.gmane.org>
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
> On Fri, 21 Sep 2007, Pavel Emelyanov wrote:
> 
>> The /sys/slab/<name>/cache_notify attribute controls
>> whether the cache <name> is to be accounted or not.
>>
>> For the reasons described before kmalloc caches cannot
>> be turned on.
> 
> It looks like the patch is forbidding to turn the notification off? On is 
> okay even if there are already objects present? 

Yup. If we "on" the notifications we will just receive new events.

> Full slabs may exist that cannot be accounted for now. I guess that is 
> okay because we only want to track new allocations?


If we turn notifications off with full slabs in memory we won't be 
able to (in case of kmem accounting) release the page's metadata that 
the slub_newpage event attached to them.

We can make this by tracking all the full slabs, and at the moment of
"off" walk them and generate slab_free and slab_release_page events,
but does it worth doing it ever?

Thanks,
Pavel
