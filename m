From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 3/5] Switch caches notification dynamically
Date: Tue, 25 Sep 2007 14:48:59 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709251447560.5072@schroedinger.engr.sgi.com>
References: <46F91841.9070708@openvz.org> <46F919BB.2000701@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46F919BB.2000701-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 25 Sep 2007, Pavel Emelyanov wrote:

> +		for_each_node_state(n, N_NORMAL_MEMORY) {
> +			struct kmem_cache_node *node;
> +			struct page *pg;
> +			
> +			node = get_node(s, n);
> +			spin_lock_irq(&node->list_lock);
> +			list_for_each_entry(pg, &node->partial, lru)
> +				SetSlabDebug(pg);
> +			spin_unlock_irq(&node->list_lock);


Is it necessary to mark all the existing slabs with SLAB_DEBUG? Would it 
not be sufficient to just mark the new ones coming up? The above operation 
could be a bit expensive.
