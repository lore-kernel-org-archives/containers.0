From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] [NETNS49] support for per/namespace routing cache
	cleanup
Date: Wed, 17 Oct 2007 12:50:35 -0600
Message-ID: <m1fy09eft0.fsf@ebiederm.dsl.xmission.com>
References: <20071017111215.GA29653@iris.sw.ru> <4715F60F.6060304@fr.ibm.com>
	<4716055D.4010102@sw.ru> <471610E8.8020008@fr.ibm.com>
	<471617CA.9090901@sw.ru> <471624C0.9020108@fr.ibm.com>
	<47164CBD.3040107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47164CBD.3040107-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Denis V. Lunev's message of "Wed,
	17 Oct 2007 21:56:13 +0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <dlunev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <dlunev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Daniel Lezcano wrote:
>> Oh, by the way, I forgot something important you spotted with the list
>> protected by the mutex.
>>
>> When looking at ipv6/fib_hash.c with Benjamin, we need to browse the network
>> namespaces list for the garbage collecting, but we are in an interrupt
>> handler, so I can not use rtnl_lock.
> where exactly....
>
> all interesting places are called under rtnl already...
>
>> Why is not possible to protect the list with a simple spinlock ? so we can
>> call spin_lock_bh when we are in interrupt handler.
>
> see my old patch with a locking rules :)

Actually at this point given that your rtnl_unlock() cleanup made it
in things are much simpler and if we really need to we can add a
spinlock protecting things.

> By the way, I have forgotten to mention, that the original patch works from 2004
> for OpenVz :)

Probably.  It is a different optimization and maintenance point
however.  So while it can inspire things it isn't an apples to apples
comparison.

Eric
