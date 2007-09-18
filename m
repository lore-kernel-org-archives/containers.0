From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/4] Kernel memory accounting container (v3)
Date: Tue, 18 Sep 2007 10:56:21 +0400
Message-ID: <46EF7695.7010804@openvz.org>
References: <46EE70B4.6060902@openvz.org>
	<Pine.LNX.4.64.0709171126330.27057@schroedinger.engr.sgi.com>
	<46EEE8B7.2070805@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0709171417330.28926@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0709171417330.28926-RYO/mD75kfhx2SFC9UQUAuF7EQX82lMiAL8bYrjMMd8@public.gmane.org>
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
> On Tue, 18 Sep 2007, Balbir Singh wrote:
> 
>> I've wondered the same thing and asked the question. Pavel wrote
>> back to me saying
>>
>> "The pages that are full of objects are not linked in any list
>> in kmem_cache so we just cannot find them."
> 
> That is true for any types of slab cache and not restricted to kmalloc 
> slabs. SLUB can be switched into a mode where it provides these lists 
> (again at a performance penalty).
> 
> But I thought we generate the counters at alloc and free time? So why do 
> we need to traverse the object lists?

When we make echo 0 > /sys/slab/xxx/cache_notify we want all the objects
to be unaccounted back immediately. Even __free_slab() won't catch this
because the  SLAB_NOTIFY flag will be turned off for this cache. So we
have to walk all the objects and unaccount them.
