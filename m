From: "Denis V. Lunev" <dlunev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [NETNS49] support for per/namespace routing cache
	cleanup
Date: Thu, 18 Oct 2007 23:01:44 +0400
Message-ID: <4717AD98.5000102@gmail.com>
References: <20071017111215.GA29653@iris.sw.ru> <4715F60F.6060304@fr.ibm.com>
	<4716055D.4010102@sw.ru> <471610E8.8020008@fr.ibm.com>
	<471617CA.9090901@sw.ru> <471624C0.9020108@fr.ibm.com>
	<47164CBD.3040107@gmail.com> <471708D8.3080808@bull.net>
	<471772EB.2060206@sw.ru> <471789FD.5020802@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <471789FD.5020802-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Benjamin Thery wrote:
> Denis V. Lunev wrote:
>> Benjamin Thery wrote:
>>> Denis V. Lunev wrote:
>>>> Daniel Lezcano wrote:
>>>>> Oh, by the way, I forgot something important you spotted with the list
>>>>> protected by the mutex.
>>>>>
>>>>> When looking at ipv6/fib_hash.c with Benjamin, we need to browse the
>>>>> network namespaces list for the garbage collecting, but we are in an
>>>>> interrupt handler, so I can not use rtnl_lock.
>>>> where exactly....
>>> Actually, it is in net/ipv6/ip6_fib.c, in fib6_clean_all().
>>>
>>> fib6_clean_all() is called by fib6_run_gc() handler of the
>>> ip6_fib_timer. If we don't want to have one such timer per net
>>> namespace, in fib6_clean_all() we have to go through all net to clean
>>> their own
>>> fib_table_hash (using for_each_net() protected by rtnl_lock).
>> after careful thinking, one timer per/namespace looks better for me :)
> 
> Why? :)

This is
- scalable: no long-long iteration over 1000 namespace
- easy in respect to a patch I just sent. We should not allow to drop 
cache from all namespaces from one
- and this approach was good for Alexey Kuznetsov. We have talked about 
this discussing OpenVZ implementation

> Then you'll have to find a way pass the target net to fib6_run_gc() 
> (the timer handler). current->nsproxy->net_ns won't work :)
> One timer for all looked simpler to me.
> 
> Can there be an impact on performance if we have several GC timers
> for the several netns running? 

the amount of job is not greater. Isn't it?

Regards,
	Den
