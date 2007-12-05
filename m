From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 12/38][IPV6] ip6_fib - move the fib table to the network
 namespace
Date: Wed, 05 Dec 2007 11:05:00 +0100
Message-ID: <475677CC.2040201@fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
	<20071203162453.368428873@mai.toulouse-stg.fr.ibm.com>
	<4755AA47.3000501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4755AA47.3000501-VXdhtT5mjnY@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, den-3ImXcnM4P+0@public.gmane.org
List-Id: containers.vger.kernel.org

Brian Haley wrote:
> Hi Daniel,
> 
> Daniel Lezcano wrote:
>> Move the global definition of the fib table to the network namespace
>> structure and make their access to the initial network namespace.
> ....
>> -void __init fib6_init(void)
>> +static int fib6_net_init(struct net *net)
>>  {
>> -    fib6_node_kmem = kmem_cache_create("fib6_nodes",
>> -                       sizeof(struct fib6_node),
>> -                       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
>> -                       NULL);
>> +    int ret;
>>  
>> -    fib_table_hash = 
>> kzalloc(sizeof(*fib_table_hash)*FIB_TABLE_HASHSZ, GFP_KERNEL);
>> -    if (!fib_table_hash)
>> -        panic("IPV6: Failed to allocate fib_table_hash.\n");
>> -
>> -    fib6_main_tbl = kzalloc(sizeof(*fib6_main_tbl), GFP_KERNEL);
>> -    if (!fib6_main_tbl)
>> -        panic("IPV6: Failed to allocate fib6_main_tbl.\n");
>> -
>> -    fib6_main_tbl->tb6_id = RT6_TABLE_MAIN;
>> -    fib6_main_tbl->tb6_root.leaf = &ip6_null_entry;
>> -    fib6_main_tbl->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | 
>> RTN_RTINFO;
>> +    if (net != &init_net)
>> +        return -EPERM;
>> +
>> +    ret = -ENOMEM;
>> +    net->fib_table_hash = 
>> kzalloc(sizeof(*net->fib_table_hash)*FIB_TABLE_HASHSZ,
>> +                      GFP_KERNEL);
>> +    if (!net->fib_table_hash)
>> +        goto out;
> 
> So originally, the fib_table_hash was global with no allocation 
> necessary.  Then in patch 11 you changed it to be dynamic and panic() on 
> failure.  Now it just gracefully returns.  Do you really want to do that 
> for the init_net namespace?  Won't the next routine that tries to access 
> this NULL pointer oops?  Same for fib6_main_table, fib6_local_table, 
> fib6_stats, etc.  Or did I miss where the callers error-out on an ENOMEM?

Yes, you are right, this is not consistent and we should not panic 
neither ignore the error. I should have modified the ip6_route_init and 
returned an error in case of register_pernet_subsys failure. So the ipv6 
initialization can fails safely.

I will post some modifications around that for net-2.6.25 for netdev@.

Thanks for catching that.

	-- Daniel
