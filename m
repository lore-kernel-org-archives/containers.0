From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [PATCH] [NETNS49] support for per/namespace routing cache
	cleanup
Date: Wed, 17 Oct 2007 16:51:41 +0400
Message-ID: <4716055D.4010102@sw.ru>
References: <20071017111215.GA29653@iris.sw.ru> <4715F60F.6060304@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4715F60F.6060304-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Denis V. Lunev wrote:
>> /proc/sys/net/route/flush should be accessible inside the net namespace.
>> Though, the complete opening of this file will result in a DoS or
>> significant entire host slowdown if a namespace process will continually
>> flush routes.
>>
>> This patch introduces per/namespace route flush facility.
>>
>> Each namespace wanted to flush a cache copies global generation count to
>> itself and starts the timer. The cache is dropped for a specific 
>> namespace
>> iff the namespace counter is greater or equal global ones.
>>
>> So, in general, unwanted namespaces do nothing. They hold very old low
>> counter and they are unaffected by the requested cleanup.
>>
>> Signed-of-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> That's right and that will happen when manipulating ip addresses of the 
> network devices too. But I am not confortable with your patchset. It 
> touches the routing flush function too hardly and it uses 
> current->nsproxy->net_ns.
> 
> IMHO we should have two flush functions. One taking a network namespace 
> parameter and one without the network namespace parameter. The first one 
> is called when a write to /proc/sys/net/ipv4/route/flush is done (we 
> must use the network namespace of the writer) or when a interface 
> address is changed or shutdown|up. The last one is called by the timer, 
> so we have a global timer flushing the routing cache for all the 
> namespaces.

we can't :( The unfortunate thing is that the actual cleanup is called 
indirectly and asynchronously. The user _schedule_ the garbage collector 
to run NOW and we are moving over a large routing cache. Really large.

The idea to iterate over the list of each namespace to flush is bad. We 
are in atomic context. The list is protected by the mutex.

The idea of several timers (per namespace) is also bad. You will iterate 
over large cache several times.

No other acceptable way here for me :(.

As for "the trigger" - rt_cache_flush, looks like you are right. We 
should pass namespace as a parameter. This should be done as a separate 
patch.

Regards,
	Den
