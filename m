From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/5] Switch caches notification dynamically
Date: Wed, 26 Sep 2007 13:39:21 +0400
Message-ID: <46FA28C9.9060101@openvz.org>
References: <46F91841.9070708@openvz.org> <46F919BB.2000701@openvz.org>
	<Pine.LNX.4.64.0709251447560.5072@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0709251447560.5072-RYO/mD75kfhx2SFC9UQUAuF7EQX82lMiAL8bYrjMMd8@public.gmane.org>
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
>> +		for_each_node_state(n, N_NORMAL_MEMORY) {
>> +			struct kmem_cache_node *node;
>> +			struct page *pg;
>> +			
>> +			node = get_node(s, n);
>> +			spin_lock_irq(&node->list_lock);
>> +			list_for_each_entry(pg, &node->partial, lru)
>> +				SetSlabDebug(pg);
>> +			spin_unlock_irq(&node->list_lock);
> 
> 
> Is it necessary to mark all the existing slabs with SLAB_DEBUG? Would it 

Yup. Otherwise we can never receive a single event e.g. if we make 
alloc/free in a loop, or similar, so that new slabs simply are not 
created.

> not be sufficient to just mark the new ones coming up? The above operation 
> could be a bit expensive.

Oh, that's OK from my POV - switching slabs mode was never supposed to
be a fast path.

Thanks,
Pavel
