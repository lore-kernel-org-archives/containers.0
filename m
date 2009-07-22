From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Wed, 22 Jul 2009 14:14:43 +0800
Message-ID: <4A66AE53.2050209__26916.6032122032$1248243533$gmane$org@cn.fujitsu.com>
References: <20090721220017.60A219D3@kernel>	 <4A66868F.4010001@cn.fujitsu.com>
	<1248237292.24021.2.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248237292.24021.2.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

12:34, Dave Hansen wrote:
> On Wed, 2009-07-22 at 11:25 +0800, Li Zefan wrote:
>>> +/**
>>> + * flex_array_put - copy data into the array at @element_nr
>>> + * @src:	address of data to copy into the array
>>> + * @element_nr:	index of the position in which to insert
>>> + * 		the new element.
>> @fa and @flags are not documented.
> 
> True...  But one of my pet peeves are kerneldocs like this:
> 
> 	@fa: the flex array
> 	@flags: GFP flags
> 
> It's so trivially obvious from looking at the types and the variable
> names that I'm not sure it's worth the cost of the lines.  
> 

I'm not kernel-doc expert, but ./scripts/kernel-doc will warn
on this. And from time to time, we receive patches to fix
kernel-doc.

>>> + *
>>> + * Note that this *copies* the contents of @src into
>>> + * the array.  If you are trying to store an array of
>>> + * pointers, make sure to pass in &ptr instead of ptr.
>>> + *
>>> + * Locking must be provided by the caller.
>>> + */
>>> +int flex_array_put(struct flex_array *fa, int element_nr, void *src, gfp_t flags)
>>> +{
>>> +	int part_nr = fa_element_to_part_nr(fa, element_nr);
>>> +	struct flex_array_part *part;
>>> +	void *dst;
>>> +
>>> +	part = __fa_get_part(fa, part_nr, flags);
>>> +	if (!part)
>>> +		return -ENOMEM;
>> So this may allocate memory, and has disavantages:
>>
>> - If flex_array_put() is called in atomic context, flags has to be GFP_ATOMIC.
>> - and thus it may fail.
>>
>> Since we pass the total_elem to flex_array_alloc(), how about add a flag,
>> and if the flag is set, the alloc() will also allocate all fa_parts?
>>
>> And add __flex_array_put(), which assumes fa_parts has been allocated.
> 
> How about flex_array_prealloc()?  It seems to work for all the radix
> tree users.
> 

I have no strong opinion. I just want a non-fail version of
flex_array_put() (I mean "void __flex_array_put()").
