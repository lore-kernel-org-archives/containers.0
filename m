From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: C/R without "leaks"
Date: Wed, 15 Apr 2009 17:38:08 -0400
Message-ID: <49E653C0.7020907@cs.columbia.edu>
References: <49E40662.2040508@cs.columbia.edu> <20090414163633.GE27461@x200.localdomain> <49E4D89D.9060903@cs.columbia.edu> <20090415195629.GD26994@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755664AbZDOVkg@vger.kernel.org>
In-Reply-To: <20090415195629.GD26994@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: containers@lists.osdl.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org



Alexey Dobriyan wrote:
>> Again, so to checkpoint one task in the topmost pid-ns you need to
>> checkpoint (if at all possible) the entire system ?!
> 
> One more argument to not allow "leaks" and checkpoint whole container,
> no ifs, buts and woulditbenices.
> 
> Just to clarify, C/R with "leak" is for example when process has separate
> pidns, but shares, for example, netns with other process not involved in
> checkpoint.
> 
> If you allow this, you lose one important property of checkpoint part,
> namely, almost everything is frozen. Losing this property means suddenly
> much more stuff is alive during dump and you has to account to more stuff
> when checkpointing. You effectively checkpointing on live data structures
> and there is no guarantee you'll get it right.

Alexey, we're entirely on par about this: everyone agrees that if you
want the maximal guarantee (if one exists) you must checkpoint entire
container and have no leaks.

The point I'm stressing is that there are other use cases, and other
users, that can do great things even without full container. And my
goal is to provide them this capability. Specially since the mechanism
is shared by both cases.

> 
> Example 1: utsns is shared with the rest of the world.
> 
> utsns content is modifiable only by tasks (current->nsproxy->uts_ns).
> Consequently, someone can modify utsns content while you're dumping it
> if you allow "leaks".
> 
> Did you take precautions? Where?
> 
> 	static int cr_write_utsns(struct cr_ctx *ctx, struct uts_namespace *uts_ns)
> 	{
> 	        struct cr_hdr h;
> 	        struct cr_hdr_utsns *hh;
> 	        int domainname_len;
> 	        int nodename_len;
> 	        int ret;
> 
> 	        h.type = CR_HDR_UTSNS;
> 	        h.len = sizeof(*hh);
> 
> 	        hh = cr_hbuf_get(ctx, sizeof(*hh));
> 	        if (!hh)
> 	                return -ENOMEM;
> 
> 	        nodename_len = strlen(uts_ns->name.nodename) + 1;
> 	        domainname_len = strlen(uts_ns->name.domainname) + 1;
> 
> 	        hh->nodename_len = nodename_len;
> 	        hh->domainname_len = domainname_len;
> 
> 	        ret = cr_write_obj(ctx, &h, hh);
> 	        cr_hbuf_put(ctx, sizeof(*hh));
> 	        if (ret < 0)
> 	                return ret;
> 
> 	        ret = cr_write_string(ctx, uts_ns->name.nodename, nodename_len);
> 	        if (ret < 0)
> 	                return ret;
> 
> 	        ret = cr_write_string(ctx, uts_ns->name.domainname, domainname_len);
> 	        return ret;
> 	}
> 
> You should take uts_sem.

Fair enough. Will fix :)

However, even with leaks count you need the uts_sem, because it if
this is shared by another task when you start the checkpoint, but
not shared by the time you do the leak check - then you missed it.

And then, even the semaphore won't work unless you keep it for the
entire duration of the checkpoint:  if task A and B inside the
container both know something about the UTS contents, and task C
outside modified it before the checkpoint was taken, then, at least
potentially, we have an inconsistency that neither you or I detect.

The best part of it, however, it is unlikely that either A or B
would ever *care* about that, especially in the case of UTS.

And that brings me to the moral: in so many cases the user will live
happily ever after even if the UTS is changes 50 times during the
checkpoint. Because her tasks don't care about it.

Remember that "flexibility" argument in my first post to this thread:
the next step is that the user can say "cradvise(UTS, I_DONT_CARE)":
during checkpoint the kernel won't save it, during restart the kernel
won't restore it. Voila, so little effort to make people happy :)

> 
> 
> Example 2: ipcns is shared with the rest of the world
> 
> Consequently, shm segment is visible outside and live. Someone already
> shmatted to it. What will end up in shm segment content? Anything.

This is another excellent example. You are _so_ right that it doesn't
make much sense to try to restart a program that relies on something
that isn't part of the checkpoint.

And yet, there are a handful programs, applications, processes that
do not depend on the outside world in any important way, tasks that
frankly, my dear, don't give a ...

> 
> You should check struct file refcount or something and disable attaching
> while dumping or something.

Yes, yes, yes !

But -- when you focus solely on the full-container-only case.

Deciding what's best for the users is a two-edged-sword. It works
well to achieve foolproof operation with the less knowledgeable,
but it's a bit of an arrogant approach for the more sophisticated
ones.

If you limit c/r to a full-container-only, you take away a freedom
from the users - you take away a huge opportunity to use the c/r
to its full potential. And you have this extra functionality for
nearly free !  It's like giving the user a full blown linux laptop
but disallowing use of the command line :p

> 
> Moral: Every time you do dump on something live you get complications.
> Every single time.

"while(1);"  will never have complications... :)

And seriously, yes, you can bring endless examples of when it won't
work. And others will bring their examples of when it will be ok
even with "complications", because if you don't care about certain
stuff, the "complication" becomes void.

We can always restrict c/r later, either by code, or privileges, or
system config, sysadmin policy, flag to checkpoint(2), you name it.
So those who seek general case guarantee are happy. Why do it a-priori
and block all other users ?  is it of everyone's best interest to
decide now that no-one should ever do so ?

Oren.

> 
> 
> There are sockets and live netns as the most complex example. I'm not
> prepared to describe it exactly, but people wishing to do C/R with
> "leaks" should be very careful with their wishes.
> 
