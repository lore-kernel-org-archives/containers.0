From: Greg Kurz <gkurz@fr.ibm.com>
Subject: Re: C/R without "leaks" (was: Re: Creating tasks on restart:
 userspace vs kernel)
Date: Fri, 17 Apr 2009 10:46:14 +0200
Message-ID: <1239957974.6143.36.camel@bahia>
References: <49E40662.2040508@cs.columbia.edu>
	 <20090414163633.GE27461@x200.localdomain>
	 <49E4D89D.9060903@cs.columbia.edu>
	 <20090415195629.GD26994@x200.localdomain> <1239835337.6610.6.camel@bahia>
	 <20090416161215.GA8505@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760076AbZDQIqg@vger.kernel.org>
In-Reply-To: <20090416161215.GA8505@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux-Kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Thu, 2009-04-16 at 20:12 +0400, Alexey Dobriyan wrote:
> On Thu, Apr 16, 2009 at 12:42:17AM +0200, Greg Kurz wrote:
> > On Wed, 2009-04-15 at 23:56 +0400, Alexey Dobriyan wrote:
> 
> > > There are sockets and live netns as the most complex example. I'm not
> > > prepared to describe it exactly, but people wishing to do C/R with
> > > "leaks" should be very careful with their wishes.
> > 
> > They should close their sockets before checkpoint and find/have some way
> > to reconnect after. This implies some kind of C/R awareness in the code
> > to be checkpointed.
> 
> How do you imagine sshd closing sockets and reconnecting?

Dunno and it isn't really my concern... I'm interested in HPC jobs that
can collaborate with the C/R feature. For examples, those jobs that use
interconnect hardware that will never be *checkpointable*... Usually,
the batch manager tells the jobs it's going to be checkpointed, so that
it can disconnect/shrink memory/reach quiescent point, and reconnect
after resuming execution.

I understand you aim at supporting transparent C/R of connected TCP
sockets. Nice feature. Could you give use cases where it's *really*
helpful/needed/mandatory ?

-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
