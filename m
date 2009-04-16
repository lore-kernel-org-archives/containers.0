From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: C/R without "leaks"
Date: Thu, 16 Apr 2009 12:10:57 -0600
Message-ID: <49E774B1.5060505@nortel.com>
References: <49E40662.2040508@cs.columbia.edu> <20090414163633.GE27461@x200.localdomain> <49E4D89D.9060903@cs.columbia.edu> <20090415195629.GD26994@x200.localdomain> <1239835337.6610.6.camel@bahia> <20090416161215.GA8505@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757676AbZDPSMa@vger.kernel.org>
In-Reply-To: <20090416161215.GA8505@x200.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Linux-Kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> On Thu, Apr 16, 2009 at 12:42:17AM +0200, Greg Kurz wrote:
>> On Wed, 2009-04-15 at 23:56 +0400, Alexey Dobriyan wrote:
> 
>>> There are sockets and live netns as the most complex example. I'm not
>>> prepared to describe it exactly, but people wishing to do C/R with
>>> "leaks" should be very careful with their wishes.
>> They should close their sockets before checkpoint and find/have some way
>> to reconnect after. This implies some kind of C/R awareness in the code
>> to be checkpointed.
> 
> How do you imagine sshd closing sockets and reconnecting?

Don't you already have to handle the case where an sshd connection is 
checkpointed, then the system is shutdown and the restore doesn't happen 
until after the TCP timeout?

Chris
