From: Nathan Lynch <ntl@pobox.com>
Subject: Re: C/R without "leaks"
Date: Tue, 21 Apr 2009 19:16:05 -0500
Message-ID: <m3ocupmtkq.fsf@pobox.com>
References: <49E40662.2040508@cs.columbia.edu>
 <20090414163633.GE27461@x200.localdomain> <49E4D89D.9060903@cs.columbia.edu>
 <20090415195629.GD26994@x200.localdomain> <49E653C0.7020907@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754525AbZDVAQa@vger.kernel.org>
In-Reply-To: <49E653C0.7020907@cs.columbia.edu> (Oren Laadan's message of
 "Wed\, 15 Apr 2009 17\:38\:08 -0400")
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

Oren Laadan <orenl@cs.columbia.edu> writes:
> Alexey Dobriyan wrote:
>>> Again, so to checkpoint one task in the topmost pid-ns you need to
>>> checkpoint (if at all possible) the entire system ?!
>> 
>> One more argument to not allow "leaks" and checkpoint whole container,
>> no ifs, buts and woulditbenices.
>> 
>> Just to clarify, C/R with "leak" is for example when process has separate
>> pidns, but shares, for example, netns with other process not involved in
>> checkpoint.
>> 
>> If you allow this, you lose one important property of checkpoint part,
>> namely, almost everything is frozen. Losing this property means suddenly
>> much more stuff is alive during dump and you has to account to more stuff
>> when checkpointing. You effectively checkpointing on live data structures
>> and there is no guarantee you'll get it right.
>
> Alexey, we're entirely on par about this: everyone agrees that if you
> want the maximal guarantee (if one exists) you must checkpoint entire
> container and have no leaks.
>
> The point I'm stressing is that there are other use cases, and other
> users, that can do great things even without full container. And my
> goal is to provide them this capability.

As it seems that Alexey's goal is more or less a subset of yours, would
it make sense in the near term to concentrate on getting an
implementation upstream that satisfies that subset (i.e. checkpoint on a
container basis only)?  And then support for checkpointing arbitrary
processes could be added later, if it proves feasible?
