From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/5] Switch caches notification dynamically
Date: Mon, 01 Oct 2007 17:21:58 +0400
Message-ID: <4700F476.4070806@openvz.org>
References: <46F91841.9070708@openvz.org> <46F919BB.2000701@openvz.org>
	<4700F2E8.5050904@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4700F2E8.5050904-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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

>> diff --git a/mm/slub.c b/mm/slub.c
>> index 31d04a3..e066a0e 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -3779,6 +3932,60 @@ static ssize_t defrag_ratio_store(struct
>>  SLAB_ATTR(defrag_ratio);
>>  #endif
>>
>> +static ssize_t cache_notify_show(struct kmem_cache *s, char *buf)
>> +{
>> +	return sprintf(buf, "%d\n", !!(s->flags & SLAB_NOTIFY));
>> +}
>> +
>> +static ssize_t cache_notify_store(struct kmem_cache *s,
>> +		const char *buf, size_t length)
>> +{
>> +	int err;
>> +	int n;
>> +
>> +	if ((buf[0] == '1') && !(s->flags & SLAB_NOTIFY)) {
> 
> Won't this code break if I pass 10 as input in buf?

I don't care about this :) And no /sys/slab/<xxx>/ file does.
It's the problem of a user if he pass some shit and doesn't 
see the notifications turned on/off ;)

>> +		err = slub_on_notify(s);
>> +		if (err < 0)
>> +			return err;
>> +
>> +		s->flags |= SLAB_NOTIFY;
>> +
>> +		flush_all(s);
> 
> Sounds like an expensive operation, can we add a comment
> to indicate the same. Also, in the documentation, could
> we warn the user that turning notifications on/off
> can be expensive?

Sure.

>> +		for_each_node_state(n, N_NORMAL_MEMORY) {
>> +			struct kmem_cache_node *node;
>> +			struct page *pg;
>> +			
>> +			node = get_node(s, n);
>> +			spin_lock_irq(&node->list_lock);
>> +			list_for_each_entry(pg, &node->partial, lru)
>> +				SetSlabDebug(pg);
>> +			spin_unlock_irq(&node->list_lock);
>> +		}
>> +		return length;
>> +	}
>> +
>> +	if ((buf[0] == '0') && (s->flags & SLAB_NOTIFY)) {
> 
> What happens if buf is 01?
> 
>> +		/*
>> +		 * TODO: make the notifications-off work
>> +		 */
>> +		if (any_slab_objects(s))
>> +			return -EBUSY;
>> +
>> +		s->flags &= ~SLAB_NOTIFY;
>> +		err = slub_off_notify(s);
>> +		if (err < 0) {
>> +			s->flags |= SLAB_NOTIFY;
>> +			return err;
>> +		}
>> +
>> +		return length;
>> +	}
>> +
>> +	return -EINVAL;
>> +}
>> +
>> +SLAB_ATTR(cache_notify);
>> +
>>  static struct attribute * slab_attrs[] = {
>>  	&slab_size_attr.attr,
>>  	&object_size_attr.attr,
>> @@ -3809,6 +4016,7 @@ static struct attribute * slab_attrs[] =
>>  #ifdef CONFIG_NUMA
>>  	&defrag_ratio_attr.attr,
>>  #endif
>> +	&cache_notify_attr.attr,
>>  	NULL
>>  };
>>
>>
> 
> 
