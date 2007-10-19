From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] [NETNS49] support for per/namespace routing cache
	cleanup
Date: Fri, 19 Oct 2007 13:03:31 -0600
Message-ID: <m17iljgc58.fsf@ebiederm.dsl.xmission.com>
References: <20071017111215.GA29653@iris.sw.ru> <4715F60F.6060304@fr.ibm.com>
	<4716055D.4010102@sw.ru> <471610E8.8020008@fr.ibm.com>
	<471617CA.9090901@sw.ru> <471624C0.9020108@fr.ibm.com>
	<47164CBD.3040107@gmail.com> <471708D8.3080808@bull.net>
	<471772EB.2060206@sw.ru> <47185F2C.1070404@fr.ibm.com>
	<47187074.3090206@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47187074.3090206-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Fri, 19
	Oct 2007 12:53:08 +0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

> Daniel Lezcano wrote:
>> So you prefer to have multiple timers flushing a portion of a shared routing
>> cache ?
>>
>> It is not impossible I already tryed that for ipv6. it will just touch much
>> more files.
>>
>> If we want, at all costs, to have the routing cache flushed per namespace, I
>> am much more favorable to have a timer per namespace than using the algorithm
>> you sent previously.
>
> as do I. But the IPv4 and IPv6 situation is much different. IPv6 cache is
> separated while IPv4 one is common.
>
> So, the situation is not uniform, at least :(
>
> By the way, we can move routing cache into the FIB tree like one for IPv4 :)

I'm trying to think through this.

- We have two cases garbage collection and flushing the cache.

- The routing cache is just a cache we loose nothing except
  performance if it is flushed.  At least that is my memory.

- Especially for ipv4 the routing cache is a shared resource because
  of a shared hash table, therefore we want to do the garbage
  collection globally.  Especially since we should be able to
  make better decisions that way.

- We appear to use a timer beneath flush to keep flushing operations
  from happening to frequently, and thus killing everyones
  performance.

- We also flush the timer when it is time to change secrets.

So as long as we are really only making the user space flush
operation per namespace I don't have a real problem with it,
as that timer should not run periodically and the whole reason
for the existence of the timer is to ensure people don't kill
other peoples performance by flushing to often.

I do still think things like the periodic secret rebuild and
the garbage collection should continue to be global across
the entire cache.

Eric
