From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Wed, 18 Mar 2009 15:04:01 -0400
Message-ID: <49C145A1.3000506__21501.5118396424$1237403417$gmane$org@cs.columbia.edu>
References: <1234475483.30155.194.camel@nimitz>	<20090212141014.2cd3d54d.akpm@linux-foundation.org>	<1234479845.30155.220.camel@nimitz>	<20090226155755.GA1456@x200.localdomain>	<20090310215305.GA2078@x200.localdomain>	<49B775B4.1040800@free.fr>	<20090312145311.GC12390@us.ibm.com>	<1236891719.32630.14.camel@bahia>	<20090312212124.GA25019@us.ibm.com>	<604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>	<20090313053458.GA28833@us.ibm.com>	<alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
	<49BAC6AF.9090607@google.com> <49BADFCE.8020207@cs.columbia.edu>
	<49C1435B.1090809@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C1435B.1090809-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Mike Waychison wrote:
> Oren Laadan wrote:
>>
>> Mike Waychison wrote:
>>> Linus Torvalds wrote:
>>>> On Thu, 12 Mar 2009, Sukadev Bhattiprolu wrote:
>>>>
>>>>> Ying Han [yinghan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org] wrote:
>>>>> | Hi Serge:
>>>>> | I made a patch based on Oren's tree recently which implement a new
>>>>> | syscall clone_with_pid. I tested with checkpoint/restart process
>>>>> tree
>>>>> | and it works as expected.
>>>>>
>>>>> Yes, I think we had a version of clone() with pid a while ago.
>>>> Are people _at_all_ thinking about security?
>>>>
>>>> Obviously not.
>>>>
>>>> There's no way we can do anything like this. Sure, it's trivial to
>>>> do inside the kernel. But it also sounds like a _wonderful_ attack
>>>> vector against badly written user-land software that sends signals
>>>> and has small races.
>>> I'm not really sure how this is different than a malicious app going
>>> off and spawning thousands of threads in an attempt to hit a target
>>> pid from a security pov.  Sure, it makes it easier, but it's not like
>>> there is anything in place to close the attack vector.
>>>
>>>> Quite frankly, from having followed the discussion(s) over the last
>>>> few weeks about checkpoint/restart in various forms, my reaction to
>>>> just about _all_ of this is that people pushing this are pretty damn
>>>> borderline.
>>>> I think you guys are working on all the wrong problems.
>>>> Let's face it, we're not going to _ever_ checkpoint any kind of
>>>> general case process. Just TCP makes that fundamentally impossible
>>>> in the general case, and there are lots and lots of other cases too
>>>> (just something as totally _trivial_ as all the files in the
>>>> filesystem that don't get rolled back).
>>> In some instances such as ours, TCP is probably the easiest thing to
>>> migrate.  In an rpc-based cluster application, TCP is nothing more
>>> than an RPC channel and applications already have to handle RPC
>>> channel failure and re-establishment.
>>>
>>> I agree that this is not the 'general case' as you mention above
>>> however.  This is the bit that sorta bothers me with the way the
>>> implementation has been going so far on this list.  The
>>> implementation that folks are building on top of Oren's patchset
>>> tries to be everything to everybody.  For our purposes, we need to
>>> have the flexibility of choosing *how* we checkpoint.  The line seems
>>> to be arbitrarily drawn at the kernel being responsible for
>>> checkpointing and restoring all resources associated with a task, and
>>> leaving userland with nothing more than transporting filesystem
>>> bits.  This approach isn't flexible enough:   Consider the case where
>>> we want to stub out most of the TCP file descriptors with
>>> ECONNRESETed sockets because we know that they are RPC sockets and
>>> can re-establish themselves, but we want to use some other mechanism
>>> for TCP sockets we don't know much about.  The current monolithic
>>> approach has zero flexibility for doing anything like this, and I
>>> figure out how we could even fit anything like this in.
>>
>> The flexibility exists, but wasn't spelled out, so here it is:
>>
>> 1) Similar to madvice(), I envision a cradvice() that could tell the c/r
>> something about specific resources, e.g.:
>>  * cradvice(CR_ADV_MEM, ptr, len)  -> don't save that memory, it's
>> scratch
>>  * cradvice(CR_ADV_SOCK, fd, CR_ADV_SOCK_RESET)  -> reset connection
>> on restart
>> etc .. (nevermind the exact interface right now)
>>
>> 2) Tasks can ask to be notified (e.g. register a signal) when a
>> checkpoint
>> or a restart complete successfully. At that time they can do their
>> private
>> house-keeping if they know better.
>>
>> 3) If restoring some resource is significantly easier in user space
>> (e.g. a
>> file-descriptor of some special device which user space knows how to
>> re-initialize), then the restarting task can prepare it ahead of time,
>> and, call:
>>   * cradvice(CR_ADV_USERFD, fd, 0)  -> use the fd in place instead of
>> trying
>>                        to restore it yourself.
> 
> This would be called by the embryo process (mktree.c?) before calling
> sys_restart?

Yes.

> 
>>
>> Method #3 is what I used in Zap to implement distributed checkpoints,
>> where
>> it is so much easier to recreate all network connections in user space
>> then
>> putting that logic into the kernel.
>>
>> Now, on the other hand, doing the c/r from userland is much less flexible
>> than in the kernel (e.g. epollfd, futex state and much more) and requires
>> exposing tremendous amount of in-kernel data to user space. And we all
>> know
>> than exposing internals is always a one-way ticket :(
>>
>> [...]
>>
>> Oren.
>>
>>
> 
> 
