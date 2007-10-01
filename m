From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/5] Account for the slub objects
Date: Mon, 01 Oct 2007 18:10:11 +0400
Message-ID: <4700FFC3.7050005@openvz.org>
References: <46F91841.9070708@openvz.org> <46F91A8A.9000001@openvz.org>
	<4700FF1F.7060604@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4700FF1F.7060604-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

[snip]

>> +int slub_alloc_notify(struct kmem_cache *s, void *obj, gfp_t gfp)
>> +{
>> +	struct page *pg;
>> +	struct kmem_container *cnt;
>> +	struct kmem_container **obj_container;
>> +
>> +	pg = virt_to_head_page(obj);
>> +	obj_container = pg->cgroups;
>> +	if (unlikely(obj_container == NULL)) {
>> +		/*
>> +		 * turned on after some objects were allocated
>> +		 */
>> +		if (slub_newpage_notify(s, pg, GFP_ATOMIC) < 0)
>> +			goto err;
>> +
>> +		obj_container = pg->cgroups;
>> +	}
>> +
>> +	rcu_read_lock();
>> +	cnt = task_kmem_container(current);
>> +	if (res_counter_charge(&cnt->res, s->size))
> 
> Is s->size measure in pages or bytes? I suspect it is bytes.

In bytes, of course :) the struct anon_vma (for example) is difficult
to account in pages :P

>> +		goto err_locked;
>> +
>> +	css_get(&cnt->css);
>> +	rcu_read_unlock();
>> +	obj_container[slab_index(obj, s, page_address(pg))] = cnt;
>> +	return 0;
>> +
>> +err_locked:
>> +	rcu_read_unlock();
>> +err:
>> +	return -ENOMEM;
>> +}
>> +
>> +void slub_free_notify(struct kmem_cache *s, void *obj)
>> +{
>> +	struct page *pg;
>> +	struct kmem_container *cnt;
>> +	struct kmem_container **obj_container;
>> +
>> +	pg = virt_to_head_page(obj);
>> +	obj_container = pg->cgroups;
>> +	if (obj_container == NULL)
>> +		return;
>> +
>> +	obj_container += slab_index(obj, s, page_address(pg));
>> +	cnt = *obj_container;
>> +	if (cnt == NULL)
>> +		return;
>> +
>> +	res_counter_uncharge(&cnt->res, s->size);
>> +	*obj_container = NULL;
>> +	css_put(&cnt->css);
>> +}
>> +
> 
> Quick check, slub_free_notify() and slab_alloc_notify() are called
> from serialized contexts, right?

Yup.

>> +int slub_on_notify(struct kmem_cache *cachep)
>> +{
>> +	return (is_kmalloc_cache(cachep) ? -EINVAL : 0);
>> +}
>> +
> 
> I know you've mentioned several times in the comments that
> kmalloc slab's cannot be accounted for, could you please
> add a big comment here as well.

This is useless comment - I will implement the kmalloc accounting
soon, so it will just go away.

> Also, looks like if I turn on notification for kmalloc

You cannot, but let's go on with this assumption :)

> slab's, the listener fails, which will cause all
> allocations to fail?

Nope, just this cache will not generate events and that's it.
