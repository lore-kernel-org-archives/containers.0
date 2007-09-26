From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/5] Add notification about some major slab events
Date: Wed, 26 Sep 2007 13:37:31 +0400
Message-ID: <46FA285B.5060709@openvz.org>
References: <46F91841.9070708@openvz.org> <46F91898.5060400@openvz.org>
	<Pine.LNX.4.64.0709251445400.5072@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0709251445400.5072-RYO/mD75kfhx2SFC9UQUAuF7EQX82lMiAL8bYrjMMd8@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Christoph Lameter wrote:
> On Tue, 25 Sep 2007, Pavel Emelyanov wrote:
> 
>> @@ -28,6 +28,7 @@
>>  #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
>>  #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
>>  #define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
>> +#define SLAB_NOTIFY		0x00400000UL	/* Notify major events */
>>  
> 
> You need to add SLAB_NOTIFY to the SLUB_NEVER_MERGE group. That way you 
> can solve the merging issue.

True, but we mark the slubs as notifyable at runtime, after they
are merged. However, once someone decides to make his slab notifyable
from the very beginning this makes sense, thanks.

> Otherwise this looks okay now.

Oh, great! Does this mean I can put Acked-by when sending this to Andrew?

Thanks,
Pavel
