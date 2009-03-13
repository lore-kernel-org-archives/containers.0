From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Fri, 13 Mar 2009 13:48:47 -0700
Message-ID: <49BAC6AF.9090607__43149.3593882353$1236977642$gmane$org@google.com>
References: <1234475483.30155.194.camel@nimitz>	<20090212141014.2cd3d54d.akpm@linux-foundation.org>	<1234479845.30155.220.camel@nimitz>	<20090226155755.GA1456@x200.localdomain>	<20090310215305.GA2078@x200.localdomain>
	<49B775B4.1040800@free.fr>	<20090312145311.GC12390@us.ibm.com>
	<1236891719.32630.14.camel@bahia>	<20090312212124.GA25019@us.ibm.com>	<604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>	<20090313053458.GA28833@us.ibm.com>
	<alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.0903131018390.3940-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Linus Torvalds wrote:
> 
> On Thu, 12 Mar 2009, Sukadev Bhattiprolu wrote:
> 
>> Ying Han [yinghan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org] wrote:
>> | Hi Serge:
>> | I made a patch based on Oren's tree recently which implement a new
>> | syscall clone_with_pid. I tested with checkpoint/restart process tree
>> | and it works as expected.
>>
>> Yes, I think we had a version of clone() with pid a while ago.
> 
> Are people _at_all_ thinking about security?
> 
> Obviously not.
> 
> There's no way we can do anything like this. Sure, it's trivial to do 
> inside the kernel. But it also sounds like a _wonderful_ attack vector 
> against badly written user-land software that sends signals and has small 
> races.

I'm not really sure how this is different than a malicious app going off 
and spawning thousands of threads in an attempt to hit a target pid from 
a security pov.  Sure, it makes it easier, but it's not like there is 
anything in place to close the attack vector.

> 
> Quite frankly, from having followed the discussion(s) over the last few 
> weeks about checkpoint/restart in various forms, my reaction to just about 
> _all_ of this is that people pushing this are pretty damn borderline. 
> 
> I think you guys are working on all the wrong problems. 
> 
> Let's face it, we're not going to _ever_ checkpoint any kind of general 
> case process. Just TCP makes that fundamentally impossible in the general 
> case, and there are lots and lots of other cases too (just something as 
> totally _trivial_ as all the files in the filesystem that don't get rolled 
> back).

In some instances such as ours, TCP is probably the easiest thing to 
migrate.  In an rpc-based cluster application, TCP is nothing more than 
an RPC channel and applications already have to handle RPC channel 
failure and re-establishment.

I agree that this is not the 'general case' as you mention above 
however.  This is the bit that sorta bothers me with the way the 
implementation has been going so far on this list.  The implementation 
that folks are building on top of Oren's patchset tries to be everything 
to everybody.  For our purposes, we need to have the flexibility of 
choosing *how* we checkpoint.  The line seems to be arbitrarily drawn at 
the kernel being responsible for checkpointing and restoring all 
resources associated with a task, and leaving userland with nothing more 
than transporting filesystem bits.  This approach isn't flexible enough: 
  Consider the case where we want to stub out most of the TCP file 
descriptors with ECONNRESETed sockets because we know that they are RPC 
sockets and can re-establish themselves, but we want to use some other 
mechanism for TCP sockets we don't know much about.  The current 
monolithic approach has zero flexibility for doing anything like this, 
and I figure out how we could even fit anything like this in.

This sort of problem is pushing me to wanting all this stuff to live up 
in userland.  The 'core dump'ish way of checkpointing is a great way to 
prototype some of the requirements, but it's going to end up being 
pretty difficult to do anything interesting long term and this is going 
to stifle any chance of this getting productized in our environments.

> 
> So unless people start realizing that
>  (a) processes that want to be checkpointed had better be ready and aware 
>      of it, and help out
>  (b) there's no way in hell that we're going to add these kinds of 
>      interfaces that have dubious upsides (just teach the damn program 
>      you're checkpointing that pids will change, and admit to everybody 
>      that people who want to be checkpointed need to do work) and are 
>      potential security holes.

This is a bit ridiculous.  This is akin to asking programs to recognize 
that their heap addresses may change.

>  (c) if you are going to play any deeper games, you need to have 
>      privileges. IOW, "clone_with_pid()" is ok for _root_, but not for 
>      some random user. And you'd better keep that in mind EVERY SINGLE 
>      STEP OF THE WAY.
> 
> I'm really fed up with these discussions. I have seen almost _zero_ 
> critical thinking at all. Probably because anybody who is in the least 
> doubtful about it simply has tuned out the discussion. So here's my input: 
> start small, start over, and start thinking about other issues than just 
> checkpointing.
> 
> 		Linus
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
